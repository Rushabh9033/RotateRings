import json
import numpy as np

# Coordinates mapping from 15.jpeg (685x1170) to Godot (720x1280)
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

# 10 Rings measured from 15.jpeg:
rings_data = [
    {
        "id": "green_top_left",
        "color_name": "green",
        "rx": 174.2, "ry": 311.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "purple_top",
        "color_name": "purple",
        "rx": 309.4, "ry": 269.1,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 110.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_top_right",
        "color_name": "green",
        "rx": 479.0, "ry": 346.2,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 10.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "purple_mid_right",
        "color_name": "purple",
        "rx": 505.2, "ry": 543.3,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 110.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "red_bot_right",
        "color_name": "red",
        "rx": 475.5, "ry": 763.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "orange_bottom",
        "color_name": "orange",
        "rx": 305.2, "ry": 849.2,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "red_bot_left",
        "color_name": "red",
        "rx": 166.1, "ry": 777.7,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": -1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_mid_left",
        "color_name": "green",
        "rx": 169.0, "ry": 551.6,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "blue_inner",
        "color_name": "blue",
        "rx": 285.5, "ry": 437.0,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 350.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "cyan_inner",
        "color_name": "cyan",
        "rx": 286.3, "ry": 666.2,
        "radius": 60.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    }
]

# Sliders:
# blue_slider: main bar from top-left (306, 277) down-right to (380, 420), then smooth hook to (360, 475)
# orange_slider: main bar from bot-left (320, 800) up-right to (380, 715), then smooth hook to (360, 642)
BLUE_P0 = (323.7, 312.9)
BLUE_AXIS = {"x": -0.53, "y": -0.85}
BLUE_SLEEVE = {"x": 397.0, "y": 442.4, "axis": {"x": -0.53, "y": -0.85}}
BLUE_PTS = [{"x": 0.0, "y": 0.0}, {"x": 3.9, "y": 7.9}, {"x": 7.9, "y": 15.7}, {"x": 12.1, "y": 23.5}, {"x": 16.3, "y": 31.2}, {"x": 20.6, "y": 38.8}, {"x": 25.0, "y": 46.5}, {"x": 29.3, "y": 54.2}, {"x": 33.5, "y": 61.8}, {"x": 37.8, "y": 69.5}, {"x": 42.0, "y": 77.2}, {"x": 46.1, "y": 85.0}, {"x": 50.3, "y": 92.8}, {"x": 54.5, "y": 100.5}, {"x": 59.0, "y": 107.9}, {"x": 63.7, "y": 115.1}, {"x": 68.6, "y": 122.3}, {"x": 73.3, "y": 129.5}, {"x": 77.8, "y": 137.0}, {"x": 82.0, "y": 144.8}, {"x": 85.6, "y": 153.1}, {"x": 88.5, "y": 161.9}, {"x": 89.5, "y": 170.7}, {"x": 87.8, "y": 178.8}, {"x": 83.1, "y": 185.8}, {"x": 76.5, "y": 191.4}, {"x": 68.7, "y": 195.7}, {"x": 61.1, "y": 199.1}]

ORANGE_P0 = (317.3, 901.8)
ORANGE_AXIS = {"x": -0.50, "y": 0.87}
ORANGE_SLEEVE = {"x": 391.0, "y": 773.5, "axis": {"x": -0.50, "y": 0.87}}
ORANGE_PTS = [{"x": 0.0, "y": 0.0}, {"x": 6.2, "y": -10.8}, {"x": 12.4, "y": -21.5}, {"x": 18.5, "y": -32.3}, {"x": 24.7, "y": -43.0}, {"x": 30.9, "y": -53.8}, {"x": 37.1, "y": -64.5}, {"x": 43.2, "y": -75.3}, {"x": 49.4, "y": -86.0}, {"x": 55.6, "y": -96.8}, {"x": 61.8, "y": -107.5}, {"x": 67.9, "y": -118.3}, {"x": 74.1, "y": -129.0}, {"x": 80.3, "y": -139.8}, {"x": 86.5, "y": -150.5}, {"x": 92.6, "y": -161.3}, {"x": 93.9, "y": -163.8}, {"x": 94.7, "y": -166.4}, {"x": 95.3, "y": -169.2}, {"x": 95.4, "y": -172.0}, {"x": 95.2, "y": -174.8}, {"x": 94.6, "y": -177.6}, {"x": 93.6, "y": -180.2}, {"x": 92.3, "y": -182.7}, {"x": 90.7, "y": -185.0}, {"x": 88.8, "y": -187.0}, {"x": 86.6, "y": -188.8}, {"x": 84.2, "y": -190.3}, {"x": 81.7, "y": -191.4}, {"x": 79.0, "y": -192.2}, {"x": 76.2, "y": -192.6}, {"x": 60.3, "y": -194.0}]

sliders_data = [
    {
        "id": "blue_slider",
        "color_name": "blue",
        "color_hex": "#2F80ED",
        "p0": BLUE_P0,
        "axis": BLUE_AXIS,
        "slide_max": 75.0,
        "path_points": BLUE_PTS,
        "sleeve": BLUE_SLEEVE,
        "stem_from": "green_top_right"
    },
    {
        "id": "orange_slider",
        "color_name": "orange",
        "color_hex": "#EA7829",
        "p0": ORANGE_P0,
        "axis": ORANGE_AXIS,
        "slide_max": 75.0,
        "path_points": ORANGE_PTS,
        "sleeve": ORANGE_SLEEVE,
        "stem_from": "red_bot_right"
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
        "piece_type": 1,
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

for s in sliders_data:
    pieces.append({
        "id": s["id"],
        "color_name": s["color_name"],
        "color_hex": s["color_hex"],
        "x": s["p0"][0],
        "y": s["p0"][1],
        "start_angle_deg": 0.0,
        "radius": 60.0,
        "radius_y": 60.0,
        "thickness": 20.0,
        "shape_type": 5, # L_SHAPE
        "piece_type": 0,
        "role": 0,
        "z_index": 2,
        "initially_locked": False,
        "locked": False,
        "property_locks": {},
        "release_direction": s["axis"],
        "target_exit_angle_deg": 0.0,
        "motion_model": 1, # SLIDE
        "motion_axis": s["axis"],
        "slide_min": 0.0,
        "slide_max": s["slide_max"],
        "path_points": s["path_points"],
        "sleeves": [
            {
                "x": s["sleeve"]["x"],
                "y": s["sleeve"]["y"],
                "axis": s["sleeve"]["axis"],
                "stem_from": s["stem_from"]
            }
        ],
        "gaps": []
    })

# Links:
links_def = [
    ("green_top_left", "purple_top"),
    ("blue_inner", "green_top_left"),
    ("green_mid_left", "blue_inner"),
    ("red_bot_left", "green_mid_left"),
    ("red_bot_left", "cyan_inner"),
    ("red_bot_left", "orange_bottom"),
    ("green_top_right", "purple_mid_right"),
    ("red_bot_right", "purple_mid_right"),
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

level_15 = {
    "id": 15,
    "title": "Level 15",
    "instruction": "",
    "par_moves": 12,
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

with open("data/user_levels/15.json", "w") as f:
    json.dump(level_15, f, indent=2)

print("Generated data/user_levels/15.json successfully with updated pixel-perfect coordinates!")
