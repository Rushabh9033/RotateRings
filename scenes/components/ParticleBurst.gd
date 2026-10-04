extends CPUParticles2D
class_name ParticleBurst

func _ready() -> void:
	emitting = true
	var timer := get_tree().create_timer(lifetime + 0.1)
	timer.timeout.connect(queue_free)

func setup(pos: Vector2, color: Color) -> void:
	global_position = pos
	color_ramp = Gradient.new()
	color_ramp.set_color(0, color)
	color_ramp.set_color(1, Color(color.r, color.g, color.b, 0.0))
