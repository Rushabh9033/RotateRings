extends Node
class_name SceneRouter

const LevelDatabaseScript = preload("res://data/level_database.gd")

enum Screen {
	HOME,
	LEVEL_SELECT,
	GAMEPLAY,
	EDITOR
}

var current_screen: Screen = Screen.HOME

var home_screen: Control = null
var level_select_screen: Control = null
var gameplay_screen: Control = null
var editor_screen: Control = null

var save_service: Node = null
var audio_service: Node = null
var haptic_service: Node = null

func setup(
	home: Control,
	level_select: Control,
	gameplay: Control,
	editor: Control,
	save_svc: Node,
	audio_svc: Node,
	haptic_svc: Node
) -> void:
	home_screen = home
	level_select_screen = level_select
	gameplay_screen = gameplay
	editor_screen = editor
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
	home_screen.editor_pressed.connect(show_editor_from_home)

	level_select_screen.level_selected.connect(show_gameplay)
	level_select_screen.back_pressed.connect(show_home)
	level_select_screen.editor_pressed.connect(show_editor_from_level_select)

	gameplay_screen.back_to_levels_requested.connect(show_level_select)
	gameplay_screen.back_to_home_requested.connect(show_home)
	gameplay_screen.edit_level_requested.connect(_on_edit_level_requested)

	# editor_screen.back_pressed is wired in app.gd (where we have access to
	# the router reference via lambda capture).

	show_home()

func show_home() -> void:
	current_screen = Screen.HOME
	home_screen.update_continue_info()
	home_screen.show()
	level_select_screen.hide()
	gameplay_screen.hide()
	editor_screen.hide()

func show_level_select() -> void:
	current_screen = Screen.LEVEL_SELECT
	level_select_screen.build_grid()
	home_screen.hide()
	level_select_screen.show()
	gameplay_screen.hide()
	editor_screen.hide()

func show_editor_from_home() -> void:
	current_screen = Screen.EDITOR
	home_screen.hide()
	level_select_screen.hide()
	gameplay_screen.hide()
	editor_screen.show()
	if editor_screen.has_method("setup_editor"):
		editor_screen.setup_editor(1)

func show_editor_from_level_select() -> void:
	current_screen = Screen.EDITOR
	home_screen.hide()
	level_select_screen.hide()
	gameplay_screen.hide()
	editor_screen.show()
	if editor_screen.has_method("setup_editor"):
		editor_screen.setup_editor(1)

func _on_edit_level_requested(level_id: int) -> void:
	current_screen = Screen.EDITOR
	home_screen.hide()
	level_select_screen.hide()
	# gameplay_screen stays live behind the editor as a "background". Hide it
	# too so memory-checks on save/release don't leak the puzzle state.
	gameplay_screen.hide()
	editor_screen.show()
	if editor_screen.has_method("setup_editor"):
		editor_screen.setup_editor(level_id)

func show_gameplay(level_id: int) -> void:
	if not LevelDatabaseScript.is_level_playable(level_id):
		push_warning("SceneRouter rejected level %d. It was not replaced with Level 1." % level_id)
		show_level_select()
		return
	current_screen = Screen.GAMEPLAY
	home_screen.hide()
	level_select_screen.hide()
	gameplay_screen.show()
	if not gameplay_screen.load_level_by_id(level_id):
		show_level_select()

func show_debug_gameplay(level_id: int) -> void:
	if not OS.is_debug_build():
		push_warning("Debug level %d was ignored outside a debug build." % level_id)
		return
	if not LevelDatabaseScript.is_level_defined(level_id):
		push_warning("SceneRouter rejected undefined debug level %d." % level_id)
		show_level_select()
		return
	current_screen = Screen.GAMEPLAY
	home_screen.hide()
	level_select_screen.hide()
	gameplay_screen.show()
	if not gameplay_screen.load_debug_level(level_id):
		show_level_select()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		if current_screen == Screen.GAMEPLAY:
			show_level_select()
			get_viewport().set_input_as_handled()
		elif current_screen == Screen.LEVEL_SELECT:
			show_home()
			get_viewport().set_input_as_handled()
