"""
gap_detector.py — three-state angular gap detection for C-rings.

For each detected ring, after the circle fit, sample the ring body in
an angular histogram with three states per bin:
  - VISIBLE_RING: the angular bin intersects the ring body mask
  - VISIBLE_EMPTY: the bin does NOT intersect the ring body AND does
    NOT intersect the cuff mask (it is genuinely empty in the ref)
  - OCCLUDED: the bin intersects the cuff mask (we don't know what's
    behind the cuff; it's not "empty" it's "unknown")

Only a continuous run of VISIBLE_EMPTY bins establishes a gap. We
then detect gap edges (transitions VISIBLE_RING -> VISIBLE_EMPTY ->
VISIBLE_RING) and compute the gap as the midpoint and arc length
between those edges, with sub-bin refinement.

If the ring body sampling region passes through the cuff mask, those
angular bins are OCCLUDED, not EMPTY. This fixes the "cuff occluded
as gap" false positive.

Output is a Gap object with:
  - center_angle_deg (canonical + sub-bin refined)
  - width_angle_deg (canonical + sub-bin refined)
  - confidence (0..1; poor confidence -> NEEDS REVIEW)
  - visible_edge_count (0, 1, or 2)
  - occluded_fraction (0..1)
  - notes (string)
"""

import math
import numpy as np
from dataclasses import dataclass


@dataclass
class Gap:
    center_angle_deg: float
    width_angle_deg: float
    confidence: float
    visible_edge_count: int
    occluded_fraction: float
    notes: str = ""


# Each state has a small int code:
STATE_VISIBLE_RING = 0
STATE_VISIBLE_EMPTY = 1
STATE_OCCLUDED = 2


def measure_gap(ring_mask, cuff_mask, cx, cy, inner_radius,
                outer_radius, bin_deg: float = 5.0,
                sub_bin_deg: float = 0.5):
    """Measure the C-ring's gap using the three-state angular histogram.

    ring_mask: boolean HxW array of the ring's body pixels
                (cuff pixels already subtracted, ideally)
    cuff_mask: boolean HxW array of the cuff pixels
    cx, cy:    ring center in pixels
    inner_radius, outer_radius: ring inner/outer pixel radii
    bin_deg:  initial bin width in degrees (5.0)
    sub_bin_deg: refinement resolution in degrees (0.5)

    Returns a Gap object.
    """
    H, W = ring_mask.shape
    # Sanity-check the radius values.
    if outer_radius <= 0 or inner_radius <= 0 or outer_radius <= inner_radius:
        return Gap(0.0, 80.0, 0.0, 0, 0.0, "invalid radii")
    # Annular sampling region: between inner + margin and outer - margin.
    # The margin is 1.5 px to be safe against anti-aliasing.
    margin = 1.5
    r_min = inner_radius + margin
    r_max = outer_radius - margin
    if r_max <= r_min:
        r_max = outer_radius
        r_min = inner_radius

    # Build a radial grid: (theta, r) pairs around the center.
    n_bins = max(8, int(round(360.0 / bin_deg)))
    bin_edges = np.linspace(0.0, 360.0, n_bins + 1)
    bin_centers = 0.5 * (bin_edges[:-1] + bin_edges[1:])

    # For each bin, sample N radial points and see if they hit ring or
    # cuff. N = 16 is enough resolution.
    N = 16
    rs = np.linspace(r_min, r_max, N)

    state = np.full(n_bins, STATE_OCCLUDED, dtype=np.int8)  # default
    sample_counts = np.zeros(n_bins, dtype=np.int32)  # how many samples in the bin

    for b in range(n_bins):
        theta = np.deg2rad(bin_centers[b])
        for r in rs:
            px = int(round(cx + r * np.cos(theta)))
            py = int(round(cy + r * np.sin(theta)))
            if 0 <= px < W and 0 <= py < H:
                sample_counts[b] += 1
                if cuff_mask[py, px]:
                    # Cuff occluded. Mark OCCLUDED only if we don't
                    # also see ring body at any other sample.
                    pass  # we'll resolve later
                if ring_mask[py, px]:
                    state[b] = STATE_VISIBLE_RING
                    # Once we've seen ring, we keep it; don't downgrade
                    # to OCCLUDED by later cuff samples.

    # Now resolve the OCCLUDED state. A bin is OCCLUDED only if:
    #  - it has NO visible ring samples AND
    #  - it has at least one cuff sample.
    for b in range(n_bins):
        if state[b] == STATE_VISIBLE_RING:
            continue
        cuff_hits = 0
        ring_hits = 0
        for r in rs:
            theta = np.deg2rad(bin_centers[b])
            px = int(round(cx + r * np.cos(theta)))
            py = int(round(cy + r * np.sin(theta)))
            if 0 <= px < W and 0 <= py < H:
                if cuff_mask[py, px]:
                    cuff_hits += 1
                if ring_mask[py, px]:
                    ring_hits += 1
        if ring_hits == 0 and cuff_hits > 0:
            state[b] = STATE_OCCLUDED
        elif ring_hits == 0 and cuff_hits == 0:
            state[b] = STATE_VISIBLE_EMPTY
        else:
            # ring_hits > 0 but we set VISIBLE_RING above; defensive
            state[b] = STATE_VISIBLE_RING

    # Find the longest run of VISIBLE_EMPTY bins (with wraparound).
    n = n_bins
    visible_empty = (state == STATE_VISIBLE_EMPTY).astype(np.int8)
    best_start = -1; best_len = 0
    cur_start = -1; cur_len = 0
    for i in range(2 * n):  # 2 passes for wraparound
        idx = i % n
        if visible_empty[idx]:
            if cur_start < 0: cur_start = i
            cur_len += 1
            if cur_len > best_len:
                best_len = cur_len; best_start = cur_start
        else:
            cur_start = -1; cur_len = 0
    if best_start < 0 or best_len == 0:
        # No detectable gap (closed ring).
        return Gap(0.0, 0.0, 0.0, 0,
                   float((state == STATE_OCCLUDED).mean()),
                   "no visible-empty bins (closed ring?)")

    # Initial edges from the bin boundaries.
    edge_a_deg = bin_edges[best_start % n]
    edge_b_deg = bin_edges[(best_start + best_len) % n]

    # Sub-bin refinement: search ±sub_bin_deg around each edge.
    edge_a_deg = _refine_edge(ring_mask, cuff_mask, cx, cy,
                              r_min, r_max, edge_a_deg, sub_bin_deg,
                              STATE_VISIBLE_RING, n)
    edge_b_deg = _refine_edge(ring_mask, cuff_mask, cx, cy,
                              r_min, r_max, edge_b_deg, sub_bin_deg,
                              STATE_VISIBLE_RING, n)

    # Compute the gap on the circle.
    center_deg = (edge_a_deg + edge_b_deg) / 2.0
    width_deg = (edge_b_deg - edge_a_deg) % 360.0
    if width_deg < 0: width_deg += 360.0

    # Confidence: based on edge count (0/1/2) and occluded fraction.
    occluded_fraction = float((state == STATE_OCCLUDED).sum()) / max(1, n)
    visible_count = 0
    # Count distinct gap edges (RING -> EMPTY transitions).
    for i in range(n):
        if state[i] == STATE_VISIBLE_EMPTY and state[(i - 1) % n] != STATE_VISIBLE_EMPTY:
            visible_count += 1
    confidence = 0.0
    if visible_count >= 2 and width_deg < 180 and occluded_fraction < 0.3:
        confidence = 0.95
    elif visible_count >= 1 and width_deg < 180:
        confidence = 0.6
    elif width_deg < 360:
        confidence = 0.3
    notes = ""
    if confidence < 0.5:
        notes = "NEEDS REVIEW"
    if width_deg > 180:
        notes += (": gap > 180 deg" if not notes else ", gap > 180 deg")
    if visible_count == 0:
        notes = "NO VISIBLE EDGES" if not notes else notes + ", NO VISIBLE EDGES"
    if visible_count == 1:
        notes = "only 1 visible edge" if not notes else notes + ", only 1 visible edge"

    return Gap(
        center_angle_deg=center_deg % 360.0,
        width_angle_deg=width_deg,
        confidence=confidence,
        visible_edge_count=visible_count,
        occluded_fraction=occluded_fraction,
        notes=notes,
    )


def _refine_edge(ring_mask, cuff_mask, cx, cy, r_min, r_max,
                 approx_deg, sub_bin_deg, target_state, n_bins):
    """Search ±sub_bin_deg around approx_deg for the transition point
    where the bin's state goes from target_state to non-target_state."""
    H, W = ring_mask.shape
    best_deg = approx_deg
    best_score = 0
    for offset in np.arange(-3.0, 3.0, sub_bin_deg):
        d = (approx_deg + offset) % 360.0
        rad = np.deg2rad(d)
        # Sample several radii in the band.
        ring_hits = 0
        not_ring_hits = 0
        for r in np.linspace(r_min, r_max, 16):
            px = int(round(cx + r * np.cos(rad)))
            py = int(round(cy + r * np.sin(rad)))
            if 0 <= px < W and 0 <= py < H:
                if ring_mask[py, px]:
                    ring_hits += 1
                else:
                    not_ring_hits += 1
        score = ring_hits - 0.5 * not_ring_hits
        if score > best_score:
            best_score = score
            best_deg = d
    return best_deg