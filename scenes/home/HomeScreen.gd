extends Control
class_name HomeScreen

const LevelDatabaseScript = preload("res://data/level_database.gd")

signal continue_pressed(level_id: int)
signal levels_pressed
signal settings_pressed

@onready var continue_btn: Button = $SafeArea/VBox/MenuBtns/ContinueBtn
@onready var levels_btn: Button = $SafeArea/VBox/MenuBtns/LevelsBtn
@onready var settings_btn: Button = $SafeArea/VBox/MenuBtns/SettingsBtn
@onready var continue_subtitle: Label = $SafeArea/VBox/MenuBtns/ContinueSubtitle

var save_service: Node = null
var audio_service: Node = null

func setup(save_svc: Node, audio_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	update_continue_info()

func _ready() -> void:
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
	if not save_service: return 1
	var highest: int = int(save_service.get_setting("highest_unlocked_level", 1))
	return clampi(highest, 1, LevelDatabaseScript.get_total_levels())

func update_continue_info() -> void:
	var lvl := get_continue_level()
	continue_subtitle.text = "Level %d" % lvl
