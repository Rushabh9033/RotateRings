import json
import numpy as np

# Coordinates mapping from 16.jpeg (685x1170) to Godot (720x1280)
def to_godot(rx, ry, img_w=685, img_h=1170):
    gx = (rx / img_w) * 720.0
    gy = (ry / img_h) * 1280.0
    return round(gx, 1), round(gy, 1)

COLORS = {
    "orange": {"name": "orange", "hex": "#EA7829"},
    "green":  {"name": "green",  "hex": "#27AE60"},
    "purple": {"name": "purple", "hex": "#7B61FF"},
    "blue":   {"name": "blue",   "hex": "#2F80ED"},
    "cyan":   {"name": "cyan",   "hex": "#32ADDA"},
    "red":    {"name": "red",    "hex": "#E63946"},
}

# 13 Rings in 16.jpeg:
rings_data = [
    # Center Root Anchor Hub:
    {
        "id": "red_center_hub",
        "color_name": "red",
        "rx": 333.0, "ry": 605.0,
        "radius": 52.0,
        "role": 1, # ROOT ANCHOR
        "piece_type": 0, # CLOSED CIRCLE
        "release_direction": {"x": 0.0, "y": 0.0},
        "gaps": []
    },
    # Top Branch:
    {
        "id": "orange_top",
        "color_name": "orange",
        "rx": 346.0, "ry": 218.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "blue_mid_top_left",
        "color_name": "blue",
        "rx": 222.0, "ry": 298.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "purple_mid_top_right",
        "color_name": "purple",
        "rx": 460.0, "ry": 304.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 300.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_upper_left",
        "color_name": "green",
        "rx": 257.0, "ry": 449.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 330.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_upper_right",
        "color_name": "green",
        "rx": 426.0, "ry": 450.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 210.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    # Left Branch:
    {
        "id": "green_mid_left",
        "color_name": "green",
        "rx": 182.0, "ry": 563.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "purple_lower_left",
        "color_name": "purple",
        "rx": 218.0, "ry": 719.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 40.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_bot_left",
        "color_name": "green",
        "rx": 176.0, "ry": 878.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": -1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    # Bottom Center:
    {
        "id": "orange_bot_mid",
        "color_name": "orange",
        "rx": 335.0, "ry": 803.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 85.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    # Right Branch:
    {
        "id": "cyan_mid_right",
        "color_name": "cyan",
        "rx": 502.0, "ry": 564.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "orange_lower_right",
        "color_name": "orange",
        "rx": 457.0, "ry": 734.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 230.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "blue_bot_right",
        "color_name": "blue",
        "rx": 496.0, "ry": 884.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    }
]

pieces = []
godot_pos = {}

for r in rings_data:
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
        "thickness": 20.0,
        "shape_type": 0,
        "piece_type": r["piece_type"],
        "role": r["role"],
        "z_index": 1,
        "initially_locked": False,
        "locked": False,
        "property_locks": {},
        "release_direction": r["release_direction"],
        "target_exit_angle_deg": 0.0,
        "motion_model": 0,
        "gaps": r["gaps"]
    })

# Links:
# 6 radial links from hub:
# red_center_hub -> green_upper_left
# red_center_hub -> green_upper_right
# red_center_hub -> cyan_mid_right
# red_center_hub -> orange_bot_mid
# red_center_hub -> purple_lower_left
# red_center_hub -> green_mid_left
# Top tree:
# blue_mid_top_left -> green_upper_left
# blue_mid_top_left -> orange_top
# orange_top -> purple_mid_top_right
# green_upper_right -> purple_mid_top_right
# Left tree:
# purple_lower_left -> green_mid_left
# purple_lower_left -> green_bot_left
# orange_bot_mid -> green_bot_left
# Right tree:
# cyan_mid_right -> orange_lower_right
# blue_bot_right -> orange_lower_right
# blue_bot_right -> orange_bot_mid

links_def = [
    # 6 hub arms:
    ("red_center_hub", "green_upper_left"),
    ("red_center_hub", "green_upper_right"),
    ("red_center_hub", "cyan_mid_right"),
    ("red_center_hub", "orange_bot_mid"),
    ("red_center_hub", "purple_lower_left"),
    ("red_center_hub", "green_mid_left"),
    # Top tree:
    ("blue_mid_top_left", "green_upper_left"),
    ("blue_mid_top_left", "orange_top"),
    ("orange_top", "purple_mid_top_right"),
    ("green_upper_right", "purple_mid_top_right"),
    # Left tree:
    ("purple_lower_left", "green_mid_left"),
    ("purple_lower_left", "green_bot_left"),
    ("orange_bot_mid", "green_bot_left"),
    # Right tree:
    ("cyan_mid_right", "orange_lower_right"),
    ("blue_bot_right", "orange_lower_right"),
    ("blue_bot_right", "orange_bot_mid"),
]

links = []
for p1, p2 in links_def:
    x1, y1 = godot_pos[p1]
    x2, y2 = godot_pos[p2]
    d = np.hypot(x2 - x1, y2 - y1)
    ang = np.degrees(np.arctan2(y2 - y1, x2 - x1)) % 360
    col_name = next(p["color_name"] for p in pieces if p["id"] == p1)
    col_hex = COLORS[col_name]["hex"]
    links.append({
        "id": f"link_{p1}_to_{p2}",
        "from_id": p1,
        "to_id": p2,
        "from_piece_id": p1,
        "to_piece_id": p2,
        "collar_angle_deg": round(ang, 1),
        "stem_dist": round(d, 1),
        "joint_color": col_name,
        "joint_color_name": col_name,
        "joint_color_hex": col_hex
    })

level_16 = {
    "id": 16,
    "title": "Level 16",
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

with open("data/user_levels/16.json", "w") as f:
    json.dump(level_16, f, indent=2)

print("Generated data/user_levels/16.json successfully with 13 rings and 16 links!")
