extends Node2D

# Renders the editor's working piece/link array, including per-piece gap
# indicators and a selection highlight. Bound to its parent LevelEditor via
# `editor_ref`.

var editor_ref = null

const TANGENTIAL_WIDTH := 32.0
const RADIAL_DEPTH := 18.0

func _ready() -> void:
	# Canvas-local origin (top-left at world (0,0)).
	position = Vector2(0, 0)
	set_process_input(true)

func _draw() -> void:
	if editor_ref == null: return
	# Cream background covering the full 720x1280 canvas.
	draw_rect(Rect2(0, 0, 720, 1280), Color(1.0, 0.96, 0.9))
	# Bounding box at canvas size (anchor at canvas origin).
	draw_rect(Rect2(0, 0, 720, 1280), Color(0.85, 0.7, 0.55), false, 4)

	# === Grid + center guides ===
	# Always draw center crosshairs at (360, 640) so the user can eyeball
	# centralization even with the grid off.
	draw_line(Vector2(360, 0), Vector2(360, 1280), Color(0.7, 0.5, 0.3, 0.35), 1.0)
	draw_line(Vector2(0, 640), Vector2(720, 640), Color(0.7, 0.5, 0.3, 0.35), 1.0)
	if editor_ref.get("grid_enabled") == true:
		var g: float = float(editor_ref.grid_size) if "grid_size" in editor_ref else 10.0
		if g >= 5.0:
			var minor := Color(0.7, 0.55, 0.4, 0.18)
			var major := Color(0.7, 0.55, 0.4, 0.30)
			var x: float = 0.0
			while x <= 720.0:
				var is_major: bool = fmod(x, 50.0) < 0.5
				draw_line(Vector2(x, 0), Vector2(x, 1280), major if is_major else minor, 1.0)
				x += g
			var y: float = 0.0
			while y <= 1280.0:
				var is_majory: bool = fmod(y, 50.0) < 0.5
				draw_line(Vector2(0, y), Vector2(720, y), major if is_majory else minor, 1.0)
				y += g

	# Draw links first (so pieces overlay them).
	for l in editor_ref._placed_links:
		var src = null
		var dst = null
		for p in editor_ref._placed_pieces:
			if p["id"] == l["from_id"]: src = p
			elif p["id"] == l["to_id"]: dst = p
		if src == null or dst == null: continue
		# Cuff position = midpoint between piece centers.
		var cx = (src["x"] + dst["x"]) * 0.5
		var cy = (src["y"] + dst["y"]) * 0.5
		var ccolor = Color(l.get("cuff_color_hex", "#EA7829"))
		draw_rect(Rect2(cx - TANGENTIAL_WIDTH * 0.5, cy - RADIAL_DEPTH * 0.5, TANGENTIAL_WIDTH, RADIAL_DEPTH), ccolor)
		# Stem line for clarity (thin, dark).
		draw_line(Vector2(src["x"], src["y"]), Vector2(dst["x"], dst["y"]), Color(0.4, 0.4, 0.4, 0.55), 2.0)

	# Draw pieces with selection highlight.
	for i in range(editor_ref._placed_pieces.size()):
		var p = editor_ref._placed_pieces[i]
		var pos = Vector2(p["x"], p["y"])
		var radius = float(p["radius"])
		var thickness = float(p["thickness"])
		var color: Color = Color(0.5, 0.5, 0.5)
		var hex := String(p["color_hex"])
		if hex != "" and Color.html_is_valid(hex):
			color = Color(hex)
		var gap_deg = float(p["gap_deg"])
		var is_closed: bool = p.get("closed", false)

		# Selection outline.
		if i == editor_ref._selected_piece_idx:
			draw_arc(pos, radius + 10, 0, 360, 64, Color(0.95, 0.7, 0.3), 3.0)
		# Hit-test outline while hovering (subtle).
		draw_arc(pos, radius + 4, 0, 360, 64, color.darkened(0.5), 1.0)

		if is_closed:
			draw_circle(pos, radius, color)
		else:
			# Filled donut with gap.
			_draw_donut_with_gap(pos, radius, thickness, color, gap_deg, 80.0)

		# Gap indicator handle: short line from center along gap direction, with dot at the rim.
		var a = deg_to_rad(gap_deg)
		var hx = pos.x + cos(a) * radius
		var hy = pos.y + sin(a) * radius
		draw_line(pos, Vector2(hx, hy), color, 3.0)
		draw_circle(Vector2(hx, hy), 10.0, color)
		# Label.
		var label := String(p["id"])
		draw_string(ThemeDB.fallback_font, pos + Vector2(radius + 18, 0), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, color.darkened(0.4))

func _draw_donut_with_gap(center: Vector2, r: float, t: float, color: Color, gap_deg: float, gap_width_deg: float) -> void:
	# Draw filled disc, erase inner disc, draw BG wedge for the gap.
	var ro = r + t * 0.5
	var ri = max(0.5, r - t * 0.5)
	draw_circle(center, ro, color)
	draw_circle(center, ri, Color(1.0, 0.96, 0.9))
	var g0 = gap_deg - gap_width_deg * 0.5
	var g1 = gap_deg + gap_width_deg * 0.5
	# Outer wedge.
	draw_arc(center, ro + 2, deg_to_rad(g0), deg_to_rad(g1), 32, Color(1.0, 0.96, 0.9), ro * 2.0 + 4.0, true)
