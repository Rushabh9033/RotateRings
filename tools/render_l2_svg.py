"""
render_l2_svg.py — Phase 11 final.

Loads data/user_levels/2.json (the converted rings-clips L2), draws:
  - each ring (piece) as an SVG arc path with the calculated gap removed
  - each link (clip) as a connector arm using the corrected stem_length
    and collar_angle_deg

Output: tools/analyzer_outputs/level_2_rendered.svg

Run:
  python tools/render_l2_svg.py [level_id]
  defaults to level_id=2.
"""
import os
import sys
import math
import json


LEVEL_PATH_TEMPLATE = "data/user_levels/{n}.json"
OUTPUT_DIR = "tools/analyzer_outputs"


def _arc_path(cx: float, cy: float, r: float, gap_center_deg: float,
              gap_width_deg: float, thickness: float, samples: int = 64) -> str:
    """Build an SVG path for a ring with a gap.

    Returns a path that draws the ring body (outer arc minus the gap
    wedge) using two cubic-Bezier-approximated arcs.
    """
    # The ring body is the annulus between (r - thickness/2) and (r + thickness/2).
    # We approximate the annulus as a stroked arc on the centerline radius.
    gap_half = gap_width_deg / 2.0
    start_deg = gap_center_deg + gap_half  # draw from this angle clockwise
    end_deg = gap_center_deg + 360.0 - gap_half
    # Build arc as a series of small line segments for portability.
    pts_outer = []
    pts_inner = []
    n = max(16, int(samples * (360.0 - gap_width_deg) / 360.0))
    for i in range(n + 1):
        ang = start_deg + (end_deg - start_deg) * i / n
        rad = math.radians(ang)
        pts_outer.append((cx + r * math.cos(rad), cy + r * math.sin(rad)))
    for i in range(n + 1):
        ang = end_deg - (end_deg - start_deg) * i / n
        rad = math.radians(ang)
        pts_inner.append((cx + (r - thickness) * math.cos(rad),
                          cy + (r - thickness) * math.sin(rad)))
    # Build a single closed path: outer arc forward, inner arc reverse.
    cmds = []
    cmds.append(f"M {pts_outer[0][0]:.2f} {pts_outer[0][1]:.2f}")
    for p in pts_outer[1:]:
        cmds.append(f"L {p[0]:.2f} {p[1]:.2f}")
    for p in pts_inner:
        cmds.append(f"L {p[0]:.2f} {p[1]:.2f}")
    cmds.append("Z")
    return " ".join(cmds)


def _stem_endpoints(piece: dict, link: dict) -> tuple:
    """Compute (parent_end, child_end) for a connector arm.

    The arm starts at the parent's edge along the collar angle, extends
    outward by stem_length, then reaches the child's edge along the
    return angle.
    """
    pcx = piece["x"]; pcy = piece["y"]; pr = piece["radius"]
    collar = link["collar_angle_deg"]
    # Parent edge: along collar angle, just outside the parent's radius.
    rad = math.radians(collar)
    parent_edge = (pcx + pr * math.cos(rad),
                   pcy + pr * math.sin(rad))
    # Child end: the link's "to" piece (look it up via from_id / to_id).
    return parent_edge, collar


def _find_piece(pieces, pid):
    for p in pieces:
        if p["id"] == pid:
            return p
    return None


def render_level(level_id: int = 2) -> str:
    """Render level_id JSON to SVG. Returns the output path."""
    json_path = LEVEL_PATH_TEMPLATE.format(n=level_id)
    if not os.path.exists(json_path):
        raise FileNotFoundError(f"Level JSON not found: {json_path}")
    with open(json_path) as f:
        data = json.load(f)

    pieces = data.get("pieces", [])
    links = data.get("links", [])

    # Compute bounding box (with 60 px padding).
    if not pieces:
        raise ValueError("No pieces in level JSON.")
    xs = [p["x"] - p["radius"] - 30 for p in pieces]
    ys = [p["y"] - p["radius"] - 30 for p in pieces]
    xs2 = [p["x"] + p["radius"] + 30 for p in pieces]
    ys2 = [p["y"] + p["radius"] + 30 for p in pieces]
    min_x, min_y = min(xs), min(ys)
    max_x, max_y = max(xs2), max(ys2)
    width = max_x - min_x
    height = max_y - min_y

    svg_parts = []
    svg_parts.append(
        f'<svg xmlns="http://www.w3.org/2000/svg" '
        f'viewBox="{min_x:.1f} {min_y:.1f} {width:.1f} {height:.1f}" '
        f'width="{width:.1f}" height="{height:.1f}">')
    svg_parts.append(
        f'  <title>Level {level_id} - {data.get("title", "")}</title>')
    svg_parts.append(
        '  <rect x="{:.1f}" y="{:.1f}" width="{:.1f}" height="{:.1f}" '
        'fill="#FAF6EF"/>'.format(min_x, min_y, width, height))

    # Draw links FIRST (so rings cover the inner ends of stems).
    for link in links:
        parent = _find_piece(pieces, link["from_id"])
        child = _find_piece(pieces, link["to_id"])
        if parent is None or child is None:
            continue
        # Compute geometry.
        collar = link["collar_angle_deg"]
        stem_len = link["stem_length"]
        # Use the runtime-measured stem_dist for the visible cuff position;
        # the engine places the cuff at distance stem_dist along the
        # parent's outward direction, with the child meeting it.
        cuff_dist = link.get("stem_dist", stem_len / 2.0)
        rad = math.radians(collar)
        pcx = parent["x"]; pcy = parent["y"]
        # Cuff center: along the collar direction, distance cuff_dist
        # from the parent's center.
        cuff_cx = pcx + cuff_dist * math.cos(rad)
        cuff_cy = pcy + cuff_dist * math.sin(rad)
        # Parent edge endpoint.
        pe_x = pcx + parent["radius"] * math.cos(rad)
        pe_y = pcy + parent["radius"] * math.sin(rad)
        # Draw the arm (stem) as a line from parent edge to cuff.
        svg_parts.append(
            f'  <line x1="{pe_x:.2f}" y1="{pe_y:.2f}" '
            f'x2="{cuff_cx:.2f}" y2="{cuff_cy:.2f}" '
            f'stroke="#1F5A82" stroke-width="{link["stem_width"]}" '
            f'stroke-linecap="round"/>')
        # Draw the cuff as a small rectangle centered on the cuff,
        # rotated by collar_angle.
        cuff_w = link["cuff_width"]
        cuff_d = link["cuff_depth"]
        svg_parts.append(
            f'  <g transform="translate({cuff_cx:.2f},{cuff_cy:.2f}) '
            f'rotate({collar:.2f})">')
        svg_parts.append(
            f'    <rect x="{-cuff_w/2:.2f}" y="{-cuff_d/2:.2f}" '
            f'width="{cuff_w:.2f}" height="{cuff_d:.2f}" '
            f'rx="{link["cuff_round_radius"]:.2f}" '
            f'fill="#1F5A82" stroke="#0F3A5A" stroke-width="1"/>')
        svg_parts.append('  </g>')

    # Draw rings (pieces).
    for piece in pieces:
        cx = piece["x"]; cy = piece["y"]; r = piece["radius"]
        thickness = piece["thickness"]
        color = piece["color_hex"]
        gaps = piece.get("gaps", [])
        if not gaps:
            # Closed ring: full annulus, no gap.
            svg_parts.append(
                f'  <circle cx="{cx:.2f}" cy="{cy:.2f}" r="{r:.2f}" '
                f'fill="none" stroke="{color}" stroke-width="{thickness:.1f}"/>')
            continue
        gap = gaps[0]
        path = _arc_path(cx, cy, r, gap["center_angle_deg"],
                         gap["width_deg"], thickness)
        svg_parts.append(
            f'  <path d="{path}" fill="{color}" stroke="none"/>')

    svg_parts.append('</svg>')
    svg = "\n".join(svg_parts)

    os.makedirs(OUTPUT_DIR, exist_ok=True)
    out_path = os.path.join(OUTPUT_DIR, f"level_{level_id}_rendered.svg")
    with open(out_path, "w") as f:
        f.write(svg)
    return out_path


def main():
    level_id = int(sys.argv[1]) if len(sys.argv) > 1 else 2
    out = render_level(level_id)
    print(f"Rendered Level {level_id} -> {out}")
    print(f"  size: {os.path.getsize(out)} bytes")


if __name__ == "__main__":
    main()