extends Node2D

var total_levels: int = 1
var v_spacing: float = 100.0
var h_amp: float = 100.0
var m_height: float = 1000.0

func setup_path(levels: int, vs: float, ha: float, mh: float) -> void:
	total_levels = levels
	v_spacing = vs
	h_amp = ha
	m_height = mh
	queue_redraw()

func _draw() -> void:
	var path_points: PackedVector2Array = []
	for lvl in range(1, total_levels + 1):
		var y_pos = m_height - (lvl * v_spacing) - 100.0
		# Offset by card center (45, 45) based on custom_minimum_size (90, 90)
		var x_pos = 150.0 + sin(lvl * 1.2) * h_amp
		path_points.append(Vector2(x_pos + 45.0, y_pos + 45.0))
		
	if path_points.size() > 1:
		draw_polyline(path_points, Color(0.8, 0.7, 0.6, 0.5), 8.0, true)
		
		# Draw dashed line or small dots along the path for extra polish
		for i in range(path_points.size() - 1):
			var p1 = path_points[i]
			var p2 = path_points[i+1]
			var dist = p1.distance_to(p2)
			var dots = int(dist / 30.0)
			for j in range(1, dots):
				var dot_pos = p1.lerp(p2, float(j)/dots)
				draw_circle(dot_pos, 4.0, Color(0.9, 0.85, 0.75, 0.8))
