import json
import math

ref_scale = 1.051094890510949
def to_godot(rx, ry):
    return round(rx * ref_scale, 1), round(ry * ref_scale + 17.0, 1)

centers = {
    'green_top': (340.0, 204.0),
    'orange_r2': (265.0, 335.0),
    'red_r2': (415.0, 335.0),
    'cyan_mid': (340.0, 470.0),
    'purple_mid_left': (200.0, 605.0),
    'blue_center_hub': (340.0, 605.0),
    'orange_mid_right': (480.0, 605.0),
    'green_far_left': (150.0, 795.0),
    'cyan_inner_left': (272.0, 745.0),
    'green_bot_left': (272.0, 870.0),
    'red_inner_right': (408.0, 745.0),
    'purple_bot_right': (408.0, 870.0),
    'blue_far_right': (530.0, 795.0)
}

COLORS = {
    "cyan": {"name": "cyan", "hex": "#2BBBEF"},
    "orange": {"name": "orange", "hex": "#EA7829"},
    "purple": {"name": "purple", "hex": "#9B51E0"},
    "red": {"name": "red", "hex": "#EB5757"},
    "green": {"name": "green", "hex": "#27AE60"},
    "blue": {"name": "blue", "hex": "#2F80ED"},
    "yellow": {"name": "yellow", "hex": "#F2C94C"},
    "teal": {"name": "teal", "hex": "#009688"}
}

rings = [
    {
        "id": "green_top",
        "color_name": "green",
        "rx": 340.0, "ry": 204.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 135.0, "length": 32.0, "width": 14.0}]
    },
    {
        "id": "orange_r2",
        "color_name": "orange",
        "rx": 265.0, "ry": 335.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 135.0, "length": 32.0, "width": 14.0}]
    },
    {
        "id": "red_r2",
        "color_name": "red",
        "rx": 415.0, "ry": 335.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 15.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "cyan_mid",
        "color_name": "cyan",
        "rx": 340.0, "ry": 470.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 0.0, "length": 48.0, "width": 14.0}]
    },
    {
        "id": "blue_center_hub",
        "color_name": "blue",
        "rx": 340.0, "ry": 605.0,
        "radius": 54.0,
        "role": 1, # closed root anchor
        "piece_type": 0,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [],
        "blockers": []
    },
    {
        "id": "purple_mid_left",
        "color_name": "purple",
        "rx": 200.0, "ry": 605.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 135.0, "length": 22.0, "width": 14.0}]
    },
    {
        "id": "orange_mid_right",
        "color_name": "orange",
        "rx": 480.0, "ry": 605.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 45.0, "length": 22.0, "width": 14.0}]
    },
    {
        "id": "green_far_left",
        "color_name": "green",
        "rx": 150.0, "ry": 795.0,
        "radius": 54.0,
        "role": 1, # root anchor for lower-left branch
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "cyan_inner_left",
        "color_name": "cyan",
        "rx": 270.0, "ry": 740.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 90.0, "length": 34.0, "width": 14.0, "is_inward": True}]
    },
    {
        "id": "green_bot_left",
        "color_name": "green",
        "rx": 270.0, "ry": 876.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 135.0, "length": 24.0, "width": 14.0, "is_inward": True}]
    },
    {
        "id": "blue_far_right",
        "color_name": "blue",
        "rx": 530.0, "ry": 795.0,
        "radius": 54.0,
        "role": 1, # root anchor for lower-right branch
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "red_inner_right",
        "color_name": "red",
        "rx": 410.0, "ry": 740.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 90.0, "length": 34.0, "width": 14.0, "is_inward": True}]
    },
    {
        "id": "purple_bot_right",
        "color_name": "purple",
        "rx": 410.0, "ry": 876.0,
        "radius": 54.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 45.0, "length": 24.0, "width": 14.0, "is_inward": True}]
    }
]

# Connectors:
# 1. red_r2 holds green_top
# 2. red_r2 holds orange_r2
# 3. blue_center_hub holds cyan_mid
# 4. blue_center_hub holds purple_mid_left
# 5. blue_center_hub holds orange_mid_right
# 6. green_far_left holds cyan_inner_left
# 7. green_far_left holds green_bot_left
# 8. blue_far_right holds red_inner_right
# 9. blue_far_right holds purple_bot_right
connectors = [
    {"parent_id": "red_r2", "child_id": "green_top"},
    {"parent_id": "red_r2", "child_id": "orange_r2"},
    {"parent_id": "blue_center_hub", "child_id": "cyan_mid"},
    {"parent_id": "blue_center_hub", "child_id": "purple_mid_left"},
    {"parent_id": "blue_center_hub", "child_id": "orange_mid_right"},
    {"parent_id": "green_far_left", "child_id": "cyan_inner_left"},
    {"parent_id": "green_far_left", "child_id": "green_bot_left"},
    {"parent_id": "blue_far_right", "child_id": "red_inner_right"},
    {"parent_id": "blue_far_right", "child_id": "purple_bot_right"},
]

pieces = []
godot_pos = {}
for r in rings:
    gx, gy = to_godot(r["rx"], r["ry"])
    godot_pos[r["id"]] = (gx, gy)
    pieces.append({
        "id": r["id"],
        "color_name": r["color_name"],
        "color_hex": COLORS[r["color_name"]]["hex"],
        "x": gx,
        "y": gy,
        "start_angle_deg": 0.0,
        "radius": r["radius"],
        "radius_y": r["radius"],
        "thickness": 18.0,
        "shape_type": 0,
        "role": r["role"],
        "piece_type": r["piece_type"],
        "has_acorn": r.get("has_acorn", False),
        "acorn_color_hex": "#F2C94C",
        "release_direction": r["release_direction"],
        "gaps": r["gaps"],
        "blockers": r.get("blockers", [])
    })

links = []
for c in connectors:
    pid = c["parent_id"]
    cid = c["child_id"]
    px, py = godot_pos[pid]
    cx, cy = godot_pos[cid]
    dx = cx - px
    dy = cy - py
    d = math.hypot(dx, dy)
    parent_ang = math.degrees(math.atan2(dy, dx)) % 360.0
    col_name = next(p["color_name"] for p in pieces if p["id"] == pid)
    col_hex = COLORS[col_name]["hex"]

    links.append({
        "id": f"link_{pid}_to_{cid}",
        "from_id": pid,
        "to_id": cid,
        "from_piece_id": pid,
        "to_piece_id": cid,
        "collar_angle_deg": round(parent_ang, 1),
        "stem_dist": round(d, 1),
        "joint_color": col_name,
        "joint_color_name": col_name,
        "joint_color_hex": col_hex
    })

level_17_data = {
    "id": 17,
    "title": "Level 17",
    "instruction": "",
    "par_moves": 16,
    "theme_id": "porcelain",
    "frame_scale": 1.0,
    "frame_offset_x": 0.0,
    "frame_offset_y": 0.0,
    "frame_anchor": "auto",
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
    "links": links
}

with open("data/user_levels/17.json", "w", encoding="utf-8") as f:
    json.dump(level_17_data, f, indent=2)

print("Generated data/user_levels/17.json successfully!")
