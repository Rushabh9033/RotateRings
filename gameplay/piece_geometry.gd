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
			var a = local_angle_rad
			var c1 = cos(a)
			var c2 = cos(a - 2.094395)
			var c3 = cos(a + 2.094395)
			# Smooth maximum using log-sum-exp (k = 6.0)
			var k = 6.0
			var h = (1.0 / k) * log(exp(k * c1) + exp(k * c2) + exp(k * c3))
			# To ensure the max radius is `radius`, note that max(c1, c2, c3) is 1.0 when a=0.
			# log(exp(k) + 2*exp(-0.5*k))/k is approx 1.0.
			# So we just scale by `radius / h`.
			# But wait, max(c1, c2, c3) at a=0 is 1.0. The minimum is at a=pi/3 (60 deg), where it's 0.5.
			# A sharp triangle has r(0) = R, r(60) = R/0.5 = 2R, which points outwards at 0, 120, 240!
			# Wait! A triangle with vertices at 0, 120, 240 has maximum radius at 0, 120, 240!
			# For r(a) = R / max(c1, c2, c3), at a=0, c1=1, r=R.
			# At a=60, max is 0.5. r=2R. Wait, that means the corners are at 0, 120, 240? NO.
			# If the edges are defined by x=R/2, then r(a) = (R/2)/cos(a). 
			# At a=0, r=R/2. At a=60, r=R. So the vertices are at 60, 180, 300!
			# Let's shift by 60 degrees (PI/3) so vertices are at 0, 120, 240.
			a = a - 1.047197
			c1 = cos(a); c2 = cos(a - 2.094395); c3 = cos(a + 2.094395)
			var smooth_max = (1.0 / k) * log(exp(k * c1) + exp(k * c2) + exp(k * c3))
			# Base apothem is radius * 0.5.
			# r(a) = (radius * 0.55) / smooth_max
			# To ensure max radius is exactly `radius`, we evaluate at vertex (a=60 deg from edge, which is a=0 after shift? No, a=1.047197 before shift, so a=0 after shift. At a=0, smooth_max ~ 1.0. So r(0) = radius * 0.55. We want it to be `radius`. So we should scale so that the maximum is `radius`.)
			# Let's just use a superformula for a triangle:
			# r(a) = R * ( abs(cos(1.5*a))^m + abs(sin(1.5*a))^m )^(-1/m)
			# With m = 3 or 4, it creates a nice rounded triangle!
			# Let's test m=3.
			var ca = abs(cos(1.5 * local_angle_rad))
			var sa = abs(sin(1.5 * local_angle_rad))
			return radius * pow(pow(ca, 3.5) + pow(sa, 3.5), -1.0/3.5)
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

## Arc-length of the whole contour. Circles are exact (2πr). Other authored outlines are sampled on the same boundary function used for hit tests and connectors.
static func contour_length(shape: int, radius: float) -> float:
	if shape == ShapeType.CIRCLE:
		return TAU * radius
	var steps := 96
	var length := 0.0
	var prev := Vector2.from_angle(0.0) * get_boundary_distance(shape, radius, 0.0)
	for i in range(1, steps + 1):
		var ang := TAU * float(i) / float(steps)
		var point := Vector2.from_angle(ang) * get_boundary_distance(shape, radius, ang)
		length += prev.distance_to(point)
		prev = point
	return length

## Perimeter parameter s in [0, 1). Circles map angle to s exactly.
static func angle_to_s(angle_deg: float) -> float:
	return fposmod(angle_deg, 360.0) / 360.0

static func gap_interval_s(center_angle_deg: float, width_deg: float) -> Vector2:
	var half := maxf(width_deg, 0.0) / 360.0 * 0.5
	var center_s := angle_to_s(center_angle_deg)
	return Vector2(fposmod(center_s - half, 1.0), fposmod(center_s + half, 1.0))

static func opening_length(shape: int, radius: float, width_deg: float) -> float:
	return contour_length(shape, radius) * (maxf(width_deg, 0.0) / 360.0)

static func opening_accepts_cuff(opening_len: float, cuff_width: float, margin: float) -> bool:
	return opening_len + 0.001 >= cuff_width + margin * 2.0

static func s_inside_gap(s: float, start_s: float, end_s: float) -> bool:
	s = fposmod(s, 1.0)
	start_s = fposmod(start_s, 1.0)
	end_s = fposmod(end_s, 1.0)
	if is_equal_approx(start_s, end_s):
		return false
	if start_s < end_s:
		return s >= start_s - 0.00001 and s <= end_s + 0.00001
	return s >= start_s - 0.00001 or s <= end_s + 0.00001

## True when the whole cuff, plus safety margin on both ends, sits inside the opening.
static func cuff_span_inside(start_s: float, end_s: float, contact_s: float, cuff_width: float, contour_len: float, margin: float) -> bool:
	if contour_len <= 0.001:
		return false
	var half := (cuff_width * 0.5 + margin) / contour_len
	var a := fposmod(contact_s - half, 1.0)
	var b := fposmod(contact_s + half, 1.0)
	return s_inside_gap(contact_s, start_s, end_s) and s_inside_gap(a, start_s, end_s) and s_inside_gap(b, start_s, end_s)
