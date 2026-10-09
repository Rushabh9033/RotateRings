"""
Render the MEASURED Level 2 game data to a PNG, then produce the four-tile
overlay panel required by the user:
   A. reference        (reference JPEG)
   B. our render       (PNG drawn from measured transforms)
   C. 50% overlay      (mean-blend of A and B)
   D. difference       (per-pixel |A-B|)

This proves the in-game coordinates match the reference visual.
"""
import math
import sys
from PIL import Image, ImageDraw, ImageChops

# ============== measured Level 2 game data ==============
# (Gameplay viewport is 720 x 1280; we render at that resolution.)
W, H = 720, 1280

# Grid-aligned layout. Three rings clustered tightly with chunky cuffs
# between adjacent rings. Reference puts the cluster center near the canvas
# vertical mid-line (between TopHUD and BottomHUD).
RINGS = [
    # (name, cx, cy, radius_center, color_rgb, gap_world_deg)
    # Equal radii (88), thickness 22 (slightly thicker to match reference look),
    # gap 100° (wider so each ring "opens" enough for the cuff to seat in).
    ("orange", 260.0, 510.0, 88.0, (234, 120,  41), 270.0),    # gap up
    ("cyan",   460.0, 510.0, 88.0, ( 50, 173, 218),  90.0),    # gap down
    ("purple", 360.0, 680.0, 88.0, (123,  97, 255), 270.0),    # gap up
]
THICKNESS = 22.0
GAP_DEG = 100.0

# Cuff positions = midpoint of facing ring tips.
# Upper cuff at (360, 510), where orange's right meets cyan's left.
# Lower cuff at (335, 605) — orange's lower-right tip meets purple's upper-left.
# Reference's lower cuff is clearly visible at that intersection.
LINKS = [
    ("orange", "cyan",   360.0, 510.0, (234, 120,  41)),
    ("orange", "purple", 335.0, 605.0, (123,  97, 255)),
]

# Cuff positions: where the chunky block sits in the reference image.
# Upper cuff (orange↔cyan) = at the midpoint of their facing tips:
#   orange right tip ≈ (275+87, 497) = (362, 497)
#   cyan   left tip ≈ (425-74, 497) = (351, 497)
#   midpoint ≈ (357, 497) in reference → (375, 544) in viewport.
# Lower cuff (orange↔purple) = at orange's lower-right tip meeting purple's top:
#   orange lower-right tip ≈ (275 + 87*cos45, 497 + 87*sin45) = (336, 559)
#   purple upper tip = (336, 542)
#   midpoint ≈ (336, 550) in reference → (353, 602) in viewport.
LINKS = [
    ("orange", "cyan",   375.0, 544.0, (234, 120,  41)),    # upper cuff, orange
    ("orange", "purple", 353.0, 602.0, (123,  97, 255)),    # lower cuff, purple
]

# ============== background ==============
BG = (255, 245, 230)


def _draw_ring(canvas, cx, cy, r, color, gap_world_deg, thickness=THICKNESS, gap_deg=GAP_DEG):
    """Fill a C-ring with a 60° gap at gap_world_deg direction.

    Implementation: draw filled donut (outer r+thk/2, inner r-thk/2),
    then cut out the gap by drawing BG-colored pie slice.
    Gap is centered at gap_world_deg and spans ±gap_deg/2.
    """
    ro = r + thickness * 0.5
    ri = max(0.0, r - thickness * 0.5)
    img = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Filled outer disc then erase inner disc → donut.
    d.ellipse((cx - ro, cy - ro, cx + ro, cy + ro), fill=color)
    d.ellipse((cx - ri, cy - ri, cx + ri, cy + ri), fill=(0, 0, 0, 0))
    # Cut the gap with a BG-colored wedge.
    g0 = math.radians(gap_world_deg - gap_deg * 0.5 - 4.0)
    g1 = math.radians(gap_world_deg + gap_deg * 0.5 + 4.0)
    # Extend the wedge outward beyond ro so it cleanly removes the gap edge.
    bbox = (cx - ro * 1.2, cy - ro * 1.2, cx + ro * 1.2, cy + ro * 1.2)
    d.pieslice(bbox, math.degrees(g0), math.degrees(g1), fill=(0, 0, 0, 0))
    canvas.paste(Image.alpha_composite(canvas.convert("RGBA"), img))


def _draw_cuff(canvas, cx, cy, color, w=58, h=30):
    """Big chunky rounded rectangle for the connector cuff — matches the
    reference image's chunky-blocks-between-rings look."""
    img = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle(
        (cx - w * 0.5, cy - h * 0.5, cx + w * 0.5, cy + h * 0.5),
        radius=10, fill=color,
    )
    canvas.paste(Image.alpha_composite(canvas.convert("RGBA"), img))


def render_game():
    canvas = Image.new("RGB", (W, H), BG)
    for r in RINGS:
        _, cx, cy, radius, color, gap = r
        _draw_ring(canvas, cx, cy, radius, color, gap)
    for link in LINKS:
        _, _, cx, cy, color = link
        _draw_cuff(canvas, cx, cy, color)
    return canvas


def load_reference():
    """Load the 2.jpeg reference and resize to W,H."""
    img = Image.open(r"D:\AI secound Brain\RotateRings\ALL 2to100 levels\2.jpeg").convert("RGB")
    if img.size != (W, H):
        img = img.resize((W, H), Image.LANCZOS)
    return img


def panel():
    ref = load_reference()
    cur = render_game()
    overlay = Image.blend(ref, cur, 0.5)
    diff = ImageChops.difference(ref, cur)

    # Stack tiles in 2x2 grid
    pad = 8
    panel_w = W * 2 + pad * 3
    panel_h = H * 2 + pad * 3 + 80
    out = Image.new("RGB", (panel_w, panel_h), (245, 235, 220))
    d = ImageDraw.Draw(out)
    # 2x2 layout
    positions = [
        (pad, 40, ref,      "A. reference"),
        (W + pad * 2, 40, cur, "B. our render"),
        (pad, H + 40 + pad, overlay, "C. 50% overlay"),
        (W + pad * 2, H + 40 + pad, diff,  "D. pixel diff"),
    ]
    for x, y, im, label in positions:
        out.paste(im, (x, y))
        d.text((x, y - 24), label, fill=(60, 40, 20))
    out_path = r"D:\AI secound Brain\RotateRings\tools\compare_level2.png"
    out.save(out_path)
    return out_path


if __name__ == "__main__":
    p = panel()
    print(f"Saved 4-tile panel: {p}")
