"""
level_author.py — consume ReferenceAnalyzer targets, write JSON.

The author does NOT re-measure the reference. It only:
  - picks a parent per cuff from the analyzer's per-cuff piece hint
  - converts cuff global (cx, cy) into the source piece's local frame
  - computes the stem geometry (cuff center → to-piece attachment)
  - writes the calibrated LevelDocument JSON

Topology rule (#10): the analyzer's `piece_id_hint` on each cuff
tells us which ring the cuff connects from. The first ring (in the
order analyzer emits them) is the default parent; explicit override
is possible but the analyzer is the source of truth for which cuff
goes with which piece.
"""
import os
import json
import math
from dataclasses import asdict
from reference_analyzer import ReferenceAnalyzer, LevelTarget

LEVELS_DIR = r"D:\AI secound Brain\RotateRings\data\user_levels"


def _cuff_to_piece_frame(cuff_cx, cuff_cy, from_cx, from_cy, from_start):
    """Convert a cuff's global canonical position to the from-piece's
    local frame. The local frame is rotated by -from_start around the
    from-piece center. Returns (local_x, local_y)."""
    dx = cuff_cx - from_cx
    dy = cuff_cy - from_cy
    rad = math.radians(-from_start)
    cs, sn = math.cos(rad), math.sin(rad)
    return (dx * cs - dy * sn, dx * sn + dy * cs)


def _stem_endpoint_geometry(from_cx, from_cy, cuff_cx, cuff_cy,
                            from_radius, from_orientation_deg,
                            cuff_width, cuff_height):
    """Compute the stem geometry: the from-piece's source attachment
    point and the cuff's far endpoint.

    from_radius = ring centerline radius
    from_orientation_deg = ring's start_angle_deg (the direction the
        cuff extends from in the local frame)
    cuff_width = cuff extent along its primary axis
    cuff_height = cuff extent perpendicular to its primary axis

    Source attachment = from_center + from_radius * (cos(start), sin(start))
    Stem endpoint = cuff_center + (cuff_height/2) * (cos(perp), sin(perp))
        where perp is perpendicular to the cuff's primary axis.
    """
    sr = math.radians(from_orientation_deg)
    src_x = from_cx + from_radius * math.cos(sr)
    src_y = from_cy + from_radius * math.sin(sr)
    # The cuff's primary axis is from_orientation_deg. The stem
    # direction (perpendicular to the cuff) goes from cuff back
    # toward the source. The cuff's "depth" is along the primary
    # axis; the "width" is perpendicular.
    perp = math.radians(from_orientation_deg + 90.0)
    end_x = cuff_cx - (cuff_width / 2.0) * math.cos(perp)
    end_y = cuff_cy - (cuff_width / 2.0) * math.sin(perp)
    return src_x, src_y, end_x, end_y


def author_level(level_id: int, target: LevelTarget, dry_run=False):
    """Consume the analyzer's LevelTarget and write a calibrated
    LevelDocument JSON. The JSON is the runtime truth; the analyzer
    is the measurement truth; the LevelAuthor bridges them."""
    out_path = os.path.join(LEVELS_DIR, f"{level_id}.json")

    # Refuse to confidently author if any piece's gap is low-confidence
    # (the analyzer flagged it NEEDS REVIEW).
    for p in target.pieces:
        conf = getattr(p.ring, "gap_confidence", 1.0)
        notes = getattr(p.ring, "gap_notes", "")
        if conf < 0.7:
            return {"level": level_id, "ok": False,
                    "error": f"refused: {p.piece_id_hint} gap confidence "
                             f"{conf:.2f} < 0.7 ({notes})"}

    # Default parent: first piece in the analyzer's order. The
    # analyzer's piece order is consistent (orange, cyan, purple),
    # so this is deterministic.
    if not target.pieces:
        return {"level": level_id, "ok": False, "error": "no pieces in target"}
    parent = target.pieces[0]
    parent_id = parent.piece_id_hint
    parent_cx, parent_cy = parent.ring.center_x, parent.ring.center_y
    parent_radius = parent.ring.centerline_radius
    parent_start = 0.0  # default; the ring is at 0° start

    # Map each piece to a piece dict. The authored geometry IS the
    # target geometry (RANSAC fit). We store it directly.
    pieces = []
    for p in target.pieces:
        ring = p.ring
        piece = {
            "id": p.piece_id_hint,
            "color_name": p.color,
            "color_hex": ("#EA7829" if p.color == "orange"
                          else "#32ADDA" if p.color == "cyan"
                          else "#7B61FF"),
            "x": float(ring.center_x),
            "y": float(ring.center_y),
            "start_angle_deg": 0.0,
            "radius": float(ring.centerline_radius),
            "radius_y": float(ring.centerline_radius),
            "thickness": float(ring.thickness),
            "shape_type": 0,
            "piece_type": 1,
            "role": 0,
            "z_index": 1,
            "initially_locked": False,
            "locked": False,
            "property_locks": {},
            "release_direction": {"x": 1.0, "y": 0.0},
            "target_exit_angle_deg": 0.0,
            "motion_model": 0,
            "gaps": [{
                "center_angle_deg": float(ring.gap_center_angle),
                "width_deg": float(ring.gap_width_angle),
                "tolerance_deg": 16.0,
            }],
        }
        pieces.append(piece)

    # Build links from the analyzer's cuff targets. Each cuff is
    # associated with its NEAREST ring as the parent. The cuff's
    # child is the second-nearest ring. This gives a real topology
    # instead of "everything connects to pieces[0]".
    # Collect all cuffs with their parent hint, then re-assign.
    all_cuffs = []  # list of (cuff_target, parent_id_hint)
    for p in target.pieces:
        for ct in p.cuffs:
            all_cuffs.append((ct, p.piece_id_hint))
    # For each cuff, find its nearest ring as parent.
    def _nearest_ring_id(cuff, exclude_id=None):
        best, best_d = None, 1e18
        for q in pieces:
            if q["id"] == exclude_id: continue
            d = math.hypot(q["x"] - cuff.center_x, q["y"] - cuff.center_y)
            if d < best_d:
                best_d, best = d, q["id"]
        return best
    links = []
    link_id = 0
    for ct, hint in all_cuffs:
        parent_id = _nearest_ring_id(ct)
        if parent_id is None: continue
        from_p = next((q for q in pieces if q["id"] == parent_id), None)
        # Find the child as the nearest ring EXCLUDING the parent.
        child_id = _nearest_ring_id(ct, exclude_id=parent_id)
        if child_id is None: continue
        # Compute collar angle + stem geometry from the cuff's
        # measured position, NOT center-to-center.
        # Source attachment: at the ring's local start angle, at
        # centerline radius.
        sr = math.radians(from_p["start_angle_deg"])
        src_x = from_p["x"] + from_p["radius"] * math.cos(sr)
        src_y = from_p["y"] + from_p["radius"] * math.sin(sr)
        # Stem vector from source attachment to cuff center.
        dx = ct.center_x - src_x
        dy = ct.center_y - src_y
        stem_len = math.hypot(dx, dy) or 1.0
        collar = math.fmod(math.degrees(math.atan2(dy, dx))
                          - from_p["start_angle_deg"], 360.0)
        if collar < 0: collar += 360.0
        # Cuff local position relative to the from-piece.
        cuff_local = _cuff_to_piece_frame(
            ct.center_x, ct.center_y,
            from_p["x"], from_p["y"],
            from_p["start_angle_deg"],
        )
        # Cuff dimensions measured by PCA.
        cuff_width = max(ct.width, 4.0)
        cuff_height = max(ct.height, 4.0)
        # Cuff orientation: align primary axis along the stem vector
        # so the cuff's long axis points along the connection.
        cuff_local_orientation = math.degrees(math.atan2(dy, dx)) \
            - from_p["start_angle_deg"]
        link = {
            "id": f"link_{link_id}",
            "from_id": from_p["id"],
            "to_id": child_id,
            "collar_angle_deg": float(collar),
            "cuff_center_local": {
                "x": float(cuff_local[0]),
                "y": float(cuff_local[1]),
            },
            "cuff_orientation_deg": float(cuff_local_orientation),
            "cuff_width": float(cuff_width),
            "cuff_depth": float(cuff_height),
            "cuff_round_radius": max(cuff_width, cuff_height) * 0.15,
            "stem_length": float(stem_len),
            "stem_width": 6.0,
            "stem_distance_from_piece": float(stem_len),
            "stem_dist": float(stem_len),
            "joint_color_hex": "#1F5A82",
            "joint_color_name": "cuff",
            "clearance_tolerance_deg": 16.0,
            "is_detached": False,
            "z_index": 0,
        }
        links.append(link)
        link_id += 1

    # Build the data dict.
    cal = target.calibration
    data = {
        "id": level_id,
        "title": f"Level {level_id}",
        "instruction": "",
        "par_moves": max(1, len(links)),
        "theme_id": "porcelain",
        "frame_anchor": "auto",
        "frame_offset_x": float(cal.canonical_offset_x),
        "frame_offset_y": float(cal.canonical_offset_y),
        "frame_scale": float(cal.uniform_scale),
        "grid_size": 20.0,
        "snap_to_grid": False, "snap_to_piece_centers": False,
        "snap_to_edges": False, "snap_to_guides": False,
        "snap_to_connector_points": False,
        "nudge_step": 1.0, "nudge_shift_multiplier": 10.0, "nudge_alt_multiplier": 0.1,
        "guides": [], "reference_guides": [], "size_links": {}, "locks": {},
        "pieces": pieces, "links": links,
        "source": f"level_author.py from reference_analyzer (L{level_id})",
    }
    if not dry_run:
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    return {"level": level_id, "ok": True,
            "n_pieces": len(pieces), "n_links": len(links)}


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 2:
        print("Usage: python level_author.py <ref_image> [level_id]")
        sys.exit(1)
    ref_path = sys.argv[1]
    level_id = int(sys.argv[2]) if len(sys.argv) > 2 else 0
    analyzer = ReferenceAnalyzer()
    target = analyzer.analyze(ref_path, level_id=level_id)
    r = author_level(level_id, target)
    print(r)
    for line in target.report_lines:
        print(line)