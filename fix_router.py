with open("D:/AI secound Brain/RotateRings/app/scene_router.gd", "r", encoding="utf-8") as f:
    text = f.read()

input_handling = """
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		if current_screen == Screen.GAMEPLAY:
			show_level_select()
			get_viewport().set_input_as_handled()
		elif current_screen == Screen.LEVEL_SELECT:
			show_home()
			get_viewport().set_input_as_handled()
"""
if "func _input" not in text:
    text += input_handling

with open("D:/AI secound Brain/RotateRings/app/scene_router.gd", "w", encoding="utf-8") as f:
    f.write(text)
