with open("D:/AI secound Brain/RotateRings/gameplay/hint_controller.gd", "r", encoding="utf-8") as f:
    text = f.read()

hint_old = """			var r = piece.radius
			var center = piece.global_position
			var grab_offset = Vector2.RIGHT * r
			var from_pos = center + grab_offset.rotated(deg_to_rad(start_deg))
			var to_pos = center + grab_offset.rotated(deg_to_rad(target_deg))"""

hint_new = """			var center = piece.global_position
			var p_shape = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
			var start_rad = deg_to_rad(start_deg)
			var target_rad = deg_to_rad(target_deg)
			var r_start = PieceGeometry.get_world_boundary_distance(p_shape, piece.radius, piece.rotation, start_rad)
			var r_target = PieceGeometry.get_world_boundary_distance(p_shape, piece.radius, piece.rotation, target_rad)
			var from_pos = center + Vector2(cos(start_rad), sin(start_rad)) * r_start
			var to_pos = center + Vector2(cos(target_rad), sin(target_rad)) * r_target"""

text = text.replace(hint_old, hint_new)

with open("D:/AI secound Brain/RotateRings/gameplay/hint_controller.gd", "w", encoding="utf-8") as f:
    f.write(text)
