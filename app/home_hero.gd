extends Control

var _rings: Array = []

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(0, 320)
	# A beautiful static geometric layout that rotates like a puzzle lock
	_rings = [
		{ "color": Color("7B61FF"), "pos": Vector2(0, 0), "speed": 0.4, "radius": 74.0, "thick": 24.0, "gap": 0.0 },
		{ "color": Color("3EBEFF"), "pos": Vector2(-80, -60), "speed": -0.6, "radius": 48.0, "thick": 18.0, "gap": 1.2 },
		{ "color": Color("FF7A3C"), "pos": Vector2(80, -60), "speed": -0.5, "radius": 48.0, "thick": 18.0, "gap": 3.4 },
		{ "color": Color("3DDC97"), "pos": Vector2(0, 95), "speed": -0.7, "radius": 54.0, "thick": 20.0, "gap": 4.5 },
	]

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var t := float(Time.get_ticks_msec()) / 1000.0
	var origin := Vector2(size.x * 0.5, size.y * 0.56)
	
	# Base shadow / backdrop
	draw_circle(origin + Vector2(0, 20), 140.0, Color(0.45, 0.28, 0.16, 0.06))
	
	# Draw the rings
	for i in _rings.size():
		var ring: Dictionary = _rings[i]
		# Breathe effect
		var pulse := 1.0 + sin(t * 1.5 + float(i)) * 0.04
		var hover := sin(t * 2.0 + float(i) * 1.2) * 6.0
		var rpos: Vector2 = ring.pos
		var pos := origin + (rpos * pulse) + Vector2(0, hover)
		var gap := t * float(ring.speed) + float(ring.gap)
		_toy_ring(pos, float(ring.radius) * pulse, float(ring.thick) * pulse, ring.color, gap)
		
	# Ambient floating sparks
	for s in 8:
		var spark_ang := t * 0.5 + float(s) * TAU / 8.0
		var spark_dist := 120.0 + sin(t * 1.2 + s) * 20.0
		var spark := origin + Vector2(cos(spark_ang), sin(spark_ang)) * spark_dist
		var spark_color := Color("F0B429")
		spark_color.a = 0.2 + 0.4 * absf(sin(t * 2.5 + s))
		draw_circle(spark, 3.0 + sin(t * 3.0 + s), spark_color)

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
