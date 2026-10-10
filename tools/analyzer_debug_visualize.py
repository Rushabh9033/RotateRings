"""
analyzer_debug_visualize.py — render the analyzer's findings as an
overlay on the reference image.

Generates an image showing per ring:
  - the fitted center
  - inner / centerline / outer circles
  - the gap edge rays (RING -> EMPTY transitions)
  - the gap center ray
  - the visible / occluded angular samples
  - the cuff mask

Usage:
  python tools/analyzer_debug_visualize.py <ref_image> <output.png>
"""
import sys
import math
import os
import numpy as np
from PIL import Image, ImageDraw, ImageFont

sys.path.insert(0, os.path.dirname(__file__))
from reference_analyzer import (
    ReferenceAnalyzer, ReferenceCalibration, _build_color_masks,
    _close_morphology, _label_components, _ransac_circle,
    _algebraic_circle_fit,
    _radial_histogram, _circle_residuals, COLOR_TARGETS,
)
from gap_detector import measure_gap as _new_measure_gap

CALIBRATION_DEFAULT = ReferenceCalibration

COLOR_OUTLINE = {
    "orange": (255, 100, 0),
    "cyan":   (0, 200, 230),
    "purple": (180, 100, 255),
    "cuff":   (255, 255, 0),
}

def draw_state_legend(img, x, y, state):
    color = {
        "VISIBLE_RING": (255, 255, 255),
        "VISIBLE_EMPTY": (0, 0, 0),
        "OCCLUDED": (255, 0, 0),
    }[state]
    ImageDraw.Draw(img).rectangle([x, y, x+10, y+10], outline=color, fill=color)


def render(ref_path, out_path, level_id=0):
    img = Image.open(ref_path).convert("RGB")
    arr = np.array(img)
    H, W, _ = arr.shape
    img = img.convert("RGBA")
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    cal = CALIBRATION_DEFAULT.from_natural_size(W, H)

    masks = _build_color_masks(arr)
    for name in masks: masks[name] = _close_morphology(masks[name])

    cuff_global = masks["cuff"]
    radius_out = 40

    for color in ("orange", "cyan", "purple"):
        comps = _label_components(masks[color], min_area=80)
        if not comps: continue
        comp = comps[0]
        ys, xs = np.where(comp["mask"] & ~cuff_global)
        if len(xs) < 50: continue
        cx, cy, r, _ = _ransac_circle(xs, ys, n_iter=300, tol_px=2.0)
        if r <= 0: continue
        # Inner / outer / centerline.
        inliers = np.abs(_circle_residuals(xs, ys, cx, cy, r)) < 2.0
        if inliers.sum() >= 30:
            cx, cy, r = _algebraic_circle_fit(xs[inliers], ys[inliers])
        centers, counts = _radial_histogram(xs[inliers], ys[inliers], cx, cy, bin_width=1.0)
        if centers.size == 0 or counts.max() == 0: continue
        threshold = float(counts.max()) * 0.05
        peak_mask = counts >= threshold
        peak_radii = centers[peak_mask]
        r_inner = float(peak_radii.min())
        r_outer = float(peak_radii.max())
        r_center = (r_inner + r_outer) / 2.0
        thickness = r_outer - r_inner

        # Apply calibration so the overlay matches the calibrated
        # measurement.
        scale = cal.uniform_scale
        cx_disp = cx * scale + cal.canonical_offset_x
        cy_disp = cy * scale + cal.canonical_offset_y

        outline = COLOR_OUTLINE[color]

        # Draw inner / centerline / outer circles.
        for r_draw, w_draw in ((r_inner, 1), (r_center, 2), (r_outer, 1)):
            draw.ellipse([cx_disp - r_draw * scale, cy_disp - r_draw * scale,
                          cx_disp + r_draw * scale, cy_disp + r_draw * scale],
                         outline=outline, width=w_draw)

        # Gap detection.
        gap = _new_measure_gap(comp["mask"] & ~cuff_global, cuff_global,
                                 cx, cy, r_inner, r_outer,
                                 bin_deg=5.0, sub_bin_deg=0.5)

        # Sample ring and cuff states for visualization.
        n_bins = 72
        bin_w = 360.0 / n_bins
        for b in range(n_bins):
            theta_deg = b * bin_w
            theta = math.radians(theta_deg)
            bin_has_ring = False
            bin_has_cuff = False
            for r in np.linspace(r_inner + 1.5, r_outer - 1.5, 8):
                px = int(round(cx + r * np.cos(theta)))
                py = int(round(cy + r * np.sin(theta)))
                if 0 <= px < W and 0 <= py < H:
                    if comp["mask"][py, px] and not cuff_global[py, px]:
                        bin_has_ring = True
                    if cuff_global[py, px]:
                        bin_has_cuff = True
            x0 = int(cx_disp + (r_center + 20) * math.cos(theta) - 3)
            y0 = int(cy_disp + (r_center + 20) * math.sin(theta) - 3)
            if bin_has_ring:
                draw.ellipse([x0, y0, x0 + 6, y0 + 6], fill=(255, 255, 255, 200))
            elif bin_has_cuff:
                draw.ellipse([x0, y0, x0 + 6, y0 + 6], fill=(255, 0, 0, 200))
            else:
                draw.ellipse([x0, y0, x0 + 6, y0 + 6], fill=(60, 60, 60, 200))

        # Gap center ray.
        if gap.width_angle_deg > 0:
            t = math.radians(gap.center_angle_deg)
            x1 = cx_disp
            y1 = cy_disp
            x2 = cx_disp + (r_outer + 20) * math.cos(t) * scale
            y2 = cy_disp + (r_outer + 20) * math.sin(t) * scale
            draw.line([x1, y1, x2, y2], fill=(0, 255, 0, 220), width=2)
            # Gap edges.
            for edge_deg in [gap.center_angle_deg - gap.width_angle_deg/2,
                            gap.center_angle_deg + gap.width_angle_deg/2]:
                t = math.radians(edge_deg % 360)
                x2 = cx_disp + (r_outer + 20) * math.cos(t) * scale
                y2 = cy_disp + (r_outer + 20) * math.sin(t) * scale
                draw.line([cx_disp, cy_disp, x2, y2], fill=(255, 200, 0, 220), width=1)

    # Overlay cuff mask faintly.
    cuff_overlay = np.zeros((H, W, 4), dtype=np.uint8)
    cuff_overlay[cuff_global] = (255, 255, 0, 60)
    img_arr = np.array(img)
    img_arr = img_arr[:, :, :3] * (1 - cuff_overlay[:, :, 3:4] / 255) + \
             cuff_overlay[:, :, :3] * (cuff_overlay[:, :, 3:4] / 255)
    img = Image.fromarray(img_arr.astype(np.uint8)).convert("RGBA")
    img = Image.alpha_composite(img, overlay)
    img.save(out_path)
    print(f"Wrote {out_path}")


def main():
    if len(sys.argv) < 3:
        print("Usage: python tools/analyzer_debug_visualize.py <ref_image> <output.png> [level_id]")
        sys.exit(1)
    ref_path = sys.argv[1]
    out_path = sys.argv[2]
    level_id = int(sys.argv[3]) if len(sys.argv) > 3 else 0
    render(ref_path, out_path, level_id=level_id)


if __name__ == "__main__":
    main()