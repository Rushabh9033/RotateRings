extends RefCounted

static func make(kind: String, ink: Color) -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match kind:
		"back":
			_triangle(img, Vector2(18, 32), Vector2(46, 14), Vector2(46, 50), ink)
		"play":
			_triangle(img, Vector2(20, 14), Vector2(50, 32), Vector2(20, 50), ink)
		"pause":
			_round_rect(img, Rect2(16, 14, 11, 36), 5.0, ink)
			_round_rect(img, Rect2(37, 14, 11, 36), 5.0, ink)
		"hint":
			_ring(img, Vector2(32, 32), 20.0, 10.0, ink)
			_disc(img, Vector2(32, 32), 4.0, ink)
		"settings":
			_gear(img, Vector2(32, 32), 22.0, 15.0, 6.8, ink)
		"map":
			_ring(img, Vector2(20, 42), 11.0, 5.0, ink)
			_ring(img, Vector2(44, 22), 11.0, 5.0, ink)
			_line(img, Vector2(20, 42), Vector2(44, 22), 4.0, ink)
		"replay":
			_ring(img, Vector2(32, 34), 18.0, 10.0, ink)
			_triangle(img, Vector2(44, 12), Vector2(58, 22), Vector2(42, 28), ink)
		"home":
			_triangle(img, Vector2(32, 10), Vector2(54, 30), Vector2(10, 30), ink)
			_round_rect(img, Rect2(20, 30, 24, 22), 4.0, ink)
			_round_rect(img, Rect2(28, 38, 8, 14), 2.0, Color(0, 0, 0, 0))
		"lock":
			_ring(img, Vector2(32, 24), 14.0, 8.0, ink)
			_round_rect(img, Rect2(16, 28, 32, 26), 6.0, ink)
			_disc(img, Vector2(32, 40), 3.0, Color(1, 1, 1, 0.9))
		"star":
			_star(img, Vector2(32, 32), 24.0, 10.5, ink)
		"star_empty":
			_star_outline(img, Vector2(32, 32), 24.0, 10.5, 4.0, ink)
		"check":
			_line(img, Vector2(16, 32), Vector2(28, 46), 6.0, ink)
			_line(img, Vector2(28, 46), Vector2(50, 18), 6.0, ink)
		"close":
			_line(img, Vector2(18, 18), Vector2(46, 46), 5.5, ink)
			_line(img, Vector2(46, 18), Vector2(18, 46), 5.5, ink)
		_:
			_disc(img, Vector2(32, 32), 10.0, ink)
	return ImageTexture.create_from_image(img)


static func _disc(img: Image, c: Vector2, radius: float, color: Color) -> void:
	var r2 := radius * radius
	var min_x := maxi(int(c.x - radius) - 1, 0)
	var max_x := mini(int(c.x + radius) + 2, img.get_width())
	var min_y := maxi(int(c.y - radius) - 1, 0)
	var max_y := mini(int(c.y + radius) + 2, img.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			if Vector2(x + 0.5, y + 0.5).distance_squared_to(c) <= r2:
				img.set_pixel(x, y, color)


static func _ring(img: Image, c: Vector2, outer: float, inner: float, color: Color) -> void:
	var o2 := outer * outer
	var i2 := inner * inner
	var min_x := maxi(int(c.x - outer) - 1, 0)
	var max_x := mini(int(c.x + outer) + 2, img.get_width())
	var min_y := maxi(int(c.y - outer) - 1, 0)
	var max_y := mini(int(c.y + outer) + 2, img.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var d2 := Vector2(x + 0.5, y + 0.5).distance_squared_to(c)
			if d2 <= o2 and d2 >= i2:
				img.set_pixel(x, y, color)


static func _round_rect(img: Image, rect: Rect2, radius: float, color: Color) -> void:
	var r := minf(radius, minf(rect.size.x, rect.size.y) * 0.5)
	for y in range(int(rect.position.y), int(rect.end.y) + 1):
		for x in range(int(rect.position.x), int(rect.end.x) + 1):
			if _in_round_rect(Vector2(x + 0.5, y + 0.5), rect, r):
				if x >= 0 and y >= 0 and x < img.get_width() and y < img.get_height():
					img.set_pixel(x, y, color)


static func _in_round_rect(p: Vector2, rect: Rect2, radius: float) -> bool:
	var inner := Rect2(rect.position + Vector2(radius, radius), rect.size - Vector2(radius, radius) * 2.0)
	if inner.has_point(p) or (p.x >= rect.position.x + radius and p.x <= rect.end.x - radius and p.y >= rect.position.y and p.y <= rect.end.y):
		return true
	if p.y >= rect.position.y + radius and p.y <= rect.end.y - radius and p.x >= rect.position.x and p.x <= rect.end.x:
		return true
	var corners: Array[Vector2] = [
		rect.position + Vector2(radius, radius),
		Vector2(rect.end.x - radius, rect.position.y + radius),
		rect.end - Vector2(radius, radius),
		Vector2(rect.position.x + radius, rect.end.y - radius),
	]
	for corner in corners:
		if p.distance_squared_to(corner) <= radius * radius:
			return true
	return false


static func _triangle(img: Image, a: Vector2, b: Vector2, c: Vector2, color: Color) -> void:
	var min_x := maxi(int(minf(a.x, minf(b.x, c.x))) - 1, 0)
	var max_x := mini(int(maxf(a.x, maxf(b.x, c.x))) + 2, img.get_width())
	var min_y := maxi(int(minf(a.y, minf(b.y, c.y))) - 1, 0)
	var max_y := mini(int(maxf(a.y, maxf(b.y, c.y))) + 2, img.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			if _in_triangle(Vector2(x + 0.5, y + 0.5), a, b, c):
				img.set_pixel(x, y, color)


static func _in_triangle(p: Vector2, a: Vector2, b: Vector2, c: Vector2) -> bool:
	var d1 := _sign(p, a, b)
	var d2 := _sign(p, b, c)
	var d3 := _sign(p, c, a)
	var has_neg := d1 < 0.0 or d2 < 0.0 or d3 < 0.0
	var has_pos := d1 > 0.0 or d2 > 0.0 or d3 > 0.0
	return not (has_neg and has_pos)


static func _sign(p: Vector2, a: Vector2, b: Vector2) -> float:
	return (p.x - b.x) * (a.y - b.y) - (a.x - b.x) * (p.y - b.y)


static func _line(img: Image, a: Vector2, b: Vector2, width: float, color: Color) -> void:
	var r := width * 0.5
	var r2 := r * r
	var ab := b - a
	var len_sq := ab.length_squared()
	var min_x := maxi(int(minf(a.x, b.x) - r) - 1, 0)
	var max_x := mini(int(maxf(a.x, b.x) + r) + 2, img.get_width())
	var min_y := maxi(int(minf(a.y, b.y) - r) - 1, 0)
	var max_y := mini(int(maxf(a.y, b.y) + r) + 2, img.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var p := Vector2(x + 0.5, y + 0.5)
			var t := clampf((p - a).dot(ab) / len_sq, 0.0, 1.0) if len_sq > 0.0 else 0.0
			var proj := a + ab * t
			if p.distance_squared_to(proj) <= r2:
				img.set_pixel(x, y, color)


static func _star(img: Image, c: Vector2, r_out: float, r_in: float, color: Color) -> void:
	var pts := _star_polygon(c, r_out, r_in)
	var min_x := maxi(int(c.x - r_out) - 1, 0)
	var max_x := mini(int(c.x + r_out) + 2, img.get_width())
	var min_y := maxi(int(c.y - r_out) - 1, 0)
	var max_y := mini(int(c.y + r_out) + 2, img.get_height())
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			if _point_in_polygon(Vector2(x + 0.5, y + 0.5), pts):
				img.set_pixel(x, y, color)


static func _star_outline(img: Image, c: Vector2, r_out: float, r_in: float, width: float, color: Color) -> void:
	var pts := _star_polygon(c, r_out, r_in)
	for i in pts.size():
		var p1: Vector2 = pts[i]
		var p2: Vector2 = pts[(i + 1) % pts.size()]
		_line(img, p1, p2, width, color)


static func _star_polygon(c: Vector2, r_out: float, r_in: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var base_ang := -PI * 0.5
	for i in 10:
		var r := r_out if (i % 2 == 0) else r_in
		var ang := base_ang + float(i) * (TAU / 10.0)
		pts.append(c + Vector2(cos(ang), sin(ang)) * r)
	return pts


static func _point_in_polygon(p: Vector2, poly: PackedVector2Array) -> bool:
	var inside := false
	var j := poly.size() - 1
	for i in poly.size():
		var pi := poly[i]
		var pj := poly[j]
		if ((pi.y > p.y) != (pj.y > p.y)) and (p.x < (pj.x - pi.x) * (p.y - pi.y) / (pj.y - pi.y) + pi.x):
			inside = not inside
		j = i
	return inside


static func _gear(img: Image, c: Vector2, r_outer: float, r_inner: float, r_hole: float, color: Color) -> void:
	var min_x := maxi(int(c.x - r_outer) - 2, 0)
	var max_x := mini(int(c.x + r_outer) + 3, img.get_width())
	var min_y := maxi(int(c.y - r_outer) - 2, 0)
	var max_y := mini(int(c.y + r_outer) + 3, img.get_height())
	var sub_offsets := [
		Vector2(0.25, 0.25),
		Vector2(0.75, 0.25),
		Vector2(0.25, 0.75),
		Vector2(0.75, 0.75)
	]
	var r_hole2 := r_hole * r_hole
	var r_outer2 := (r_outer + 1.5) * (r_outer + 1.5)
	for y in range(min_y, max_y):
		for x in range(min_x, max_x):
			var hits := 0
			for sub in sub_offsets:
				var p := Vector2(float(x) + sub.x, float(y) + sub.y)
				var d2 := p.distance_squared_to(c)
				if d2 < r_hole2 or d2 > r_outer2:
					continue
				var d := sqrt(d2)
				var ang := (p - c).angle()
				var t := cos(6.0 * ang)
				var t_shaped := tanh(t * 2.5)
				var r_profile := r_inner + (r_outer - r_inner) * (0.5 + 0.5 * t_shaped)
				if d <= r_profile:
					hits += 1
			if hits > 0:
				var alpha := float(hits) / 4.0
				img.set_pixel(x, y, Color(color.r, color.g, color.b, color.a * alpha))
