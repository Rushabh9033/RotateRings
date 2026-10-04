extends Control
class_name PauseModal

signal resume_pressed
signal restart_pressed
signal levels_pressed
signal home_pressed

@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var levels_btn: Button = $Panel/VBox/LevelsBtn
@onready var home_btn: Button = $Panel/VBox/HomeBtn
@onready var sound_check: CheckBox = $Panel/VBox/SettingsRow/SoundCheck
@onready var haptics_check: CheckBox = $Panel/VBox/SettingsRow/HapticsCheck

var save_service: Node = null

func setup(save_svc: Node) -> void:
	save_service = save_svc
	if save_service:
		sound_check.button_pressed = bool(save_service.get_setting("sound", true))
		haptics_check.button_pressed = bool(save_service.get_setting("haptics", true))

func _ready() -> void:
	resume_btn.pressed.connect(func(): resume_pressed.emit(); hide())
	restart_btn.pressed.connect(func(): restart_pressed.emit(); hide())
	levels_btn.pressed.connect(func(): levels_pressed.emit(); hide())
	home_btn.pressed.connect(func(): home_pressed.emit(); hide())
	
	sound_check.toggled.connect(func(toggled: bool):
		if save_service: save_service.set_setting("sound", toggled)
	)
	haptics_check.toggled.connect(func(toggled: bool):
		if save_service: save_service.set_setting("haptics", toggled)
	)

func show_modal() -> void:
	if save_service:
		sound_check.button_pressed = bool(save_service.get_setting("sound", true))
		haptics_check.button_pressed = bool(save_service.get_setting("haptics", true))
	show()
