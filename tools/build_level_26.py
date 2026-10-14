import json

scale = 720.0 / 685.0
y_off = 20.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

level_26 = {
    "id": 26,
    "title": "Level 26",
    "par_moves": 30,
    "theme_id": "porcelain",
    "pieces": [],
    "links": []
}

R_hub = 42.0
R = 38.0

# ----------------- PIECES -----------------
# 0. Center Hub (closed ring, root anchor)
hx, hy = to_g(340.0, 545.0)
level_26["pieces"].append({
    "id": "cyan_hub", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": hx, "y": hy, "start_angle_deg": 0.0,
    "radius": R_hub, "radius_y": R_hub, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": 0.0},
    "motion_model": 0, "gaps": [], "blockers": []
})

# Inner 6 C-rings
inner_rings = [
    ("orange_in_top", "orange", "#EA7829", 340.0, 414.0, 270.0),
    ("purple_in_tr", "purple", "#9B51E0", 436.0, 480.0, 270.0),
    ("red_in_br", "red", "#EB5757", 444.0, 600.0, 90.0),
    ("blue_in_bot", "blue", "#2F80ED", 340.0, 676.0, 90.0),
    ("green_in_bl", "green", "#27AE60", 236.0, 600.0, 90.0),
    ("purple_in_tl", "purple", "#9B51E0", 244.0, 480.0, 270.0),
]

for pid, cname, chex, rx, ry, gap_ang in inner_rings:
    gx, gy = to_g(rx, ry)
    level_26["pieces"].append({
        "id": pid, "color_name": cname, "color_hex": chex,
        "x": gx, "y": gy, "start_angle_deg": 0.0,
        "radius": R, "radius_y": R, "thickness": 18.0,
        "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
        "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0 if "top" in pid or "t" in pid else 1.0},
        "motion_model": 0,
        "gaps": [{"center_angle_deg": gap_ang, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": []
    })

# Outer 10 C-rings
outer_rings = [
    ("green_top_left", "green", "#27AE60", 235.0, 350.0, 270.0),
    ("purple_tr", "purple", "#9B51E0", 445.0, 350.0, 270.0),
    ("red_tr", "red", "#EB5757", 532.0, 435.0, 0.0),
    ("orange_mr", "orange", "#EA7829", 510.0, 545.0, 0.0),
    ("purple_mr", "purple", "#9B51E0", 532.0, 655.0, 0.0),
    ("red_br", "red", "#EB5757", 445.0, 740.0, 90.0),
    ("cyan_bl", "cyan", "#2BBBEF", 235.0, 740.0, 90.0),
    ("orange_bl", "orange", "#EA7829", 148.0, 655.0, 180.0),
    ("green_ml", "green", "#27AE60", 170.0, 545.0, 180.0),
    ("blue_tl", "blue", "#2F80ED", 148.0, 435.0, 180.0),
]

for pid, cname, chex, rx, ry, gap_ang in outer_rings:
    gx, gy = to_g(rx, ry)
    level_26["pieces"].append({
        "id": pid, "color_name": cname, "color_hex": chex,
        "x": gx, "y": gy, "start_angle_deg": 0.0,
        "radius": R, "radius_y": R, "thickness": 18.0,
        "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
        "has_acorn": False, "release_direction": {"x": 1.0 if "r" in pid else -1.0, "y": -1.0 if "top" in pid or "t" in pid else 1.0},
        "motion_model": 0,
        "gaps": [{"center_angle_deg": gap_ang, "width_deg": 105.0, "tolerance_deg": 16.0}],
        "blockers": []
    })


# ----------------- LINKS -----------------
# 1. Hub spokes (hub holds inner 6)
hub_links = [
    ("orange_in_top", 270.0),
    ("purple_in_tr", 330.0),
    ("red_in_br", 30.0),
    ("blue_in_bot", 90.0),
    ("green_in_bl", 150.0),
    ("purple_in_tl", 210.0),
]

for to_id, ang in hub_links:
    level_26["links"].append({
        "id": f"link_hub_{to_id}",
        "from_piece_id": "cyan_hub",
        "to_piece_id": to_id,
        "color_name": "cyan",
        "color_hex": "#2BBBEF",
        "anchor_angle_deg": ang,
        "length": 30.0
    })

# 2. Outer ring links:
outer_links = [
    # Top
    ("orange_in_top", "green_top_left", "orange", "#EA7829", 150.0),
    ("orange_in_top", "purple_tr", "orange", "#EA7829", 30.0),
    ("green_top_left", "blue_tl", "green", "#27AE60", 210.0),
    ("purple_tr", "red_tr", "purple", "#9B51E0", 330.0),
    
    # Left side
    ("blue_tl", "green_ml", "blue", "#2F80ED", 90.0),
    ("purple_in_tl", "green_ml", "purple", "#9B51E0", 180.0),
    ("green_ml", "green_in_bl", "green", "#27AE60", 330.0),
    ("green_ml", "orange_bl", "green", "#27AE60", 210.0),
    ("orange_bl", "cyan_bl", "orange", "#EA7829", 90.0),
    ("blue_in_bot", "cyan_bl", "blue", "#2F80ED", 180.0),
    
    # Right side
    ("red_tr", "orange_mr", "red", "#EB5757", 90.0),
    ("purple_in_tr", "orange_mr", "purple", "#9B51E0", 0.0),
    ("red_in_br", "orange_mr", "red", "#EB5757", 30.0),
    ("orange_mr", "purple_mr", "orange", "#EA7829", 330.0),
    ("purple_mr", "red_br", "purple", "#9B51E0", 90.0),
    ("blue_in_bot", "red_br", "blue", "#2F80ED", 0.0),
]

for from_id, to_id, cname, chex, ang in outer_links:
    level_26["links"].append({
        "id": f"link_{from_id}_{to_id}",
        "from_piece_id": from_id,
        "to_piece_id": to_id,
        "color_name": cname,
        "color_hex": chex,
        "anchor_angle_deg": ang,
        "length": 30.0
    })

with open("data/user_levels/26.json", "w") as f:
    json.dump(level_26, f, indent=2)

print("Saved data/user_levels/26.json successfully with %d pieces and %d links!" % (len(level_26["pieces"]), len(level_26["links"])))
