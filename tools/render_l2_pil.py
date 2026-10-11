"""
render_l2_pil.py — render the L2 JSON to PNG via PIL (no extra deps).
Loads data/user_levels/2.json, draws:
  - each ring (piece) as a stroked arc with the gap removed
  - each link (clip) as a stem + cuff using the runtime-measured
    stem_dist and collar_angle_deg

Output: tools/analyzer_outputs/level_2_rendered.png
"""
import os
import sys
import math
import json
from PIL import Image, ImageDraw

LEVEL_PATH = "data/user_levels/2.json"
OUTPUT_PATH = "tools/analyzer_outputs/level_2_rendered.png"
CANVAS_W = 720
CANVAS_H = 1280


def _ring_path(cx, cy, r, thickness, gap_center_deg, gap_width_deg, samples=200):
    """Generate points along the ring centerline, skipping the gap."""
    half = gap_width_deg / 2.0
    start = gap_center_deg + half
    end = gap_center_deg + 360.0 - half
    # Span: from start, going clockwise, to end.
    pts = []
    for i in range(samples + 1):
        ang = start + (end - start) * i / samples
        rad = math.radians(ang)
        pts.append((cx + r * math.cos(rad), cy + r * math.sin(rad)))
    return pts


def render():
    with open(LEVEL_PATH) as f:
        data = json.load(f)
    pieces = data["pieces"]
    links = data["links"]

    img = Image.new("RGB", (CANVAS_W, CANVAS_H), (250, 246, 239))
    draw = ImageDraw.Draw(img, "RGBA")

    # 1. Draw links FIRST.
    for link in links:
        from_id = link["from_id"]
        parent = next((p for p in pieces if p["id"] == from_id), None)
        if parent is None:
            continue
        collar = link["collar_angle_deg"]
        cuff_dist = link.get("stem_dist", link["stem_length"] / 2.0)
        rad = math.radians(collar)
        pcx = parent["x"]; pcy = parent["y"]; pr = parent["radius"]
        # Parent edge point.
        pe_x = pcx + pr * math.cos(rad)
        pe_y = pcy + pr * math.sin(rad)
        # Cuff center.
        ccx = pcx + cuff_dist * math.cos(rad)
        ccy = pcy + cuff_dist * math.sin(rad)
        # Stem line.
        draw.line([(pe_x, pe_y), (ccx, ccy)],
                  fill=(31, 90, 130, 255),
                  width=int(link["stem_width"]))
        # Cuff rectangle.
        cuff_w = link["cuff_width"]
        cuff_d = link["cuff_depth"]
        # Compute corners (rotated rect).
        cos_a = math.cos(rad); sin_a = math.sin(rad)
        def _rot(dx, dy):
            return (ccx + dx * cos_a - dy * sin_a,
                    ccy + dx * sin_a + dy * cos_a)
        c1 = _rot(-cuff_w / 2, -cuff_d / 2)
        c2 = _rot( cuff_w / 2, -cuff_d / 2)
        c3 = _rot( cuff_w / 2,  cuff_d / 2)
        c4 = _rot(-cuff_w / 2,  cuff_d / 2)
        draw.polygon([c1, c2, c3, c4], fill=(31, 90, 130, 255),
                     outline=(15, 58, 90, 255))

    # 2. Draw rings.
    for piece in pieces:
        cx = piece["x"]; cy = piece["y"]; r = piece["radius"]
        thickness = piece["thickness"]
        color_hex = piece["color_hex"].lstrip("#")
        rgb = (int(color_hex[0:2], 16),
               int(color_hex[2:4], 16),
               int(color_hex[4:6], 16))
        gaps = piece.get("gaps", [])
        if not gaps:
            # Closed ring: full circle.
            draw.ellipse([cx - r, cy - r, cx + r, cy + r],
                         outline=rgb + (255,), width=int(thickness))
            continue
        gap = gaps[0]
        pts = _ring_path(cx, cy, r, thickness,
                         gap["center_angle_deg"], gap["width_deg"],
                         samples=240)
        if len(pts) >= 2:
            draw.line(pts, fill=rgb + (255,), width=int(thickness),
                      joint="curve")

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    img.save(OUTPUT_PATH)
    print(f"Wrote {OUTPUT_PATH}  ({os.path.getsize(OUTPUT_PATH)} bytes)")


if __name__ == "__main__":
    render()