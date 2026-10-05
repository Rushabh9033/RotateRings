with open("D:/AI secound Brain/RotateRings/gameplay/piece_geometry.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re
triangle_code_old = """		ShapeType.ROUNDED_TRIANGLE:
			var ca = abs(cos(1.5 * local_angle_rad))
			var sa = abs(sin(1.5 * local_angle_rad))
			return radius * pow(pow(ca, 3.5) + pow(sa, 3.5), -1.0/3.5)"""

# Sharp triangle: r_sharp(a) = R_apothem / max(cos(a), cos(a-120), cos(a+120))
# Let's orient the triangle with a flat edge at the bottom, pointing UP (vertex at 90 deg / PI/2).
# Or vertex at 0 deg (pointing RIGHT). Let's point RIGHT (0 deg).
# Edges are at 180, 60, -60. Normal angles are 180, 60, 300.
# h(a) = max(cos(a - pi), cos(a - pi/3), cos(a + pi/3))
# r_sharp(a) = R_apothem / h(a)
# To make it rounded, we can use log-sum-exp for the max function.
# Let k = 10.0 for a nice rounding.
# h_smooth(a) = (1/k) * log( exp(k*cos(a-pi)) + exp(k*cos(a-pi/3)) + exp(k*cos(a+pi/3)) )
# If vertex is at 0, h_smooth(0) = (1/k)*log( exp(-k) + 2*exp(k/2) ) ~ (1/k)*(k/2) = 0.5.
# So r_sharp(0) = R_apothem / 0.5 = 2 * R_apothem.
# So if we want max radius to be `radius`, we set R_apothem = radius / 2.
# Let's implement this!

triangle_code_new = """		ShapeType.ROUNDED_TRIANGLE:
			var a = local_angle_rad
			var c1 = cos(a - 3.14159)
			var c2 = cos(a - 1.047197)
			var c3 = cos(a + 1.047197)
			var k = 8.0
			var h_smooth = (1.0 / k) * log(exp(k * c1) + exp(k * c2) + exp(k * c3))
			# At a = 0 (vertex), h_smooth is approx 0.5. r = radius * 0.5 / 0.5 = radius.
			# At a = 180 (edge), h_smooth is approx 1.0. r = radius * 0.5 / 1.0 = 0.5 * radius.
			return (radius * 0.52) / h_smooth"""

text = text.replace(triangle_code_old, triangle_code_new)

with open("D:/AI secound Brain/RotateRings/gameplay/piece_geometry.gd", "w", encoding="utf-8") as f:
    f.write(text)
