"""
level_from_image.py — Phase 12.

Auto-detect a RotateRings level from a single screenshot and emit
the modern-schema data/user_levels/N.json. Eliminates the manual
JSON-editing loop that caused the Phase 11 L2 visual mistakes.

Pipeline (mirrored after the Phase 9/10 analyzer but purpose-built
for a level screenshot rather than a reference plate):

  1. Per-color HSV segmentation. Palette is the RotateRings
     8-color set (orange, cyan, purple, red, green, cuff_blue,
     yellow, pink). Each color is matched with hue-tolerance +
     saturation floor + value tolerance, exactly as the runtime
     `color_segmentation.py` does.
  2. Per-color connected components. Pick the LARGEST component
     per color as a ring body.
  3. For each ring, fit a RANSAC circle (cx, cy, r) and measure
     inner/outer radius from the radial histogram. This gives:
       center, centerline_radius, thickness.
  4. Detect the GAP on each ring. For each ring, sample the
     radial histogram in 5-deg bins, find the bin with the lowest
     "ring body" occupancy, declare that bin the gap (center
     angle_deg = bin center, width_deg = 2 * bin half-width).
  5. Detect CUFFS. Look for small dark-blue rectangles
     (#1F5A82 or whatever the cuff color is) that lie BETWEEN
     two ring centers. For each cuff, find the two nearest
     rings and record the link between them.
  6. Compute link geometry. For each (parent, child) pair,
       collar_angle_deg = atan2(child.center - parent.center)
       (in Godot's screen convention; the engine recomputes this
       at load, so this is just a sensible authoring default).
       cuff_center = midpoint(parent.edge, child.edge) along
       the collar direction.
  7. Emit the modern JSON. The Python writer mirrors PieceDefini
     tion.to_dict() so the JSON is lossless.
  8. Optionally call `godot --headless --script
     tools/test_solvable_l2_l3.gd` to verify the level BFS-solves.

Usage:
  python tools/level_from_image.py <image_path> [level_id]
  defaults to level_id=2.

Returns the path to the written JSON on success.
"""
import os
import sys
import math
import json
import argparse
import numpy as np
from PIL import Image

# Reuse the existing color segmentation.
sys.path.insert(0, os.path.dirname(__file__))
from color_segmentation import build_color_masks_hsv


# =============================================================================
# Canvas conversion: ref (685x1170) -> canonical (720x1280)
# =============================================================================
# The reference images in ALL 2to100 levels/ are 685x1170.
# RotateRings canonical canvas is 720x1280. So a point (x_r, y_r) in
# the reference image maps to canonical (720/685 * x_r, 1280/1170 * y_r).
REF_W = 685.0
REF_H = 1170.0
CANONICAL_W = 720.0
CANONICAL_H = 1280.0
SCALE_X = CANONICAL_W / REF_W
SCALE_Y = CANONICAL_H / REF_H


# =============================================================================
# Per-color ring detection
# =============================================================================

# The 8-color palette the engine recognizes.
PALETTE = {
    "#ea7829": "orange",
    "#32adda": "cyan",
    "#7b61ff": "purple",
    "#e63946": "red",
    "#3ec6b0": "green",
    "#1f5a82": "cuff_blue",
    "#f4c95d": "yellow",
    "#f2a6b5": "pink",
}
# Each ring color we expect to find in a level. Note: the underlying
# `build_color_masks_hsv` only supports {orange, cyan, purple, cuff},
# so we restrict the ring-color list to those for now. Red/green/
# yellow/pink rings would require extending color_segmentation.py.
RING_COLORS = ["orange", "cyan", "purple"]


def _ransac_circle(xs, ys, n_iter=500, tol_px=2.0):
    """RANSAC circle fit. Picks 3 random points, fits a circle, then
    refits the circle on the inliers. Returns (cx, cy, r, n_inliers)."""
    if len(xs) < 3:
        return (0.0, 0.0, 0.0, 0)
    n = len(xs)
    best_inliers = 0
    best_cx = best_cy = best_r = 0.0
    for _ in range(n_iter):
        idx = np.random.choice(n, 3, replace=False)
        x1, x2, x3 = xs[idx[0]], xs[idx[1]], xs[idx[2]]
        y1, y2, y3 = ys[idx[0]], ys[idx[1]], ys[idx[2]]
        ax = x1 - x2
        ay = y1 - y2
        bx = x1 - x3
        by = y1 - y3
        d = 2.0 * (ax * (y1 - y3) - ay * (x1 - x3))
        if abs(d) < 1e-6:
            continue
        ux = ((x1 * x1 + y1 * y1) * (y1 - y3) - (x3 * x3 + y3 * y3) * (y1 - y2)) / d
        uy = ((x3 * x3 + y3 * y3) * (x1 - x2) - (x1 * x1 + y1 * y1) * (x1 - x3)) / d
        r0 = math.hypot(ux - x1, uy - y1)
        if r0 <= 0:
            continue
        # Find inliers.
        residuals = np.sqrt((xs - ux) ** 2 + (ys - uy) ** 2) - r0
        inlier_mask = np.abs(residuals) < tol_px
        n_in = int(inlier_mask.sum())
        if n_in < 3:
            continue
        # Reject absurd radii.
        if r0 > 5000 or r0 < 1:
            continue
        # Refit circle on the inliers.
        xs_in = xs[inlier_mask]
        ys_in = ys[inlier_mask]
        # Algebraic least-squares on inliers.
        A = np.column_stack([2 * xs_in, 2 * ys_in, np.ones(n_in)])
        b_vec = xs_in * xs_in + ys_in * ys_in
        sol, *_ = np.linalg.lstsq(A, b_vec, rcond=None)
        cx_r, cy_r, c_r = sol
        r_refit = math.sqrt(c_r + cx_r * cx_r + cy_r * cy_r)
        if r_refit <= 0 or r_refit > 5000:
            continue
        # Count inliers of the refit (with same tolerance).
        residuals2 = np.sqrt((xs - cx_r) ** 2 + (ys - cy_r) ** 2) - r_refit
        n_in_refit = int(np.sum(np.abs(residuals2) < tol_px))
        if n_in_refit > best_inliers:
            best_inliers = n_in_refit
            best_cx, best_cy, best_r = float(cx_r), float(cy_r), float(r_refit)
    return (best_cx, best_cy, best_r, best_inliers)


def _radial_thickness(xs, ys, cx, cy, bin_width=1.0):
    """Radial histogram of cleaned ring pixels. Return (r_inner, r_outer)."""
    r = np.sqrt((xs - cx) ** 2 + (ys - cy) ** 2)
    if r.size == 0:
        return (0.0, 0.0)
    r_max = float(r.max())
    if r_max <= 0:
        return (0.0, 0.0)
    n_bins = max(1, int(r_max / bin_width) + 1)
    counts, edges = np.histogram(r, bins=n_bins, range=(0, r_max + bin_width))
    centers = (edges[:-1] + edges[1:]) / 2
    if counts.max() == 0:
        return (0.0, 0.0)
    threshold = float(counts.max()) * 0.10  # 10% of peak
    peak = counts >= threshold
    idxs = np.where(peak)[0]
    if len(idxs) == 0:
        return (0.0, 0.0)
    return (float(centers[idxs.min()]), float(centers[idxs.max()]))


def _detect_gap_direction(mask, cx, cy, r_inner, r_outer, n_bins=72):
    """Find the angular bin with the lowest ring-body occupancy.
    Returns (center_angle_deg, width_deg) using Godot's screen
    convention (0 deg = +X = right, 90 deg = +Y = down)."""
    H, W = mask.shape
    ys, xs = np.where(mask)
    if len(xs) < 30:
        return (0.0, 360.0)
    # Polar angle of each pixel, in degrees, 0 = +X (right).
    angles = np.degrees(np.arctan2(ys - cy, xs - cx)) % 360.0
    bin_width = 360.0 / n_bins
    counts, _ = np.histogram(angles, bins=n_bins, range=(0, 360))
    # The bin with the LOWEST count is the gap.
    gap_bin = int(np.argmin(counts))
    # Refine: the gap is a contiguous span around the minimum.
    threshold = float(counts.max()) * 0.5
    occupied = counts > threshold
    # Walk left and right from gap_bin while bin is unoccupied.
    width_bins = 1
    for direction in (-1, 1):
        idx = gap_bin
        while True:
            idx = (idx + direction) % n_bins
            if occupied[idx]:
                break
            width_bins += 1
            if width_bins > n_bins // 2:
                break
    width_deg = width_bins * bin_width
    center_deg = (gap_bin * bin_width + width_deg / 2.0) % 360.0
    return (center_deg, width_deg)


def _detect_ring(image_arr, color_name, min_area=200, min_radius=20, max_radius=200,
                  inlier_tol_px=2.0, min_inlier_frac=0.03):
    """Return (cx, cy, r_inner, r_outer, gap_center, gap_width) for the
    largest connected component of the given color in the image.
    Filters out background noise and HUD text (anything in the top
    20% of the image)."""
    masks = build_color_masks_hsv(image_arr, [color_name])
    mask = masks[color_name]
    if mask.sum() < min_area:
        return None
    # Largest connected component.
    from scipy.ndimage import label
    lbl, n = label(mask)
    if n == 0:
        return None
    # Filter: ignore components in the HUD area (top 20% of the image).
    H = mask.shape[0]
    hud_cutoff = int(H * 0.20)
    # Pick the largest component that fits plausible ring sizes AND
    # has its center below the HUD cutoff.
    sizes = [(int((lbl == i).sum()), i) for i in range(1, n + 1)]
    sizes.sort(reverse=True)
    big = None
    cx = cy = r_fit = 0.0
    for size, i in sizes:
        if size < min_area:
            break
        cm = (lbl == i)
        ys, xs = np.where(cm)
        cy_est = float(ys.mean())
        if cy_est < hud_cutoff:
            continue
        cx_t, cy_t, r_fit_t, n_in = _ransac_circle(xs.astype(np.float32),
                                                   ys.astype(np.float32),
                                                   tol_px=inlier_tol_px)
        # Always try bbox fallback if RANSAC is bad.
        bw = float(xs.max() - xs.min())
        bh = float(ys.max() - ys.min())
        # For a C-ring the bbox is wider than tall (gap on the side),
        # so use the LARGER dimension to estimate radius. We use
        # (max + min) / 2 to balance over-estimation in one axis.
        r_bbox = (max(bw, bh) + min(bw, bh)) * 0.25
        if r_fit_t <= 0 or n_in < max(50, size * min_inlier_frac) \
                or r_fit_t < min_radius or r_fit_t > max_radius or n_in < 3:
            if r_bbox >= min_radius and r_bbox <= max_radius:
                cx = (xs.min() + xs.max()) * 0.5
                cy = (ys.min() + ys.max()) * 0.5
                r_fit_t = r_bbox
                print(f"  [{color_name}] comp {i} size={size} RANSAC gave r={r_fit_t:.1f} (n_in={n_in}); fell back to bbox r={r_bbox:.1f}")
            else:
                print(f"  [{color_name}] comp {i} size={size} bbox={r_bbox:.1f} also out of range, skipping")
                continue
        else:
            cx, cy, r_fit = cx_t, cy_t, r_fit_t
        big = cm
        print(f"  [{color_name}] comp {i} size={size} cx={cx:.0f} cy={cy:.0f} r={r_fit_t:.1f}")
        break
    if big is None:
        return None
    ys, xs = np.where(big)
    cx, cy, r_fit, n_in = _ransac_circle(xs.astype(np.float32),
                                          ys.astype(np.float32),
                                          tol_px=inlier_tol_px)
    r_inner, r_outer = _radial_thickness(
        xs.astype(np.float32), ys.astype(np.float32), cx, cy)
    gap_center, gap_width = _detect_gap_direction(big, cx, cy, r_inner, r_outer)
    thickness = r_outer - r_inner
    if thickness < 1.0 or thickness > 60.0:
        # Bad radial histogram (likely bbox-fallback ring); use default.
        thickness = 22.0
        r_inner = r_fit - thickness / 2.0
        r_outer = r_fit + thickness / 2.0
    return {
        "cx_ref": float(cx), "cy_ref": float(cy),
        "r_centerline": float((r_inner + r_outer) / 2.0),
        "r_inner": float(r_inner),
        "r_outer": float(r_outer),
        "thickness": float(thickness),
        "gap_center_deg": float(gap_center),
        "gap_width_deg": float(gap_width),
        "n_pixels": int(big.sum()),
    }


# =============================================================================
# Cuff detection
# =============================================================================

def _detect_cuffs(image_arr, rings):
    """Find small dark rectangles between rings. For each cuff,
    return the two ring ids it connects (by nearest center)."""
    # Cuffs are dark blue (#1F5A82) rectangles. Match by HSV.
    # The color_segmentation module uses the key "cuff" (not "cuff_blue").
    masks = build_color_masks_hsv(image_arr, ["cuff"])
    cuff_mask = masks["cuff"]
    if cuff_mask.sum() < 30:
        return []
    from scipy.ndimage import label
    lbl, n = label(cuff_mask)
    cuffs = []
    for i in range(1, n + 1):
        cm = (lbl == i)
        if cm.sum() < 50 or cm.sum() > 5000:
            continue  # too small or too big
        ys, xs = np.where(cm)
        cx = float(xs.mean())
        cy = float(ys.mean())
        # Find the two nearest rings.
        dists = []
        for rid, r in rings.items():
            d = math.hypot(r["cx_ref"] - cx, r["cy_ref"] - cy)
            dists.append((d, rid))
        dists.sort()
        if len(dists) < 2:
            continue
        (d1, r1), (d2, r2) = dists[0], dists[1]
        if d1 > 100 or d2 > 200:
            continue
        cuffs.append({
            "parent_id": r1,
            "child_id": r2,
            "cx_ref": cx, "cy_ref": cy,
            "parent_dist": d1,
            "child_dist": d2,
        })
    return cuffs


# =============================================================================
# JSON emission
# =============================================================================

def _ref_to_canonical(x, y):
    return (x * SCALE_X, y * SCALE_Y)


def _gap_center_for_link(ring, other):
    """Pick the gap direction that's roughly toward `other` from `ring`,
    then mirror so it's actually away from `other`. The original
    design has the cuff at the gap, so we want the gap facing the
    OTHER ring."""
    dx = other["cx_ref"] - ring["cx_ref"]
    dy = other["cy_ref"] - ring["cy_ref"]
    # In Godot's screen convention (Y down), atan2(dy, dx) gives the
    # world angle of the direction from ring to other.
    angle = math.degrees(math.atan2(dy, dx)) % 360.0
    return angle


def _build_link_dict(parent_ring, child_ring, cuff_pos_ref, link_idx):
    """Build one link dict for the modern schema."""
    # Parent -> child world direction (Godot screen convention).
    dx = child_ring["cx_ref"] - parent_ring["cx_ref"]
    dy = child_ring["cy_ref"] - parent_ring["cy_ref"]
    angle = math.degrees(math.atan2(dy, dx)) % 360.0
    # For the gap, use the OPPOSITE of the cuff direction (the gap
    # faces away from the connected ring, matching the original
    # screenshot where gaps face the outer edge of the triangle).
    gap_center = (angle + 180.0) % 360.0
    # Canonical positions.
    pcx, pcy = _ref_to_canonical(parent_ring["cx_ref"], parent_ring["cy_ref"])
    # Cap the gap width at a sensible value.
    gap_width = min(120.0, max(60.0, parent_ring["gap_width_deg"]))
    return {
        "id": f"link_{link_idx}",
        "from_id": parent_ring["ring_id"],
        "to_id": child_ring["ring_id"],
        "collar_angle_deg": float(angle),
        "cuff_center_local": {"x": 0.0, "y": 0.0},
        "cuff_orientation_deg": float(angle),
        "cuff_width": 32.0,
        "cuff_depth": 18.0,
        "cuff_round_radius": 5.0,
        "stem_length": 20.0,
        "stem_width": 6.0,
        "stem_distance_from_piece": 20.0,
        "stem_dist": 20.0,
        # Use the parent's color so the connector visually matches.
        "joint_color_hex": _palette_hex_for(parent_ring["color"]),
        "joint_color_name": parent_ring["color"],
        "clearance_tolerance_deg": 16.0,
        "is_detached": False,
        "z_index": 0,
    }


def _palette_hex_for(color_name):
    for hex_code, name in PALETTE.items():
        if name == color_name:
            return f"#{hex_code}"
    return "#EA7829"


def build_level_json(rings_ref, cuff_links, level_id):
    """Convert the detected rings + links to the modern schema."""
    pieces = []
    for rid, r in rings_ref.items():
        # Detect color_name from the original ring record.
        color_name = r["color"]
        cx_can, cy_can = _ref_to_canonical(r["cx_ref"], r["cy_ref"])
        gap_width = min(120.0, max(60.0, r["gap_width_deg"]))
        pieces.append({
            "id": rid,
            "color_name": color_name,
            "color_hex": _palette_hex_for(color_name),
            "x": round(cx_can, 2),
            "y": round(cy_can, 2),
            "start_angle_deg": 0.0,
            "radius": round(r["r_centerline"], 2),
            "radius_y": round(r["r_centerline"], 2),
            "thickness": round(r["thickness"], 2),
            "shape_type": 0,
            "piece_type": 1,
            "role": 0,
            "z_index": 1,
            "initially_locked": False,
            "locked": False,
            "property_locks": {},
            "release_direction": {"x": 1, "y": 0},
            "target_exit_angle_deg": 0.0,
            "motion_model": 0,
            "gaps": [{
                "center_angle_deg": round(r["gap_center_deg"], 2),
                "width_deg": round(gap_width, 2),
                "tolerance_deg": 16.0,
            }],
        })
    links = []
    for i, link in enumerate(cuff_links):
        parent = rings_ref[link["parent_id"]]
        child = rings_ref[link["child_id"]]
        links.append(_build_link_dict(parent, child, (link["cx_ref"], link["cy_ref"]), i))
    return {
        "id": level_id,
        "title": f"Level {level_id} (auto-detected from image)",
        "instruction": "",
        "par_moves": 3,
        "theme_id": "porcelain",
        "frame_anchor": "auto",
        "frame_offset_x": 0.0,
        "frame_offset_y": 0.0,
        "frame_scale": 1.0,
        "grid_size": 20.0,
        "snap_to_grid": False,
        "snap_to_piece_centers": False,
        "snap_to_edges": False,
        "snap_to_guides": False,
        "snap_to_connector_points": False,
        "nudge_step": 1.0,
        "nudge_shift_multiplier": 10.0,
        "nudge_alt_multiplier": 0.1,
        "guides": [],
        "reference_guides": [],
        "size_links": {},
        "locks": {},
        "pieces": pieces,
        "links": links,
        "source": f"auto-detected from image by tools/level_from_image.py",
    }


# =============================================================================
# Top-level
# =============================================================================

def detect_level(image_path, level_id):
    """Detect rings + cuffs in the image, return (rings, links)."""
    img = Image.open(image_path).convert("RGB")
    arr = np.array(img)
    H, W = arr.shape[:2]
    # Detect one ring per color.
    rings_ref = {}
    for color in RING_COLORS:
        info = _detect_ring(arr, color)
        if info is None:
            print(f"  no {color} ring detected")
            continue
        ring_id = f"{color}_ring"
        info["color"] = color
        info["ring_id"] = ring_id
        rings_ref[ring_id] = info
        print(f"  {color}_ring: center=({info['cx_ref']:.0f}, {info['cy_ref']:.0f}) "
              f"r={info['r_centerline']:.0f} thickness={info['thickness']:.0f} "
              f"gap=({info['gap_center_deg']:.0f} +/- {info['gap_width_deg']/2:.0f} deg)")
    # Detect cuffs and link them to nearest two rings.
    cuff_links = _detect_cuffs(arr, rings_ref)
    for c in cuff_links:
        print(f"  cuff: parent={c['parent_id']} child={c['child_id']} "
              f"at ({c['cx_ref']:.0f}, {c['cy_ref']:.0f})")
    return rings_ref, cuff_links


def main():
    parser = argparse.ArgumentParser(description="Auto-detect a RotateRings level from a screenshot.")
    parser.add_argument("image", help="Path to the level screenshot (PNG/JPEG).")
    parser.add_argument("level_id", nargs="?", type=int, default=2,
                        help="Level ID to save under (default: 2).")
    parser.add_argument("--out", default=None,
                        help="Output path (default: data/user_levels/<id>.json).")
    parser.add_argument("--no-verify", action="store_true",
                        help="Skip the Godot solvability check.")
    args = parser.parse_args()

    if not os.path.exists(args.image):
        print(f"Image not found: {args.image}")
        sys.exit(1)
    out_path = args.out or f"data/user_levels/{args.level_id}.json"
    print(f"Detecting rings in {args.image}...")
    rings, links = detect_level(args.image, args.level_id)
    if not rings:
        print("No rings detected; aborting.")
        sys.exit(2)
    level = build_level_json(rings, links, args.level_id)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "w") as f:
        json.dump(level, f, indent=2)
    print(f"\nWrote {out_path}")
    print(f"  {len(rings)} rings, {len(links)} links")
    if not args.no_verify:
        print("\nVerifying via Godot solvability check...")
        import subprocess
        result = subprocess.run(
            ["C:\\Godot\\godot.cmd", "--headless",
             "--script", "res://tools/test_solvable_l2_l3.gd",
             "--quit-after", "120"],
            capture_output=True, text=True, cwd="D:\\AI secound Brain\\RotateRings",
        )
        out = result.stdout + result.stderr
        for line in out.splitlines():
            if "solved=" in line or "PASS" in line or "FAIL" in line:
                print("  " + line.strip())


if __name__ == "__main__":
    main()