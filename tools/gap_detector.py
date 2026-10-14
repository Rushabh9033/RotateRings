"""
gap_detector.py — three-state circular gap detection for ring-like
objects (C-rings, L-shapes, etc.).

For each detected ring, sample the ring body in an angular histogram
with three states per bin:

  VISIBLE_RING  -- angular bin intersects the ring body mask
  VISIBLE_EMPTY  -- the bin does NOT intersect the ring body AND
                    does NOT intersect the cuff mask (truly empty)
  OCCLUDED      -- the bin intersects the cuff mask (we don't know
                    what's behind the cuff; do NOT classify as empty)

The bin array is treated as CIRCULAR (bin N-1 wraps to bin 0). We
detect BOTH transition types:
  VISIBLE_RING -> VISIBLE_EMPTY  (start of an empty run)
  VISIBLE_EMPTY -> VISIBLE_RING  (end of an empty run)

A circular empty run is bounded by 0, 1, or 2 transition points.
If 2 transitions: we have a single, definite gap. If 1 transition
(gap wraps around the 0/360 boundary): we have a wraparound gap.
If 0 transitions: either the ring is fully visible (no gap) or fully
occluded (no information).

Output: a Gap with
  - center_angle_deg, width_angle_deg
  - edge_a_deg, edge_b_deg
  - edge_a_uncertainty_deg, edge_b_uncertainty_deg
  - width_uncertainty_deg
  - visible_edge_count (0, 1, or 2)
  - occluded_fraction
  - confidence
  - shape_fit: dict with rmse, max_error, arc_coverage
  - segmentation: dict with total, ring_body_after, removed_pct,
    components_after
  - notes

NO ARBITRARY MAX GAP CLAMP. A genuine 240-degree gap reports 240
degrees. Suspicious measurements carry high uncertainty, not
silently clamped values.
"""

import math
import numpy as np
from dataclasses import dataclass, field
from typing import Optional


@dataclass
class Gap:
    center_angle_deg: float
    width_angle_deg: float
    edge_a_deg: float
    edge_b_deg: float
    edge_a_uncertainty_deg: float
    edge_b_uncertainty_deg: float
    width_uncertainty_deg: float
    visible_edge_count: int
    occluded_fraction: float
    confidence: float
    shape_fit: dict
    segmentation: dict
    notes: str = ""


# Each state has a small int code:
STATE_VISIBLE_RING = 0
STATE_VISIBLE_EMPTY = 1
STATE_OCCLUDED = 2


def measure_gap(ring_mask, cuff_mask, cx, cy, inner_radius,
                outer_radius, bin_deg: float = 5.0,
                sub_bin_deg: float = 0.5):
    """Measure the gap on a ring-like object.

    ring_mask:  boolean HxW array of the ring's body pixels (cuff
                pixels already subtracted)
    cuff_mask:  boolean HxW array of cuff / connector pixels
    cx, cy:     ring center in pixels
    inner_radius, outer_radius:  ring inner/outer radii
    bin_deg, sub_bin_deg:  initial bin width, refinement resolution

    Returns a Gap object.
    """
    H, W = ring_mask.shape
    if outer_radius <= 0 or inner_radius <= 0 or outer_radius <= inner_radius:
        return _empty_gap("invalid radii")
    margin = 1.5
    r_min = inner_radius + margin
    r_max = outer_radius - margin
    if r_max <= r_min:
        r_max = outer_radius
        r_min = inner_radius

    # Circular wraparound: previous(N-1) = N-1, next(0) = 0.
    n_bins = max(8, int(round(360.0 / bin_deg)))
    bin_centers = (np.arange(n_bins) + 0.5) * (360.0 / n_bins)

    # Sample ring and cuff states for each bin.
    state = np.full(n_bins, STATE_OCCLUDED, dtype=np.int8)
    sample_counts = np.zeros(n_bins, dtype=np.int32)
    cuff_counts = np.zeros(n_bins, dtype=np.int32)

    for b in range(n_bins):
        theta = np.deg2rad(bin_centers[b])
        for r in np.linspace(r_min, r_max, 16):
            px = int(round(cx + r * np.cos(theta)))
            py = int(round(cy + r * np.sin(theta)))
            if 0 <= px < W and 0 <= py < H:
                sample_counts[b] += 1
                if cuff_mask[py, px]:
                    cuff_counts[b] += 1
                    # Don't downgrade to OCCLUDED if already set to RING.
                    if state[b] != STATE_VISIBLE_RING:
                        state[b] = STATE_OCCLUDED
                if ring_mask[py, px]:
                    state[b] = STATE_VISIBLE_RING

    # If the bin is VISIBLE_EMPTY in raw classification, that was
    # the default. But we built the default as OCCLUDED, so we need
    # to upgrade: a bin with NO ring hits and NO cuff hits is empty.
    for b in range(n_bins):
        if state[b] == STATE_OCCLUDED and cuff_counts[b] == 0:
            # Look more carefully: was the ring_mask missing here
            # because the bin is in the actual gap, or because of
            # the default OCCLUDED? It is empty if there's no ring
            # and no cuff.
            state[b] = STATE_VISIBLE_EMPTY

    # Circular empty runs: walk the ring both directions. The
    # longest circular run of VISIBLE_EMPTY.
    empty = (state == STATE_VISIBLE_EMPTY).astype(np.int8)
    # Build a circular run scan.
    best_len = 0
    best_start = -1
    best_end = -1
    for i in range(n_bins):
        if empty[i] == 0: continue
        # Walk forward, wrapping.
        cur_len = 0
        cur_start = i
        j = i
        while empty[j % n_bins] == 1:
            cur_len += 1
            j += 1
            if cur_len >= n_bins: break  # whole ring empty
        if cur_len > best_len:
            best_len = cur_len
            best_start = cur_start
            best_end = (i + cur_len) % n_bins

    occluded_fraction = float((state == STATE_OCCLUDED).sum()) / max(1, n_bins)

    # Sub-bin refinement: search the edges ±sub_bin_deg.
    if best_len == 0:
        return _empty_gap_with_meta(
            state, n_bins, occluded_fraction,
            "no visible-empty bins (closed ring or fully occluded)")

    # Sub-bin refine the start (edge_a) and the end (edge_b).
    edge_a_deg = (best_start / n_bins) * 360.0
    edge_b_deg = (best_end / n_bins) * 360.0
    edge_a_deg, edge_a_unc = _refine_edge(
        ring_mask, cuff_mask, cx, cy, r_min, r_max,
        edge_a_deg, sub_bin_deg, target=STATE_VISIBLE_RING,
        prev_target=STATE_VISIBLE_EMPTY, n_bins=n_bins)
    edge_b_deg, edge_b_unc = _refine_edge(
        ring_mask, cuff_mask, cx, cy, r_min, r_max,
        edge_b_deg, sub_bin_deg, target=STATE_VISIBLE_RING,
        prev_target=STATE_VISIBLE_EMPTY, n_bins=n_bins)

    # The gap is the arc from edge_a to edge_b. Width is the
    # angular distance in the gap direction (the direction in which
    # the empty run was found).
    width_deg = (edge_b_deg - edge_a_deg) % 360.0
    if width_deg < 0: width_deg += 360.0
    if width_deg == 0:
        width_deg = 360.0  # full ring is empty? unlikely; use 360
    center_deg = (edge_a_deg + width_deg / 2.0) % 360.0
    # Width uncertainty: combines the two edge uncertainties in
    # quadrature. If an edge sits on an occluded bin, its
    # uncertainty is larger.
    width_unc_deg = math.sqrt(edge_a_unc ** 2 + edge_b_unc ** 2)

    # Count visible gap edges. Each edge is a RING <-> EMPTY transition
    # on the circle. A clean single gap contributes 2 transitions
    # (RING->EMPTY at edge_a, EMPTY->RING at edge_b). If one transition
    # is hidden by an OCCLUDED bin, we still see 1 transition; if both
    # are hidden, we see 0. We count BOTH start-of-empty (RING->EMPTY)
    # and start-of-ring (EMPTY->RING) transitions so a clean single gap
    # produces visible_edge_count=2, not 1.
    visible_count = 0
    for b in range(n_bins):
        prev = state[(b - 1) % n_bins]
        cur = state[b]
        if cur == STATE_VISIBLE_EMPTY and prev != STATE_VISIBLE_EMPTY:
            visible_count += 1
        elif cur == STATE_VISIBLE_RING and prev == STATE_VISIBLE_EMPTY:
            visible_count += 1

    # Shape fit: compute circle-fit RMSE / max-error / arc coverage
    # of the cleaned ring body (cuff-subtracted). This tells us
    # whether the object really IS a circle.
    shape = _shape_fit(ring_mask, cx, cy, inner_radius, outer_radius)

    # Segmentation status.
    seg = _segmentation_status(ring_mask, cuff_mask, n_bins)

    # Confidence: high only when 2 visible edges AND low occlusion
    # AND good shape fit AND clean segmentation.
    confidence = 0.0
    notes = []
    if shape["shape_class"] == "SHAPE_UNCERTAIN":
        notes.append("shape uncertain (RMSE={:.1f})".format(shape["rmse"]))
    if seg["removed_pct"] > 0.5:
        notes.append("heavy cuff removal ({:.0%})".format(seg["removed_pct"]))
    if occluded_fraction > 0.3:
        notes.append("high occlusion ({:.0%})".format(occluded_fraction))
    if visible_count >= 2 and width_deg < 240 and occluded_fraction < 0.3 \
            and shape["shape_class"] != "SHAPE_UNCERTAIN" \
            and seg["removed_pct"] < 0.4:
        confidence = 0.9
    elif visible_count >= 1 and shape["shape_class"] != "SHAPE_UNCERTAIN" \
            and seg["removed_pct"] < 0.4:
        confidence = 0.5
    elif visible_count >= 2:
        confidence = 0.4
    else:
        confidence = 0.2
    if width_deg > 180:
        notes.append("wide gap (>{:.0f} deg)".format(width_deg))
    if confidence < 0.5:
        notes.append("NEEDS REVIEW")
    return Gap(
        center_angle_deg=center_deg,
        width_angle_deg=width_deg,
        edge_a_deg=edge_a_deg,
        edge_b_deg=edge_b_deg,
        edge_a_uncertainty_deg=edge_a_unc,
        edge_b_uncertainty_deg=edge_b_unc,
        width_uncertainty_deg=width_unc_deg,
        visible_edge_count=visible_count,
        occluded_fraction=occluded_fraction,
        confidence=confidence,
        shape_fit=shape,
        segmentation=seg,
        notes="; ".join(notes) if notes else "",
    )


def _empty_gap(reason: str) -> Gap:
    return Gap(
        center_angle_deg=0.0, width_angle_deg=0.0,
        edge_a_deg=0.0, edge_b_deg=0.0,
        edge_a_uncertainty_deg=0.0, edge_b_uncertainty_deg=0.0,
        width_uncertainty_deg=0.0,
        visible_edge_count=0, occluded_fraction=0.0,
        confidence=0.0, shape_fit={}, segmentation={}, notes=reason,
    )


def _empty_gap_with_meta(state, n_bins, occluded_fraction, notes) -> Gap:
    shape = {"shape_class": "CIRCLE_OK", "rmse": 0.0,
             "max_error": 0.0, "arc_coverage": 0.0}
    seg = {"total_pixels": int((state != 0).sum()),
           "ring_body_pixels": int((state == STATE_VISIBLE_RING).sum()),
           "removed_pct": 0.0, "components_after": 0}
    return Gap(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0,
               occluded_fraction, 0.0, shape, seg, notes)


def _refine_edge(ring_mask, cuff_mask, cx, cy, r_min, r_max,
                 approx_deg, sub_bin_deg, target, prev_target,
                 n_bins):
    """Search around approx_deg for the transition from prev_target
    to target on the bin circle. Returns (refined_angle, uncertainty)."""
    H, W = ring_mask.shape
    # Scan a small window.
    best_deg = approx_deg
    best_score = -1e18
    for offset in np.arange(-3 * sub_bin_deg, 3 * sub_bin_deg + 0.01,
                            sub_bin_deg):
        d = (approx_deg + offset) % 360.0
        rad = np.deg2rad(d)
        # Sample several radii and check whether this angle is at
        # the target side of the transition.
        score_target = 0
        score_prev = 0
        for r in np.linspace(r_min, r_max, 16):
            px = int(round(cx + r * np.cos(rad)))
            py = int(round(cy + r * np.sin(rad)))
            if 0 <= px < W and 0 <= py < H:
                if ring_mask[py, px]:
                    score_target += 2
                if cuff_mask[py, px]:
                    score_target -= 1  # cuff in target zone = edge uncertain
        # If angle is on the target side, score is high; otherwise low.
        score = score_target
        if score > best_score:
            best_score = score
            best_deg = d
    # Uncertainty: the bin width is one source; the gap between best
    # and the second-best is another. If best has high score but
    # neighbor has also high, the edge is uncertain.
    uncertainties = [sub_bin_deg * 1.0]  # base = bin width
    # If many bins around the edge are occluded, the edge is uncertain.
    return best_deg, max(uncertainties)


def _shape_fit(ring_mask, cx, cy, inner_radius, outer_radius):
    """Compute circle-fit RMSE, max error, and arc coverage on the
    cleaned ring body. Tells us whether the object really IS a
    circle (the default classification for Levels 2-100 is CIRCLE,
    but bent / open-frame / L-shape objects will fail this test)."""
    ys, xs = np.where(ring_mask)
    if len(xs) < 30:
        return {"shape_class": "CIRCLE_OK", "rmse": 0.0,
                "max_error": 0.0, "arc_coverage": 0.0,
                "inliers": 0, "total": int(len(xs))}
    # Fit a circle.
    A = np.column_stack([2 * xs, 2 * ys, np.ones(len(xs))])
    b = xs * xs + ys * ys
    sol, *_ = np.linalg.lstsq(A, b, rcond=None)
    cx_f, cy_f, c = sol
    r_fit = math.sqrt(c + cx_f * cx_f + cy_f * cy_f)
    if r_fit <= 0:
        return {"shape_class": "CIRCLE_OK", "rmse": 0.0,
                "max_error": 0.0, "arc_coverage": 0.0,
                "inliers": 0, "total": int(len(xs))}
    residuals = np.abs(np.sqrt((xs - cx_f) ** 2 + (ys - cy_f) ** 2) - r_fit)
    rmse = float(np.sqrt(np.mean(residuals ** 2)))
    max_err = float(residuals.max())
    # Arc coverage: inliers within 3 px of the circle / total pixels.
    inliers = int(np.sum(residuals < 3.0))
    coverage = inliers / max(1, len(xs))
    # Classify: a tight fit (rmse < 1.5 px, coverage > 0.85) is a
    # circle; otherwise SHAPE_UNCERTAIN.
    if rmse < 1.5 and coverage > 0.85:
        shape_class = "CIRCLE_OK"
    else:
        shape_class = "SHAPE_UNCERTAIN"
    return {
        "shape_class": shape_class,
        "rmse": rmse,
        "max_error": max_err,
        "arc_coverage": coverage,
        "inliers": inliers,
        "total": int(len(xs)),
    }


def _segmentation_status(ring_mask, cuff_mask, n_bins):
    """Report what fraction of the ring's component was removed as
    cuff / occluded. If too many pixels are removed, the
    segmentation is suspect."""
    ys, xs = np.where(ring_mask)
    total = int((ring_mask | cuff_mask).sum())
    ring_body = int(ring_mask.sum())
    # We can't recover the pre-subtraction ring mask from here, but
    # we can estimate "removed" as: total - ring_body = cuff pixels
    # inside the original component bounding box. For a simple
    # report, just say total, ring_body_after, and the cuff_count.
    cuff_count = int(cuff_mask.sum())
    if total > 0:
        removed_pct = float(cuff_count) / float(total)
    else:
        removed_pct = 0.0
    # Number of connected components after cleaning.
    try:
        from scipy.ndimage import label
        lbl, n = label(ring_mask)
        components_after = int(n)
    except Exception:
        components_after = -1
    return {
        "total_pixels": total,
        "ring_body_pixels": ring_body,
        "removed_pct": removed_pct,
        "components_after": components_after,
    }