import json
import math

scale = 720.0 / 685.0
y_off = 35.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

# Centroids fitted directly from ref 23.jpeg
C = {
    "purple_hub_tl": (221.0, 340.0),
    "green_tr": (500.0, 270.0),
    "green_outer_tm": (365.0, 310.0),
    "orange_outer_tl": (199.0, 480.0),
    "orange_outer_tr": (545.0, 460.0),
    "red_outer_mid": (365.0, 480.0),
    "blue_outer_ml": (191.0, 620.0),
    "blue_hub_mid": (370.0, 620.0),
    "red_outer_mr": (545.0, 610.0),
    "cyan_mid_bot": (320.0, 690.0),
    "green_outer_bl": (195.0, 815.0),
    "red_bot": (385.0, 775.0),
    "orange_outer_br": (545.0, 770.0)
}

level_23 = {
    "id": 23,
    "title": "Level 23",
    "par_moves": 26,
    "theme_id": "porcelain",
    "pieces": [],
    "links": []
}

# Hub 1: purple_hub_tl
ptx, pty = to_g(*C["purple_hub_tl"])
level_23["pieces"].append({
    "id": "purple_hub_tl",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "x": ptx, "y": pty,
    "start_angle_deg": 0.0,
    "radius": 46.0, "radius_y": 46.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

# Hub 2: blue_hub_mid
bmx, bmy = to_g(*C["blue_hub_mid"])
level_23["pieces"].append({
    "id": "blue_hub_mid",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": bmx, "y": bmy,
    "start_angle_deg": 0.0,
    "radius": 46.0, "radius_y": 46.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 0, "role": 1, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [], "blockers": []
})

# Pair 1: orange_outer_tl (R=72), cyan_inner_tl (R=43)
p1x, p1y = to_g(*C["orange_outer_tl"])
level_23["pieces"].append({
    "id": "orange_outer_tl",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": p1x, "y": p1y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 45.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "cyan_inner_tl",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": p1x, "y": p1y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 2: green_outer_tm (R=72), cyan_inner_top (R=43)
p2x, p2y = to_g(*C["green_outer_tm"])
level_23["pieces"].append({
    "id": "green_outer_tm",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": p2x, "y": p2y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 135.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "cyan_inner_top",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": p2x, "y": p2y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Single: green_tr (R=42)
gtx, gty = to_g(*C["green_tr"])
level_23["pieces"].append({
    "id": "green_tr",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": gtx, "y": gty,
    "start_angle_deg": 0.0,
    "radius": 42.0, "radius_y": 42.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 3: orange_outer_tr (R=72), purple_inner_tr (R=43)
p3x, p3y = to_g(*C["orange_outer_tr"])
level_23["pieces"].append({
    "id": "orange_outer_tr",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": p3x, "y": p3y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "purple_inner_tr",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "x": p3x, "y": p3y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 135.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 4: blue_outer_ml (R=72), green_inner_ml (R=43)
p4x, p4y = to_g(*C["blue_outer_ml"])
level_23["pieces"].append({
    "id": "blue_outer_ml",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": p4x, "y": p4y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "green_inner_ml",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": p4x, "y": p4y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 225.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 5: red_outer_mid (R=65), green_inner_mid (R=40)
p5x, p5y = to_g(*C["red_outer_mid"])
level_23["pieces"].append({
    "id": "red_outer_mid",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": p5x, "y": p5y,
    "start_angle_deg": 0.0,
    "radius": 65.0, "radius_y": 65.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 270.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "green_inner_mid",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": p5x, "y": p5y,
    "start_angle_deg": 0.0,
    "radius": 40.0, "radius_y": 40.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 225.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 6: red_outer_mr (R=68), green_inner_mr (R=43)
p6x, p6y = to_g(*C["red_outer_mr"])
level_23["pieces"].append({
    "id": "red_outer_mr",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": p6x, "y": p6y,
    "start_angle_deg": 0.0,
    "radius": 68.0, "radius_y": 68.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "green_inner_mr",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": p6x, "y": p6y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 0.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 0.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Single: cyan_mid_bot (R=42)
cbx, cby = to_g(*C["cyan_mid_bot"])
level_23["pieces"].append({
    "id": "cyan_mid_bot",
    "color_name": "cyan",
    "color_hex": "#2BBBEF",
    "x": cbx, "y": cby,
    "start_angle_deg": 0.0,
    "radius": 42.0, "radius_y": 42.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": -1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 180.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 7: green_outer_bl (R=72), blue_inner_bl (R=43)
p7x, p7y = to_g(*C["green_outer_bl"])
level_23["pieces"].append({
    "id": "green_outer_bl",
    "color_name": "green",
    "color_hex": "#27AE60",
    "x": p7x, "y": p7y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 225.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "blue_inner_bl",
    "color_name": "blue",
    "color_hex": "#2F80ED",
    "x": p7x, "y": p7y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": -1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 45.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Single: red_bot (R=45)
rbx, rby = to_g(*C["red_bot"])
level_23["pieces"].append({
    "id": "red_bot",
    "color_name": "red",
    "color_hex": "#EB5757",
    "x": rbx, "y": rby,
    "start_angle_deg": 0.0,
    "radius": 45.0, "radius_y": 45.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 0.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Pair 8: orange_outer_br (R=72), purple_inner_br (R=43)
p8x, p8y = to_g(*C["orange_outer_br"])
level_23["pieces"].append({
    "id": "orange_outer_br",
    "color_name": "orange",
    "color_hex": "#EA7829",
    "x": p8x, "y": p8y,
    "start_angle_deg": 0.0,
    "radius": 72.0, "radius_y": 72.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 225.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})
level_23["pieces"].append({
    "id": "purple_inner_br",
    "color_name": "purple",
    "color_hex": "#9B51E0",
    "x": p8x, "y": p8y,
    "start_angle_deg": 0.0,
    "radius": 43.0, "radius_y": 43.0, "thickness": 18.0,
    "shape_type": 0, "piece_type": 1, "role": 0, "z_index": 2,
    "has_acorn": False,
    "release_direction": {"x": 1.0, "y": 1.0},
    "motion_model": 0,
    "gaps": [{"center_angle_deg": 90.0, "width_deg": 105.0, "tolerance_deg": 16.0}],
    "blockers": []
})

# Links:
# 1. purple_hub_tl holds cyan_inner_tl (down-left)
level_23["links"].append({
    "id": "link_purple_hub_cyan_tl",
    "from_piece_id": "purple_hub_tl", "to_piece_id": "cyan_inner_tl",
    "color_name": "purple", "color_hex": "#9B51E0",
    "anchor_angle_deg": 115.0, "length": 35.0
})

# 2. purple_hub_tl holds cyan_inner_top (right, ~0 deg)
level_23["links"].append({
    "id": "link_purple_hub_cyan_top",
    "from_piece_id": "purple_hub_tl", "to_piece_id": "cyan_inner_top",
    "color_name": "purple", "color_hex": "#9B51E0",
    "anchor_angle_deg": 0.0, "length": 35.0
})

# 3. green_outer_tm holds orange_outer_tr (down-right, ~35 deg)
level_23["links"].append({
    "id": "link_green_tm_orange_tr",
    "from_piece_id": "green_outer_tm", "to_piece_id": "orange_outer_tr",
    "color_name": "orange", "color_hex": "#EA7829",
    "anchor_angle_deg": 35.0, "length": 30.0
})

# 4. green_outer_tm holds red_outer_mid (down, 90 deg)
level_23["links"].append({
    "id": "link_green_tm_red_mid",
    "from_piece_id": "green_outer_tm", "to_piece_id": "red_outer_mid",
    "color_name": "green", "color_hex": "#27AE60",
    "anchor_angle_deg": 90.0, "length": 30.0
})

# 5. orange_outer_tr holds green_tr (up, 270 deg)
level_23["links"].append({
    "id": "link_orange_tr_green_tr",
    "from_piece_id": "orange_outer_tr", "to_piece_id": "green_tr",
    "color_name": "orange", "color_hex": "#EA7829",
    "anchor_angle_deg": 270.0, "length": 30.0
})

# 6. orange_outer_tr holds purple_inner_tr (down-left, 135 deg)
level_23["links"].append({
    "id": "link_orange_tr_purple_tr",
    "from_piece_id": "orange_outer_tr", "to_piece_id": "purple_inner_tr",
    "color_name": "orange", "color_hex": "#EA7829",
    "anchor_angle_deg": 135.0, "length": 25.0
})

# 7. orange_outer_tr holds red_outer_mr (down, 90 deg)
level_23["links"].append({
    "id": "link_orange_tr_red_mr",
    "from_piece_id": "orange_outer_tr", "to_piece_id": "red_outer_mr",
    "color_name": "red", "color_hex": "#EB5757",
    "anchor_angle_deg": 90.0, "length": 30.0
})

# 8. red_outer_mid holds orange_outer_tl (up-left, 145 deg)
level_23["links"].append({
    "id": "link_red_mid_orange_tl",
    "from_piece_id": "red_outer_mid", "to_piece_id": "orange_outer_tl",
    "color_name": "red", "color_hex": "#EB5757",
    "anchor_angle_deg": 145.0, "length": 30.0
})

# 9. blue_hub_mid holds green_inner_mid (up-left, 315 deg)
level_23["links"].append({
    "id": "link_blue_hub_green_mid",
    "from_piece_id": "blue_hub_mid", "to_piece_id": "green_inner_mid",
    "color_name": "blue", "color_hex": "#2F80ED",
    "anchor_angle_deg": 315.0, "length": 30.0
})

# 10. blue_hub_mid holds green_inner_mr (right, 0 deg)
level_23["links"].append({
    "id": "link_blue_hub_green_mr",
    "from_piece_id": "blue_hub_mid", "to_piece_id": "green_inner_mr",
    "color_name": "blue", "color_hex": "#2F80ED",
    "anchor_angle_deg": 0.0, "length": 30.0
})

# 11. blue_hub_mid holds cyan_mid_bot (down-left, 225 deg)
level_23["links"].append({
    "id": "link_blue_hub_cyan_bot",
    "from_piece_id": "blue_hub_mid", "to_piece_id": "cyan_mid_bot",
    "color_name": "blue", "color_hex": "#2F80ED",
    "anchor_angle_deg": 225.0, "length": 30.0
})

# 12. orange_outer_tl holds blue_outer_ml (down, 90 deg)
level_23["links"].append({
    "id": "link_orange_tl_blue_ml",
    "from_piece_id": "orange_outer_tl", "to_piece_id": "blue_outer_ml",
    "color_name": "orange", "color_hex": "#EA7829",
    "anchor_angle_deg": 90.0, "length": 30.0
})

# 13. blue_outer_ml holds green_inner_ml (up-right, 45 deg)
level_23["links"].append({
    "id": "link_blue_ml_green_ml",
    "from_piece_id": "blue_outer_ml", "to_piece_id": "green_inner_ml",
    "color_name": "blue", "color_hex": "#2F80ED",
    "anchor_angle_deg": 45.0, "length": 25.0
})

# 14. green_outer_bl holds blue_outer_ml (up, 270 deg)
level_23["links"].append({
    "id": "link_green_bl_blue_ml",
    "from_piece_id": "green_outer_bl", "to_piece_id": "blue_outer_ml",
    "color_name": "green", "color_hex": "#27AE60",
    "anchor_angle_deg": 270.0, "length": 30.0
})

# 15. green_outer_bl holds blue_inner_bl (up-left, 135 deg)
level_23["links"].append({
    "id": "link_green_bl_blue_bl",
    "from_piece_id": "green_outer_bl", "to_piece_id": "blue_inner_bl",
    "color_name": "green", "color_hex": "#27AE60",
    "anchor_angle_deg": 135.0, "length": 25.0
})

# 16. green_outer_bl holds red_bot (right, 0 deg)
level_23["links"].append({
    "id": "link_green_bl_red_bot",
    "from_piece_id": "green_outer_bl", "to_piece_id": "red_bot",
    "color_name": "green", "color_hex": "#27AE60",
    "anchor_angle_deg": 0.0, "length": 30.0
})

# 17. red_bot holds cyan_mid_bot (up-left, 315 deg)
level_23["links"].append({
    "id": "link_red_bot_cyan_bot",
    "from_piece_id": "red_bot", "to_piece_id": "cyan_mid_bot",
    "color_name": "red", "color_hex": "#EB5757",
    "anchor_angle_deg": 315.0, "length": 30.0
})

# 18. red_bot holds orange_outer_br (right, 0 deg)
level_23["links"].append({
    "id": "link_red_bot_orange_br",
    "from_piece_id": "red_bot", "to_piece_id": "orange_outer_br",
    "color_name": "red", "color_hex": "#EB5757",
    "anchor_angle_deg": 0.0, "length": 30.0
})

# 19. red_outer_mr holds purple_inner_br (down, 90 deg)
level_23["links"].append({
    "id": "link_red_mr_purple_br",
    "from_piece_id": "red_outer_mr", "to_piece_id": "purple_inner_br",
    "color_name": "purple", "color_hex": "#9B51E0",
    "anchor_angle_deg": 90.0, "length": 30.0
})

with open("data/user_levels/23.json", "w") as f:
    json.dump(level_23, f, indent=2)

print("Successfully wrote data/user_levels/23.json!")
