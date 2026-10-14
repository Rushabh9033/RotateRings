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

# 6 Rings in the pig face
rings_spec = [
    {
        "id": "red_head",
        "color_name": "red",
        "cx": 275.0, "cy": 370.0,
        "radius": 210.0,
        "role": 1, # Anchor hub for the entire face
        "piece_type": 0,
        "gaps": [],
        "blockers": []
    },
    {
        "id": "purple_snout",
        "color_name": "purple",
        "cx": 275.0, "cy": 470.0,
        "radius": 100.0,
        "role": 0,
        "piece_type": 1,
        "gaps": [{"center_angle_deg": 270.0, "width_deg": 120.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "cyan_nostril",
        "color_name": "cyan",
        "cx": 220.0, "cy": 435.0,
        "radius": 40.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "orange_nostril",
        "color_name": "orange",
        "cx": 330.0, "cy": 435.0,
        "radius": 40.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "green_eye",
        "color_name": "green",
        "cx": 200.0, "cy": 270.0,
        "radius": 48.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 180.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    },
    {
        "id": "blue_eye",
        "color_name": "blue",
        "cx": 350.0, "cy": 270.0,
        "radius": 48.0,
        "role": 0,
        "piece_type": 1,
        "has_acorn": True,
        "gaps": [{"center_angle_deg": 0.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
        "blockers": []
    }
]

# 8 Sliders (horns and cheeks)
sliders_spec = [
    # Left Horn Outer
    {
        "id": "green_horn_l",
        "color_name": "green",
        "origin": (145.0, 170.0),
        "motion_axis": (-0.6, -0.8),
        "slide_max": 80.0,
        "path": [(45.0, -125.0), (-40.0, -75.0), (15.0, 25.0)],
        "sleeves": [{"cx": 145.0, "cy": 170.0, "axis": (-0.6, -0.8)}]
    },
    # Left Horn Inner
    {
        "id": "blue_horn_l",
        "color_name": "blue",
        "origin": (195.0, 80.0),
        "motion_axis": (-0.4, -0.9),
        "slide_max": 80.0,
        "path": [(10.0, -25.0), (-15.0, 35.0), (90.0, 85.0)],
        "sleeves": [{"cx": 195.0, "cy": 80.0, "axis": (-0.4, -0.9)}]
    },
    # Right Horn Outer
    {
        "id": "green_horn_r",
        "color_name": "green",
        "origin": (405.0, 170.0),
        "motion_axis": (0.6, -0.8),
        "slide_max": 80.0,
        "path": [(-45.0, -125.0), (40.0, -75.0), (-15.0, 25.0)],
        "sleeves": [{"cx": 405.0, "cy": 170.0, "axis": (0.6, -0.8)}]
    },
    # Right Horn Inner
    {
        "id": "green_horn_inner_r",
        "color_name": "green",
        "origin": (355.0, 80.0),
        "motion_axis": (0.4, -0.9),
        "slide_max": 80.0,
        "path": [(-10.0, -25.0), (15.0, 35.0), (-90.0, 85.0)],
        "sleeves": [{"cx": 355.0, "cy": 80.0, "axis": (0.4, -0.9)}]
    },
    # Left Cheek Upper
    {
        "id": "green_cheek_l",
        "color_name": "green",
        "origin": (110.0, 230.0),
        "motion_axis": (-1.0, -0.5),
        "slide_max": 80.0,
        "path": [(-40.0, -10.0), (-60.0, 30.0), (30.0, 10.0)],
        "sleeves": [{"cx": 110.0, "cy": 230.0, "axis": (-1.0, -0.5)}]
    },
    # Left Cheek Lower
    {
        "id": "blue_cheek_l",
        "color_name": "blue",
        "origin": (60.0, 290.0),
        "motion_axis": (-1.0, 0.5),
        "slide_max": 80.0,
        "path": [(-10.0, -20.0), (10.0, 20.0), (80.0, -10.0)],
        "sleeves": [{"cx": 60.0, "cy": 290.0, "axis": (-1.0, 0.5)}]
    },
    # Right Cheek Upper
    {
        "id": "cyan_cheek_r",
        "color_name": "cyan",
        "origin": (440.0, 230.0),
        "motion_axis": (1.0, -0.5),
        "slide_max": 80.0,
        "path": [(40.0, -10.0), (60.0, 30.0), (-30.0, 10.0)],
        "sleeves": [{"cx": 440.0, "cy": 230.0, "axis": (1.0, -0.5)}]
    },
    # Right Cheek Lower
    {
        "id": "orange_cheek_r",
        "color_name": "orange",
        "origin": (490.0, 290.0),
        "motion_axis": (1.0, 0.5),
        "slide_max": 80.0,
        "path": [(10.0, -20.0), (-10.0, 20.0), (-80.0, -10.0)],
        "sleeves": [{"cx": 490.0, "cy": 290.0, "axis": (1.0, 0.5)}]
    }
]

# Links
links_spec = [
    # Snout held by red head at bottom
    {"from": "red_head", "to": "purple_snout", "angle_deg": 90.0, "color_hex": COLORS["red"]["hex"]},
    # Nostrils held by purple snout
    {"from": "purple_snout", "to": "cyan_nostril", "angle_deg": 180.0, "color_hex": COLORS["cyan"]["hex"]},
    {"from": "purple_snout", "to": "orange_nostril", "angle_deg": 0.0, "color_hex": COLORS["orange"]["hex"]},
    # Eyes held by red head
    {"from": "red_head", "to": "green_eye", "angle_deg": 225.0, "color_hex": COLORS["red"]["hex"]},
    {"from": "red_head", "to": "blue_eye", "angle_deg": 315.0, "color_hex": COLORS["red"]["hex"]},
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
        "shape_type": 5,
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
        "cuff_inner_radius": 48.0,
        "cuff_outer_radius": 48.0,
        "cuff_arc_deg": 35.0,
        "cuff_thickness": 18.0,
        "cuff_color_hex": l["color_hex"],
        "z_index": 1,
        "break_sound": "res://assets/audio/cuff_break.wav",
        "lock_flags": 0
    })

level_20_json = {
    "id": 20,
    "title": "Level 20",
    "par_moves": 10,
    "theme_id": "porcelain",
    "pieces": pieces_out,
    "links": links_out
}

with open("data/user_levels/20.json", "w") as f:
    json.dump(level_20_json, f, indent=2)

print("Saved data/user_levels/20.json successfully!")
