with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_rules.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

# We need to replace `piece.radius` with boundary distance in pos_cuff calculations
old_cuff = 'var pos_cuff: Vector2 = from_p.position + dir * (link.def.stem_dist - piece.radius)'
new_cuff = """var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
				var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
				var pos_cuff: Vector2 = from_p.position + dir * (link.def.stem_dist - child_r)"""

text = text.replace(old_cuff, new_cuff)

old_cuff_2 = 'var pos_cuff: Vector2 = parent_p.position + dir * (link_in.def.stem_dist - piece.radius)'
new_cuff_2 = """var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
			var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
			var pos_cuff: Vector2 = parent_p.position + dir * (link_in.def.stem_dist - child_r)"""
text = text.replace(old_cuff_2, new_cuff_2)

old_child = 'var child_r: float = child_p.radius if child_p else 76.0'
new_child = """var shape_type = child_p.def.shape_type if child_p and child_p.get("def") and "shape_type" in child_p.def else 0
		var c_rot = child_p.rotation if child_p else 0.0
		var child_r: float = PieceGeometry.get_world_boundary_distance(shape_type, child_p.radius if child_p else 76.0, c_rot, stem_dir.angle() + PI)"""
text = text.replace(old_child, new_child)

old_parent = 'var parent_outer_r: float = active_limiter_parent.radius + parent_thickness * 0.5'
new_parent = """var p_shape = active_limiter_parent.def.shape_type if active_limiter_parent.get("def") and "shape_type" in active_limiter_parent.def else 0
		var parent_outer_r: float = PieceGeometry.get_world_boundary_distance(p_shape, active_limiter_parent.radius, active_limiter_parent.rotation, to_head.angle()) + parent_thickness * 0.5"""
text = text.replace(old_parent, new_parent)

with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_rules.gd", "w", encoding="utf-8") as f:
    f.write(text)
