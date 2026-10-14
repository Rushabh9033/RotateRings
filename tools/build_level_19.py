import json
import math

ref_scale = 1.051094890510949
y_base = 17.0

def to_godot(cx, cy):
    fx = cx + 50.0
    fy = cy + 260.0
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

# 9 Rings
rings_spec = [
    {
        "id": "green_top",
        "color_name": "green",
        "cx": 248.0, "cy": 120.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "red_ml",
        "color_name": "red",
        "cx": 180.0, "cy": 205.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 135.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "red_mr",
        "color_name": "red",
        "cx": 425.0, "cy": 240.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "orange_c",
        "color_name": "orange",
        "cx": 280.0, "cy": 290.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 45.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "cyan_l",
        "color_name": "cyan",
        "cx": 147.0, "cy": 335.0,
        "radius": 56.0,
        "role": 1, # Anchor hub holding branches
        "piece_type": 0,
        "has_acorn": True,
        "gaps": [],
        "blockers": []
    },
    {
        "id": "purple_mr",
        "color_name": "purple",
        "cx": 380.0, "cy": 395.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "teal_bm",
        "color_name": "teal",
        "cx": 350.0, "cy": 520.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 90.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "blue_br",
        "color_name": "blue",
        "cx": 455.0, "cy": 490.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 315.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "teal_bot",
        "color_name": "teal",
        "cx": 455.0, "cy": 630.0,
        "radius": 52.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    }
]

# 11 Sliders (rectilinear rods & brackets)
sliders_spec = [
    {
        "id": "purple_tl_slider",
        "color_name": "purple",
        "origin": (135.0, 35.0), # sleeve position
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-55.0, 0.0), (55.0, 0.0), (55.0, 38.0)],
        "sleeves": [{"cx": 135.0, "cy": 35.0, "axis": (-1.0, 0.0)}]
    },
    {
        "id": "blue_tl_slider",
        "color_name": "blue",
        "origin": (315.0, 35.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 90.0,
        "path": [(-80.0, 60.0), (-80.0, 0.0), (40.0, 0.0)],
        "sleeves": [{"cx": 315.0, "cy": 35.0, "axis": (1.0, 0.0)}]
    },
    {
        "id": "blue_tr_slider",
        "color_name": "blue",
        "origin": (400.0, 70.0),
        "motion_axis": (0.0, -1.0),
        "slide_max": 80.0,
        "path": [(0.0, -70.0), (0.0, 70.0), (-55.0, 70.0)],
        "sleeves": [{"cx": 400.0, "cy": 70.0, "axis": (0.0, -1.0)}]
    },
    {
        "id": "cyan_tr_slider",
        "color_name": "cyan",
        "origin": (490.0, 140.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-55.0, -140.0), (-55.0, 0.0), (15.0, 0.0)],
        "sleeves": [{"cx": 490.0, "cy": 140.0, "axis": (1.0, 0.0)}]
    },
    {
        "id": "cyan_mid_slider",
        "color_name": "cyan",
        "origin": (305.0, 190.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-85.0, 0.0), (50.0, 0.0), (50.0, 60.0)],
        "sleeves": [{"cx": 305.0, "cy": 190.0, "axis": (-1.0, 0.0)}]
    },
    {
        "id": "red_mr_slider",
        "color_name": "red",
        "origin": (490.0, 280.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(0.0, -70.0), (0.0, 90.0), (-55.0, 90.0)],
        "sleeves": [{"cx": 490.0, "cy": 280.0, "axis": (0.0, 1.0)}]
    },
    {
        "id": "green_mid_slider",
        "color_name": "green",
        "origin": (240.0, 420.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(0.0, 35.0), (0.0, -65.0), (60.0, -65.0)],
        "sleeves": [{"cx": 240.0, "cy": 420.0, "axis": (0.0, 1.0)}]
    },
    {
        "id": "green_bl_slider",
        "color_name": "green",
        "origin": (140.0, 455.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-90.0, 0.0), (45.0, 0.0), (45.0, -45.0)],
        "sleeves": [{"cx": 140.0, "cy": 455.0, "axis": (-1.0, 0.0)}]
    },
    {
        "id": "cyan_bl_slider",
        "color_name": "cyan",
        "origin": (135.0, 495.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-85.0, 0.0), (70.0, 0.0), (70.0, -35.0)],
        "sleeves": [{"cx": 135.0, "cy": 495.0, "axis": (-1.0, 0.0)}]
    },
    {
        "id": "purple_bot_bracket",
        "color_name": "purple",
        "origin": (170.0, 560.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(0.0, 20.0), (0.0, -30.0), (165.0, -30.0), (165.0, 20.0)],
        "sleeves": [
            {"cx": 170.0, "cy": 560.0, "axis": (0.0, 1.0)},
            {"cx": 335.0, "cy": 560.0, "axis": (0.0, 1.0)}
        ]
    },
    {
        "id": "cyan_bot_bracket",
        "color_name": "cyan",
        "origin": (280.0, 580.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(0.0, -20.0), (0.0, 50.0), (165.0, 50.0), (165.0, -20.0)],
        "sleeves": [
            {"cx": 280.0, "cy": 580.0, "axis": (0.0, 1.0)},
            {"cx": 445.0, "cy": 580.0, "axis": (0.0, 1.0)}
        ]
    }
]

# Links between rings
# green_top held by red_ml
# red_ml held by cyan_l
# orange_c held by purple_mr
# red_mr held by purple_mr
# purple_mr held by teal_bm
# teal_bm held by blue_br
# blue_br held by teal_bot
# teal_bot held by cyan_bot_bracket sleeve / collar link
links_spec = [
    {"from": "red_ml", "to": "green_top", "angle_deg": 45.0, "color_hex": COLORS["red"]["hex"]},
    {"from": "cyan_l", "to": "red_ml", "angle_deg": 270.0, "color_hex": COLORS["blue"]["hex"]},
    {"from": "purple_mr", "to": "red_mr", "angle_deg": 270.0, "color_hex": COLORS["red"]["hex"]},
    {"from": "purple_mr", "to": "orange_c", "angle_deg": 135.0, "color_hex": COLORS["orange"]["hex"]},
    {"from": "teal_bm", "to": "purple_mr", "angle_deg": 45.0, "color_hex": COLORS["teal"]["hex"]},
    {"from": "teal_bm", "to": "blue_br", "angle_deg": 0.0, "color_hex": COLORS["blue"]["hex"]},
    {"from": "teal_bot", "to": "blue_br", "angle_deg": 270.0, "color_hex": COLORS["teal"]["hex"]},
]

pieces_out = []

for r in rings_spec:
    gx, gy = to_godot(r["cx"], r["cy"])
    col = COLORS[r["color_name"]]
    p = {
        "id": r["id"],
        "color_name": col["name"],
        "color_hex": col["hex"],
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
        "release_direction": {"x": 1.0, "y": 0.0},
        "motion_model": 0,
        "gaps": r["gaps"],
        "blockers": r.get("blockers", [])
    }
    pieces_out.append(p)

for s in sliders_spec:
    gx, gy = to_godot(s["origin"][0], s["origin"][1])
    col = COLORS[s["color_name"]]
    
    # Scale path points
    scaled_path = []
    for pt in s["path"]:
        scaled_path.append({
            "x": round(pt[0] * ref_scale, 1),
            "y": round(pt[1] * ref_scale, 1)
        })
        
    scaled_sleeves = []
    for slv in s["sleeves"]:
        sgx, sgy = to_godot(slv["cx"], slv["cy"])
        scaled_sleeves.append({
            "x": sgx,
            "y": sgy,
            "axis": {"x": slv["axis"][0], "y": slv["axis"][1]}
        })
        
    p = {
        "id": s["id"],
        "color_name": col["name"],
        "color_hex": col["hex"],
        "x": gx,
        "y": gy,
        "start_angle_deg": 0.0,
        "radius": 52.0,
        "radius_y": 52.0,
        "thickness": 18.0,
        "shape_type": 5, # Slider polyline
        "piece_type": 0,
        "role": 0,
        "z_index": 2,
        "initially_locked": False,
        "locked": False,
        "property_locks": {},
        "release_direction": {"x": s["motion_axis"][0], "y": s["motion_axis"][1]},
        "motion_model": 1,
        "motion_axis": {"x": s["motion_axis"][0], "y": s["motion_axis"][1]},
        "slide_min": 0.0,
        "slide_max": s["slide_max"],
        "path_points": scaled_path,
        "sleeves": scaled_sleeves,
        "gaps": []
    }
    pieces_out.append(p)

links_out = []
for i, l in enumerate(links_spec):
    links_out.append({
        "id": f"link_{l['from']}_{l['to']}",
        "from_piece_id": l["from"],
        "to_piece_id": l["to"],
        "angle_deg": l["angle_deg"],
        "length": 55.0,
        "cuff_angle_offset_deg": 0.0,
        "stem_color_hex": l["color_hex"],
        "stem_thickness": 8.0,
        "cuff_inner_radius": 52.0,
        "cuff_outer_radius": 52.0,
        "cuff_arc_deg": 35.0,
        "cuff_thickness": 18.0,
        "cuff_color_hex": l["color_hex"],
        "z_index": 1,
        "break_sound": "res://assets/audio/cuff_break.wav",
        "lock_flags": 0
    })

level_19_json = {
    "id": 19,
    "title": "Level 19",
    "par_moves": 16,
    "theme_id": "porcelain",
    "pieces": pieces_out,
    "links": links_out
}

with open("data/user_levels/19.json", "w") as f:
    json.dump(level_19_json, f, indent=2)

print("Saved data/user_levels/19.json successfully!")
