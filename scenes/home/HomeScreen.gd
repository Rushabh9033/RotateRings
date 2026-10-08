extends Control
class_name HomeScreen

const UiTheme = preload("res://app/ui_theme.gd")

signal continue_pressed(level_id: int)
signal levels_pressed
signal settings_pressed
signal editor_pressed

@onready var continue_btn: Button = $SafeArea/VBox/MenuBtns/ContinueBtn
@onready var levels_btn: Button = $SafeArea/VBox/MenuBtns/LevelsBtn
@onready var settings_btn: Button = $SafeArea/VBox/MenuBtns/SettingsBtn
@onready var editor_btn: Button = $SafeArea/VBox/MenuBtns/EditorBtn
@onready var continue_subtitle: Label = $SafeArea/VBox/MenuBtns/ContinueSubtitle

var save_service: Node = null
var audio_service: Node = null

func setup(save_svc: Node, audio_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	update_continue_info()

func _ready() -> void:
	UiTheme.mount_backdrop(self)
	var hero: Control = preload("res://app/home_hero.gd").new()
	hero.name = "Hero"
	$SafeArea/VBox.add_child(hero)
	$SafeArea/VBox.move_child(hero, 0)
	UiTheme.paint_button(continue_btn, "primary", UiTheme.FONT_HEAD)
	UiTheme.paint_button(levels_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.paint_button(editor_btn, "secondary", UiTheme.FONT_BODY)
	editor_btn.pressed.connect(func():
		if audio_service and audio_service.has_method("play_ui_tap"):
			audio_service.play_ui_tap()
		editor_pressed.emit()
	)
	UiTheme.paint_button(settings_btn, "secondary", UiTheme.FONT_BODY)
	UiTheme.paint_label($SafeArea/VBox/Header/Logo, UiTheme.FONT_DISPLAY)
	UiTheme.paint_label($SafeArea/VBox/Header/Tagline, 18, true)
	UiTheme.paint_label(continue_subtitle, UiTheme.FONT_CAPTION, true)
	var rule := get_node_or_null("SafeArea/VBox/Header/Rule") as ColorRect
	if rule:
		rule.color = UiTheme.ACCENT
		rule.custom_minimum_size = Vector2(88, 8)
	UiTheme.apply_font(self)
	modulate.a = 0.0
	var intro := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	intro.tween_property(self, "modulate:a", 1.0, 0.28)
	continue_btn.pressed.connect(func():
		if audio_service: audio_service.play_ui_tap()
		var target := get_continue_level()
		continue_pressed.emit(target)
	)
	levels_btn.pressed.connect(func():
		if audio_service: audio_service.play_ui_tap()
		levels_pressed.emit()
	)
	settings_btn.pressed.connect(func():
		if audio_service: audio_service.play_ui_tap()
		settings_pressed.emit()
	)

func get_continue_level() -> int:
	if save_service and save_service.has_method("get_continue_level"):
		return int(save_service.get_continue_level())
	return 1

func update_continue_info() -> void:
	var lvl := get_continue_level()
	continue_subtitle.text = "Level %d" % lvl
