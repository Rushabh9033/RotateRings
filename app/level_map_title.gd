extends HBoxContainer
class_name LevelMapTitle

const UiTheme = preload("res://app/ui_theme.gd")

func _init() -> void:
	alignment = BoxContainer.ALIGNMENT_CENTER
	add_theme_constant_override("separation", 3)
	custom_minimum_size = Vector2(0, 48)

	var font = UiTheme.rounded_font()
	var font_size = 32
	var text_color = Color("543324")

	# 1. "LEVEL"
	var lbl_lvl = Label.new()
	lbl_lvl.text = "LEVEL"
	lbl_lvl.add_theme_font_override("font", font)
	lbl_lvl.add_theme_font_size_override("font_size", font_size)
	lbl_lvl.add_theme_color_override("font_color", text_color)
	lbl_lvl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl_lvl)

	# 2. Cyan C-Ring
	var ring_ctrl = Control.new()
	ring_ctrl.custom_minimum_size = Vector2(30, 36)
	ring_ctrl.draw.connect(func():
		var center = Vector2(15, 16.5)
		# Gap at ~45 degrees pointing bottom-right
		UiTheme.draw_c_ring(ring_ctrl, center, 12.0, 7.5, Color("29B6F6"), 0.7, 1.1)
	)
	add_child(ring_ctrl)

	# 3. "MAP"
	var lbl_map = Label.new()
	lbl_map.text = "MAP"
	lbl_map.add_theme_font_override("font", font)
	lbl_map.add_theme_font_size_override("font_size", font_size)
	lbl_map.add_theme_color_override("font_color", text_color)
	lbl_map.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_child(lbl_map)
