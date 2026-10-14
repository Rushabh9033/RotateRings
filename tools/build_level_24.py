import json

scale = 720.0 / 685.0
y_off = 20.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

def to_rel(pts, ox, oy):
    return [{"x": round((p[0] - ox) * scale, 1), "y": round((p[1] - oy) * scale, 1)} for p in pts]

level_24 = {
    "id": 24,
    "title": "Level 24",
    "par_moves": 28,
    "theme_id": "porcelain",
    "pieces": [],
    "links": []
}

R = 44.0

# Row 1 (y=296): green_r1, blue_r1, red_r1
g1x, g1y = to_g(224.0, 296.0)
level_24["pieces"].append({
    "id": "green_r1", "color_name": "green", "color_hex": "#27AE60",
    "x": g1x, "y": g1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

b1x, b1y = to_g(338.0, 296.0)
level_24["pieces"].append({
    "id": "blue_r1", "color_name": "blue", "color_hex": "#2F80ED",
    "x": b1x, "y": b1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

r1x, r1y = to_g(452.0, 296.0)
level_24["pieces"].append({
    "id": "red_r1", "color_name": "red", "color_hex": "#EB5757",
    "x": r1x, "y": r1y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Row 2 (y=410): cyan_r2 (closed hub), orange_r2, purple_r2
c2x, c2y = to_g(224.0, 410.0)
level_24["pieces"].append({
    "id": "cyan_r2", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c2x, "y": c2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

o2x, o2y = to_g(338.0, 410.0)
level_24["pieces"].append({
    "id": "orange_r2", "color_name": "orange", "color_hex": "#EA7829",
    "x": o2x, "y": o2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

p2x, p2y = to_g(452.0, 410.0)
level_24["pieces"].append({
    "id": "purple_r2", "color_name": "purple", "color_hex": "#9B51E0",
    "x": p2x, "y": p2y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 240.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Row 3 (y=550): cyan_r3, blue_r3, green_r3, orange_r3
c3x, c3y = to_g(167.0, 550.0)
level_24["pieces"].append({
    "id": "cyan_r3", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c3x, "y": c3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

b3x, b3y = to_g(281.0, 550.0)
level_24["pieces"].append({
    "id": "blue_r3", "color_name": "blue", "color_hex": "#2F80ED",
    "x": b3x, "y": b3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

g3x, g3y = to_g(395.0, 550.0)
level_24["pieces"].append({
    "id": "green_r3", "color_name": "green", "color_hex": "#27AE60",
    "x": g3x, "y": g3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

o3x, o3y = to_g(509.0, 550.0)
level_24["pieces"].append({
    "id": "orange_r3", "color_name": "orange", "color_hex": "#EA7829",
    "x": o3x, "y": o3y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Row 4 (y=675): blue_r4, green_r4 (closed hub), purple_r4, red_r4 (closed hub)
b4x, b4y = to_g(167.0, 675.0)
level_24["pieces"].append({
    "id": "blue_r4", "color_name": "blue", "color_hex": "#2F80ED",
    "x": b4x, "y": b4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 315.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

g4x, g4y = to_g(281.0, 675.0)
level_24["pieces"].append({
    "id": "green_r4", "color_name": "green", "color_hex": "#27AE60",
    "x": g4x, "y": g4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

p4x, p4y = to_g(395.0, 675.0)
level_24["pieces"].append({
    "id": "purple_r4", "color_name": "purple", "color_hex": "#9B51E0",
    "x": p4x, "y": p4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

r4x, r4y = to_g(509.0, 675.0)
level_24["pieces"].append({
    "id": "red_r4", "color_name": "red", "color_hex": "#EB5757",
    "x": r4x, "y": r4y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

# Row 5 (y=820): cyan_r5 (closed hub)
c5x, c5y = to_g(224.0, 820.0)
level_24["pieces"].append({
    "id": "cyan_r5", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": c5x, "y": c5y, "start_angle_deg": 0.0,
    "radius": R, "radius_y": R, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False, "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

# --- 7 SLIDERS ---

# Slider 1: green_slider_tl (L-slider)
s1_ox, s1_oy = 135.0, 467.0
s1_pos_x, s1_pos_y = to_g(s1_ox, s1_oy)
s1_pts = [(135.0, 200.0), (135.0, 467.0), (80.0, 467.0)]
level_24["pieces"].append({
    "id": "green_slider_tl", "color_name": "green", "color_hex": "#27AE60",
    "x": s1_pos_x, "y": s1_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 1,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": -1.0}, "slide_max": 250.0,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "path_points": to_rel(s1_pts, s1_ox, s1_oy), "gaps": [], "blockers": []
})

# Slider 2: red_slider_mid (L-slider)
s2_ox, s2_oy = 167.0, 480.0
s2_pos_x, s2_pos_y = to_g(s2_ox, s2_oy)
s2_pts = [(167.0, 530.0), (167.0, 480.0), (550.0, 480.0)]
level_24["pieces"].append({
    "id": "red_slider_mid", "color_name": "red", "color_hex": "#EB5757",
    "x": s2_pos_x, "y": s2_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 1,
    "has_acorn": False,
    "motion_axis": {"x": 1.0, "y": 0.0}, "slide_max": 300.0,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 1,
    "path_points": to_rel(s2_pts, s2_ox, s2_oy), "gaps": [], "blockers": []
})

# Slider 3: green_slider_bot (L-slider)
s3_ox, s3_oy = 380.0, 745.0
s3_pos_x, s3_pos_y = to_g(s3_ox, s3_oy)
s3_pts = [(110.0, 745.0), (380.0, 745.0), (380.0, 810.0)]
level_24["pieces"].append({
    "id": "green_slider_bot", "color_name": "green", "color_hex": "#27AE60",
    "x": s3_pos_x, "y": s3_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 1,
    "has_acorn": False,
    "motion_axis": {"x": -1.0, "y": 0.0}, "slide_max": 300.0,
    "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 1,
    "path_points": to_rel(s3_pts, s3_ox, s3_oy), "gaps": [], "blockers": []
})

# Slider 4: cyan_slider_bot (L-slider)
s4_ox, s4_oy = 420.0, 745.0
s4_pos_x, s4_pos_y = to_g(s4_ox, s4_oy)
s4_pts = [(600.0, 745.0), (420.0, 745.0), (420.0, 810.0)]
level_24["pieces"].append({
    "id": "cyan_slider_bot", "color_name": "cyan", "color_hex": "#2BBBEF",
    "x": s4_pos_x, "y": s4_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 1,
    "has_acorn": False,
    "motion_axis": {"x": 1.0, "y": 0.0}, "slide_max": 300.0,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 1,
    "path_points": to_rel(s4_pts, s4_ox, s4_oy), "gaps": [], "blockers": []
})

# Slider 5: orange_slider_vert
s5_ox, s5_oy = 395.0, 730.0
s5_pos_x, s5_pos_y = to_g(s5_ox, s5_oy)
s5_pts = [(395.0, 730.0), (395.0, 825.0)]
level_24["pieces"].append({
    "id": "orange_slider_vert", "color_name": "orange", "color_hex": "#EA7829",
    "x": s5_pos_x, "y": s5_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": 1.0}, "slide_max": 250.0,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "path_points": to_rel(s5_pts, s5_ox, s5_oy), "gaps": [], "blockers": []
})

# Slider 6: orange_slider_u
s6_ox, s6_oy = 281.0, 880.0
s6_pos_x, s6_pos_y = to_g(s6_ox, s6_oy)
s6_pts = [(281.0, 810.0), (281.0, 880.0), (520.0, 880.0), (520.0, 810.0)]
level_24["pieces"].append({
    "id": "orange_slider_u", "color_name": "orange", "color_hex": "#EA7829",
    "x": s6_pos_x, "y": s6_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 1,
    "has_acorn": False,
    "motion_axis": {"x": 0.0, "y": 1.0}, "slide_max": 300.0,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "path_points": to_rel(s6_pts, s6_ox, s6_oy), "gaps": [], "blockers": []
})

# Slider 7: orange_slider_bar
s7_ox, s7_oy = 305.0, 845.0
s7_pos_x, s7_pos_y = to_g(s7_ox, s7_oy)
s7_pts = [(305.0, 845.0), (490.0, 845.0)]
level_24["pieces"].append({
    "id": "orange_slider_bar", "color_name": "orange", "color_hex": "#EA7829",
    "x": s7_pos_x, "y": s7_pos_y, "start_angle_deg": 0.0,
    "radius": 14.0, "radius_y": 14.0, "thickness": 18.0,
    "shape_type": 5, "piece_type": 0, "role": 0, "z_index": 2,
    "has_acorn": False,
    "motion_axis": {"x": 1.0, "y": 0.0}, "slide_max": 250.0,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 1,
    "path_points": to_rel(s7_pts, s7_ox, s7_oy), "gaps": [], "blockers": []
})

# --- LINKS ---
# 1. cyan_r2 holds green_r1 (up, 270 deg)
level_24["links"].append({
    "id": "link_cyan_r2_green_r1", "from_piece_id": "cyan_r2", "to_piece_id": "green_r1",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 270.0, "length": 30.0
})

# 2. cyan_r2 holds orange_r2 (right, 0 deg)
level_24["links"].append({
    "id": "link_cyan_r2_orange_r2", "from_piece_id": "cyan_r2", "to_piece_id": "orange_r2",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 0.0, "length": 30.0
})

# 3. cyan_r2 holds green_slider_tl (left, 180 deg)
level_24["links"].append({
    "id": "link_cyan_r2_slider_tl", "from_piece_id": "cyan_r2", "to_piece_id": "green_slider_tl",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 180.0, "length": 30.0
})

# 4. cyan_r2 holds red_slider_mid (down, 90 deg)
level_24["links"].append({
    "id": "link_cyan_r2_slider_mid", "from_piece_id": "cyan_r2", "to_piece_id": "red_slider_mid",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 90.0, "length": 30.0
})

# 5. green_r1 holds blue_r1 (right, 0 deg)
level_24["links"].append({
    "id": "link_green_r1_blue_r1", "from_piece_id": "green_r1", "to_piece_id": "blue_r1",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 0.0, "length": 30.0
})

# 6. red_r1 holds blue_r1 (left, 180 deg)
level_24["links"].append({
    "id": "link_red_r1_blue_r1", "from_piece_id": "red_r1", "to_piece_id": "blue_r1",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 180.0, "length": 30.0
})

# 7. red_r1 holds purple_r2 (down, 90 deg)
level_24["links"].append({
    "id": "link_red_r1_purple_r2", "from_piece_id": "red_r1", "to_piece_id": "purple_r2",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 90.0, "length": 30.0
})

# 8. orange_r2 holds red_slider_mid (down, 90 deg)
level_24["links"].append({
    "id": "link_orange_r2_slider_mid", "from_piece_id": "orange_r2", "to_piece_id": "red_slider_mid",
    "color_name": "orange", "color_hex": "#EA7829", "anchor_angle_deg": 90.0, "length": 30.0
})

# 9. purple_r2 holds red_slider_mid (down, 90 deg)
level_24["links"].append({
    "id": "link_purple_r2_slider_mid", "from_piece_id": "purple_r2", "to_piece_id": "red_slider_mid",
    "color_name": "purple", "color_hex": "#9B51E0", "anchor_angle_deg": 90.0, "length": 30.0
})

# 10. blue_r3 holds red_slider_mid (up, 270 deg)
level_24["links"].append({
    "id": "link_blue_r3_slider_mid", "from_piece_id": "blue_r3", "to_piece_id": "red_slider_mid",
    "color_name": "blue", "color_hex": "#2F80ED", "anchor_angle_deg": 270.0, "length": 30.0
})

# 11. blue_r3 holds cyan_r3 (left, 180 deg)
level_24["links"].append({
    "id": "link_blue_r3_cyan_r3", "from_piece_id": "blue_r3", "to_piece_id": "cyan_r3",
    "color_name": "blue", "color_hex": "#2F80ED", "anchor_angle_deg": 180.0, "length": 30.0
})

# 12. blue_r3 holds green_r3 (right, 0 deg)
level_24["links"].append({
    "id": "link_blue_r3_green_r3", "from_piece_id": "blue_r3", "to_piece_id": "green_r3",
    "color_name": "blue", "color_hex": "#2F80ED", "anchor_angle_deg": 0.0, "length": 30.0
})

# 13. green_r3 holds orange_r3 (right, 0 deg)
level_24["links"].append({
    "id": "link_green_r3_orange_r3", "from_piece_id": "green_r3", "to_piece_id": "orange_r3",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 0.0, "length": 30.0
})

# 14. green_r3 holds purple_r4 (down, 90 deg)
level_24["links"].append({
    "id": "link_green_r3_purple_r4", "from_piece_id": "green_r3", "to_piece_id": "purple_r4",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 90.0, "length": 30.0
})

# 15. red_r4 holds orange_r3 (up, 270 deg)
level_24["links"].append({
    "id": "link_red_r4_orange_r3", "from_piece_id": "red_r4", "to_piece_id": "orange_r3",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 270.0, "length": 30.0
})

# 16. green_r4 (closed hub) holds blue_r4 (left, 180 deg)
level_24["links"].append({
    "id": "link_green_r4_blue_r4", "from_piece_id": "green_r4", "to_piece_id": "blue_r4",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 180.0, "length": 30.0
})

# 17. green_r4 holds purple_r4 (right, 0 deg)
level_24["links"].append({
    "id": "link_green_r4_purple_r4", "from_piece_id": "green_r4", "to_piece_id": "purple_r4",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 0.0, "length": 30.0
})

# 18. green_r4 holds green_slider_bot (down, 90 deg)
level_24["links"].append({
    "id": "link_green_r4_slider_bot", "from_piece_id": "green_r4", "to_piece_id": "green_slider_bot",
    "color_name": "green", "color_hex": "#27AE60", "anchor_angle_deg": 90.0, "length": 30.0
})

# 19. red_r4 holds purple_r4 (left, 180 deg)
level_24["links"].append({
    "id": "link_red_r4_purple_r4", "from_piece_id": "red_r4", "to_piece_id": "purple_r4",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 180.0, "length": 30.0
})

# 20. red_r4 holds cyan_slider_bot (down, 90 deg)
level_24["links"].append({
    "id": "link_red_r4_slider_bot", "from_piece_id": "red_r4", "to_piece_id": "cyan_slider_bot",
    "color_name": "red", "color_hex": "#EB5757", "anchor_angle_deg": 90.0, "length": 30.0
})

# 21. cyan_r5 (closed hub) holds green_slider_bot (up, 270 deg)
level_24["links"].append({
    "id": "link_cyan_r5_slider_bot", "from_piece_id": "cyan_r5", "to_piece_id": "green_slider_bot",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 270.0, "length": 30.0
})

# 22. cyan_r5 holds orange_slider_u (right, 0 deg)
level_24["links"].append({
    "id": "link_cyan_r5_slider_u", "from_piece_id": "cyan_r5", "to_piece_id": "orange_slider_u",
    "color_name": "cyan", "color_hex": "#2BBBEF", "anchor_angle_deg": 0.0, "length": 30.0
})

with open("data/user_levels/24.json", "w") as f:
    json.dump(level_24, f, indent=2)

print("Successfully wrote data/user_levels/24.json!")
