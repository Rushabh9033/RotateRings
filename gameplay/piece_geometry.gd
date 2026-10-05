class_name PieceGeometry

const ShapeType = preload("res://data/piece_definition.gd").ShapeType

## Returns the distance from the center to the boundary of the shape at a given LOCAL angle (in radians).
static func get_boundary_distance(shape: int, radius: float, local_angle_rad: float) -> float:
	match shape:
		ShapeType.CIRCLE:
			return radius
		ShapeType.ROUNDED_SQUARE:
			# A rounded square can be approximated by a superellipse or by taking the min of 1/cos and 1/sin.
			# For a square of half-size R, the distance is R / max(|cos(a)|, |sin(a)|).
			# To make it "rounded", we can use a p-norm (e.g. p=4).
			# r(theta) = R * ( |cos(theta)|^4 + |sin(theta)|^4 )^(-1/4)
			var c = abs(cos(local_angle_rad))
			var s = abs(sin(local_angle_rad))
			return radius * pow(pow(c, 4.0) + pow(s, 4.0), -0.25)
		ShapeType.ROUNDED_TRIANGLE:
			# A rounded triangle (Reuleaux-like or 3-lobed).
			# r(theta) = R * (1 + 0.15 * cos(3 * theta)) -- just a smooth 3-lobed shape.
			return radius * (0.9 + 0.15 * cos(3.0 * local_angle_rad))
		ShapeType.OVAL:
			# An ellipse with aspect ratio 1.5. (width = R, height = R/1.5)
			var a = radius
			var b = radius * 0.65
			var c = cos(local_angle_rad)
			var s = sin(local_angle_rad)
			return (a * b) / sqrt(pow(b * c, 2.0) + pow(a * s, 2.0))
	return radius

## Given a world angle, compute the local boundary distance
static func get_world_boundary_distance(shape: int, radius: float, piece_rotation_rad: float, world_angle_rad: float) -> float:
	var local_angle = world_angle_rad - piece_rotation_rad
	return get_boundary_distance(shape, radius, local_angle)
