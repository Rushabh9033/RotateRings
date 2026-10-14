import json
import math

# Reference scale from 685x1170 to Godot 720x1280
# Puzzle region in 18.jpeg is x: 100..620, y: 320..850
# crop_18 offset: x_off = 100, y_off = 320
ref_scale = 1.051094890510949
y_base = 17.0

def to_godot(cx, cy):
    # cx, cy in crop_18 coordinates
    fx = cx + 100.0
    fy = cy + 320.0
    return round(fx * ref_scale, 1), round(fy * ref_scale + y_base, 1)

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

# 10 Rings with exact measured crop centers and gaps
# Center positions in crop_18:
# purple_tl: (166, 84)
# red_tr: (296, 88)
# green_ur: (364, 182)
# blue_r: (426, 280)
# orange_br: (364, 378)
# cyan_bm: (236, 378)
# blue_bl: (102, 376)
# cyan_ml: (38, 280)
# orange_ul: (104, 182)
# orange_center: (232, 248)

rings_spec = [
    {
        "id": "purple_tl",
        "color_name": "purple",
        "cx": 166.0, "cy": 84.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 115.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "red_tr",
        "color_name": "red",
        "cx": 296.0, "cy": 88.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 115.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "green_ur",
        "color_name": "green",
        "cx": 364.0, "cy": 182.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "release_direction": {"x": 1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 135.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 315.0, "length": 24.0, "width": 14.0}]
    },
    {
        "id": "blue_r",
        "color_name": "blue",
        "cx": 426.0, "cy": 280.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 122.3, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "orange_br",
        "color_name": "orange",
        "cx": 364.0, "cy": 378.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 1.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 302.3, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": [{"angle_deg": 135.0, "length": 24.0, "width": 14.0}]
    },
    {
        "id": "cyan_bm",
        "color_name": "cyan",
        "cx": 236.0, "cy": 378.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": 0.0, "y": 1.0},
        "gaps": [{"center_angle_deg": 250.0, "width_deg": 115.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "blue_bl",
        "color_name": "blue",
        "cx": 102.0, "cy": 376.0,
        "radius": 52.0,
        "role": 1, # Root anchor 1 with acorn
        "piece_type": 0,
        "has_acorn": True,
        "release_direction": {"x": -1.0, "y": 1.0},
        "gaps": [],
        "blockers": []
    },
    {
        "id": "cyan_ml",
        "color_name": "cyan",
        "cx": 38.0, "cy": 280.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": 0.0},
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "orange_ul",
        "color_name": "orange",
        "cx": 104.0, "cy": 182.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "release_direction": {"x": -1.0, "y": -1.0},
        "gaps": [{"center_angle_deg": 32.0, "width_deg": 160.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "orange_center",
        "color_name": "orange",
        "cx": 232.0, "cy": 248.0,
        "radius": 52.0,
        "role": 1, # Root anchor 2 with acorn
        "piece_type": 0,
        "has_acorn": True,
        "release_direction": {"x": 0.0, "y": -1.0},
        "gaps": [],
        "blockers": []
    }
]

# 4 Sliders with exact measured paths and sleeves
# 1. Red U-Arch Slider:
# Path starts at (160, 74) in crop
# Up to y=25, across to x=307, then down to (307, 74)
arch_p0 = (160.0, 74.0)
arch_p1 = (160.0, 25.0)
arch_p2 = (307.0, 25.0)
arch_p3 = (307.0, 74.0)

# 2. Purple Slider (pins blue_r and orange_br):
# Starts at (365.6, 375.5) in crop, goes to (424.4, 282.5)
purp_p0 = (365.6, 375.5)
purp_p1 = (424.4, 282.5)

# 3. Green Center Slider:
# Held by orange_center collar at crop (295.7, 184.6)
# Starts at (217.0, 140.0), goes straight along (0.707, 0.707) to bend at (333.0, 244.0), then hooks down-left to (316.0, 270.0)
gc_p0 = (217.0, 140.0)
gc_p1 = (333.0, 244.0)
gc_p2 = (316.0, 270.0)

# 4. Green Hook Slider:
# Sleeve at cyan_bm gap at crop (213, 371)
# Top tip at (112, 181), corner at (91, 208), down to (226, 343), hook to (213, 371)
gh_p0 = (112.0, 181.0)
gh_p1 = (91.0, 208.0)
gh_p2 = (226.0, 343.0)
gh_p3 = (213.0, 371.0)

sliders_spec = [
    {
        "id": "red_arch",
        "color_name": "red",
        "crop_start": arch_p0,
        "crop_path": [arch_p0, arch_p1, arch_p2, arch_p3],
        "axis": {"x": 0.0, "y": -1.0},
        "slide_max": 80.0,
        "sleeves": [
            {"cx": 160.0, "cy": 74.0, "axis": {"x": 0.0, "y": -1.0}, "stem_from": "purple_tl"},
            {"cx": 307.0, "cy": 74.0, "axis": {"x": 0.0, "y": -1.0}, "stem_from": "red_tr"}
        ]
    },
    {
        "id": "purple_slider",
        "color_name": "purple",
        "crop_start": purp_p0,
        "crop_path": [purp_p0, purp_p1],
        "axis": {"x": 0.534, "y": -0.845},
        "slide_max": 90.0,
        "sleeves": [
            {"cx": 395.0, "cy": 329.0, "axis": {"x": 0.534, "y": -0.845}, "stem_from": "blue_r"}
        ]
    },
    {
        "id": "green_slider_center",
        "color_name": "green",
        "crop_start": gc_p0,
        "crop_path": [gc_p0, gc_p1, gc_p2],
        "axis": {"x": -0.707, "y": -0.707},
        "slide_max": 90.0,
        "sleeves": [
            {"cx": 295.7, "cy": 184.6, "axis": {"x": 0.707, "y": 0.707}, "stem_from": "orange_center"}
        ]
    },
    {
        "id": "green_slider_diag",
        "color_name": "green",
        "crop_start": gh_p0,
        "crop_path": [gh_p0, gh_p1, gh_p2, gh_p3],
        "axis": {"x": -0.707, "y": -0.707},
        "slide_max": 95.0,
        "sleeves": [
            {"cx": 213.0, "cy": 371.0, "axis": {"x": 0.707, "y": 0.707}, "stem_from": "cyan_bm"}
        ]
    }
]

# Connectors (Tree links)
# Root anchors: blue_bl, orange_center
# blue_bl -> cyan_bm -> orange_br
# blue_bl -> cyan_ml -> orange_ul -> purple_tl -> red_tr -> green_ur -> blue_r
connectors = [
    {"parent_id": "blue_bl", "child_id": "cyan_bm"},
    {"parent_id": "cyan_bm", "child_id": "orange_br"},
    {"parent_id": "blue_bl", "child_id": "cyan_ml"},
    {"parent_id": "cyan_ml", "child_id": "orange_ul"},
    {"parent_id": "orange_ul", "child_id": "purple_tl"},
    {"parent_id": "purple_tl", "child_id": "red_tr"},
    {"parent_id": "red_tr", "child_id": "green_ur"},
    {"parent_id": "green_ur", "child_id": "blue_r"},
    {"parent_id": "orange_center", "child_id": "green_slider_center"}
]

pieces = []
godot_pos = {}

for r in rings_spec:
    gx, gy = to_godot(r["cx"], r["cy"])
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
        "piece_type": r["piece_type"],
        "role": r["role"],
        "z_index": 1,
        "has_acorn": r.get("has_acorn", False),
        "acorn_color_hex": "#F2C94C",
        "release_direction": r["release_direction"],
        "motion_model": 0,
        "gaps": r["gaps"],
        "blockers": r.get("blockers", [])
    })

for s in sliders_spec:
    gx0, gy0 = to_godot(s["crop_start"][0], s["crop_start"][1])
    godot_pos[s["id"]] = (gx0, gy0)

    # Relative path points in Godot scale
    scaled_path = []
    p0_cx, p0_cy = s["crop_start"]
    for pt in s["crop_path"]:
        dx = (pt[0] - p0_cx) * ref_scale
        dy = (pt[1] - p0_cy) * ref_scale
        scaled_path.append({"x": round(dx, 1), "y": round(dy, 1)})

    sleeves = []
    for sl in s["sleeves"]:
        sl_gx, sl_gy = to_godot(sl["cx"], sl["cy"])
        sl_data = {
            "x": sl_gx,
            "y": sl_gy,
            "axis": sl["axis"]
        }
        if "stem_from" in sl:
            sl_data["stem_from"] = sl["stem_from"]
        sleeves.append(sl_data)

    pieces.append({
        "id": s["id"],
        "color_name": s["color_name"],
        "color_hex": COLORS[s["color_name"]]["hex"],
        "x": gx0,
        "y": gy0,
        "start_angle_deg": 0.0,
        "radius": 52.0,
        "radius_y": 52.0,
        "thickness": 18.0,
        "shape_type": 5, # PATH
        "piece_type": 0,
        "role": 0,
        "z_index": 2,
        "initially_locked": False,
        "locked": False,
        "property_locks": {},
        "release_direction": s["axis"],
        "motion_model": 1, # SLIDE
        "motion_axis": s["axis"],
        "slide_min": 0.0,
        "slide_max": s["slide_max"],
        "path_points": scaled_path,
        "sleeves": sleeves,
        "gaps": []
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

level_18_data = {
    "id": 18,
    "title": "Level 18",
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

with open("data/user_levels/18.json", "w", encoding="utf-8") as f:
    json.dump(level_18_data, f, indent=2)

print("Generated data/user_levels/18.json with 10 rings and 4 calibrated sliders!")
