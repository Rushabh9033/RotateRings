with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

# Update _draw() calls to pass def.shape_type
text = text.replace(
    '_draw_ring_arc(Vector2.ZERO, radius, 0.0, TAU, seg_count, cap_r, is_closed)',
    '_draw_ring_arc(Vector2.ZERO, radius, 0.0, TAU, seg_count, cap_r, is_closed, def.shape_type)'
)

text = text.replace(
    'draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, glow_c, thickness + 12.0, true)',
    '_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, glow_c, thickness + 12.0, def.shape_type)'
)

text = text.replace(
    'draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, true)',
    '_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, def.shape_type)'
)

text = text.replace(
    'draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, true)',
    '_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, def.shape_type)'
)

text = text.replace(
    '_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, false)',
    '_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, false, def.shape_type)'
)


func_draw_ring_arc = """func _draw_ring_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool, shape_type: int) -> void:
	# PERFORMANCE: fixed 72 segs for shapes
	segs = 72
	
	var shadow_off1 := Vector2(0, 6.0) * shadow_offset_mult
	var off_dark := Vector2(0, 2.5)
	
	_draw_poly_arc(center + shadow_off1, r, a_start, a_end, segs, _c_shadow, thickness + 2.0, shape_type)
	if not is_closed:
		var p_start = center + shadow_off1 + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + shadow_off1 + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r + 1.0, _c_shadow)
		draw_circle(p_end, cap_r + 1.0, _c_shadow)
		
	_draw_poly_arc(center + off_dark, r, a_start, a_end, segs, _c_dark, thickness, shape_type)
	if not is_closed:
		var p_start = center + off_dark + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + off_dark + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r, _c_dark)
		draw_circle(p_end, cap_r, _c_dark)
		
	_draw_poly_arc(center, r, a_start, a_end, segs, _c_main, thickness, shape_type)
	if not is_closed:
		var p_start = center + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r, _c_main)
		draw_circle(p_end, cap_r, _c_main)
		
	var off_hl := Vector2(-1.5, -2.5)
	var hl_w = thickness * 0.4
	_draw_poly_arc(center + off_hl, r, a_start, a_end, segs, _c_light, hl_w, shape_type)

func _draw_poly_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, color: Color, line_width: float, shape_type: int) -> void:
	var pts = PackedVector2Array()
	var step = (a_end - a_start) / float(segs)
	for i in range(segs + 1):
		var theta = a_start + step * i
		var dist = PieceGeometry.get_boundary_distance(shape_type, r, theta)
		pts.append(center + Vector2(cos(theta), sin(theta)) * dist)
	
	if pts.size() >= 2:
		draw_polyline(pts, color, line_width, true)
"""

# We need to replace the old _draw_ring_arc function entirely.
# Let's find it.
start_idx = text.find('func _draw_ring_arc(')
if start_idx != -1:
    text = text[:start_idx] + func_draw_ring_arc

with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "w", encoding="utf-8") as f:
    f.write(text)
