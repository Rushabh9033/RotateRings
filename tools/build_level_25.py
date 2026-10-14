import json

scale = 720.0 / 685.0
y_off = 20.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

def to_rel(pts, ox, oy):
    return [{"x": round((p[0] - ox) * scale, 1), "y": round((p[1] - oy) * scale, 1)} for p in pts]

level_25 = {
    "id": 25,
    "title": "Level 25",
    "par_moves": 26,
    "theme_id": "porcelain",
    "pieces": [],
    "links": []
}

R = 44.0

# ----------------- RINGS -----------------
# 1. purple_r1 (top)
p1x, p1y = to_g(290.0, 310.0)
level_25["pieces"].append({
    "id": "purple_r1", "color_name": "purple", "color_hex": "#9B51E0",
    "x": p1x, "y": p1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 315.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": [{"angle_deg": 225.0, "length": 22.0, "width": 14.0}]
})

# 2. cyan_r1 (top-left)
c1x, c1y = to_g(198.0, 414.0)
level_25["pieces"].append({
    "id": "cyan_r1", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c1x, "y": c1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 315.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 3. orange_r1 (top-mid)
o1x, o1y = to_g(308.0, 426.0)
level_25["pieces"].append({
    "id": "orange_r1", "color_name": "orange", "color_hex": "#EA7829",
    "x": o1x, "y": o1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 135.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 4. cyan_r2 (top-mid-right)
c2x, c2y = to_g(408.0, 368.0)
level_25["pieces"].append({
    "id": "cyan_r2", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c2x, "y": c2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 5. orange_r2 (top-right)
o2x, o2y = to_g(514.0, 368.0)
level_25["pieces"].append({
    "id": "orange_r2", "color_name": "orange", "color_hex": "#EA7829",
    "x": o2x, "y": o2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": [{"angle_deg": 135.0, "length": 25.0, "width": 14.0}]
})

# 6. red_r1 (mid-left)
r1x, r1y = to_g(216.0, 520.0)
level_25["pieces"].append({
    "id": "red_r1", "color_name": "red", "color_hex": "#EB5757",
    "x": r1x, "y": r1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 7. cyan_r3 (center)
c3x, c3y = to_g(408.0, 546.0)
level_25["pieces"].append({
    "id": "cyan_r3", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c3x, "y": c3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 315.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 8. blue_r1 (mid-right)
b1x, b1y = to_g(528.0, 534.0)
level_25["pieces"].append({
    "id": "blue_r1", "color_name": "blue", "color_hex": "#2F80ED",
    "x": b1x, "y": b1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": [{"angle_deg": 135.0, "length": 25.0, "width": 14.0}]
})

# 9. orange_r3 (center-mid-left)
o3x, o3y = to_g(276.0, 606.0)
level_25["pieces"].append({
    "id": "orange_r3", "color_name": "orange", "color_hex": "#EA7829",
    "x": o3x, "y": o3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 10. red_r2 (center-mid-right)
r2x, r2y = to_g(376.0, 666.0)
level_25["pieces"].append({
    "id": "red_r2", "color_name": "red", "color_hex": "#EB5757",
    "x": r2x, "y": r2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 315.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 11. green_r1 (mid-right-lower)
g1x, g1y = to_g(502.0, 650.0)
level_25["pieces"].append({
    "id": "green_r1", "color_name": "green", "color_hex": "#27AE60",
    "x": g1x, "y": g1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 12. cyan_r4 (lower-left)
c4x, c4y = to_g(192.0, 682.0)
level_25["pieces"].append({
    "id": "cyan_r4", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c4x, "y": c4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 13. orange_r4 (bottom-left)
o4x, o4y = to_g(158.0, 780.0)
level_25["pieces"].append({
    "id": "orange_r4", "color_name": "orange", "color_hex": "#EA7829",
    "x": o4x, "y": o4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 14. green_r2 (bottom-center)
g2x, g2y = to_g(368.0, 794.0)
level_25["pieces"].append({
    "id": "green_r2", "color_name": "green", "color_hex": "#27AE60",
    "x": g2x, "y": g2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": [{"angle_deg": 270.0, "length": 25.0, "width": 14.0}]
})

# 15. blue_r2 (bottom-right)
b2x, b2y = to_g(476.0, 766.0)
level_25["pieces"].append({
    "id": "blue_r2", "color_name": "blue", "color_hex": "#2F80ED",
    "x": b2x, "y": b2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 45.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})


# ----------------- SLIDERS -----------------
# Slider 1: purple_s1 (inverted-L, top-left)
s1_ox, s1_oy = 192.0, 298.0
s1_pos_x, s1_pos_y = to_g(s1_ox, s1_oy)
s1_pts = [(225.0, 298.0), (192.0, 298.0), (192.0, 455.0)]
s1_slv_x, s1_slv_y = to_g(192.0, 375.0)
level_25["pieces"].append({
    "id": "purple_s1", "color_name": "purple", "color_hex": "#9B51E0",
    "x": s1_pos_x, "y": s1_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": -1.0}, "slide_max": 250.0,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "path_points": to_rel(s1_pts, s1_ox, s1_oy),
    "sleeves": [{"x": s1_slv_x, "y": s1_slv_y, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": [], "blockers": []
})

# Slider 2: blue_s1 (inverted-L, mid-right)
s2_ox, s2_oy = 512.0, 432.0
s2_pos_x, s2_pos_y = to_g(s2_ox, s2_oy)
s2_pts = [(468.0, 432.0), (512.0, 432.0), (512.0, 545.0)]
s2_slv_x, s2_slv_y = to_g(512.0, 490.0)
level_25["pieces"].append({
    "id": "blue_s1", "color_name": "blue", "color_hex": "#2F80ED",
    "x": s2_pos_x, "y": s2_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": -1.0}, "slide_max": 250.0,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "path_points": to_rel(s2_pts, s2_ox, s2_oy),
    "sleeves": [{"x": s2_slv_x, "y": s2_slv_y, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": [], "blockers": []
})

# Slider 3: purple_s2 (bent diagonal, center)
s3_ox, s3_oy = 314.0, 529.0
s3_pos_x, s3_pos_y = to_g(s3_ox, s3_oy)
s3_pts = [(314.0, 529.0), (406.0, 438.0), (441.0, 465.0)]
s3_slv_x, s3_slv_y = to_g(375.0, 470.0)
level_25["pieces"].append({
    "id": "purple_s2", "color_name": "purple", "color_hex": "#9B51E0",
    "x": s3_pos_x, "y": s3_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": -0.707, "y": 0.707}, "slide_max": 250.0,
    "release_direction": {"x": -0.707, "y": 0.707},
    "motion_model": 1,
    "path_points": to_rel(s3_pts, s3_ox, s3_oy),
    "sleeves": [{"x": s3_slv_x, "y": s3_slv_y, "axis": {"x": 0.707, "y": -0.707}}],
    "gaps": [], "blockers": []
})

# Slider 4: green_s1 (L-slider, lower-mid)
s4_ox, s4_oy = 262.0, 580.0
s4_pos_x, s4_pos_y = to_g(s4_ox, s4_oy)
s4_pts = [(262.0, 580.0), (262.0, 735.0), (305.0, 735.0)]
s4_slv_x, s4_slv_y = to_g(262.0, 640.0)
level_25["pieces"].append({
    "id": "green_s1", "color_name": "green", "color_hex": "#27AE60",
    "x": s4_pos_x, "y": s4_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": -1.0}, "slide_max": 250.0,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "path_points": to_rel(s4_pts, s4_ox, s4_oy),
    "sleeves": [{"x": s4_slv_x, "y": s4_slv_y, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": [], "blockers": []
})

# Slider 5: green_s2 (L-slider, bottom)
s5_ox, s5_oy = 235.0, 760.0
s5_pos_x, s5_pos_y = to_g(s5_ox, s5_oy)
s5_pts = [(235.0, 760.0), (235.0, 815.0), (370.0, 815.0)]
s5_slv_x, s5_slv_y = to_g(300.0, 815.0)
level_25["pieces"].append({
    "id": "green_s2", "color_name": "green", "color_hex": "#27AE60",
    "x": s5_pos_x, "y": s5_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": -1.0, "y": 0.0}, "slide_max": 250.0,
    "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 1,
    "path_points": to_rel(s5_pts, s5_ox, s5_oy),
    "sleeves": [{"x": s5_slv_x, "y": s5_slv_y, "axis": {"x": 1.0, "y": 0.0}}],
    "gaps": [], "blockers": []
})


# ----------------- LINKS -----------------
# 1. orange_r1 holds purple_r1 (up, 270 deg)
level_25["links"].append({
    "id": "link_orange_r1_purple_r1", "from_piece_id": "orange_r1", "to_piece_id": "purple_r1",
    "color_name": "orange", "color_hex": "#EA7829", "anchor_angle_deg": 270.0, "length": 30.0
})

# 2. cyan_r1 holds orange_r1 (right, 0 deg)
level_25["links"].append({
    "id": "link_cyan_r1_orange_r1", "from_piece_id": "cyan_r1", "to_piece_id": "orange_r1",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 0.0, "length": 30.0
})

# 3. cyan_r1 holds purple_s1 (left, 180 deg)
level_25["links"].append({
    "id": "link_cyan_r1_purple_s1", "from_piece_id": "cyan_r1", "to_piece_id": "purple_s1",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 180.0, "length": 25.0
})

# 4. cyan_r2 holds orange_r2 (right, 0 deg)
level_25["links"].append({
    "id": "link_cyan_r2_orange_r2", "from_piece_id": "cyan_r2", "to_piece_id": "orange_r2",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 0.0, "length": 30.0
})

# 5. blue_r1 holds blue_s1 (up, 270 deg)
level_25["links"].append({
    "id": "link_blue_r1_blue_s1", "from_piece_id": "blue_r1", "to_piece_id": "blue_s1",
    "color_name": "blue", "color_hex": "#2F80ED", "anchor_angle_deg": 270.0, "length": 25.0
})

# 6. green_r1 holds blue_r1 (up, 270 deg)
level_25["links"].append({
    "id": "link_green_r1_blue_r1", "from_piece_id": "green_r1", "to_piece_id": "blue_r1",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 270.0, "length": 30.0
})

# 7. green_r1 holds blue_r2 (down, 90 deg)
level_25["links"].append({
    "id": "link_green_r1_blue_r2", "from_piece_id": "green_r1", "to_piece_id": "blue_r2",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 90.0, "length": 30.0
})

# 8. blue_r2 holds green_r2 (left, 180 deg)
level_25["links"].append({
    "id": "link_blue_r2_green_r2", "from_piece_id": "blue_r2", "to_piece_id": "green_r2",
    "color_name": "blue", "color_hex": "#2F80ED", "anchor_angle_deg": 180.0, "length": 30.0
})

# 9. green_r2 holds green_s2 (left, 180 deg)
level_25["links"].append({
    "id": "link_green_r2_green_s2", "from_piece_id": "green_r2", "to_piece_id": "green_s2",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 180.0, "length": 25.0
})

# 10. cyan_r3 holds purple_s2 (top-left, 225 deg)
level_25["links"].append({
    "id": "link_cyan_r3_purple_s2", "from_piece_id": "cyan_r3", "to_piece_id": "purple_s2",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 225.0, "length": 25.0
})

# 11. cyan_r3 holds red_r2 (down, 90 deg)
level_25["links"].append({
    "id": "link_cyan_r3_red_r2", "from_piece_id": "cyan_r3", "to_piece_id": "red_r2",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 90.0, "length": 30.0
})

# 12. red_r2 holds orange_r3 (left, 160 deg)
level_25["links"].append({
    "id": "link_red_r2_orange_r3", "from_piece_id": "red_r2", "to_piece_id": "orange_r3",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 160.0, "length": 30.0
})

# 13. orange_r3 holds red_r1 (top-left, 225 deg)
level_25["links"].append({
    "id": "link_orange_r3_red_r1", "from_piece_id": "orange_r3", "to_piece_id": "red_r1",
    "color_name": "orange", "color_hex": "#EA7829", "anchor_angle_deg": 225.0, "length": 30.0
})

# 14. cyan_r4 holds green_s1 (right, 0 deg)
level_25["links"].append({
    "id": "link_cyan_r4_green_s1", "from_piece_id": "cyan_r4", "to_piece_id": "green_s1",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 0.0, "length": 25.0
})

# 15. cyan_r4 holds orange_r4 (bottom-left, 110 deg)
level_25["links"].append({
    "id": "link_cyan_r4_orange_r4", "from_piece_id": "cyan_r4", "to_piece_id": "orange_r4",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 110.0, "length": 30.0
})

with open("data/user_levels/25.json", "w") as f:
    json.dump(level_25, f, indent=2)

print("Saved data/user_levels/25.json successfully with %d pieces and %d links!" % (len(level_25["pieces"]), len(level_25["links"])))
