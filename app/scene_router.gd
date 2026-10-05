extends Node
class_name SceneRouter

enum Screen {
	HOME,
	LEVEL_SELECT,
	GAMEPLAY
}

var current_screen: Screen = Screen.HOME

var home_screen: Control = null
var level_select_screen: Control = null
var gameplay_screen: Control = null

var save_service: Node = null
var audio_service: Node = null
var haptic_service: Node = null

func setup(
	home: Control,
	level_select: Control,
	gameplay: Control,
	save_svc: Node,
	audio_svc: Node,
	haptic_svc: Node
) -> void:
	home_screen = home
	level_select_screen = level_select
	gameplay_screen = gameplay
	save_service = save_svc
	audio_service = audio_svc
	haptic_service = haptic_svc
	
	home_screen.setup(save_service, audio_service)
	level_select_screen.setup(save_service, audio_service)
	gameplay_screen.setup(save_service, audio_service, haptic_service)
	
	home_screen.continue_pressed.connect(func(lvl_id: int):
		show_gameplay(lvl_id)
	)
	home_screen.levels_pressed.connect(show_level_select)
	
	level_select_screen.level_selected.connect(show_gameplay)
	level_select_screen.back_pressed.connect(show_home)
	
	gameplay_screen.back_to_levels_requested.connect(show_level_select)
	gameplay_screen.back_to_home_requested.connect(show_home)
	
	show_home()

func show_home() -> void:
	current_screen = Screen.HOME
	home_screen.update_continue_info()
	home_screen.show()
	level_select_screen.hide()
	gameplay_screen.hide()

func show_level_select() -> void:
	current_screen = Screen.LEVEL_SELECT
	level_select_screen.build_grid()
	home_screen.hide()
	level_select_screen.show()
	gameplay_screen.hide()

func show_gameplay(level_id: int) -> void:
	current_screen = Screen.GAMEPLAY
	home_screen.hide()
	level_select_screen.hide()
	gameplay_screen.show()
	gameplay_screen.load_level_by_id(level_id)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		if current_screen == Screen.GAMEPLAY:
			show_level_select()
			get_viewport().set_input_as_handled()
		elif current_screen == Screen.LEVEL_SELECT:
			show_home()
			get_viewport().set_input_as_handled()
