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
	draw_rect(Rect2(Vector2.ZERO, s), Color("F7ECD6"))
	draw_circle(Vector2(s.x * 0.5, s.y * 0.42), s.y * 0.55, Color(0.99, 0.96, 0.90, 0.95))
	if board_mode:
		_wash(s, 0.35)
	else:
		_wash(s, 0.7)

func _wash(s: Vector2, strength: float) -> void:
	draw_circle(Vector2(s.x * 0.12, 40.0), 160.0, Color(1.0, 0.62, 0.45, 0.12 * strength))
	draw_circle(Vector2(s.x * 0.9, s.y * 0.12), 140.0, Color(0.45, 0.78, 0.95, 0.10 * strength))
	draw_circle(Vector2(s.x * 0.2, s.y * 0.92), 180.0, Color(0.95, 0.75, 0.35, 0.08 * strength))
