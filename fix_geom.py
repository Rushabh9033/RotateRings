with open("D:/AI secound Brain/RotateRings/gameplay/piece_geometry.gd", "r", encoding="utf-8") as f:
    text = f.read()

triangle_code_old = """		ShapeType.ROUNDED_TRIANGLE:
			# A rounded triangle (Reuleaux-like or 3-lobed).
			# r(theta) = R * (1 + 0.15 * cos(3 * theta)) -- just a smooth 3-lobed shape.
			return radius * (0.9 + 0.15 * cos(3.0 * local_angle_rad))"""

# A better rounded triangle polar distance function:
# We can find the intersection of a ray at angle `a` with a rounded triangle.
# For a standard equilateral triangle with vertices at 0, 120, -120 deg.
# The boundary is 3 lines. We can interpolate between a circle and a triangle.
# Or use max(cos(a - 0), cos(a - 120), cos(a + 120))
# Let h(a) = max(cos(a), cos(a - 2pi/3), cos(a + 2pi/3)). For a pure triangle, r(a) = (R/2) / h(a).
# To make it rounded, we can use a p-norm of these projections!
# r(a) = R_scale * ( (cos(a))^p + (cos(a-2pi/3))^p + (cos(a+2pi/3))^p )^(-1/p) (using positive parts only).
# Actually, an easier smooth triangular function is:
# r(a) = R * (1.0 - 0.2 * cos(3 * a)) is 3 lobed.
# What about r(a) = R / (max(cos(a), cos(a - 2pi/3), cos(a + 2pi/3))) ? That's a sharp triangle!
# We can smooth it using log-sum-exp:
# h(a) = (1/k) * ln( exp(k*cos(a)) + exp(k*cos(a-2pi/3)) + exp(k*cos(a+2pi/3)) )
# r(a) = (R/2) / h(a)
# Let's use k = 5.0 for a nice rounded triangle!

triangle_code_new = """		ShapeType.ROUNDED_TRIANGLE:
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
			return radius * pow(pow(ca, 3.5) + pow(sa, 3.5), -1.0/3.5)"""

text = text.replace(triangle_code_old, triangle_code_new)

with open("D:/AI secound Brain/RotateRings/gameplay/piece_geometry.gd", "w", encoding="utf-8") as f:
    f.write(text)
