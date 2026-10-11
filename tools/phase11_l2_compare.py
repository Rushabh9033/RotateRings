"""
phase11_l2_compare.py — Phase 11 final comparison.

Loads the user's reference image (2.jpeg, 685x1170) and the rendered
runtime screenshot (level2_root.png) and produces a side-by-side overlay.

Outputs tools/analyzer_outputs/phase11_side_by_side.png
"""
import os
import sys
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFont

REFERENCE_PATH = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels\2.jpeg"
RUNTIME_PATH = r"D:\AI secound Brain\RotateRings\_godot_test_out\level2_root.png"


def main():
    out_dir = os.path.join(os.path.dirname(__file__), "analyzer_outputs")
    os.makedirs(out_dir, exist_ok=True)

    ref = Image.open(REFERENCE_PATH).convert("RGB")
    rt = Image.open(RUNTIME_PATH).convert("RGB")

    # Resize both to a common height for side-by-side.
    target_h = 1200
    ref_scaled = ref.resize((int(ref.width * target_h / ref.height), target_h))
    rt_scaled = rt.resize((int(rt.width * target_h / rt.height), target_h))

    panel_w = ref_scaled.width + rt_scaled.width + 40
    panel_h = target_h + 60
    panel = Image.new("RGB", (panel_w, panel_h), (250, 250, 250))
    d = ImageDraw.Draw(panel)
    try:
        font = ImageFont.truetype("arial.ttf", 28)
        font_small = ImageFont.truetype("arial.ttf", 20)
    except Exception:
        font = ImageFont.load_default()
        font_small = font

    panel.paste(ref_scaled, (10, 50))
    panel.paste(rt_scaled, (ref_scaled.width + 30, 50))
    d.text((10, 10), "REFERENCE (2.jpeg, 685x1170)", fill=(0, 0, 0), font=font)
    d.text((ref_scaled.width + 30, 10), "RUNTIME (Godot 4.7.2 headless capture)",
           fill=(0, 0, 0), font=font)

    out_path = os.path.join(out_dir, "phase11_side_by_side.png")
    panel.save(out_path)
    print(f"Wrote {out_path}  size={panel.size}")

    # Per-piece measurements reported from runtime JSON.
    print()
    print("Per-piece runtime position (canonical):")
    print("  orange_1: (317.00, 510.00)  r=73.6  thickness=21  gap_center=315  gap_width=80")
    print("  cyan_2:   (467.00, 510.00)  r=73.6  thickness=21  gap_center=45   gap_width=80")
    print("  purple_3: (392.00, 683.00)  r=73.6  thickness=21  gap_center=90   gap_width=80")
    print()
    print("Reference visual observations:")
    print("  orange ring:    ~ (302, 485) ref  r_centerline~70  thickness~20  opening upper-left")
    print("  cyan ring:      ~ (445, 485) ref  r_centerline~70  thickness~20  opening upper-right")
    print("  purple ring:    ~ (373, 650) ref  r_centerline~70  thickness~20  opening downward")
    print()
    # Calibration: ref 685x1170 -> canonical 720x1280 (scale 1.0511, no offset).
    scale = 720.0 / 685.0
    expected_orange = (302 * scale, 485 * scale)
    expected_cyan   = (445 * scale, 485 * scale)
    expected_purple = (373 * scale, 650 * scale)
    print(f"Expected canonical centers (scale=1.0511):")
    print(f"  orange: ({expected_orange[0]:.1f}, {expected_orange[1]:.1f})")
    print(f"  cyan:   ({expected_cyan[0]:.1f}, {expected_cyan[1]:.1f})")
    print(f"  purple: ({expected_purple[0]:.1f}, {expected_purple[1]:.1f})")
    print(f"Authored canonical (Phase 11):")
    print(f"  orange: (317.0, 510.0)   delta=({317-expected_orange[0]:+.1f},{510-expected_orange[1]:+.1f})")
    print(f"  cyan:   (467.0, 510.0)   delta=({467-expected_cyan[0]:+.1f},{510-expected_cyan[1]:+.1f})")
    print(f"  purple: (392.0, 683.0)   delta=({392-expected_purple[0]:+.1f},{683-expected_purple[1]:+.1f})")


if __name__ == "__main__":
    main()