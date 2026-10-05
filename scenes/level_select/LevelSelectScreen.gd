extends Control
class_name LevelSelectScreen

const LevelDatabaseScript = preload("res://data/level_database.gd")

signal level_selected(level_id: int)
signal back_pressed

@onready var back_btn: Button = $SafeArea/VBox/Header/TopRow/BackBtn
@onready var chapter_title: Label = $SafeArea/VBox/Header/ChapterTitle
@onready var progress_lbl: Label = $SafeArea/VBox/Header/ProgressLbl
@onready var grid_container: GridContainer = $SafeArea/VBox/Scroll/Grid

var save_service: Node = null
var audio_service: Node = null

func setup(save_svc: Node, audio_svc: Node) -> void:
	save_service = save_svc
	audio_service = audio_svc
	build_grid()

func _ready() -> void:
	back_btn.pressed.connect(func():
		if audio_service and audio_service.has_method("play_ui_tap"):
			audio_service.play_ui_tap()
		back_pressed.emit()
	)

func build_grid() -> void:
	if not is_instance_valid(grid_container): return
	
	# Replace GridContainer with a generic Control for custom mapping
	var scroll = $SafeArea/VBox/Scroll
	var journey_map = Control.new()
	scroll.add_child(journey_map)
	grid_container.queue_free()
	
	var total_levels: int = LevelDatabaseScript.get_total_levels()
	var cleared_count := 0
	
	# Path settings
	var vertical_spacing := 120.0
	var horizontal_amp := 140.0
	var map_height = total_levels * vertical_spacing + 200.0
	journey_map.custom_minimum_size = Vector2(0, map_height)
	journey_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	for lvl in range(1, total_levels + 1):
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
		card.add_theme_font_size_override("font_size", 28)
		card.add_theme_color_override("font_color", Color.WHITE)
		card.add_theme_color_override("font_pressed_color", Color(0.8, 0.8, 0.8))
		card.add_theme_color_override("font_disabled_color", Color(0.6, 0.6, 0.6))
		
		card.is_unlocked = is_unlocked
		card.is_cleared = is_cleared
		card.is_perfect = is_perfect
		
		if not is_unlocked:
			card.disabled = true
			card.text = ""
		else:
			card.text = str(lvl)
			
		# S-curve calculation for custom positioning (bottom to top)
		# map_height - (lvl * vertical_spacing) makes level 1 at the bottom
		var y_pos = map_height - (lvl * vertical_spacing) - 100.0
		var x_pos = 150.0 + sin(lvl * 1.2) * horizontal_amp
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
		var delay = float(lvl) * 0.05
		var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(card, "scale", Vector2.ONE, 0.4).set_delay(delay)
		
		journey_map.add_child(card)
		
	# Draw lines connecting the nodes? We can add a custom CanvasItem behind them
	var path_drawer = Node2D.new()
	journey_map.add_child(path_drawer)
	journey_map.move_child(path_drawer, 0)
	path_drawer.set_script(preload("res://scenes/level_select/journey_path_drawer.gd"))
	path_drawer.setup_path(total_levels, vertical_spacing, horizontal_amp, map_height)
		
	progress_lbl.text = "%d / %d Cleared" % [cleared_count, total_levels]
