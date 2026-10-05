with open("D:/AI secound Brain/RotateRings/gameplay/drag_rotation_controller.gd", "r", encoding="utf-8") as f:
    text = f.read()

hit_logic_old = """		var global_radius: float = p.radius * global_scale_factor
		var global_thickness: float = (float(p.get("thickness")) if p.get("thickness") != null else 12.0) * global_scale_factor
		var dist_from_center: float = (global_pt - p.global_position).length()
		var dist_to_tube: float = absf(dist_from_center - global_radius)"""

hit_logic_new = """		var global_thickness: float = (float(p.get("thickness")) if p.get("thickness") != null else 12.0) * global_scale_factor
		var dist_from_center: float = (global_pt - p.global_position).length()
		var pt_angle: float = (global_pt - p.global_position).angle()
		var shape_type = p.def.shape_type if (p.get("def") and "shape_type" in p.def) else 0
		var boundary_dist = PieceGeometry.get_world_boundary_distance(shape_type, p.radius, p.global_rotation, pt_angle)
		var global_boundary_dist: float = boundary_dist * global_scale_factor
		var dist_to_tube: float = absf(dist_from_center - global_boundary_dist)"""

text = text.replace(hit_logic_old, hit_logic_new)

with open("D:/AI secound Brain/RotateRings/gameplay/drag_rotation_controller.gd", "w", encoding="utf-8") as f:
    f.write(text)
