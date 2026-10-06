extends Control
class_name SettingsModal

const UiTheme = preload("res://app/ui_theme.gd")

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
	_apply_chrome()
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
		title.text = "Settings"
		UiTheme.paint_label(title, UiTheme.FONT_TITLE)
	UiTheme.paint_check(sound_check)
	UiTheme.paint_check(haptics_check)
	UiTheme.paint_check(motion_check)
	UiTheme.paint_button(reset_btn, "danger", UiTheme.FONT_BODY)
	UiTheme.paint_button(close_btn, "primary", UiTheme.FONT_HEAD)
	UiTheme.apply_font(self)
	reset_btn.text = "Reset progress"
	close_btn.text = "Close"
