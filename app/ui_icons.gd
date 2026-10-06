extends RefCounted

static func make(kind: String, ink: Color) -> Texture2D:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match kind:
		"back":
			_triangle(img, Vector2(18, 32), Vector2(46, 14), Vector2(46, 50), ink)
		"pause":
			_round_rect(img, Rect2(16, 12, 12, 40), 6.0, ink)
			_round_rect(img, Rect2(36, 12, 12, 40), 6.0, ink)
		"hint":
			_ring(img, Vector2(32, 32), 18.0, 8.0, ink)
		"settings":
			_ring(img, Vector2(32, 32), 16.0, 7.0, ink)
			for i in 6:
				var ang := TAU * float(i) / 6.0
				_disc(img, Vector2(32, 32) + Vector2.from_angle(ang) * 24.0, 5.0, ink)
		"map":
			_ring(img, Vector2(22, 40), 10.0, 4.0, ink)
			_ring(img, Vector2(42, 24), 10.0, 4.0, ink)
		"replay":
			_ring(img, Vector2(32, 34), 16.0, 8.0, ink)
			_triangle(img, Vector2(44, 14), Vector2(58, 22), Vector2(42, 28), ink)
		"home":
			_triangle(img, Vector2(32, 10), Vector2(54, 30), Vector2(10, 30), ink)
			_round_rect(img, Rect2(20, 30, 24, 22), 4.0, ink)
		"lock":
			_ring(img, Vector2(32, 26), 13.0, 8.0, ink)
			_round_rect(img, Rect2(16, 30, 32, 24), 5.0, ink)
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
