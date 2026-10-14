extends Node2D

const UiTheme = preload("res://app/ui_theme.gd")

var total_levels: int = 1
var v_spacing: float = 120.0
var h_amp: float = 100.0
var m_height: float = 1000.0
var x_base: float = 291.0
var frontier_level: int = 1

func setup_path(levels: int, vs: float, ha: float, mh: float, origin_x: float = 291.0, frontier: int = 1) -> void:
	total_levels = levels
	v_spacing = vs
	h_amp = ha
	m_height = mh
	x_base = origin_x
	frontier_level = frontier
	queue_redraw()

func _draw() -> void:
	var node_center_offset := Vector2(45.0, 45.0)
	var pts: Array[Vector2] = []
	for lvl in range(1, total_levels + 1):
		var y_pos = m_height - (lvl * v_spacing) - 100.0
		var x_pos = x_base + sin(lvl * 1.2) * h_amp
		pts.append(Vector2(x_pos, y_pos) + node_center_offset)
	
	if pts.size() < 2:
		return

	# Draw segments between lvl and lvl+1
	# Segment index i is from level (i+1) to level (i+2)
	# If (i + 1) < frontier_level: segment is unlocked/cleared -> green 3D tube with golden bead pairs
	# If (i + 1) >= frontier_level: segment is locked -> cream ivory track
	for i in range(pts.size() - 1):
		var p1: Vector2 = pts[i]
		var p2: Vector2 = pts[i + 1]
		var seg_lvl := i + 1
		var is_unlocked_segment := seg_lvl < frontier_level
		
		if is_unlocked_segment:
			# Vibrant green 3D tube
			# 1. Soft shadow
			draw_line(p1 + Vector2(0, 3.5), p2 + Vector2(0, 3.5), Color(0.18, 0.35, 0.15, 0.22), 15.0, true)
			# 2. Dark emerald border
			draw_line(p1, p2, Color("1E8A5C"), 12.0, true)
			# 3. Main emerald body
			draw_line(p1, p2, Color("27AE60"), 9.5, true)
			# 4. Highlight stripe
			var hi_offset := Vector2(-0.8, -1.0)
			draw_line(p1 + hi_offset, p2 + hi_offset, Color("7DCEA0"), 3.0, true)
			
			# 2 Golden beads along the green pipe
			for t in [0.35, 0.65]:
				var bead_c := p1.lerp(p2, t)
				# Bead shadow
				draw_circle(bead_c + Vector2(0, 1.5), 5.5, Color(0.2, 0.3, 0.15, 0.3))
				# Dark gold ring
				draw_circle(bead_c, 5.0, Color("D48806"))
				# Gold body
				draw_circle(bead_c, 4.0, Color("F4B41A"))
				# Specular highlight
				draw_circle(bead_c + Vector2(-1.0, -1.0), 1.5, Color("FFFDF5"))
		else:
			# Ivory / cream rail track
			# 1. Subtle shadow
			draw_line(p1 + Vector2(0, 2.0), p2 + Vector2(0, 2.0), Color(0.38, 0.25, 0.16, 0.1), 10.0, true)
			# 2. Cream border
			draw_line(p1, p2, Color("E2D6C6"), 8.0, true)
			# 3. Light cream inner track
			draw_line(p1, p2, Color("FAF7F2"), 5.0, true)
