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

# 23 Sliding Pipes in Level 21
sliders_spec = [
    # 1. purple_top_l: Top horizontal bar
    {
        "id": "purple_top_l",
        "color_name": "purple",
        "origin": (210.0, 45.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 90.0,
        "path": [(-130.0, 40.0), (-130.0, 0.0), (140.0, 0.0)],
        "sleeves": [{"cx": 210.0, "cy": 45.0, "axis": (-1.0, 0.0)}]
    },
    # 2. blue_top_mid: Hook
    {
        "id": "blue_top_mid",
        "color_name": "blue",
        "origin": (250.0, 230.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 90.0,
        "path": [(-50.0, -160.0), (0.0, -160.0), (0.0, 40.0)],
        "sleeves": [{"cx": 250.0, "cy": 230.0, "axis": (0.0, 1.0)}]
    },
    # 3. green_top_mid: Hook
    {
        "id": "green_top_mid",
        "color_name": "green",
        "origin": (350.0, 230.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 90.0,
        "path": [(-50.0, -160.0), (0.0, -160.0), (0.0, 40.0)],
        "sleeves": [{"cx": 350.0, "cy": 230.0, "axis": (0.0, 1.0)}]
    },
    # 4. red_top_r: Hook
    {
        "id": "red_top_r",
        "color_name": "red",
        "origin": (440.0, 95.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-70.0, -45.0), (-70.0, 0.0), (50.0, 0.0)],
        "sleeves": [{"cx": 440.0, "cy": 95.0, "axis": (1.0, 0.0)}]
    },
    # 5. green_top_r: Hook
    {
        "id": "green_top_r",
        "color_name": "green",
        "origin": (430.0, 50.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-50.0, 0.0), (80.0, 0.0), (80.0, 50.0)],
        "sleeves": [{"cx": 430.0, "cy": 50.0, "axis": (1.0, 0.0)}]
    },
    # 6. cyan_col_1: Left vertical pipe
    {
        "id": "cyan_col_1",
        "color_name": "cyan",
        "origin": (70.0, 190.0),
        "motion_axis": (0.0, -1.0),
        "slide_max": 90.0,
        "path": [(0.0, -150.0), (0.0, 140.0)],
        "sleeves": [{"cx": 70.0, "cy": 190.0, "axis": (0.0, -1.0)}]
    },
    # 7. blue_col_2: Hook
    {
        "id": "blue_col_2",
        "color_name": "blue",
        "origin": (120.0, 190.0),
        "motion_axis": (0.0, -1.0),
        "slide_max": 90.0,
        "path": [(0.0, -90.0), (0.0, 140.0), (45.0, 140.0)],
        "sleeves": [{"cx": 120.0, "cy": 190.0, "axis": (0.0, -1.0)}]
    },
    # 8. green_col_3: Hook
    {
        "id": "green_col_3",
        "color_name": "green",
        "origin": (170.0, 230.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 90.0,
        "path": [(-60.0, -160.0), (0.0, -160.0), (0.0, 50.0)],
        "sleeves": [{"cx": 170.0, "cy": 230.0, "axis": (0.0, 1.0)}]
    },
    # 9. orange_col_4: Hook
    {
        "id": "orange_col_4",
        "color_name": "orange",
        "origin": (210.0, 190.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 90.0,
        "path": [(0.0, -90.0), (0.0, 140.0), (50.0, 140.0)],
        "sleeves": [{"cx": 210.0, "cy": 190.0, "axis": (0.0, 1.0)}]
    },
    # 10. purple_col_5: Hook
    {
        "id": "purple_col_5",
        "color_name": "purple",
        "origin": (290.0, 190.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 90.0,
        "path": [(0.0, -90.0), (0.0, 140.0), (60.0, 140.0)],
        "sleeves": [{"cx": 290.0, "cy": 190.0, "axis": (0.0, 1.0)}]
    },
    # 11. blue_pin: Vertical pin
    {
        "id": "blue_pin",
        "color_name": "blue",
        "origin": (380.0, 170.0),
        "motion_axis": (0.0, -1.0),
        "slide_max": 70.0,
        "path": [(0.0, -60.0), (0.0, 60.0)],
        "sleeves": [{"cx": 380.0, "cy": 170.0, "axis": (0.0, -1.0)}]
    },
    # 12. green_pin: Vertical pin
    {
        "id": "green_pin",
        "color_name": "green",
        "origin": (420.0, 200.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 70.0,
        "path": [(0.0, -80.0), (0.0, 40.0)],
        "sleeves": [{"cx": 420.0, "cy": 200.0, "axis": (0.0, 1.0)}]
    },
    # 13. cyan_pin: Vertical pin
    {
        "id": "cyan_pin",
        "color_name": "cyan",
        "origin": (460.0, 170.0),
        "motion_axis": (0.0, -1.0),
        "slide_max": 70.0,
        "path": [(0.0, -60.0), (0.0, 60.0)],
        "sleeves": [{"cx": 460.0, "cy": 170.0, "axis": (0.0, -1.0)}]
    },
    # 14. teal_mid_hook:
    {
        "id": "teal_mid_hook",
        "color_name": "teal",
        "origin": (470.0, 275.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-100.0, 0.0), (0.0, 0.0)],
        "sleeves": [{"cx": 470.0, "cy": 275.0, "axis": (1.0, 0.0)}]
    },
    # 15. green_mid_r: Hook
    {
        "id": "green_mid_r",
        "color_name": "green",
        "origin": (450.0, 380.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(-60.0, -70.0), (0.0, -70.0), (0.0, 40.0)],
        "sleeves": [{"cx": 450.0, "cy": 380.0, "axis": (0.0, 1.0)}]
    },
    # 16. green_far_r: Hook
    {
        "id": "green_far_r",
        "color_name": "green",
        "origin": (510.0, 350.0),
        "motion_axis": (0.0, 1.0),
        "slide_max": 80.0,
        "path": [(0.0, -110.0), (0.0, 130.0), (-60.0, 130.0)],
        "sleeves": [{"cx": 510.0, "cy": 350.0, "axis": (0.0, 1.0)}]
    },
    # 17. orange_mid_l: Hook
    {
        "id": "orange_mid_l",
        "color_name": "orange",
        "origin": (130.0, 370.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-70.0, 0.0), (50.0, 0.0), (50.0, 50.0)],
        "sleeves": [{"cx": 130.0, "cy": 370.0, "axis": (-1.0, 0.0)}]
    },
    # 18. purple_mid: S-pipe
    {
        "id": "purple_mid",
        "color_name": "purple",
        "origin": (130.0, 460.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-70.0, 0.0), (70.0, 0.0), (70.0, -90.0), (220.0, -90.0)],
        "sleeves": [{"cx": 130.0, "cy": 460.0, "axis": (-1.0, 0.0)}]
    },
    # 19. cyan_mid_h: Horizontal bar
    {
        "id": "cyan_mid_h",
        "color_name": "cyan",
        "origin": (305.0, 410.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-75.0, 0.0), (75.0, 0.0)],
        "sleeves": [{"cx": 305.0, "cy": 410.0, "axis": (1.0, 0.0)}]
    },
    # 20. orange_mid_h: Hook
    {
        "id": "orange_mid_h",
        "color_name": "orange",
        "origin": (320.0, 440.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-90.0, 0.0), (90.0, 0.0), (90.0, -50.0)],
        "sleeves": [{"cx": 320.0, "cy": 440.0, "axis": (1.0, 0.0)}]
    },
    # 21. red_bot_h: Hook
    {
        "id": "red_bot_h",
        "color_name": "red",
        "origin": (200.0, 490.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-130.0, 30.0), (-130.0, 0.0), (120.0, 0.0)],
        "sleeves": [{"cx": 200.0, "cy": 490.0, "axis": (-1.0, 0.0)}]
    },
    # 22. green_bot_h: Hook
    {
        "id": "green_bot_h",
        "color_name": "green",
        "origin": (200.0, 520.0),
        "motion_axis": (-1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-110.0, 0.0), (140.0, 0.0), (140.0, -40.0)],
        "sleeves": [{"cx": 200.0, "cy": 520.0, "axis": (-1.0, 0.0)}]
    },
    # 23. purple_bot_r: Hook
    {
        "id": "purple_bot_r",
        "color_name": "purple",
        "origin": (430.0, 520.0),
        "motion_axis": (1.0, 0.0),
        "slide_max": 80.0,
        "path": [(-60.0, 0.0), (70.0, 0.0), (70.0, -40.0)],
        "sleeves": [{"cx": 430.0, "cy": 520.0, "axis": (1.0, 0.0)}]
    }
]

pieces_out = []

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

level_21_json = {
    "id": 21,
    "title": "Level 21",
    "par_moves": 23,
    "theme_id": "porcelain",
    "pieces": pieces_out,
    "links": []
}

with open("data/user_levels/21.json", "w") as f:
    json.dump(level_21_json, f, indent=2)

print("Saved data/user_levels/21.json successfully!")
