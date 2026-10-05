with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_controller.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

# We will just rewrite _get_child_radius_for_link to _get_child_boundary_distance(link, dir: Vector2)
func_get_child_old = """func _get_child_radius_for_link(link: ConnectorRuntime) -> float:
	var to_p = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, active_pieces)
	if is_instance_valid(to_p):
		return to_p.radius
	if current_level_def:
		for p_def in current_level_def.pieces:
			if p_def.id == link.def.to_piece_id:
				return p_def.radius
	return 72.0"""

func_get_child_new = """func _get_child_boundary_distance(link: ConnectorRuntime, dir: Vector2) -> float:
	var shape_type = 0
	var r = 72.0
	var rot = 0.0
	var to_p = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, active_pieces)
	if is_instance_valid(to_p):
		shape_type = to_p.def.shape_type if to_p.get("def") and "shape_type" in to_p.def else 0
		r = to_p.radius
		rot = to_p.global_rotation
	elif current_level_def:
		for p_def in current_level_def.pieces:
			if p_def.id == link.def.to_piece_id:
				shape_type = p_def.shape_type if "shape_type" in p_def else 0
				r = p_def.radius
				rot = deg_to_rad(p_def.start_angle_deg)
				break
	return PieceGeometry.get_world_boundary_distance(shape_type, r, rot, dir.angle() + PI)
"""

text = text.replace(func_get_child_old, func_get_child_new)

# In _on_stems_layer_draw
text = text.replace(
    'var child_r: float = _get_child_radius_for_link(link)',
    'var child_r: float = _get_child_boundary_distance(link, dir)'
)

text = text.replace(
    'var pos_stem_start: Vector2 = from_p.position + dir * from_p.radius',
    'var parent_shape = from_p.def.shape_type if from_p.get("def") and "shape_type" in from_p.def else 0\n\t\tvar pos_stem_start: Vector2 = from_p.position + dir * PieceGeometry.get_boundary_distance(parent_shape, from_p.radius, deg_to_rad(link.def.collar_angle_deg))'
)

with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_controller.gd", "w", encoding="utf-8") as f:
    f.write(text)
