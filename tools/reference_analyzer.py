"""
reference_analyzer.py — independent reference measurement pipeline.

Measures a reference image (e.g. 2.jpeg) without producing or
modifying any level data. Produces a Target Report that the author
and the acceptance test consume. This module is the single source of
truth for "what the puzzle looks like".

Per the GPT's review (issues #2, #3, #4, #7, #8):
  - Real circle fit (RANSAC + algebraic least-squares), not bbox
    center. C-rings have biased bboxes; the center of the visible
    arc is not the center of the ring.
  - Subtract cuff pixels from the ring mask BEFORE fitting.
  - Measure inner_radius, outer_radius, thickness from a radial
    histogram of the cleaned ring pixels.
  - Measure the gap from the polar histogram: the largest missing
    angular interval is the gap, with proper wraparound handling.
  - Measure cuff geometry: PCA on the cuff mask → center, width,
    height, orientation (primary axis angle).

Calibration (issue #5):
  ReferenceCalibration = (reference_crop_origin, reference_width,
  reference_height, uniform_scale, canonical_offset_x,
  canonical_offset_y). All consumers (author, accept) read this.

The mapping is:
  canonical =
    (reference - reference_crop_origin) * uniform_scale
    + (canonical_offset_x, canonical_offset_y)

A default calibration is constructed from the image's natural
size: reference_crop_origin=(0,0), uniform_scale=720/ref_w,
canonical_offset=(0,0). For Level 2 the image is 685x1170 so
uniform_scale=1.0511. If the user wants to crop the HUD or recenter
the puzzle, they update the calibration explicitly.
"""

import os
import math
import json
import numpy as np
from PIL import Image
import scipy.ndimage as ndi
from dataclasses import dataclass, field, asdict
from typing import Optional, List, Tuple

CANONICAL_W = 720.0
CANONICAL_H = 1280.0

COLOR_TARGETS = {
    "orange": (234, 120, 41),
    "cyan":   (50, 173, 218),
    "purple": (123, 97, 255),
    "cuff":   (31, 90, 130),
}

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))


# ============================================================================
# Calibration
# ============================================================================

@dataclass
class ReferenceCalibration:
    reference_crop_origin: Tuple[float, float] = (0.0, 0.0)  # top-left in ref
    reference_width: float = 0.0                            # 0 = use full
    reference_height: float = 0.0                           # 0 = use full
    uniform_scale: float = 1.0                              # canonical per ref
    canonical_offset_x: float = 0.0
    canonical_offset_y: float = 0.0
    locked: bool = False

    def map_to_canonical(self, x_ref: float, y_ref: float) -> Tuple[float, float]:
        """Map a point in ref pixel space to canonical authored coords."""
        rx, ry = self.reference_crop_origin
        return ((x_ref - rx) * self.uniform_scale + self.canonical_offset_x,
                (y_ref - ry) * self.uniform_scale + self.canonical_offset_y)

    def map_from_canonical(self, x_can: float, y_can: float) -> Tuple[float, float]:
        rx, ry = self.reference_crop_origin
        return ((x_can - self.canonical_offset_x) / self.uniform_scale + rx,
                (y_can - self.canonical_offset_y) / self.uniform_scale + ry)

    @staticmethod
    def from_natural_size(ref_w: int, ref_h: int) -> "ReferenceCalibration":
        s = min(CANONICAL_W / ref_w, CANONICAL_H / ref_h)
        return ReferenceCalibration(
            reference_crop_origin=(0.0, 0.0),
            reference_width=float(ref_w), reference_height=float(ref_h),
            uniform_scale=s,
            canonical_offset_x=0.0, canonical_offset_y=0.0,
        )


# ============================================================================
# Per-ring target
# ============================================================================

@dataclass
class RingTarget:
    color: str
    centerline_radius: float       # (inner + outer) / 2
    inner_radius: float
    outer_radius: float
    thickness: float
    center_x: float                # canonical
    center_y: float
    gap_center_angle: float        # degrees
    gap_width_angle: float         # degrees
    piece_id_hint: str = ""         # "orange_1" etc.; author may override
    bbox_count: int = 0             # how many components fed into the fit


# ============================================================================
# Per-cuff target
# ============================================================================

@dataclass
class CuffTarget:
    center_x: float                # canonical
    center_y: float
    width: float
    height: float
    orientation_deg: float         # primary axis angle, world-frame
    area: int = 0
    piece_id_hint: str = ""


# ============================================================================
# Per-piece target (ring + cuffs attached to it)
# ============================================================================

@dataclass
class PieceTarget:
    piece_id_hint: str
    color: str
    ring: RingTarget
    cuffs: List[CuffTarget] = field(default_factory=list)


# ============================================================================
# Level target = the calibrated targets for one level
# ============================================================================

@dataclass
class LevelTarget:
    level_id: int
    calibration: ReferenceCalibration
    reference_image_size: Tuple[int, int]  # (W, H) in pixels
    pieces: List[PieceTarget] = field(default_factory=list)
    puzzle_centroid_canonical: Tuple[float, float] = (0.0, 0.0)
    report_lines: List[str] = field(default_factory=list)


# ============================================================================
# Per-color masks
# ============================================================================

def _build_color_masks(arr: np.ndarray) -> dict:
    H, W, _ = arr.shape
    masks = {}
    for name, target in COLOR_TARGETS.items():
        m = np.zeros((H, W), dtype=bool)
        for y in range(H):
            for x in range(W):
                if close(arr[y, x], target):
                    m[y, x] = True
        masks[name] = m
    return masks


def _close_morphology(m: np.ndarray) -> np.ndarray:
    return ndi.binary_closing(m, iterations=4)


def _label_components(m: np.ndarray, min_area: int = 50) -> List[dict]:
    """Return list of component dicts (x0,y0,x1,y1,cx,cy,w,h,area,mask)."""
    lbl, n = ndi.label(m)
    out = []
    for i in range(1, n + 1):
        ys, xs = np.where(lbl == i)
        if len(ys) < min_area: continue
        x0, x1 = int(xs.min()), int(xs.max())
        y0, y1 = int(ys.min()), int(ys.max())
        out.append({
            "x0": x0, "y0": y0, "x1": x1, "y1": y1,
            "cx": float((x0 + x1) / 2.0),
            "cy": float((y0 + y1) / 2.0),
            "w": float(x1 - x0 + 1),
            "h": float(y1 - y0 + 1),
            "area": int(len(ys)),
            "mask": lbl == i,
        })
    out.sort(key=lambda d: -d["area"])
    return out


# ============================================================================
# Real circle fit (RANSAC) on cleaned ring pixels
# ============================================================================

def _algebraic_circle_fit(xs: np.ndarray, ys: np.ndarray) -> Tuple[float, float, float]:
    """Kasa algebraic least-squares circle fit. Returns (cx, cy, r)."""
    n = len(xs)
    if n < 3:
        return (0.0, 0.0, 0.0)
    A = np.column_stack([2 * xs, 2 * ys, np.ones(n)])
    b = xs * xs + ys * ys
    sol, *_ = np.linalg.lstsq(A, b, rcond=None)
    cx, cy, c = sol
    r = max(0.0, float(np.sqrt(c + cx * cx + cy * cy)))
    return (float(cx), float(cy), r)


def _circle_residuals(xs, ys, cx, cy, r):
    return np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2) - r


def _ransac_circle(xs, ys, n_iter: int = 200, tol_px: float = 2.0) -> Tuple[float, float, float, int]:
    """RANSAC: pick 3 random points, fit circle, count inliers. Best by inliers."""
    if len(xs) < 3:
        return (0.0, 0.0, 0.0, 0)
    n = len(xs)
    best_inliers = 0
    best_cx, best_cy, best_r = 0.0, 0.0, 0.0
    for _ in range(n_iter):
        idx = np.random.choice(n, 3, replace=False)
        c2 = _algebraic_circle_fit(xs[idx], ys[idx])
        if c2[2] <= 0: continue
        cx, cy, r = c2
        residuals = _circle_residuals(xs, ys, cx, cy, r)
        inliers = int(np.sum(np.abs(residuals) < tol_px))
        if inliers > best_inliers:
            best_inliers = inliers
            best_cx, best_cy, best_r = cx, cy, r
    if best_inliers >= 3:
        mask = np.abs(_circle_residuals(xs, ys, best_cx, best_cy, best_r)) < tol_px
        if mask.sum() >= 3:
            cx2, cy2, r2 = _algebraic_circle_fit(xs[mask], ys[mask])
            if r2 > 0:
                return (cx2, cy2, r2, int(mask.sum()))
    return (best_cx, best_cy, best_r, best_inliers)


def _radial_histogram(xs, ys, cx, cy, bin_width: float = 1.0):
    """Return (radii, counts) arrays for ring pixels relative to (cx, cy)."""
    radii = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2)
    r_max = float(radii.max())
    if r_max <= 0: return (np.array([0.0]), np.array([1]))
    n_bins = int(r_max / bin_width) + 1
    counts, edges = np.histogram(radii, bins=n_bins, range=(0, r_max + bin_width))
    centers = (edges[:-1] + edges[1:]) / 2
    return centers, counts


def _fit_one_ring(comp_mask, cuff_global, color, calibration):
    """Fit a real circle to the largest connected component of this
    color, after subtracting the global cuff mask. Returns a
    RingTarget or None."""
    # Subtract cuff pixels from this ring's mask.
    ring_mask = comp_mask & ~cuff_global
    ys, xs = np.where(ring_mask)
    if len(xs) < 30:
        return None

    # RANSAC circle fit.
    cx, cy, r_ransac, n_inliers = _ransac_circle(xs, ys)
    if r_ransac <= 0:
        return None

    # Inlier set: tight residuals.
    inliers = np.abs(_circle_residuals(xs, ys, cx, cy, r_ransac)) < 2.0
    if inliers.sum() < 30:
        return None
    xs_i = xs[inliers]; ys_i = ys[inliers]

    # Refit on inliers for accuracy.
    cx_f, cy_f, r_final = _algebraic_circle_fit(xs_i, ys_i)
    if r_final <= 0:
        return None

    # Radial histogram: find inner/outer radius. A C-ring has a clear
    # bimodal histogram: ring body + highlight. The centerline
    # radius is the peak; inner and outer are the edges of the peak.
    centers, counts = _radial_histogram(xs_i, ys_i, cx_f, cy_f, bin_width=1.0)
    if centers.size == 0 or counts.max() == 0:
        return None

    # Find the dominant peak (largest count, ignoring noise below 5%
    # of max).
    threshold = float(counts.max()) * 0.05
    peak_mask = counts >= threshold
    peak_radii = centers[peak_mask]
    if peak_radii.size == 0:
        return None
    r_inner = float(peak_radii.min())
    r_outer = float(peak_radii.max())
    r_centerline = (r_inner + r_outer) / 2.0
    thickness = r_outer - r_inner

    # Map center to canonical space.
    cx_can, cy_can = calibration.map_to_canonical(cx_f, cy_f)
    return RingTarget(
        color=color,
        centerline_radius=r_centerline,
        inner_radius=r_inner,
        outer_radius=r_outer,
        thickness=thickness,
        center_x=cx_can, center_y=cy_can,
        gap_center_angle=0.0,  # filled in by gap measurement pass
        gap_width_angle=80.0,
        bbox_count=int(ring_mask.sum()),
    )


def _measure_gap(ring_mask, cx, cy, calibration):
    """Polar histogram of ring body pixels. Find the largest missing
    angular interval; that's the gap. Returns (gap_center, gap_width)
    in degrees. Handles 0/360 wraparound."""
    ys, xs = np.where(ring_mask)
    if len(xs) < 30:
        return (0.0, 80.0)
    angles = np.degrees(np.arctan2(ys - cy, xs - cx)) % 360.0
    # Bin to 2 degrees.
    bin_w = 2.0
    n_bins = int(360.0 / bin_w)
    counts, edges = np.histogram(angles, bins=n_bins, range=(0, 360))
    # Threshold: < 5% of the max count is "empty" (gap).
    thresh = counts.max() * 0.05
    empty = counts < thresh
    if not empty.any():
        return (0.0, 80.0)
    # Find runs of empty bins; pick the longest.
    best_start = -1; best_len = 0
    cur_start = -1; cur_len = 0
    for i, e in enumerate(empty):
        if e:
            if cur_start < 0: cur_start = i
            cur_len += 1
        else:
            if cur_len > best_len:
                best_len = cur_len; best_start = cur_start
            cur_start = -1; cur_len = 0
    if cur_len > best_len:
        best_len = cur_len; best_start = cur_start
    if best_start < 0 or best_len == 0:
        return (0.0, 80.0)
    # Handle wraparound: if the gap spans the 360/0 boundary, the run
    # we picked may end before the boundary. Expand.
    center_bin = (best_start + best_len / 2.0) % n_bins
    width_deg = best_len * bin_w
    # Extend the run in both directions if the next bin is also empty.
    i = best_start
    while empty[(i - 1) % n_bins] and width_deg < 180:
        i = (i - 1) % n_bins
        width_deg += bin_w
    j = (best_start + best_len) % n_bins
    while empty[(j + 1) % n_bins] and width_deg < 180:
        j = (j + 1) % n_bins
        width_deg += bin_w
    center_bin = ((best_start + best_start + best_len) / 2.0) % n_bins
    gap_center = (center_bin / n_bins) * 360.0
    return (gap_center, width_deg)


# ============================================================================
# Cuff measurement: PCA on the cuff mask
# ============================================================================

def _measure_cuff(comp, calibration):
    """Measure cuff center, width, height, orientation via PCA."""
    ys, xs = np.where(comp["mask"])
    if len(xs) < 20:
        return None
    # Center of mass
    cx = float(xs.mean()); cy = float(ys.mean())
    # 2x2 covariance
    pts = np.column_stack([xs - cx, ys - cy])
    if len(pts) < 2:
        return CuffTarget(
            center_x=0.0, center_y=0.0, width=0.0, height=0.0,
            orientation_deg=0.0, area=comp["area"],
        )
    cov = np.cov(pts.T)
    if cov.shape != (2, 2):
        return CuffTarget(
            center_x=0.0, center_y=0.0, width=0.0, height=0.0,
            orientation_deg=0.0, area=comp["area"],
        )
    eigvals, eigvecs = np.linalg.eigh(cov)
    # Primary axis = eigvec with larger eigenvalue
    primary = eigvecs[:, -1]
    orientation = math.degrees(math.atan2(primary[1], primary[0])) % 180.0
    # Width = 4 * sigma along primary axis (covers ~95% of mass)
    # Height = 4 * sigma along secondary axis
    width = 4.0 * float(np.sqrt(eigvals[-1]))
    height = 4.0 * float(np.sqrt(eigvals[0]))
    cx_can, cy_can = calibration.map_to_canonical(cx, cy)
    return CuffTarget(
        center_x=cx_can, center_y=cy_can,
        width=width, height=height,
        orientation_deg=orientation,
        area=comp["area"],
    )


# ============================================================================
# Top-level: ReferenceAnalyzer.analyze()
# ============================================================================

class ReferenceAnalyzer:
    def __init__(self, calibration: Optional[ReferenceCalibration] = None):
        self.calibration = calibration

    def analyze(self, ref_path: str, level_id: int = 0) -> LevelTarget:
        img = Image.open(ref_path).convert("RGB")
        arr = np.array(img)
        H, W, _ = arr.shape
        if self.calibration is None:
            self.calibration = ReferenceCalibration.from_natural_size(W, H)
        cal = self.calibration

        masks = _build_color_masks(arr)
        for name in masks:
            masks[name] = _close_morphology(masks[name])

        # Cuff mask is the union of all cuff components — we subtract
        # it from the ring masks before fitting.
        cuff_global = masks["cuff"]

        pieces: List[PieceTarget] = []
        report_lines: List[str] = []
        centroid_x = 0.0
        centroid_y = 0.0
        n_pieces = 0

        # Process each non-cuff color. For each largest component, fit
        # a real circle. Use the calibrated coordinates for the final
        # center.
        piece_counter = {"orange": 0, "cyan": 0, "purple": 0}
        for color in ("orange", "cyan", "purple"):
            comps = _label_components(masks[color], min_area=80)
            if not comps: continue
            # Try the largest first; if the fit is too thin, try the
            # next. Stop when we have one good ring per color (L2 is
            # one ring per color; L5 has multiple of the same color).
            accepted = []
            for comp in comps[:4]:
                rt = _fit_one_ring(comp["mask"], cuff_global, color, cal)
                if rt is None: continue
                # RANSAC on the cuff-subtracted mask for a robust
                # center. C-rings have biased bounding boxes; we must
                # not derive the center from the bbox.
                ys, xs = np.where(comp["mask"] & ~cuff_global)
                if len(xs) < 30:
                    continue
                cx_f, cy_f, r_f, _n = _ransac_circle(xs, ys, n_iter=300, tol_px=2.0)
                if r_f <= 0:
                    cx_f, cy_f = rt.center_x_can, rt.center_y_can
                gap_c, gap_w = _measure_gap(comp["mask"] & ~cuff_global,
                                              cx_f, cy_f, cal)
                cx_can, cy_can = cal.map_to_canonical(cx_f, cy_f)
                rt.center_x = cx_can
                rt.center_y = cy_can
                rt.gap_center_angle = gap_c
                rt.gap_width_angle = gap_w
                rt.piece_id_hint = f"{color}_{piece_counter[color]+1}"
                piece_counter[color] += 1
                accepted.append(rt)
                if len(accepted) >= 1:
                    break
            for rt in accepted:
                centroid_x += rt.center_x
                centroid_y += rt.center_y
                n_pieces += 1
                pieces.append(PieceTarget(
                    piece_id_hint=rt.piece_id_hint,
                    color=color,
                    ring=rt,
                ))

        if n_pieces > 0:
            centroid_x /= n_pieces
            centroid_y /= n_pieces

        # Cuff measurement
        cuff_comps = _label_components(masks["cuff"], min_area=20)
        cuffs: List[CuffTarget] = []
        for comp in cuff_comps:
            ct = _measure_cuff(comp, cal)
            if ct is not None:
                cuffs.append(ct)

        # Assign cuffs to nearest piece (for hint purposes only — the
        # user / LevelAuthor can override).
        for ct in cuffs:
            best_dist = 1e18
            best_p = None
            for p in pieces:
                d = math.hypot(p.ring.center_x - ct.center_x, p.ring.center_y - ct.center_y)
                if d < best_dist:
                    best_dist = d; best_p = p
            if best_p is not None:
                best_p.cuffs.append(ct)
                ct.piece_id_hint = best_p.piece_id_hint

        # Build report
        report_lines.append("=" * 60)
        report_lines.append(f"Reference target report: level {level_id}")
        report_lines.append(f"  Reference image: {os.path.basename(ref_path)} ({W}x{H})")
        report_lines.append(f"  Calibration: crop_origin={cal.reference_crop_origin} "
                            f"ref={cal.reference_width}x{cal.reference_height} "
                            f"scale={cal.uniform_scale:.4f} "
                            f"off=({cal.canonical_offset_x:.2f},{cal.canonical_offset_y:.2f})")
        report_lines.append("=" * 60)
        report_lines.append("")
        report_lines.append("--- Ring targets (canonical) ---")
        for p in pieces:
            r = p.ring
            report_lines.append(
                f"  {p.piece_id_hint:<14} {p.color:<7} "
                f"center=({r.center_x:7.2f}, {r.center_y:7.2f})  "
                f"r_centerline={r.centerline_radius:5.1f}  "
                f"r_in={r.inner_radius:5.1f}  r_out={r.outer_radius:5.1f}  "
                f"thickness={r.thickness:5.1f}"
            )
            report_lines.append(
                f"  {'':14} {'':7}  gap_center={r.gap_center_angle:6.1f}  "
                f"gap_width={r.gap_width_angle:5.1f}  area={r.bbox_count}"
            )
        report_lines.append("")
        report_lines.append(f"--- Cuff targets ({len(cuffs)}) ---")
        for ct in cuffs:
            report_lines.append(
                f"  cuff (to {ct.piece_id_hint or '?'})  "
                f"center=({ct.center_x:7.2f}, {ct.center_y:7.2f})  "
                f"w={ct.width:5.1f}  h={ct.height:5.1f}  "
                f"orient={ct.orientation_deg:5.1f}"
            )
        report_lines.append("")
        report_lines.append("=" * 60)

        return LevelTarget(
            level_id=level_id,
            calibration=cal,
            reference_image_size=(W, H),
            pieces=pieces,
            puzzle_centroid_canonical=(centroid_x, centroid_y),
            report_lines=report_lines,
        )


def main():
    import sys
    if len(sys.argv) < 2:
        print("Usage: python reference_analyzer.py <ref_image> [level_id]")
        return 1
    ref_path = sys.argv[1]
    level_id = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    analyzer = ReferenceAnalyzer()
    target = analyzer.analyze(ref_path, level_id=level_id)
    for line in target.report_lines:
        print(line)
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(main())