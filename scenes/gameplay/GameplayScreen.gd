extends Control
class_name GameplayScreen

const LevelDatabaseScript = preload("res://data/level_database.gd")
const MascotCompanionScript = preload("res://gameplay/mascot_companion.gd")
const DroppedRing2DScript = preload("res://gameplay/dropped_ring_2d.gd")
const UiTheme = preload("res://app/ui_theme.gd")
const LevelDocumentScript = preload("res://data/level_document.gd")
const EditorToolbarScript = preload("res://scenes/editor/EditorToolbar.gd")

signal back_to_levels_requested
signal back_to_home_requested
signal edit_level_requested(level_id: int)

@onready var puzzle_controller = $PuzzleArea/PuzzleController
@onready var edit_overlay = $PuzzleArea/PieceEditOverlay
@onready var pause_btn: Button = $SafeArea/TopHUD/PauseBtn
@onready var edit_btn: Button = $SafeArea/TopHUD/EditBtn
@onready var back_btn: Button = $SafeArea/TopHUD/BackBtn
@onready var level_prefix: Label = $SafeArea/TopHUD/LevelBox/LevelPrefix
@onready var level_num_lbl: Label = $SafeArea/TopHUD/LevelBox/LevelNum
@onready var score_lbl: Label = $SafeArea/TopHUD/CenterHUD/ScorePill/ScoreLbl
@onready var rocket_btn: Button = $SafeArea/BottomHUD/RocketCard/RocketBtn
@onready var hammer_btn: Button = $SafeArea/BottomHUD/HammerCard/HammerBtn

@onready var pause_modal = $PauseModal
@onready var victory_modal = $VictoryModal

# In-game editor toolbar (mounted at runtime by _ensure_editor_toolbar).
var editor_toolbar: Control = null
# The current editor document. Created on first Edit press from the
# level's LevelDefinition. Survives save/load and TEST LEVEL round-trips.
var editor_document: Resource = null
# Saved LevelDefinition for "back to editor" on TEST LEVEL.
var _editor_saved_def: Resource = null

var save_service: Node = null
var audio_service: Node = null
var haptic_service: Node = null
var mascot: Node2D = null

var current_level_id: int = 1
var current_score: int = 0
var target_score: int = 0

func setup(save_svc: Node, audio_svc: Node, haptic_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	haptic_service = haptic_svc

	if puzzle_controller != null and pause_modal != null and edit_overlay != null:
		puzzle_controller.setup(audio_service, haptic_service, save_service)
		pause_modal.setup(save_service)
		edit_overlay.set_puzzle(puzzle_controller)
		edit_overlay.set_level_id(current_level_id)

func _ready() -> void:
	if save_service != null and puzzle_controller != null and pause_modal != null and edit_overlay != null:
		puzzle_controller.setup(audio_service, haptic_service, save_service)
		pause_modal.setup(save_service)
		edit_overlay.set_puzzle(puzzle_controller)
		edit_overlay.set_level_id(current_level_id)

	pause_modal.z_index = 100
	pause_modal.z_as_relative = false
	victory_modal.z_index = 100
	victory_modal.z_as_relative = false

	pause_btn.pressed.connect(_on_pause_pressed)
	edit_btn.pressed.connect(_on_edit_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	_apply_chrome()
	if rocket_btn: rocket_btn.pressed.connect(_on_hint_pressed)
	# Hammer is locked, do not connect to hint
	if hammer_btn: hammer_btn.disabled = true
	
	mascot = MascotCompanionScript.new()
	mascot.position = Vector2(get_viewport().get_visible_rect().size.x * 0.5, 200.0)
	mascot.z_index = 50
	$SafeArea/TopHUD.add_sibling(mascot)
	
	puzzle_controller.moves_updated.connect(_on_moves_updated)
	puzzle_controller.piece_count_updated.connect(_on_piece_count_updated)
	puzzle_controller.level_completed.connect(_on_level_completed)
	
	pause_modal.resume_pressed.connect(func(): puzzle_controller.resume_game())
	pause_modal.restart_btn.pressed.connect(restart_level)
	pause_modal.levels_pressed.connect(func(): back_to_levels_requested.emit())
	pause_modal.home_pressed.connect(func(): back_to_home_requested.emit())
	
	victory_modal.next_pressed.connect(_on_next_level_pressed)
	victory_modal.replay_pressed.connect(restart_level)
	victory_modal.levels_pressed.connect(func(): back_to_levels_requested.emit())

func load_level_by_id(lvl_id: int) -> bool:
	if not LevelDatabaseScript.is_level_playable(lvl_id):
		push_warning("GameplayScreen rejected level %d. It was not replaced with Level 1." % lvl_id)
		return false
	return _load_definition(lvl_id, LevelDatabaseScript.get_level(lvl_id))

func load_debug_level(lvl_id: int) -> bool:
	if not OS.is_debug_build():
		push_warning("load_debug_level(%d) ignored outside a debug build." % lvl_id)
		return false
	if not LevelDatabaseScript.is_level_defined(lvl_id):
		push_warning("GameplayScreen rejected undefined debug level %d." % lvl_id)
		return false
	return _load_definition(lvl_id, LevelDatabaseScript.get_level(lvl_id))

func _load_definition(lvl_id: int, def) -> bool:
	if def == null:
		push_warning("GameplayScreen refused to load level %d because it has no definition." % lvl_id)
		if OS.is_debug_build():
			assert(false, "Playable or debug level %d resolved to null." % lvl_id)
		return false
	current_level_id = lvl_id
	if edit_overlay: edit_overlay.set_level_id(current_level_id)

	level_prefix.text = "Level"
	level_num_lbl.text = str(lvl_id)
	level_num_lbl.add_theme_font_size_override("font_size", 24)
	current_score = 0
	target_score = 0
	total_pieces_in_level = 0
	score_lbl.text = "0"
	
	pause_modal.hide()
	victory_modal.hide()
	
	puzzle_controller.load_level(def)
	
	# Give it a frame to ensure all nodes are placed, then frame the puzzle
	get_tree().process_frame.connect(_frame_puzzle, CONNECT_ONE_SHOT)
	
	# Auto-trigger tutorial on Level 1
	if lvl_id == 1 and save_service and not save_service.has_seen_tutorial():
		get_tree().create_timer(2.0).timeout.connect(func():
			if not save_service.has_seen_tutorial():
				puzzle_controller.hint_controller.trigger_hint()
		)
	return true

func _frame_puzzle() -> void:
	if not is_instance_valid(puzzle_controller): return
	
	var target_scale: Vector2 = Vector2.ONE
	var target_pos: Vector2 = Vector2.ZERO
	
	if editor_document != null and (editor_document.frame_scale != 1.0 or editor_document.frame_offset_x != 0.0 or editor_document.frame_offset_y != 0.0):
		var gs: float = float(editor_document.frame_scale)
		target_scale = Vector2(gs, gs)
		target_pos = Vector2(float(editor_document.frame_offset_x), float(editor_document.frame_offset_y))
	else:
		var pieces: Array = puzzle_controller.active_pieces
		if pieces.is_empty() and puzzle_controller.pieces_container != null:
			pieces = puzzle_controller.pieces_container.get_children()
		
		if not pieces.is_empty():
			var min_pt := Vector2(1e9, 1e9)
			var max_pt := Vector2(-1e9, -1e9)
			for p in pieces:
				if not (p is Node2D): continue
				var pos: Vector2 = p.def.position if ("def" in p and p.def != null) else p.position
				var r: float = 64.0
				if "radius" in p:
					r = float(p.radius)
				elif "radius_x" in p:
					r = float(p.radius_x)
				min_pt.x = minf(min_pt.x, pos.x - r - 20.0)
				min_pt.y = minf(min_pt.y, pos.y - r - 20.0)
				max_pt.x = maxf(max_pt.x, pos.x + r + 20.0)
				max_pt.y = maxf(max_pt.y, pos.y + r + 20.0)
			
			var puzzle_size := max_pt - min_pt
			var puzzle_center := (min_pt + max_pt) * 0.5
			
			# Target area: X: 60 to 660 (width 600, center 360), Y: 220 to 1040 (height 820, center 630)
			var target_area_size := Vector2(600.0, 800.0)
			var target_area_center := Vector2(360.0, 620.0)
			
			var fit_scale_x := target_area_size.x / maxf(puzzle_size.x, 100.0)
			var fit_scale_y := target_area_size.y / maxf(puzzle_size.y, 100.0)
			var s := clampf(minf(fit_scale_x, fit_scale_y), 0.75, 1.25)
			
			target_scale = Vector2(s, s)
			target_pos = target_area_center - puzzle_center * s
	
	puzzle_controller.scale = target_scale
	puzzle_controller.position = target_pos

var total_pieces_in_level: int = 0

func _apply_chrome() -> void:
	# Pure porcelain cream canvas for gameplay, matching reference 4.jpeg
	if has_node("Background"):
		$Background.color = Color("F7EFE3")
	if back_btn:
		UiTheme.squircle_button(back_btn)
	if pause_btn:
		pause_btn.custom_minimum_size = Vector2(56, 56)
		pause_btn.text = "settings"
		UiTheme.squircle_button(pause_btn)
	if edit_btn:
		edit_btn.custom_minimum_size = Vector2(64, 48)
		UiTheme.squircle_button(edit_btn)
		edit_btn.add_theme_font_size_override("font_size", 14)

	# Top-left Level text
	if level_prefix:
		level_prefix.text = "Level"
		level_prefix.add_theme_font_override("font", UiTheme.rounded_font())
		level_prefix.add_theme_font_size_override("font_size", 16)
		level_prefix.add_theme_color_override("font_color", UiTheme.WARM_INK)
	if level_num_lbl:
		level_num_lbl.text = str(current_level_id)
		level_num_lbl.add_theme_font_override("font", UiTheme.rounded_font())
		level_num_lbl.add_theme_font_size_override("font_size", 28)
		level_num_lbl.add_theme_color_override("font_color", UiTheme.WARM_INK)

	# Center Moves Pill
	var pill := get_node_or_null("SafeArea/TopHUD/CenterHUD/ScorePill") as PanelContainer
	if pill:
		pill.custom_minimum_size = Vector2(230, 52)
		pill.add_theme_stylebox_override("panel", UiTheme.warm_pill())
	if score_lbl:
		score_lbl.add_theme_font_override("font", UiTheme.rounded_font())
		score_lbl.add_theme_font_size_override("font_size", 30)
		score_lbl.add_theme_color_override("font_color", UiTheme.WARM_INK)
		score_lbl.text = "0"

	# CenterHUD Subtitle "Game Rush"
	var center_hud := get_node_or_null("SafeArea/TopHUD/CenterHUD") as VBoxContainer
	if center_hud:
		center_hud.add_theme_constant_override("separation", 10)
		var sub := center_hud.get_node_or_null("RushSubtitle") as Label
		if sub == null:
			sub = Label.new()
			sub.name = "RushSubtitle"
			sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			center_hud.add_child(sub)
		sub.text = "Game Rush"
		sub.add_theme_font_override("font", UiTheme.rounded_font())
		sub.add_theme_font_size_override("font_size", 16)
		sub.add_theme_color_override("font_color", Color("CC181E"))

	# Bottom HUD Power-up Cards
	var rocket_card := get_node_or_null("SafeArea/BottomHUD/RocketCard") as PanelContainer
	if rocket_card and rocket_btn:
		_mount_powerup_card(rocket_card, rocket_btn, load("res://art/tools/rocket_tool.png"), "Free")

	var hammer_card := get_node_or_null("SafeArea/BottomHUD/HammerCard") as PanelContainer
	if hammer_card and hammer_btn:
		_mount_powerup_card(hammer_card, hammer_btn, load("res://art/tools/hammer_tool.png"), "locked")

	UiTheme.apply_font(self)

func _on_piece_count_updated(remaining: int) -> void:
	if total_pieces_in_level == 0:
		total_pieces_in_level = remaining
		if is_instance_valid(mascot):
			mascot.set_state(MascotCompanionScript.State.WATCHING)
			mascot.look_target = puzzle_controller.global_position
		return
		
	if is_instance_valid(mascot):
		mascot.set_state(MascotCompanionScript.State.REACT_GOOD)
		get_tree().create_timer(1.0).timeout.connect(func():
			if is_instance_valid(mascot) and mascot.current_state != MascotCompanionScript.State.CELEBRATING:
				mascot.set_state(MascotCompanionScript.State.WATCHING)
		)

func _on_moves_updated(moves: int, par_moves: int) -> void:
	score_lbl.text = str(moves)

	var pill = get_node_or_null("SafeArea/TopHUD/CenterHUD/ScorePill")
	if pill and moves > 0:
		var ptween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		pill.pivot_offset = pill.size / 2.0
		ptween.tween_property(pill, "scale", Vector2(1.15, 1.15), 0.1)
		ptween.tween_property(pill, "scale", Vector2.ONE, 0.4)
		# Color the pill red when the player has exceeded par.
		if moves > par_moves:
			score_lbl.add_theme_color_override("font_color", Color("#E53935"))
		else:
			score_lbl.remove_theme_color_override("font_color")

func _on_level_completed(moves: int, par_moves: int, used_hint: bool) -> void:
	var result: Dictionary = { "is_perfect": false, "best_moves": moves }
	if save_service:
		result = save_service.record_level_completion(current_level_id, moves, par_moves, used_hint)
	if audio_service:
		audio_service.play_level_clear(result.get("is_perfect", false))
	if haptic_service:
		haptic_service.trigger_level_complete()

	# Refill happens inside record_level_completion — refresh the badge so the +1 is visible.
	_refresh_hint_badge()
		
	# Trigger Mascot Portal Completion Sequence!
	var viewport_center = get_viewport().get_visible_rect().size * 0.5
	
	# Fire Confetti Burst!
	_fire_confetti(viewport_center)
	
	if is_instance_valid(mascot):
		mascot.set_state(MascotCompanionScript.State.CELEBRATING)
		
		# Animate mascot jumping to center screen
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(mascot, "position", viewport_center, 0.6)
			
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(victory_modal):
		var next_id := LevelDatabaseScript.get_next_playable_level(current_level_id)
		if next_id > 0 and not LevelDatabaseScript.is_level_playable(next_id):
			push_warning("Victory flow pointed at non-playable level %d." % next_id)
			next_id = 0
		victory_modal.show_victory(
			moves,
			par_moves,
			result.get("is_perfect", false),
			result.get("best_moves", moves),
			next_id
		)

func _on_next_level_pressed() -> void:
	var next_id := LevelDatabaseScript.get_next_playable_level(current_level_id)
	if next_id <= 0:
		back_to_levels_requested.emit()
	else:
		load_level_by_id(next_id)

func restart_level() -> void:
	if audio_service: audio_service.play_ui_tap()
	if LevelDatabaseScript.is_level_playable(current_level_id):
		load_level_by_id(current_level_id)
	else:
		load_debug_level(current_level_id)

func _on_back_pressed() -> void:
	if audio_service: audio_service.play_ui_tap()
	back_to_levels_requested.emit()

func _on_pause_pressed() -> void:
	if audio_service: audio_service.play_ui_tap()
	if puzzle_controller and puzzle_controller.has_method("pause_input"):
		puzzle_controller.pause_input()
	puzzle_controller.is_active = false
	pause_modal.show_modal()

func _on_edit_pressed() -> void:
	if audio_service: audio_service.play_ui_tap()
	# Toggle the in-built edit overlay. Puzzle keeps rendering; the overlay
	# enables drag-to-move on each piece and saves on drag-end.
	var new_state: bool = not edit_overlay.is_active()
	# First-time entry: build the editor document from the current level
	# definition so the toolbar + level_document have something to bind to.
	if new_state and editor_document == null:
		_ensure_editor_document()
	# Mount the toolbar if not yet present.
	if new_state:
		_ensure_editor_toolbar()
		# Coming back from TEST LEVEL: re-show toolbar and re-load the
		# editor document into the puzzle so the visible state matches.
		if editor_toolbar != null:
			editor_toolbar.visible = true
		# Hide the standard top HUD while in edit mode.
		if has_node("SafeArea/TopHUD"):
			$SafeArea/TopHUD.visible = false
	else:
		# Toggling OFF: hide the toolbar + show the standard HUD.
		if editor_toolbar != null:
			editor_toolbar.visible = false
		if has_node("SafeArea/TopHUD"):
			$SafeArea/TopHUD.visible = true
	edit_overlay.toggle(new_state)
	edit_btn.text = "Edit ON" if new_state else "Edit"
	# While edit is on, pause the puzzle input so gestures don't double-fire.
	if puzzle_controller and puzzle_controller.has_method("pause_input"):
		puzzle_controller.pause_input()
	puzzle_controller.is_active = not new_state

# Build the editor document from the current LevelDefinition on first entry.
# Survives in memory across multiple Edit toggles and the TEST LEVEL button.
func _ensure_editor_document() -> void:
	if editor_document != null: return
	var def = puzzle_controller.current_level_def
	if def == null: return
	editor_document = LevelDocumentScript.from_level_definition(def)

# Lazy-mount the EditorToolbar above the puzzle area.
func _ensure_editor_toolbar() -> void:
	if editor_toolbar != null: return
	editor_toolbar = EditorToolbarScript.new()
	editor_toolbar.set_document(editor_document)
	editor_toolbar.set_overlay(edit_overlay)
	editor_toolbar.test_level_pressed.connect(_on_test_level_pressed)
	editor_toolbar.fit_puzzle_requested.connect(_on_fit_puzzle_requested)
	editor_toolbar.open_reference_requested.connect(_on_open_reference_requested)
	editor_toolbar.calibrate_reference_requested.connect(_on_calibrate_reference_requested)
	editor_toolbar.snap_to_reference_requested.connect(_on_snap_to_reference_requested)
	# Re-frame the puzzle when the dock is shown/hidden so pieces
	# stay draggable.
	if editor_toolbar.has_signal("editor_panel_shown"):
		editor_toolbar.editor_panel_shown.connect(_on_editor_panel_shown)
	# Right-side slide-in dock. The dock self-anchors to the right edge
	# of the screen; it's hidden by default and a thin handle sits on
	# the right edge for the user to click and slide it in.
	editor_toolbar.z_index = 50
	add_child(editor_toolbar)
	# Auto-show on first entry so the user sees their tools immediately.
	editor_toolbar.show_panel()
	# Hide the standard top HUD while in edit mode.
	if has_node("SafeArea/TopHUD"):
		$SafeArea/TopHUD.visible = false

# M22: TEST LEVEL button. Snapshot the current editor document into a
# runtime LevelDefinition, swap the puzzle controller to use it, and
# exit edit mode. The editor document stays in memory so Back returns
# to the exact same state.
func _on_editor_panel_shown(_shown: bool) -> void:
	# Re-frame the puzzle so the safe area respects the dock's width.
	if is_inside_tree():
		get_tree().process_frame.connect(_frame_puzzle, CONNECT_ONE_SHOT)

func _on_test_level_pressed() -> void:
	if editor_document == null: return
	# Build a LevelDefinition from the editor document and hand it to the
	# puzzle controller.
	var def = editor_document.to_level_definition()
	puzzle_controller.load_level(def)
	# Exit edit mode (this does NOT clear the editor document).
	edit_overlay.toggle(false)
	edit_btn.text = "Edit"
	puzzle_controller.is_active = true
	if puzzle_controller and puzzle_controller.has_method("resume_input"):
		puzzle_controller.resume_input()
	# Hide the toolbar so the gameplay HUD is visible.
	if editor_toolbar != null:
		editor_toolbar.visible = false
	# Keep the level number visible.
	if has_node("SafeArea/TopHUD"):
		$SafeArea/TopHUD.visible = true

# Phase 8 wiring: explicit "Fit Puzzle" — compute ONE uniform global
# transform that fits the puzzle's authored bbox in the safe area,
# and write it into the document. Does NOT auto-run on load.
func _on_fit_puzzle_requested() -> void:
	if editor_document == null: return
	if puzzle_controller == null: return
	# Authored bbox in canvas space.
	var bounds = puzzle_controller.get_puzzle_bounds()
	if bounds.size.x <= 0 or bounds.size.y <= 0: return
	var viewport_size = get_viewport().get_visible_rect().size
	# Reserve space for the editor dock.
	var safe_margin_right: float = 36.0
	if editor_toolbar != null and editor_toolbar.is_panel_shown():
		safe_margin_right = maxf(safe_margin_right, 320.0 + 28.0 + 12.0)
	var safe_margin_x: float = 36.0
	var safe_margin_top: float = 96.0
	var safe_margin_bottom: float = 200.0
	var safe_w: float = viewport_size.x - safe_margin_x - safe_margin_right
	var safe_h: float = viewport_size.y - safe_margin_top - safe_margin_bottom
	if safe_w <= 50 or safe_h <= 50: return
	# Compute the uniform scale that fits the authored bbox.
	var sx: float = safe_w / bounds.size.x
	var sy: float = safe_h / bounds.size.y
	var s: float = minf(sx, sy)
	s = minf(s, 0.95)
	# Center the bbox in the safe area.
	var bounds_center: Vector2 = bounds.get_center()
	var safe_center: Vector2 = Vector2(safe_margin_x + safe_w * 0.5, safe_margin_top + safe_h * 0.5)
	# Apply the transform to the document (single source of truth).
	# authored * scale + offset = safe_center, so
	#   offset = safe_center - bounds_center * scale
	var ox: float = safe_center.x - bounds_center.x * s
	var oy: float = safe_center.y - bounds_center.y * s
	editor_document.apply_edit(func():
		editor_document.frame_scale = s
		editor_document.frame_offset_x = ox
		editor_document.frame_offset_y = oy
	)
	# Re-frame the puzzle immediately.
	_frame_puzzle()

# Phase 8: open the reference viewer. The viewer is a separate scene
# that lives inside the puzzle area; we instantiate it on demand.
var _ref_viewer: Control = null
func _on_open_reference_requested() -> void:
	if _ref_viewer == null:
		_ref_viewer = preload("res://scenes/reference_viewer/ReferenceViewer.tscn").instantiate()
		add_child(_ref_viewer)
		_ref_viewer.closed.connect(_on_reference_closed)
	if editor_document != null:
		# Pass the current pieces snapshot so the viewer can render the
		# puzzle ghost outline.
		var pieces_snap: Array = []
		for p in editor_document.pieces:
			pieces_snap.append({
				"position": Vector2(float(p.get("x", 0)), float(p.get("y", 0))),
				"radius": float(p.get("radius", 60)),
				"color": _puzzle_color(p),
			})
		_ref_viewer.setup(editor_document.level_id, pieces_snap)
		# Forward the fit/calibrate signals.
		_ref_viewer.fit_puzzle_requested.connect(_on_fit_puzzle_requested)
		_ref_viewer.calibrate_requested.connect(_on_calibrate_reference_requested)
		# Calibrate button may have already been pressed; apply state.
		_ref_viewer.set_calibration(
			_ref_viewer._ref_image_origin,
			_ref_viewer._ref_canvas_origin,
			_ref_viewer._ref_scale,
			_ref_viewer._puzzle_region_min,
			_ref_viewer._puzzle_region_max,
		)
	_ref_viewer.visible = true

func _on_reference_closed() -> void:
	if _ref_viewer != null:
		_ref_viewer.visible = false

# Phase 8: calibration entry point. For now this is a stub that resets
# the calibration to the default (full image, no crop). A future
# pass adds 4 drag handles so the user can crop the puzzle region.
func _on_calibrate_reference_requested() -> void:
	if _ref_viewer == null:
		_on_open_reference_requested()
	if _ref_viewer == null: return
	_ref_viewer.reset_calibration()

# Phase 14: snap the selected piece to its reference target. The
# overlay holds the per-piece reference_targets dict; we delegate
# to its public method.
func _on_snap_to_reference_requested() -> void:
	if edit_overlay == null: return
	if edit_overlay.has_method("snap_selected_to_reference_target"):
		edit_overlay.snap_selected_to_reference_target()

func _puzzle_color(p: Dictionary) -> Color:
	var hex: String = String(p.get("color_hex", "#EA7829"))
	if hex.begins_with("#"):
		var r: int = int("0x" + hex.substr(1, 2))
		var g: int = int("0x" + hex.substr(3, 2))
		var b: int = int("0x" + hex.substr(5, 2))
		return Color(r / 255.0, g / 255.0, b / 255.0, 1.0)
	return Color("#EA7829")

func _mount_powerup_card(card: PanelContainer, btn: Button, tex: Texture2D, count_str: String) -> void:
	if card == null or btn == null:
		return
	card.custom_minimum_size = Vector2(104, 104)
	card.add_theme_stylebox_override("panel", UiTheme.powerup_card())
	
	btn.text = ""
	btn.flat = true
	btn.set_anchors_preset(Control.PRESET_FULL_RECT)
	btn.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_stylebox_override("disabled", StyleBoxEmpty.new())
	
	# Icon
	var icon := btn.get_node_or_null("ToolIcon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "ToolIcon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 12.0
		icon.offset_top = 12.0
		icon.offset_right = -12.0
		icon.offset_bottom = -12.0
		btn.add_child(icon)
	icon.texture = tex
	icon.visible = true
	
	# Remove old flat turn mark if any
	var old_mark = btn.get_node_or_null("TurnMark")
	if old_mark:
		old_mark.queue_free()
	var old_cap = btn.get_node_or_null("ToolCaption")
	if old_cap:
		old_cap.queue_free()
	
	# Badge
	var badge := card.get_node_or_null("Badge") as PanelContainer
	if badge == null:
		badge = PanelContainer.new()
		badge.name = "Badge"
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(badge)
	badge.visible = true
	badge.custom_minimum_size = Vector2(28, 28)
	badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	badge.size_flags_horizontal = Control.SIZE_SHRINK_END
	badge.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	
	var is_locked := (count_str == "locked" or count_str == "Locked" or btn.disabled)
	var is_free := (count_str == "Free" or count_str == "free")
	if is_locked:
		badge.custom_minimum_size = Vector2(28, 28)
		badge.add_theme_stylebox_override("panel", UiTheme.gray_badge())
	elif is_free:
		badge.custom_minimum_size = Vector2(46, 22)
		badge.add_theme_stylebox_override("panel", UiTheme.green_badge())
	else:
		badge.custom_minimum_size = Vector2(28, 28)
		badge.add_theme_stylebox_override("panel", UiTheme.red_badge())
	
	var badge_lbl := badge.get_node_or_null("BadgeLbl") as Label
	if badge_lbl == null:
		badge_lbl = Label.new()
		badge_lbl.name = "BadgeLbl"
		badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.add_child(badge_lbl)
	badge_lbl.text = "🔒" if is_locked else count_str
	badge_lbl.add_theme_font_override("font", UiTheme.rounded_font())
	badge_lbl.add_theme_font_size_override("font_size", 13 if is_locked else (12 if is_free else 16))
	badge_lbl.add_theme_color_override("font_color", Color.WHITE)
	
	# Tactile spring bounce on press
	if not card.has_meta("bound_press"):
		card.set_meta("bound_press", true)
		card.pivot_offset = Vector2(52, 52)
		btn.button_down.connect(func():
			var tw = card.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tw.tween_property(card, "scale", Vector2(0.92, 0.92), 0.08)
		)
		btn.button_up.connect(func():
			var tw = card.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tw.tween_property(card, "scale", Vector2.ONE, 0.2)
		)


func _mount_tool(btn: Button, texture: Texture2D, caption: String, locked: bool) -> void:
	btn.text = ""
	btn.flat = false
	btn.disabled = locked
	btn.tooltip_text = "Locked" if locked else caption
	UiTheme.paint_button(btn, "secondary", 13)
	var card := btn.get_parent() as PanelContainer
	if card:
		card.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		var old_badge := card.get_node_or_null("Badge")
		if old_badge:
			old_badge.visible = false
	var icon := btn.get_node_or_null("ToolIcon") as TextureRect
	if icon == null:
		icon = TextureRect.new()
		icon.name = "ToolIcon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 12.0
		icon.offset_top = 8.0
		icon.offset_right = -12.0
		icon.offset_bottom = -30.0
		btn.add_child(icon)
	icon.texture = texture
	icon.modulate = Color(1, 1, 1, 0.42) if locked else Color.WHITE
	if texture == null and caption == "Hint":
		icon.visible = false
		var mark := btn.get_node_or_null("TurnMark")
		if mark == null:
			mark = TurnMark.new()
			mark.name = "TurnMark"
			mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
			mark.set_anchors_preset(Control.PRESET_FULL_RECT)
			mark.offset_left = 16.0
			mark.offset_top = 8.0
			mark.offset_right = -16.0
			mark.offset_bottom = -28.0
			btn.add_child(mark)
	var cap := btn.get_node_or_null("ToolCaption") as Label
	if cap == null:
		cap = Label.new()
		cap.name = "ToolCaption"
		cap.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		cap.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		cap.offset_top = -28.0
		cap.offset_bottom = -6.0
		btn.add_child(cap)
	cap.text = caption
	UiTheme.paint_label(cap, 13, true)
	if locked:
		cap.add_theme_color_override("font_color", Color("B7A394"))
		_mount_lock(btn)


func _mount_lock(btn: Button) -> void:
	if btn.get_node_or_null("LockChip"):
		return
	var chip := TextureRect.new()
	chip.name = "LockChip"
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.texture = preload("res://app/ui_icons.gd").make("lock", Color("8A6554"))
	chip.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	chip.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	chip.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	chip.offset_left = -30.0
	chip.offset_top = 8.0
	chip.offset_right = -8.0
	chip.offset_bottom = 30.0
	btn.add_child(chip)


func _on_hint_pressed() -> void:
	if save_service and not save_service.consume_hint():
		# Out of hints — flash the badge and bail.
		_flash_hint_badge()
		return
	puzzle_controller.request_hint()
	_refresh_hint_badge()

func _refresh_hint_badge() -> void:
	var badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/Badge/BadgeLbl")
	if badge == null:
		badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/RocketBtn/HintBadge")
	if badge and badge is Label:
		if badge.text == "Free":
			return
		var remaining: int = save_service.get_hints_remaining() if save_service else 5
		badge.text = str(remaining)
		badge.get_parent().visible = remaining > 0

func _flash_hint_badge() -> void:
	var badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/Badge")
	if badge == null:
		badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/RocketBtn/HintBadge")
	if badge:
		var t := create_tween().set_loops(2)
		t.tween_property(badge, "modulate:a", 0.3, 0.1)
		t.tween_property(badge, "modulate:a", 1.0, 0.1)

func _fire_confetti(pos: Vector2) -> void:
	var chunk_tex := _chunk_texture()
	var colors = PackedColorArray([
		Color("FF6A45"),
		Color("3DDC97"),
		Color("3EBEFF"),
		Color("F0B429"),
		Color("7B61FF"),
	])
	for c in colors:
		var confetti := CPUParticles2D.new()
		confetti.one_shot = true
		confetti.explosiveness = 0.92
		confetti.lifetime = 2.2
		confetti.amount = 18
		confetti.direction = Vector2(0, -1)
		confetti.spread = 140.0
		confetti.gravity = Vector2(0, 720.0)
		confetti.initial_velocity_min = 280.0
		confetti.initial_velocity_max = 760.0
		confetti.angular_velocity_min = -540.0
		confetti.angular_velocity_max = 540.0
		confetti.scale_amount_min = 0.45
		confetti.scale_amount_max = 1.15
		confetti.texture = chunk_tex
		confetti.color = c
		confetti.position = pos + Vector2(randf_range(-24.0, 24.0), randf_range(-12.0, 12.0))
		confetti.z_index = 200
		add_child(confetti)
		confetti.emitting = true
		var tween := create_tween()
		tween.tween_callback(confetti.queue_free).set_delay(2.6)

func _chunk_texture() -> Texture2D:
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var pts: Array[Vector2] = [
		Vector2(24, 6), Vector2(40, 16), Vector2(42, 32),
		Vector2(28, 44), Vector2(10, 34), Vector2(8, 16),
	]
	for y in 48:
		for x in 48:
			var p := Vector2(x + 0.5, y + 0.5)
			if not _point_in_poly(p, pts):
				continue
			var side := p.y > 30.0
			var shade := 0.55 if side else 1.0
			if p.distance_to(Vector2(18, 16)) < 8.0:
				shade = 1.25
			img.set_pixel(x, y, Color(shade, shade, shade, 1.0))
	return ImageTexture.create_from_image(img)

func _point_in_poly(p: Vector2, pts: Array[Vector2]) -> bool:
	var inside := false
	var j := pts.size() - 1
	for i in pts.size():
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[j]
		if ((a.y > p.y) != (b.y > p.y)) and (p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x):
			inside = not inside
		j = i
	return inside


class TurnMark extends Control:
	func _draw() -> void:
		var c := size * 0.5
		var radius := minf(size.x, size.y) * 0.34
		var width := maxf(radius * 0.46, 8.0)
		var shadow := Color(0.29, 0.16, 0.1, 0.22)
		var body := Color("3EBEFF")
		var dark := Color("1E8FCB")
		var light := Color("D7F4FF")
		var start := 0.85
		var end := 5.35
		draw_arc(c + Vector2(0, 4), radius, start, end, 36, shadow, width + 2.0, true)
		draw_arc(c + Vector2(0, 1.5), radius, start, end, 36, dark, width, true)
		draw_arc(c, radius, start, end, 36, body, width, true)
		draw_arc(c + Vector2(-1, -1.5), radius, start + 0.3, end - 0.8, 24, light, width * 0.34, true)
		var tip := c + Vector2.from_angle(end) * radius
		var forward := Vector2.from_angle(end + PI * 0.5)
		var side := Vector2.from_angle(end)
		var nose := tip + forward * width * 0.95
		var wing := width * 0.85
		var coral := Color("FF6A45")
		var coral_dark := Color("D24428")
		draw_line(tip - forward * wing + side * wing, nose + Vector2(0, 2), shadow, width * 0.62, true)
		draw_line(tip - forward * wing - side * wing, nose + Vector2(0, 2), shadow, width * 0.62, true)
		draw_line(tip - forward * wing + side * wing, nose, coral_dark, width * 0.55, true)
		draw_line(tip - forward * wing - side * wing, nose, coral_dark, width * 0.55, true)
		draw_line(tip - forward * wing * 0.85 + side * wing * 0.8, nose - forward * 1.5, coral, width * 0.5, true)
		draw_line(tip - forward * wing * 0.85 - side * wing * 0.8, nose - forward * 1.5, coral, width * 0.5, true)
