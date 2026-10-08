extends Node2D
class_name TutorialHand

## A short plastic arrow that rides the outside of a ring. Same soft shading as the rings.

const INK := Color("FF6A45")
const INK_DARK := Color("D24428")
const SHADOW := Color(0.29, 0.16, 0.1, 0.30)

var is_active: bool = false
var _center := Vector2.ZERO
var _orbit := 90.0
var _from := 0.0
var _sweep := 1.0
var _along := 0.0


func _ready() -> void:
	z_index = 200
	modulate.a = 0.0


func _process(_delta: float) -> void:
	if not is_active:
		return
	var ang := _from + _sweep * _along
	position = _center + Vector2.from_angle(ang) * _orbit
	var turn := 1.0 if _sweep >= 0.0 else -1.0
	rotation = ang + PI * 0.5 * turn
	queue_redraw()


func play_orbit(center: Vector2, orbit: float, from_ang: float, sweep: float) -> void:
	top_level = true
	is_active = true
	_center = center
	_orbit = orbit
	_from = from_ang
	_sweep = sweep
	_along = 0.0
	var tween := create_tween().set_loops()
	tween.tween_property(self, "modulate:a", 1.0, 0.16)
	tween.parallel().tween_method(_set_along, 0.0, 1.0, 0.85).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate:a", 0.0, 0.16)
	tween.tween_interval(0.2)
	tween.tween_callback(func() -> void: _along = 0.0)


func _set_along(value: float) -> void:
	_along = value


func stop() -> void:
	is_active = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.14)
	tween.tween_callback(queue_free)


func _draw() -> void:
	var base_color := Color("FFFFFF")
	var shadow := Color(0, 0, 0, 0.3)
	
	# Draw the hand
	# Shadow
	draw_circle(Vector2(2, 22), 16, shadow)
	draw_line(Vector2(2, 22), Vector2(2, -10), shadow, 14, true)
	# Main hand
	draw_circle(Vector2(0, 20), 16, base_color)
	draw_line(Vector2(0, 20), Vector2(0, -12), base_color, 14, true)
