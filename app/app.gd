extends Control
class_name App

const SaveServiceScript = preload("res://app/save_service.gd")
const AudioServiceScript = preload("res://app/audio_service.gd")
const HapticServiceScript = preload("res://app/haptic_service.gd")
const SceneRouterScript = preload("res://app/scene_router.gd")

@onready var save_service = $Services/SaveService
@onready var audio_service = $Services/AudioService
@onready var haptic_service = $Services/HapticService
@onready var scene_router = $SceneRouter

@onready var home_screen = $Screens/HomeScreen
@onready var level_select_screen = $Screens/LevelSelectScreen
@onready var gameplay_screen = $Screens/GameplayScreen
@onready var settings_modal = $Screens/SettingsModal
@onready var level_editor = $Screens/LevelEditor

func _ready() -> void:
	audio_service.setup(save_service)
	haptic_service.setup(save_service)
	settings_modal.setup(save_service, audio_service)

	home_screen.settings_pressed.connect(func():
		settings_modal.show_modal()
	)
	settings_modal.progress_reset.connect(func():
		home_screen.update_continue_info()
		level_select_screen.build_grid()
	)

	scene_router.setup(
		home_screen,
		level_select_screen,
		gameplay_screen,
		level_editor,
		save_service,
		audio_service,
		haptic_service
	)
	level_editor.back_pressed.connect(func():
		scene_router.show_home()
	)
	var splash := preload("res://scenes/splash/SplashScreen.tscn").instantiate()
	add_child(splash)
	splash.begin(audio_service, haptic_service)

func _input(event: InputEvent) -> void:
	# F2 = toggle level editor (debug / authoring tool). Use _input (not
	# _unhandled_input) so it fires even if a child Control with mouse_filter
	# STOP is currently focused. Marked handled with get_viewport().set_input_as_handled()
	# so the event doesn't propagate and trigger other actions.
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F2:
		if level_editor.visible:
			level_editor.hide()
			if home_screen: home_screen.show()
			if level_select_screen: level_select_screen.show()
			if gameplay_screen: gameplay_screen.show()
		else:
			if home_screen: home_screen.hide()
			if level_select_screen: level_select_screen.hide()
			if gameplay_screen: gameplay_screen.hide()
			level_editor.show()
			# Force input focus on the editor so subsequent clicks work.
			level_editor.grab_focus()
		get_viewport().set_input_as_handled()
