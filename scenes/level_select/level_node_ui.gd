extends Button

@export var is_unlocked: bool = false
@export var is_cleared: bool = false
@export var is_perfect: bool = false

var base_color: Color = Color(0.3, 0.7, 1.0, 1.0)
var thickness: float = 24.0

func _ready() -> void:
	flat = true
	# We don't use modulate for the whole button because it tints everything including text and shadows.
	# We manually select base_color.
	
	if not is_unlocked:
		base_color = Color(0.4, 0.45, 0.55, 1.0)
	elif is_perfect:
		base_color = Color(1.0, 0.85, 0.2, 1.0)
	elif is_cleared:
		base_color = Color(0.2, 0.9, 0.5, 1.0)
	else:
		base_color = Color(0.3, 0.7, 1.0, 1.0)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var center = size * 0.5
	var r = min(size.x, size.y) * 0.5 - (thickness * 0.5) - 4.0
	var segs = 128
	
	var is_pressed_visual = button_pressed
	var z_offset: float = 0.0
	var shadow_mult: float = 1.0
	var light_mult: float = 1.0
	
	# Current level breathes
	if is_unlocked and not is_cleared:
		var time = float(Time.get_ticks_msec()) / 1000.0
		z_offset = sin(time * 3.0) * 2.0
		shadow_mult = 1.0 + (z_offset * 0.1)
	
	if is_pressed_visual:
		z_offset = -4.0
		shadow_mult = 0.5
		light_mult = 0.8
		
	# Draw Shadow
	var shadow_c1 := Color(0.20, 0.14, 0.10, 0.15)
	var shadow_off1: Vector2 = Vector2(0, 8.0 - z_offset) * shadow_mult
	draw_arc(center + shadow_off1, r, 0, TAU, segs, shadow_c1, thickness + 2.0, true)
	
	# Darker Base
	var c_dark = base_color.darkened(0.22)
	var off_dark: Vector2 = Vector2(0, 3.5 - z_offset)
	draw_arc(center + off_dark, r, 0, TAU, segs, c_dark, thickness, true)
	
	# Main Body
	var c_main = base_color.lightened(0.02)
	var off_main: Vector2 = Vector2(0, -z_offset)
	draw_arc(center + off_main, r, 0, TAU, segs, c_main, thickness, true)
	
	# Highlight
	var c_light = base_color.lightened(0.25)
	c_light = c_light.lerp(Color.BLACK, 1.0 - light_mult)
	c_light.a = 0.85
	var off_light: Vector2 = Vector2(-1.5, -2.5 - z_offset)
	draw_arc(center + off_light, r, 0, TAU, segs, c_light, thickness - 3.0, true)
	
	# Inner shadow
	var c_inner = base_color.darkened(0.1)
	c_inner.a = 0.5
	draw_arc(center + off_main + Vector2(0, -1.0), r - (thickness * 0.5) + 1.5, 0, TAU, segs, c_inner, 1.5, true)
	
	# Draw lock if needed
	if not is_unlocked:
		var lock_c = Color(0.2, 0.2, 0.25, 0.8)
		# Draw a small padlock shape in the center
		draw_rect(Rect2(center.x - 8, center.y - 4 - z_offset, 16, 12), lock_c)
		draw_arc(center + Vector2(0, -4 - z_offset), 6.0, PI, TAU, 32, lock_c, 3.0, true)
