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
		save_service,
		audio_service,
		haptic_service
	)
