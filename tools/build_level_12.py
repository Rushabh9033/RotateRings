import json
import numpy as np

# Coordinates mapping: 685x1170 -> 720x1280
S = 1.051
ref_cx = 342.5
ref_cy = 570.0
target_cx = 360.0
target_cy = 570.0

def to_godot(rx, ry):
    gx = round((rx - ref_cx) * S + target_cx, 1)
    gy = round((ry - ref_cy) * S + target_cy, 1)
    return gx, gy

rings_data = [
    {
        "id": "cyan_top_left",
        "color_name": "cyan",
        "color_hex": "#32ADDA",
        "rx": 179.7, "ry": 432.1,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 325.0, "width_deg": 100.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "blue_top_mid",
        "color_name": "blue",
        "color_hex": "#2F80ED",
        "rx": 359.5, "ry": 410.0,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 245.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_top_right",
        "color_name": "green",
        "color_hex": "#27AE60",
        "rx": 511.1, "ry": 479.4,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 30.0, "width_deg": 100.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "green_mid_left",
        "color_name": "green",
        "color_hex": "#27AE60",
        "rx": 252.0, "ry": 592.1,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 325.0, "width_deg": 90.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "cyan_mid_right",
        "color_name": "cyan",
        "color_hex": "#32ADDA",
        "rx": 415.1, "ry": 614.7,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 215.0, "width_deg": 105.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "cyan_bot_left",
        "color_name": "cyan",
        "color_hex": "#32ADDA",
        "rx": 221.3, "ry": 750.4,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 110.0, "tolerance_deg": 16.0}]
    },
    {
        "id": "orange_bot_right",
        "color_name": "orange",
        "color_hex": "#EA7829",
        "rx": 458.1, "ry": 781.5,
        "radius": 60.0,
        "role": 0,
        "release_direction": {"x": 1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 170.0, "width_deg": 110.0, "tolerance_deg": 16.0}]
    }
]

# 4 Sliders:
sliders_data = [
    {
        "id": "orange_slider_tl",
        "color_name": "orange",
        "color_hex": "#EA7829",
        "p_start": (174.0, 445.0), # bottom-left tip inside cyan_top_left opening
        "p_end": (275.0, 343.0),   # top-right tip with safe 32px clearance to red slider
        "axis": {"x": 0.707, "y": -0.707}, # slides up-right
        "slide_max": 80.0,
        "sleeve": (235.1, 385.9)
    },
    {
        "id": "red_slider_top",
        "color_name": "red",
        "color_hex": "#E63946",
        "p_start": (360.0, 410.0), # bottom-right tip inside blue_top_mid opening
        "p_end": (281.0, 266.0),   # top-left tip
        "axis": {"x": -0.480, "y": -0.877}, # slides up-left
        "slide_max": 80.0,
        "sleeve": (325.6, 347.1)
    },
    {
        "id": "blue_slider_mid",
        "color_name": "blue",
        "color_hex": "#2F80ED",
        "p_start": (249.0, 572.0), # bottom-left tip inside green_mid_left opening
        "p_end": (375.0, 538.0),   # top-right tip tilted at -15.3 deg
        "axis": {"x": 0.965, "y": -0.263}, # slides up-right along true tilt
        "slide_max": 60.0,
        "sleeve": (312.2, 555.2)
    },
    {
        "id": "purple_slider_bot",
        "color_name": "purple",
        "color_hex": "#7B61FF",
        "p_start": (300.0, 766.8), # left tip
        "p_end": (469.0, 781.8),   # right tip entering opening of orange_bot_right
        "axis": {"x": 0.996, "y": 0.088}, # slides rightward with slight natural tilt
        "slide_max": 70.0,
        "sleeve": (384.6, 774.3)
    }
]

pieces = []
for r in rings_data:
    gx, gy = to_godot(r["rx"], r["ry"])
    pieces.append({
        "id": r["id"],
        "color_name": r["color_name"],
        "color_hex": r["color_hex"],
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
    gx1, gy1 = to_godot(s["p_start"][0], s["p_start"][1])
    gx2, gy2 = to_godot(s["p_end"][0], s["p_end"][1])
    dx = round(gx2 - gx1, 1)
    dy = round(gy2 - gy1, 1)
    sl_gx, sl_gy = to_godot(s["sleeve"][0], s["sleeve"][1])
    pieces.append({
        "id": s["id"],
        "color_name": s["color_name"],
        "color_hex": s["color_hex"],
        "x": gx1,
        "y": gy1,
        "start_angle_deg": 0.0,
        "radius": 60.0,
        "radius_y": 60.0,
        "thickness": 20.0,
        "shape_type": 5, # PATH
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
        "path_points": [
            {"x": 0.0, "y": 0.0},
            {"x": dx, "y": dy}
        ],
        "sleeves": [
            {
                "x": sl_gx,
                "y": sl_gy,
                "axis": s["axis"]
            }
        ],
        "gaps": []
    })

links_def = [
    ("cyan_top_left", "green_mid_left", "cyan", "#32ADDA"),
    ("green_mid_left", "cyan_bot_left", "green", "#27AE60"),
    ("blue_top_mid", "green_top_right", "blue", "#2F80ED"),
    ("green_top_right", "cyan_mid_right", "green", "#27AE60"),
    ("cyan_mid_right", "orange_bot_right", "cyan", "#32ADDA")
]

godot_pos = {p["id"]: (p["x"], p["y"]) for p in pieces if p["shape_type"] == 0}

links = []
for p1, p2, col_name, col_hex in links_def:
    x1, y1 = godot_pos[p1]
    x2, y2 = godot_pos[p2]
    d = np.hypot(x2 - x1, y2 - y1)
    ang = np.degrees(np.arctan2(y2 - y1, x2 - x1)) % 360
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

level_12 = {
    "id": 12,
    "title": "Level 12",
    "instruction": "",
    "par_moves": 11,
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

with open("data/user_levels/12.json", "w") as f:
    json.dump(level_12, f, indent=2)

print("Generated data/user_levels/12.json successfully!")
