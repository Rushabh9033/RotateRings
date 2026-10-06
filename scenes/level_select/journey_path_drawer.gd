extends Node2D

const UiTheme = preload("res://app/ui_theme.gd")

var total_levels: int = 1
var v_spacing: float = 100.0
var h_amp: float = 100.0
var m_height: float = 1000.0
var x_base: float = 291.0

func setup_path(levels: int, vs: float, ha: float, mh: float, origin_x: float = 291.0) -> void:
	total_levels = levels
	v_spacing = vs
	h_amp = ha
	m_height = mh
	x_base = origin_x
	queue_redraw()

func _draw() -> void:
	var path_points: PackedVector2Array = []
	for lvl in range(1, total_levels + 1):
		var y_pos = m_height - (lvl * v_spacing) - 100.0
		# Offset by card center (45, 45) based on custom_minimum_size (90, 90)
		var x_pos = x_base + sin(lvl * 1.2) * h_amp
		path_points.append(Vector2(x_pos + 45.0, y_pos + 45.0))
		
	if path_points.size() > 1:
		var shadow := Color(0.45, 0.28, 0.16, 0.14)
		draw_polyline(path_points, shadow, 18.0, true)
		draw_polyline(path_points, Color("E7C9A4"), 12.0, true)
		draw_polyline(path_points, Color("FFF6EA"), 4.0, true)
