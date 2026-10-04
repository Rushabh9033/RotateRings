extends Control
class_name SettingsModal

signal closed
signal progress_reset

@onready var sound_check: CheckBox = $Panel/VBox/SoundCheck
@onready var haptics_check: CheckBox = $Panel/VBox/HapticsCheck
@onready var motion_check: CheckBox = $Panel/VBox/MotionCheck
@onready var reset_btn: Button = $Panel/VBox/ResetBtn
@onready var close_btn: Button = $Panel/VBox/CloseBtn

var save_service: Node = null
var audio_service: Node = null

func setup(save_svc: Node, audio_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	if save_service:
		sound_check.button_pressed = bool(save_service.get_setting("sound", true))
		haptics_check.button_pressed = bool(save_service.get_setting("haptics", true))
		motion_check.button_pressed = bool(save_service.get_setting("reduced_motion", false))

func _ready() -> void:
	close_btn.pressed.connect(func():
		if audio_service: audio_service.play_ui_tap()
		hide()
		closed.emit()
	)
	sound_check.toggled.connect(func(toggled: bool):
		if save_service: save_service.set_setting("sound", toggled)
	)
	haptics_check.toggled.connect(func(toggled: bool):
		if save_service: save_service.set_setting("haptics", toggled)
	)
	motion_check.toggled.connect(func(toggled: bool):
		if save_service: save_service.set_setting("reduced_motion", toggled)
	)
	reset_btn.pressed.connect(func():
		if save_service: save_service.reset_all_progress()
		if audio_service: audio_service.play_ui_tap()
		progress_reset.emit()
	)

func show_modal() -> void:
	if save_service:
		sound_check.button_pressed = bool(save_service.get_setting("sound", true))
		haptics_check.button_pressed = bool(save_service.get_setting("haptics", true))
		motion_check.button_pressed = bool(save_service.get_setting("reduced_motion", false))
	show()
