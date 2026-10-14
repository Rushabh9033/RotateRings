extends HBoxContainer
class_name HomeTitleLogo

const UiTheme = preload("res://app/ui_theme.gd")

func _init() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 2)
	custom_minimum_size = Vector2(0, 56)

	var font = UiTheme.rounded_font()
	var font_size = 42
	var text_color = Color("543324")

	# 1. "R"
	var lbl_r = Label.new()
	lbl_r.text = "R"
	lbl_r.add_theme_font_override("font", font)
	lbl_r.add_theme_font_size_override("font_size", font_size)
	lbl_r.add_theme_color_override("font_color", text_color)
	lbl_r.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl_r)

	# 2. Orange C-Ring ("O")
	var ring_ctrl = Control.new()
	ring_ctrl.custom_minimum_size = Vector2(36, 44)
	ring_ctrl.draw.connect(func():
		var center = Vector2(18, 19.5)
		UiTheme.draw_c_ring(ring_ctrl, center, 14.5, 9.5, Color("FF7A29"), 0.0, 1.15)
	)
	add_child(ring_ctrl)

	# 3. "TATE"
	var lbl_tate = Label.new()
	lbl_tate.text = "TATE"
	lbl_tate.add_theme_font_override("font", font)
	lbl_tate.add_theme_font_size_override("font_size", font_size)
	lbl_tate.add_theme_color_override("font_color", text_color)
	lbl_tate.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl_tate)

	# 4. Spacing between "ROTATE" and "RINGS"
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(14, 0)
	add_child(spacer)

	# 5. "RINGS"
	var lbl_rings = Label.new()
	lbl_rings.text = "RINGS"
	lbl_rings.add_theme_font_override("font", font)
	lbl_rings.add_theme_font_size_override("font_size", font_size)
	lbl_rings.add_theme_color_override("font_color", text_color)
	lbl_rings.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl_rings)
