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

	puzzle_controller.setup(audio_service, haptic_service, save_service)
	pause_modal.setup(save_service)
	# Edit overlay is fully inert until toggle(true) is called. Wire the puzzle
	# controller reference so the overlay can read/write piece data on drag-end.
	edit_overlay.set_puzzle(puzzle_controller)
	# Inject the active level id so the overlay's _save_all_pieces() can write
	# to res://data/user_levels/<n>.json without walking the parent chain.
	edit_overlay.set_level_id(current_level_id)

func _ready() -> void:
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
	# Phase 1 of the LOCKED-CANVAS architecture: the puzzle's authored
	# coordinate space is canonical. The runtime applies ONE uniform
	# transform (scale + offset) on the PuzzleController. We do NOT
	# auto-fit or re-center per level.
	#
	# The transform is read from the LevelDocument if present; otherwise
	# it falls back to identity (scale=1, offset=(0,0)) which places the
	# puzzle at its authored coordinates in the top-left of the viewport.
	#
	# The user (or the editor) explicitly sets this transform once per
	# level via the ReferenceViewer's 'Fit Puzzle' / 'Calibrate' actions.
	if not is_instance_valid(puzzle_controller): return
	if editor_document == null:
		# No level loaded yet; leave the puzzle at its authored coordinates.
		return
	var gs: float = float(editor_document.frame_scale)
	var gx: float = float(editor_document.frame_offset_x)
	var gy: float = float(editor_document.frame_offset_y)
	# Animate to the target transform over 0.4s. Identity is the default
	# (scale=1, offset=0) so the puzzle sits at its authored location.
	var target_scale: Vector2 = Vector2(gs, gs)
	var target_pos: Vector2 = Vector2(gx, gy)
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(puzzle_controller, "scale", target_scale, 0.4)
	tween.tween_property(puzzle_controller, "position", target_pos, 0.4)

var total_pieces_in_level: int = 0

func _apply_chrome() -> void:
	UiTheme.mount_backdrop(self, true)
	UiTheme.paint_button(back_btn, "secondary", UiTheme.FONT_CAPTION)
	UiTheme.paint_button(pause_btn, "secondary", UiTheme.FONT_CAPTION)
	UiTheme.paint_label(level_prefix, UiTheme.FONT_CAPTION, true)
	UiTheme.paint_label(level_num_lbl, UiTheme.FONT_HEAD)
	var pill := get_node_or_null("SafeArea/TopHUD/CenterHUD/ScorePill") as PanelContainer
	if pill:
		pill.add_theme_stylebox_override("panel", UiTheme.pill())
	UiTheme.paint_label(score_lbl, UiTheme.FONT_CAPTION)
	if rocket_btn:
		_mount_tool(rocket_btn, null, "Hint", false)
		# Hint count badge — created in code so no .tscn edit is required.
		if not rocket_btn.has_node("HintBadge"):
			var b := Label.new()
			b.name = "HintBadge"
			b.text = "3"
			UiTheme.paint_label(b, UiTheme.FONT_CAPTION)
			b.position = Vector2(rocket_btn.size.x - 14.0, -6.0)
			b.pivot_offset = Vector2(10, 10)
			b.modulate = Color(1, 1, 1, 1)
			rocket_btn.add_child(b)
		_refresh_hint_badge()
	if hammer_btn:
		_mount_tool(hammer_btn, preload("res://art/tools/hammer_tool.png"), "Hammer", true)
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
	score_lbl.text = "%d / %d" % [moves, par_moves]

	var pill = get_node_or_null("SafeArea/TopHUD/CenterHUD/ScorePill")
	if pill and moves > 0:
		var ptween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		pill.pivot_offset = pill.size / 2.0
		ptween.tween_property(pill, "scale", Vector2(1.15, 1.15), 0.1)
		ptween.tween_property(pill, "scale", Vector2.ONE, 0.4)

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
	var badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/RocketBtn/HintBadge")
	if badge and badge is Label:
		var remaining: int = save_service.get_hints_remaining() if save_service else 3
		badge.text = str(remaining)
		badge.visible = remaining > 0

func _flash_hint_badge() -> void:
	var badge = get_node_or_null("SafeArea/BottomHUD/RocketCard/RocketBtn/HintBadge")
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
