extends Control

var board_mode: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	resized.connect(queue_redraw)
	call_deferred("queue_redraw")

func _draw() -> void:
	var s := size
	if s.x < 2.0 or s.y < 2.0:
		return
	draw_rect(Rect2(Vector2.ZERO, s), Color("F6EBDD"))
	draw_circle(Vector2(s.x * 0.5, s.y * 0.42), s.y * 0.55, Color(1, 0.97, 0.93, 0.9))
	if board_mode:
		_wash(s, 0.35)
	else:
		_wash(s, 1.0)
		_corner_ring(Vector2(-30.0, s.y * 0.72), 120.0, Color("FF8A62"))
		_corner_ring(Vector2(s.x + 20.0, s.y * 0.18), 100.0, Color("49C4B0"))
		_corner_ring(Vector2(s.x * 0.78, s.y + 10.0), 90.0, Color("F0B429"))
	draw_rect(Rect2(0, 0, s.x, 18), Color(0.55, 0.35, 0.22, 0.04))
	draw_rect(Rect2(0, s.y - 22, s.x, 22), Color(0.55, 0.35, 0.22, 0.05))

func _wash(s: Vector2, strength: float) -> void:
	draw_circle(Vector2(s.x * 0.12, 40.0), 160.0, Color(1.0, 0.62, 0.45, 0.16 * strength))
	draw_circle(Vector2(s.x * 0.9, s.y * 0.12), 140.0, Color(0.45, 0.78, 0.95, 0.14 * strength))
	draw_circle(Vector2(s.x * 0.2, s.y * 0.92), 180.0, Color(0.95, 0.75, 0.35, 0.12 * strength))

func _corner_ring(center: Vector2, radius: float, color: Color) -> void:
	var body := color
	body.a = 0.55
	draw_arc(center, radius, 0.4, 5.0, 48, body, 22.0, true)
	var lip := color.darkened(0.18)
	lip.a = 0.4
	draw_arc(center + Vector2(0, 6), radius, 0.4, 5.0, 48, lip, 22.0, true)
	var hi := Color(1, 1, 1, 0.45)
	draw_arc(center + Vector2(-2, -3), radius, 0.8, 2.6, 24, hi, 6.0, true)
