extends Button

const UiTheme = preload("res://app/ui_theme.gd")

@export var level_number: int = 1
@export var is_unlocked: bool = false
@export var is_cleared: bool = false
@export var is_perfect: bool = false
@export var is_current: bool = false

var base_radius: float = 27.0
var thickness: float = 13.0

func _ready() -> void:
	flat = true
	text = "" # We draw the number or icon procedurally in _draw()
	button_down.connect(queue_redraw)
	button_up.connect(queue_redraw)

func _process(_delta: float) -> void:
	if is_current:
		queue_redraw()

func _draw() -> void:
	var center: Vector2 = size * 0.5
	var font = UiTheme.rounded_font()

	var is_pressed_visual := button_pressed
	var z_offset := -3.0 if is_pressed_visual else 0.0

	var draw_pos := center + Vector2(0, z_offset)

	if is_current:
		# Frontier / Active Level
		var time := float(Time.get_ticks_msec()) / 1000.0
		# Outer pulsing halo ring
		var halo_r := base_radius + 13.0 + sin(time * 3.5) * 2.0
		var halo_alpha := 0.45 + 0.25 * sin(time * 3.5)
		draw_arc(draw_pos, halo_r, 0, TAU, 48, Color(1.0, 0.48, 0.24, halo_alpha), 3.0, true)

		# 3D Orange C-Ring (gap facing right, 0.0 rad)
		UiTheme.draw_c_ring(self, draw_pos, base_radius + 1.5, thickness + 1.0, Color("FF7A3C"), 0.0, 1.1)

		# Solid dark terracotta/chocolate disc in center
		var disc_r := 19.5
		draw_circle(draw_pos + Vector2(0, 1.5), disc_r, Color(0.2, 0.1, 0.05, 0.25))
		draw_circle(draw_pos, disc_r, Color("5A3828"))
		draw_arc(draw_pos, disc_r, 0, TAU, 36, Color("422618"), 1.5, true)

		# White bold level number
		var num_str := str(level_number)
		var font_size := 22
		var string_size := font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := draw_pos + Vector2(-string_size.x * 0.5, font.get_ascent(font_size) - string_size.y * 0.5)
		draw_string(font, text_pos, num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color("FFFFFF"))

	elif is_unlocked:
		# Cleared / Perfect Level
		var ring_color := Color("27AE60") if is_perfect else Color("F39C12")
		var gap_ang := 0.85 # ~50 degrees (bottom-right)

		# 3D C-Ring
		UiTheme.draw_c_ring(self, draw_pos, base_radius, thickness, ring_color, gap_ang, 1.15)

		# Cream inner disc
		var disc_r := 18.5
		draw_circle(draw_pos + Vector2(0, 1.2), disc_r, Color(0.3, 0.2, 0.1, 0.15))
		draw_circle(draw_pos, disc_r, Color("FFFDF9"))
		draw_arc(draw_pos, disc_r, 0, TAU, 36, Color("EADFD2"), 1.5, true)

		# Warm dark brown level number
		var num_str := str(level_number)
		var font_size := 20
		var string_size := font.get_string_size(num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := draw_pos + Vector2(-string_size.x * 0.5, font.get_ascent(font_size) - string_size.y * 0.5)
		draw_string(font, text_pos, num_str, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color("5A3828"))

		# 3 Golden beads inside the gap
		for k in range(-1, 2):
			var bead_ang := gap_ang + float(k) * 0.28
			var bead_pos := draw_pos + Vector2.from_angle(bead_ang) * base_radius
			draw_circle(bead_pos + Vector2(0, 1.0), 3.5, Color(0.25, 0.15, 0.05, 0.25))
			draw_circle(bead_pos, 3.2, Color("D48806"))
			draw_circle(bead_pos, 2.4, Color("F4B41A"))
			draw_circle(bead_pos + Vector2(-0.8, -0.8), 0.8, Color("FFFDF5"))

	else:
		# Locked Level
		var gap_ang := 2.3 # ~135 degrees (top-left)
		# Frosted silver/cream C-ring
		UiTheme.draw_c_ring(self, draw_pos, base_radius, thickness, Color("DDD7CE"), gap_ang, 1.15)

		# Soft ivory inner disc
		var disc_r := 18.5
		draw_circle(draw_pos, disc_r, Color("F4EDE4"))
		draw_arc(draw_pos, disc_r, 0, TAU, 36, Color("E2D8CC"), 1.2, true)

		# Padlock vector icon
		var lock_c := Color("8C786A")
		# Shackle
		var shackle_center := draw_pos + Vector2(0, -3.0)
		draw_arc(shackle_center, 4.8, PI, TAU, 24, lock_c, 2.2, true)
		draw_line(shackle_center + Vector2(-4.8, 0), shackle_center + Vector2(-4.8, 2.5), lock_c, 2.2, true)
		draw_line(shackle_center + Vector2(4.8, 0), shackle_center + Vector2(4.8, 2.5), lock_c, 2.2, true)
		# Body
		var body_rect := Rect2(draw_pos.x - 6.5, draw_pos.y - 1.0, 13.0, 9.5)
		draw_rect(body_rect, lock_c)

	# Milestone badge on multiples of 5 (level 5, 10, 15, etc.)
	if level_number % 5 == 0:
		var line_start := draw_pos + Vector2(base_radius + 8.0, 0)
		var line_end := draw_pos + Vector2(base_radius + 26.0, 0)
		draw_line(line_start, line_end, Color("E8B67D"), 2.0, true)

		var badge_c := draw_pos + Vector2(base_radius + 38.0, 0)
		var badge_r := 13.5
		draw_circle(badge_c + Vector2(0, 1.2), badge_r, Color(0.3, 0.2, 0.1, 0.18))
		draw_circle(badge_c, badge_r, Color("FF8C42"))
		draw_circle(badge_c, badge_r - 1.8, Color("FFF2E5"))

		var badge_str := "+5"
		var b_size := 11
		var b_str_sz := font.get_string_size(badge_str, HORIZONTAL_ALIGNMENT_CENTER, -1, b_size)
		var b_text_pos := badge_c + Vector2(-b_str_sz.x * 0.5, font.get_ascent(b_size) - b_str_sz.y * 0.5)
		draw_string(font, b_text_pos, badge_str, HORIZONTAL_ALIGNMENT_CENTER, -1, b_size, Color("D35400"))
