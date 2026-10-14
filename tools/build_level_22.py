import json
import math

scale = 720.0 / 685.0
y_off = 20.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

def to_rel(pts, ox, oy):
    return [{"x": round((p[0] - ox) * scale, 1), "y": round((p[1] - oy) * scale, 1)} for p in pts]

level_22 = {
    "id": 22,
    "title": "Level 22",
    "par_moves": 22,
    "theme_id": "porcelain",
    "pieces": [],
    "links": []
}

# 1. giant red ring (C-ring)
gx, gy = to_g(334.0, 553.0)
level_22["pieces"].append({
    "id": "red_giant_ring",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": gx, "y": gy,
    "start_angle_deg": 0.0,
    "radius": 185.0,
    "radius_y": 185.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 120.0, "width_deg": 48.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 2. blue_top_hub (Role 1: HUB)
bx, by = to_g(333.0, 311.0)
level_22["pieces"].append({
    "id": "blue_top_hub",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": bx, "y": by,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 0,
    "role": 1,
    "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [],
    "blockers": []
})

# 3. orange_tl_ring
ox, oy = to_g(178.0, 255.0)
level_22["pieces"].append({
    "id": "orange_tl_ring",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": ox, "y": oy,
    "start_angle_deg": 0.0,
    "radius": 42.0,
    "radius_y": 42.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 4. purple_tl_ring
px, py = to_g(136.0, 350.0)
level_22["pieces"].append({
    "id": "purple_tl_ring",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "x": px, "y": py,
    "start_angle_deg": 0.0,
    "radius": 44.0,
    "radius_y": 44.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 5. green_inner
igx, igy = to_g(334.0, 490.0)
level_22["pieces"].append({
    "id": "green_inner",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": igx, "y": igy,
    "start_angle_deg": 0.0,
    "radius": 49.0,
    "radius_y": 49.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 6. orange_inner
iox, ioy = to_g(275.0, 595.0)
level_22["pieces"].append({
    "id": "orange_inner",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": iox, "y": ioy,
    "start_angle_deg": 0.0,
    "radius": 49.0,
    "radius_y": 49.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": [{"angle_deg": 180.0, "length": 20.0, "width": 14.0}]
})

# 7. cyan_inner
icx, icy = to_g(395.0, 595.0)
level_22["pieces"].append({
    "id": "cyan_inner",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": icx, "y": icy,
    "start_angle_deg": 0.0,
    "radius": 49.0,
    "radius_y": 49.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# 8. blue_br_ring
brx, bry = to_g(479.1, 749.1)
level_22["pieces"].append({
    "id": "blue_br_ring",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": brx, "y": bry,
    "start_angle_deg": 0.0,
    "radius": 46.0,
    "radius_y": 46.0,
    "thickness": 18.0,
    "shape_type": 0,
    "piece_type": 1,
    "role": 0,
    "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 45.0, "width_deg": 110.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Sliders:
# 9. red_slider_left: held by purple_tl_ring
rsl_pts = [(136, 394), (75, 394), (75, 535)]
rsl_ox, rsl_oy = to_g(136, 394)
level_22["pieces"].append({
    "id": "red_slider_left",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": rsl_ox, "y": rsl_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(rsl_pts, 136, 394),
    "sleeves": [],
    "gaps": []
})

# 10. orange_slider_left: sleeve at (105, 595)
osl_pts = [(140, 440), (105, 440), (105, 750)]
osl_ox, osl_oy = to_g(105, 595)
level_22["pieces"].append({
    "id": "orange_slider_left",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": osl_ox, "y": osl_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 120.0,
    "path_points": to_rel(osl_pts, 105, 595),
    "sleeves": [{"x": osl_ox, "y": osl_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 11. cyan_slider_tl: vertical rod at x=245, bottom turn to x=205
cstl_pts = [(245, 160), (245, 305), (205, 305)]
cstl_ox, cstl_oy = to_g(245, 305)
level_22["pieces"].append({
    "id": "cyan_slider_tl",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": cstl_ox, "y": cstl_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": -1.0},
    "slide_min": 0.0,
    "slide_max": 100.0,
    "path_points": to_rel(cstl_pts, 245, 305),
    "sleeves": [],
    "gaps": []
})

# 12. green_slider_tr: vertical rod at x=415, bottom turn to x=455
gstr_pts = [(415, 215), (415, 305), (455, 305)]
gstr_ox, gstr_oy = to_g(415, 305)
level_22["pieces"].append({
    "id": "green_slider_tr",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": gstr_ox, "y": gstr_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": -1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(gstr_pts, 415, 305),
    "sleeves": [],
    "gaps": []
})

# 13. blue_slider_tr: S-hook, sleeve at (488, 396)
bstr_pts = [(445, 125), (445, 235), (488, 235), (488, 435)]
bstr_ox, bstr_oy = to_g(488, 396)
level_22["pieces"].append({
    "id": "blue_slider_tr",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": bstr_ox, "y": bstr_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": -1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(bstr_pts, 488, 396),
    "sleeves": [{"x": bstr_ox, "y": bstr_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 14. red_slider_tr: L-hook, sleeve at (517, 357)
rstr_pts = [(465, 160), (517, 160), (517, 515)]
rstr_ox, rstr_oy = to_g(517, 357)
level_22["pieces"].append({
    "id": "red_slider_tr",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": rstr_ox, "y": rstr_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(rstr_pts, 517, 357),
    "sleeves": [{"x": rstr_ox, "y": rstr_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 15. green_slider_mr: L-hook, sleeve at (570, 424)
gsmr_pts = [(570, 330), (570, 510), (525, 510)]
gsmr_ox, gsmr_oy = to_g(570, 424)
level_22["pieces"].append({
    "id": "green_slider_mr",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": gsmr_ox, "y": gsmr_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": -1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(gsmr_pts, 570, 424),
    "sleeves": [{"x": gsmr_ox, "y": gsmr_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 16. green_slider_br: L-hook, sleeve at (532, 648)
gsbr_pts = [(575, 580), (532, 580), (532, 680)]
gsbr_ox, gsbr_oy = to_g(532, 648)
level_22["pieces"].append({
    "id": "green_slider_br",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": gsbr_ox, "y": gsbr_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(gsbr_pts, 532, 648),
    "sleeves": [{"x": gsbr_ox, "y": gsbr_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 17. cyan_slider_bot: Z-hook, sleeve at (342, 812)
csb_pts = [(265, 685), (265, 755), (342, 755), (342, 950)]
csb_ox, csb_oy = to_g(342, 812)
level_22["pieces"].append({
    "id": "cyan_slider_bot",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": csb_ox, "y": csb_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 100.0,
    "path_points": to_rel(csb_pts, 342, 812),
    "sleeves": [{"x": csb_ox, "y": csb_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# 18. orange_slider_bot: L-hook, sleeve at (407, 820)
osb_pts = [(365, 760), (407, 760), (407, 880)]
osb_ox, osb_oy = to_g(407, 820)
level_22["pieces"].append({
    "id": "orange_slider_bot",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": osb_ox, "y": osb_oy,
    "start_angle_deg": 0.0,
    "radius": 45.0,
    "radius_y": 45.0,
    "thickness": 18.0,
    "shape_type": 5,
    "piece_type": 0,
    "role": 0,
    "z_index": 2,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 1,
    "motion_axis": {"x": 0.0, "y": 1.0},
    "slide_min": 0.0,
    "slide_max": 90.0,
    "path_points": to_rel(osb_pts, 407, 820),
    "sleeves": [{"x": osb_ox, "y": osb_oy, "axis": {"x": 0.0, "y": 1.0}}],
    "gaps": []
})

# Links:
# 1. blue_top_hub holds red_giant_ring at 90 deg (down)
level_22["links"].append({
    "id": "link_blue_hub_giant_red",
    "from_piece_id": "blue_top_hub",
    "to_piece_id": "red_giant_ring",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "anchor_angle_deg": 90.0,
    "length": 40.0
})

# 2. blue_top_hub holds cyan_slider_tl at 180 deg (left)
level_22["links"].append({
    "id": "link_blue_hub_cyan_slider",
    "from_piece_id": "blue_top_hub",
    "to_piece_id": "cyan_slider_tl",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "anchor_angle_deg": 180.0,
    "length": 40.0
})

# 3. blue_top_hub holds green_slider_tr at 0 deg (right)
level_22["links"].append({
    "id": "link_blue_hub_green_slider",
    "from_piece_id": "blue_top_hub",
    "to_piece_id": "green_slider_tr",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "anchor_angle_deg": 0.0,
    "length": 40.0
})

# 4. orange_tl_ring holds cyan_slider_tl at 0 deg (right)
level_22["links"].append({
    "id": "link_orange_tl_cyan_slider",
    "from_piece_id": "orange_tl_ring",
    "to_piece_id": "cyan_slider_tl",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "anchor_angle_deg": 0.0,
    "length": 25.0
})

# 5. purple_tl_ring holds orange_tl_ring at 45 deg (up-right)
level_22["links"].append({
    "id": "link_purple_tl_orange_tl",
    "from_piece_id": "purple_tl_ring",
    "to_piece_id": "orange_tl_ring",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "anchor_angle_deg": 315.0, # up-right
    "length": 35.0
})

# 6. purple_tl_ring holds red_slider_left at 90 deg (down)
level_22["links"].append({
    "id": "link_purple_tl_red_slider",
    "from_piece_id": "purple_tl_ring",
    "to_piece_id": "red_slider_left",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "anchor_angle_deg": 90.0,
    "length": 25.0
})

# 7. green_inner holds orange_inner at 125 deg (down-left)
level_22["links"].append({
    "id": "link_green_inner_orange_inner",
    "from_piece_id": "green_inner",
    "to_piece_id": "orange_inner",
    "color_name": "green",
    "color_hex": "#27AE60",
    "anchor_angle_deg": 125.0,
    "length": 35.0
})

# 8. green_inner holds cyan_inner at 55 deg (down-right)
level_22["links"].append({
    "id": "link_green_inner_cyan_inner",
    "from_piece_id": "green_inner",
    "to_piece_id": "cyan_inner",
    "color_name": "green",
    "color_hex": "#27AE60",
    "anchor_angle_deg": 55.0,
    "length": 35.0
})

# 9. red_giant_ring holds blue_br_ring at 45 deg (down-right)
level_22["links"].append({
    "id": "link_giant_red_blue_br",
    "from_piece_id": "red_giant_ring",
    "to_piece_id": "blue_br_ring",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "anchor_angle_deg": 55.0,
    "length": 30.0
})

with open("data/user_levels/22.json", "w") as f:
    json.dump(level_22, f, indent=2)

print("Successfully wrote data/user_levels/22.json!")
