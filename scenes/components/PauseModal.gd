extends Control
class_name PauseModal

const UiTheme = preload("res://app/ui_theme.gd")

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
	_apply_chrome()
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
	modulate.a = 0.0
	show()
	var panel := get_node_or_null("Panel") as Control
	if panel:
		UiTheme.present_modal(panel)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.16)

func _apply_chrome() -> void:
	var dimmer := get_node_or_null("Dimmer") as ColorRect
	if dimmer:
		dimmer.color = UiTheme.DIMMER
	var panel := get_node_or_null("Panel") as Panel
	if panel:
		panel.add_theme_stylebox_override("panel", UiTheme.panel())
	var title := get_node_or_null("Panel/VBox/Title") as Label
	if title:
		title.text = "Paused"
		UiTheme.paint_label(title, UiTheme.FONT_TITLE)
	UiTheme.paint_check(sound_check)
	UiTheme.paint_check(haptics_check)
	resume_btn.text = "Resume"
	restart_btn.text = "Restart"
	levels_btn.text = "Level map"
	home_btn.text = "Main menu"
	UiTheme.paint_button(resume_btn, "primary", UiTheme.FONT_HEAD)
	UiTheme.paint_button(restart_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.paint_button(levels_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.paint_button(home_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.apply_font(self)
