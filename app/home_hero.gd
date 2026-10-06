extends Control

var _rings: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 320)
	_rings = [
		{ "color": Color("3EBEFF"), "orbit": 92.0, "speed": 0.55, "phase": 0.2, "spin": 0.8, "radius": 74.0, "thick": 28.0, "bob": 10.0 },
		{ "color": Color("FF7A3C"), "orbit": 108.0, "speed": -0.42, "phase": 2.1, "spin": -1.1, "radius": 80.0, "thick": 30.0, "bob": 14.0 },
		{ "color": Color("7B61FF"), "orbit": 36.0, "speed": 0.9, "phase": 4.0, "spin": 1.4, "radius": 58.0, "thick": 24.0, "bob": 8.0 },
		{ "color": Color("3DDC97"), "orbit": 132.0, "speed": 0.33, "phase": 1.2, "spin": 0.6, "radius": 46.0, "thick": 18.0, "bob": 16.0 },
	]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := float(Time.get_ticks_msec()) / 1000.0
	var origin := Vector2(size.x * 0.5, size.y * 0.56)
	draw_circle(origin + Vector2(0, 78), 120.0, Color(0.45, 0.28, 0.16, 0.08))
	draw_circle(origin + Vector2(0, 86), 78.0, Color(0.45, 0.28, 0.16, 0.06))
	for i in _rings.size():
		var ring: Dictionary = _rings[i]
		var ang := float(ring.phase) + t * float(ring.speed)
		var bob := sin(t * 1.7 + float(i)) * float(ring.bob)
		var pulse := 1.0 + sin(t * 2.2 + float(i) * 0.7) * 0.035
		var pos := origin + Vector2(cos(ang), sin(ang) * 0.42) * float(ring.orbit) + Vector2(0, bob)
		var gap := t * float(ring.spin) + float(ring.phase)
		_toy_ring(pos, float(ring.radius) * pulse, float(ring.thick), ring.color, gap)
	for s in 8:
		var spark_ang := t * 1.3 + float(s) * TAU / 8.0
		var spark := origin + Vector2(cos(spark_ang), sin(spark_ang) * 0.55) * (150.0 + sin(t + s) * 8.0)
		var spark_color := Color("F0B429")
		spark_color.a = 0.35 + 0.45 * absf(sin(t * 3.0 + s))
		draw_circle(spark, 3.5 + sin(t * 4.0 + s), spark_color)

func _toy_ring(center: Vector2, radius: float, thickness: float, color: Color, gap_rot: float) -> void:
	var start := gap_rot
	var end := gap_rot + 5.05
	var shadow := Color(0.42, 0.24, 0.14, 0.18)
	draw_arc(center + Vector2(0, 12), radius, start, end, 72, shadow, thickness + 4.0, true)
	draw_arc(center + Vector2(0, 6), radius, start, end, 72, color.darkened(0.28), thickness, true)
	draw_arc(center, radius, start, end, 72, color, thickness, true)
	var hi := Color(1, 1, 1, 0.55)
	draw_arc(center + Vector2(-3, -4), radius, start + 0.35, start + 2.1, 28, hi, thickness * 0.28, true)
	var gloss := color.lightened(0.22)
	gloss.a = 0.7
	draw_arc(center + Vector2(-1, -2), radius, start + 0.15, end - 0.15, 56, gloss, thickness * 0.34, true)
	for cap_ang in [start, end]:
		var cap := center + Vector2.from_angle(cap_ang) * radius
		draw_circle(cap + Vector2(0, 5), thickness * 0.52, color.darkened(0.28))
		draw_circle(cap, thickness * 0.52, color)
		draw_circle(cap + Vector2(-3, -3), thickness * 0.18, Color(1, 1, 1, 0.7))
