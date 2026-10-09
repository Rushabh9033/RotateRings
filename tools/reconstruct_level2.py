"""
Brahmaastra section 13: Reconstruct Level 2 from the reference image and
produce the 4-tile comparison panel.

Reads:
  - 2.jpeg (reference, ground truth)
  - data/user_levels/2.json (our current authored data)
  - tools/measure_level2.json (color-cluster measurements from the reference)

Writes:
  - tools/reconstruct_level2_compare.png   (REFERENCE | OUR RENDER | 50% OVERLAY | DIFF)
  - tools/reconstruct_level2_measurements.json  (per-piece center/radius/gap/orientation)
"""
import json
import math
from pathlib import Path
from PIL import Image, ImageDraw, ImageChops, ImageFilter, ImageFont

ROOT = Path(r"D:\AI secound Brain\RotateRings")
REF = ROOT / "ALL 2to100 levels" / "2.jpeg"
USER_JSON = ROOT / "data" / "user_levels" / "2.json"
MEASUREMENTS = ROOT / "tools" / "measure_level2.json"
OUT_PANEL = ROOT / "tools" / "reconstruct_level2_compare.png"
OUT_REPORT = ROOT / "tools" / "reconstruct_level2_measurements.json"
GAME_REF_W = 720
GAME_REF_H = 1280

# ---- Load reference ----
ref_img = Image.open(REF).convert("RGB")
ref_w, ref_h = ref_img.size
print(f"Reference image: {ref_w} x {ref_h}")

# ---- Load current authored Level 2 ----
data = json.load(open(USER_JSON, encoding="utf-8"))
pieces = data["pieces"]
links = data["links"]
print(f"Authored pieces: {len(pieces)}  links: {len(links)}")

# ---- Render our puzzle at the reference image's native resolution ----
def render_puzzle(width: int, height: int) -> Image.Image:
    """Render the authored puzzle as flat circles, no fancy 3D tube.
    This is intentional: per the directive, the editor preview should not
    fake the rendered result. The comparison shows STRUCTURAL truth.
    """
    img = Image.new("RGB", (width, height), (255, 245, 230))
    draw = ImageDraw.Draw(img)
    sx = width / ref_w
    sy = height / ref_h
    def s(p):  # scale a measurement coord
        return (p[0] * sx, p[1] * sy)
    for piece in pieces:
        cx, cy = piece["x"], piece["y"]
        r = piece.get("radius", 80)
        thickness = piece.get("thickness", 22)
        color_hex = piece.get("color_hex", "#32ADDA")
        color = tuple(int(color_hex[i:i+2], 16) for i in (1, 3, 5))
        # Draw the ring as a torus
        rr = r * sx
        thickness_scaled = max(2, thickness * sy)
        bbox = [cx * sx - rr, cy * sy - rr, cx * sx + rr, cy * sy + rr]
        draw.ellipse(bbox, outline=color, width=int(thickness_scaled))
        # Draw gaps as small wedge cuts
        for g in piece.get("gaps", []):
            gap_center_deg = g.get("center_angle_deg", 0)
            gap_width_deg = g.get("width_deg", 60)
            world_center = (piece.get("start_angle_deg", 0) + gap_center_deg) % 360
            half = gap_width_deg / 2
            a0 = (world_center - half - 90) * math.pi / 180
            a1 = (world_center + half - 90) * math.pi / 180
            # Cut a wedge of the same color as the background
            draw.pieslice(bbox, -math.degrees(a0), -math.degrees(a1),
                           fill=(255, 245, 230), outline=(255, 245, 230))
        # Center mark
        draw.ellipse([cx*sx-3, cy*sy-3, cx*sx+3, cy*sy+3], fill=color)
    # Draw connectors
    for link in links:
        from_id = link.get("from_id")
        to_id = link.get("to_id")
        from_p = next((p for p in pieces if p["id"] == from_id), None)
        to_p = next((p for p in pieces if p["id"] == to_id), None)
        if not from_p or not to_p: continue
        draw.line(
            [(from_p["x"] * sx, from_p["y"] * sy),
             (to_p["x"] * sx, to_p["y"] * sy)],
            fill=(31, 90, 130),
            width=int(8 * sy),
        )
    return img

our = render_puzzle(ref_w, ref_h)

# ---- 4-tile panel: REFERENCE | OUR | 50% OVERLAY | DIFF ----
panel_w = ref_w * 2
panel_h = ref_h * 2
panel = Image.new("RGB", (panel_w, panel_h), (245, 235, 220))
panel.paste(ref_img, (0, 0))
panel.paste(our, (ref_w, 0))
overlay = Image.blend(ref_img, our, 0.5)
panel.paste(overlay, (0, ref_h))
diff = ImageChops.difference(ref_img, our)
# Amplify diff visibility
import numpy as np
diff_np = np.array(diff, dtype=np.uint16)
amplified = np.clip(diff_np.astype(np.int32) * 4, 0, 255).astype(np.uint8)
diff_amp = Image.fromarray(amplified)
panel.paste(diff_amp, (ref_w, ref_h))

# Draw labels (top-left of each tile)
draw = ImageDraw.Draw(panel)
try:
    font = ImageFont.truetype("arial.ttf", 18)
except OSError:
    font = ImageFont.load_default()
draw.text((10, 10), "A. REFERENCE (2.jpeg, native {})".format(ref_img.size), fill=(20, 20, 20), font=font)
draw.text((ref_w + 10, 10), "B. OUR RENDER (data/user_levels/2.json)", fill=(20, 20, 20), font=font)
draw.text((10, ref_h + 10), "C. 50% OVERLAY", fill=(20, 20, 20), font=font)
draw.text((ref_w + 10, ref_h + 10), "D. PIXEL DIFF (4x amplified)", fill=(20, 20, 20), font=font)

panel.save(OUT_PANEL)
print(f"Saved 4-tile panel to {OUT_PANEL}")

# ---- Measurements report ----
measurements = json.load(open(MEASUREMENTS, encoding="utf-8"))
report = {
    "reference_image": str(REF),
    "reference_size": [ref_w, ref_h],
    "authored_json": str(USER_JSON),
    "pieces": [],
    "links": [],
}

def s(piece_id, p):
    cx, cy = p["x"], p["y"]
    r = p.get("radius", 80)
    return {"id": piece_id, "x": cx, "y": cy, "radius": r, "thickness": p.get("thickness", 22),
            "color": p.get("color_name"), "gaps": p.get("gaps", []), "start_angle_deg": p.get("start_angle_deg", 0)}

for p in pieces:
    report["pieces"].append(s(p["id"], p))
for l in links:
    report["links"].append(l)

# Per-piece reference vs our error
def find_ref(comp_name, color_name):
    """Return a per-color reference dict computed from the COMBINED bounding
    box of all major components of that color. Using only the largest component
    gives a biased y-center when the C-ring has a gap; combining all large
    components (top + bottom arcs) gives a stable center.
    """
    bigs = [c for c in measurements.get(color_name, []) if c["area"] > 800]
    if not bigs:
        return None
    x0 = min(c["x0"] for c in bigs)
    y0 = min(c["y0"] for c in bigs)
    x1 = max(c["x1"] for c in bigs)
    y1 = max(c["y1"] for c in bigs)
    return {
        "x0": x0, "y0": y0, "x1": x1, "y1": y1,
        "cx": (x0 + x1) * 0.5, "cy": (y0 + y1) * 0.5,
        "w": x1 - x0 + 1, "h": y1 - y0 + 1,
        "area": sum(c["area"] for c in bigs),
    }

color_map = {
    "ring_orange": "orange",
    "ring_cyan": "cyan",
    "ring_purple": "purple",
}
errors = []
for piece in pieces:
    color_name = color_map.get(piece["id"], None)
    if not color_name: continue
    ref = find_ref(None, color_name)
    if not ref: continue
    our_cx, our_cy = piece["x"], piece["y"]
    our_r = piece["radius"]
    # Reference bbox: width and height give diameter. Radius = max/2.
    ref_dx = ref["w"] / 2
    ref_dy = ref["h"] / 2
    ref_r = max(ref_dx, ref_dy)  # the gap-facing side shrinks
    # Reference image is 685x1170; our authored coordinates are in 720x1280.
    # Scale reference center and radius to viewport coords for an apples-to-apples
    # comparison. (Both ring_piece_2d and connector rendering work in viewport
    # pixels, not reference pixels.)
    sx = 720.0 / 685.0
    sy = 1280.0 / 1170.0
    ref_cx = ref["cx"] * sx
    ref_cy = ref["cy"] * sy
    ref_r_scaled = ref_r * ((sx + sy) * 0.5)
    err_x = our_cx - ref_cx
    err_y = our_cy - ref_cy
    err_r = our_r - ref_r_scaled
    errors.append({
        "id": piece["id"],
        "ref_center_viewport": [round(ref_cx, 1), round(ref_cy, 1)],
        "our_center": [our_cx, our_cy],
        "err_center_px": [round(err_x, 2), round(err_y, 2)],
        "ref_radius_viewport": round(ref_r_scaled, 1),
        "our_radius": our_r,
        "err_radius_px": round(err_r, 2),
    })

report["per_piece_errors"] = errors
with open(OUT_REPORT, "w", encoding="utf-8") as f:
    json.dump(report, f, indent=2)
print(f"Saved measurements report to {OUT_REPORT}")

print()
print("=== Per-piece center/radius errors (level 2) ===")
for e in errors:
    print(f"  {e['id']:12s}  err_x={e['err_center_px'][0]:+6.1f}  err_y={e['err_center_px'][1]:+6.1f}  err_r={e['err_radius_px']:+5.1f}")
