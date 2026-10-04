extends Node2D
class_name FloatingText

# Game praise popup ("Good!", "Great!", "Excellent!") with glossy white body, cyan/green/purple outline and glow
var label: Label

func setup(pos: Vector2, text_content: String, outline_accent: Color) -> void:
	global_position = pos
	z_index = 100

	label = Label.new()
	label.text = text_content
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 42)
	# White fill
	label.add_theme_color_override("font_color", Color.WHITE)
	# Vibrant outline
	label.add_theme_color_override("font_outline_color", outline_accent)
	label.add_theme_constant_override("outline_size", 10)
	# Soft drop shadow
	label.add_theme_color_override("font_shadow_color", Color(0.2, 0.14, 0.08, 0.35))
	label.add_theme_constant_override("shadow_offset_x", 0)
	label.add_theme_constant_override("shadow_offset_y", 4)

	# Center label pivot
	label.position = Vector2(-150, -35)
	label.custom_minimum_size = Vector2(300, 70)
	add_child(label)

	scale = Vector2(0.2, 0.2)
	modulate.a = 1.0

	var tween = create_tween().set_parallel(true)
	# Punchy pop-in
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", position.y - 70.0, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.35).set_delay(0.35)

	tween.chain().tween_callback(queue_free)
