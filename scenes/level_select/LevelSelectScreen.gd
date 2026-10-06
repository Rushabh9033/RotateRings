extends Control
class_name LevelSelectScreen

const LevelDatabaseScript = preload("res://data/level_database.gd")
const UiTheme = preload("res://app/ui_theme.gd")

signal level_selected(level_id: int)
signal back_pressed

@onready var back_btn: Button = $SafeArea/VBox/Header/TopRow/BackBtn
@onready var chapter_title: Label = $SafeArea/VBox/Header/ChapterTitle
@onready var progress_lbl: Label = $SafeArea/VBox/Header/ProgressLbl
@onready var map_container: Control = $SafeArea/VBox/Scroll/MapContainer

var save_service: Node = null
var audio_service: Node = null

func setup(save_svc: Node, audio_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	build_grid()

func _ready() -> void:
	UiTheme.mount_backdrop(self)
	UiTheme.paint_button(back_btn, "secondary", UiTheme.FONT_CAPTION)
	UiTheme.paint_label(chapter_title, UiTheme.FONT_TITLE)
	UiTheme.paint_label(progress_lbl, UiTheme.FONT_CAPTION, true)
	_paint_key("SafeArea/VBox/Header/Legend/OpenKey", UiTheme.ACCENT)
	_paint_key("SafeArea/VBox/Header/Legend/ClearedKey", UiTheme.CLEARED_DARK)
	_paint_key("SafeArea/VBox/Header/Legend/PerfectKey", UiTheme.PERFECT_DARK)
	_paint_key("SafeArea/VBox/Header/Legend/LockedKey", UiTheme.TEXT_MUTED)
	UiTheme.apply_font(self)
	var scroll := get_node_or_null("SafeArea/VBox/Scroll") as ScrollContainer
	if scroll:
		scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	back_btn.pressed.connect(func():
		if audio_service and audio_service.has_method("play_ui_tap"):
			audio_service.play_ui_tap()
		back_pressed.emit()
	)

func build_grid() -> void:
	if not is_instance_valid(map_container): return
	
	for child in map_container.get_children():
		map_container.remove_child(child)
		child.free()
		
	var journey_map = map_container
	
	var playable_ids: Array[int] = LevelDatabaseScript.get_playable_level_ids()
	var total_levels: int = playable_ids.size()
	var cleared_count := 0
	
	# Path sits inside the 24px safe frame on a 720-wide portrait.
	var vertical_spacing := 120.0
	var horizontal_amp := 100.0
	var x_base := 291.0
	var map_height = total_levels * vertical_spacing + 200.0
	journey_map.custom_minimum_size = Vector2(0, map_height)
	journey_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var frontier := 1
	for lvl_probe in playable_ids:
		var probe_unlocked := lvl_probe == 1
		if save_service and save_service.has_method("is_level_unlocked"):
			probe_unlocked = save_service.is_level_unlocked(lvl_probe)
		if probe_unlocked:
			frontier = lvl_probe

	for lvl in playable_ids:
		if not LevelDatabaseScript.is_level_playable(lvl):
			push_warning("Level select skipped non-playable id %d." % lvl)
			continue
		var is_unlocked := (lvl == 1)
		if save_service and save_service.has_method("is_level_unlocked"):
			is_unlocked = save_service.is_level_unlocked(lvl)
			
		var is_cleared := false
		if save_service and save_service.has_method("is_level_cleared"):
			is_cleared = save_service.is_level_cleared(lvl)
			
		var is_perfect := false
		if save_service and save_service.has_method("is_level_perfect"):
			is_perfect = save_service.is_level_perfect(lvl)
		
		if is_cleared:
			cleared_count += 1
			
		var card = preload("res://scenes/level_select/level_node_ui.gd").new()
		card.custom_minimum_size = Vector2(90, 90)
		card.add_theme_font_size_override("font_size", 22)
		
		card.is_unlocked = is_unlocked
		card.is_cleared = is_cleared
		card.is_perfect = is_perfect
		card.is_current = is_unlocked and not is_cleared and lvl == frontier
		
		if not is_unlocked:
			card.disabled = true
			card.text = ""
		else:
			card.text = str(lvl)
			
		# S-curve calculation for custom positioning (bottom to top)
		# map_height - (lvl * vertical_spacing) makes level 1 at the bottom
		var y_pos = map_height - (lvl * vertical_spacing) - 100.0
		var x_pos = x_base + sin(lvl * 1.2) * horizontal_amp
		card.position = Vector2(x_pos, y_pos)
			
		var target_lvl := lvl
		card.pressed.connect(func():
			if audio_service and audio_service.has_method("play_ui_tap"):
				audio_service.play_ui_tap()
			level_selected.emit(target_lvl)
		)
		
		# Better UI Motion: Pop-in animation
		card.pivot_offset = card.custom_minimum_size * 0.5
		card.scale = Vector2.ZERO
		var delay = minf(float(lvl) * 0.012, 0.32)
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "scale", Vector2.ONE, 0.4).set_delay(delay)
		
		journey_map.add_child(card)
		
	# Draw lines connecting the nodes? We can add a custom CanvasItem behind them
	var path_drawer = Node2D.new()
	journey_map.add_child(path_drawer)
	journey_map.move_child(path_drawer, 0)
	path_drawer.set_script(preload("res://scenes/level_select/journey_path_drawer.gd"))
	path_drawer.setup_path(total_levels, vertical_spacing, horizontal_amp, map_height, x_base)
		
	progress_lbl.text = "%d / %d Cleared" % [cleared_count, total_levels]
	
	# Scroll to the highest unlocked level
	var highest_unlocked: int = playable_ids[0]
	for index in range(playable_ids.size() - 1, -1, -1):
		var candidate: int = playable_ids[index]
		if save_service and save_service.has_method("is_level_unlocked") and save_service.is_level_unlocked(candidate):
			highest_unlocked = candidate
			break
			
	var target_y = map_height - (highest_unlocked * vertical_spacing) - 100.0
	var scroll_node = $SafeArea/VBox/Scroll
	# Center the target_y in the scroll container
	call_deferred("_scroll_to", scroll_node, target_y - (scroll_node.size.y / 2.0))

func _scroll_to(scroll_node: ScrollContainer, val: float) -> void:
	scroll_node.scroll_vertical = int(max(0, val))

func _paint_key(path: String, color: Color) -> void:
	var label := get_node_or_null(path) as Label
	if label == null:
		return
	label.add_theme_font_size_override("font_size", UiTheme.FONT_CAPTION)
	label.add_theme_color_override("font_color", color)
