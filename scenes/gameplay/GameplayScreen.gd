extends Control
class_name GameplayScreen

const LevelDatabaseScript = preload("res://data/level_database.gd")
const MascotCompanionScript = preload("res://gameplay/mascot_companion.gd")
const DroppedRing2DScript = preload("res://gameplay/dropped_ring_2d.gd")

signal back_to_levels_requested
signal back_to_home_requested

@onready var puzzle_controller = $PuzzleArea/PuzzleController
@onready var pause_btn: Button = $SafeArea/TopHUD/PauseBtn
@onready var level_num_lbl: Label = $SafeArea/TopHUD/LevelBox/LevelNum
@onready var score_lbl: Label = $SafeArea/TopHUD/ScorePill/ScoreLbl
@onready var rocket_btn: Button = $SafeArea/BottomHUD/RocketCard/RocketBtn
@onready var hammer_btn: Button = $SafeArea/BottomHUD/HammerCard/HammerBtn

@onready var pause_modal = $PauseModal
@onready var victory_modal = $VictoryModal

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
	
	puzzle_controller.setup(audio_service, haptic_service)
	pause_modal.setup(save_service)

func _ready() -> void:
	pause_modal.z_index = 100
	pause_modal.z_as_relative = false
	victory_modal.z_index = 100
	victory_modal.z_as_relative = false

	pause_btn.pressed.connect(_on_pause_pressed)
	if rocket_btn: rocket_btn.pressed.connect(_on_hint_pressed)
	# Hammer is locked, do not connect to hint
	if hammer_btn: hammer_btn.disabled = true
	
	mascot = MascotCompanionScript.new()
	mascot.position = Vector2(get_viewport_rect().size.x * 0.5, 200.0)
	mascot.z_index = 50
	$SafeArea/TopHUD.add_sibling(mascot)
	
	puzzle_controller.moves_updated.connect(_on_moves_updated)
	puzzle_controller.piece_count_updated.connect(_on_piece_count_updated)
	puzzle_controller.level_completed.connect(_on_level_completed)
	
	pause_modal.resume_pressed.connect(func(): puzzle_controller.is_active = true)
	pause_modal.restart_btn.pressed.connect(restart_level)
	pause_modal.levels_pressed.connect(func(): back_to_levels_requested.emit())
	pause_modal.home_pressed.connect(func(): back_to_home_requested.emit())
	
	victory_modal.next_pressed.connect(_on_next_level_pressed)
	victory_modal.replay_pressed.connect(restart_level)
	victory_modal.levels_pressed.connect(func(): back_to_levels_requested.emit())

func load_level_by_id(lvl_id: int) -> void:
	current_level_id = lvl_id
	var def = LevelDatabaseScript.get_level(lvl_id)
	
	level_num_lbl.text = str(lvl_id)
	current_score = 0
	target_score = 0
	total_pieces_in_level = 0
	score_lbl.text = "0"
	
	pause_modal.hide()
	victory_modal.hide()
	
	puzzle_controller.load_level(def)
	
	# Give it a frame to ensure all nodes are placed, then frame the puzzle
	get_tree().process_frame.connect(_frame_puzzle, CONNECT_ONE_SHOT)
	
	# Auto-trigger tutorial on Level 1 (wait for Toy Drop to finish)
	if lvl_id == 1:
		get_tree().create_timer(2.0).timeout.connect(func():
			puzzle_controller.request_hint()
		)

func _frame_puzzle() -> void:
	if not is_instance_valid(puzzle_controller): return
	
	var bounds = puzzle_controller.get_puzzle_bounds()
	if bounds.size.x <= 0 or bounds.size.y <= 0: return
	
	# Calculate safe area dynamically based on UI nodes
	var viewport_size = get_viewport_rect().size
	
	var top_hud = $SafeArea/TopHUD
	var bottom_hud = $SafeArea/BottomHUD
	
	var safe_margin_top = top_hud.size.y + 40.0 if is_instance_valid(top_hud) and top_hud.size.y > 0 else 200.0
	
	# Fallback to 160 if bottom_hud size is 0 (layout not ready)
	var bh_h = bottom_hud.size.y if is_instance_valid(bottom_hud) else 0.0
	var safe_margin_bottom = (bh_h + 40.0) if bh_h > 0 else 160.0
	
	var safe_margin_x = 40.0
	
	var safe_width = viewport_size.x - (safe_margin_x * 2.0)
	var safe_height = viewport_size.y - safe_margin_top - safe_margin_bottom
	var safe_rect = Rect2(safe_margin_x, safe_margin_top, safe_width, safe_height)
	
	# Calculate required scale to fit within safe_rect
	var scale_x = safe_rect.size.x / bounds.size.x
	var scale_y = safe_rect.size.y / bounds.size.y
	var target_scale = minf(scale_x, scale_y)
	
	# Optional: limit max scale so simple puzzles aren't gigantic
	target_scale = minf(target_scale, 1.5)
	
	# Center the puzzle in the safe area
	# We want puzzle_controller.position so that bounds.get_center() * target_scale is at safe_rect.get_center()
	var bounds_center = bounds.get_center()
	var target_pos = safe_rect.get_center() - (bounds_center * target_scale)
	
	# Animate the camera framing smoothly
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(puzzle_controller, "scale", Vector2(target_scale, target_scale), 0.6)
	tween.tween_property(puzzle_controller, "position", target_pos, 0.6)

var total_pieces_in_level: int = 0

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
	score_lbl.text = "Moves: " + str(moves) + " / " + str(par_moves)
	
	var pill = get_node_or_null("SafeArea/TopHUD/ScorePill")
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
		
	# Trigger Mascot Portal Completion Sequence!
	var viewport_center = get_viewport_rect().size * 0.5
	
	# Fire Confetti Burst!
	_fire_confetti(viewport_center)
	
	if is_instance_valid(mascot):
		mascot.set_state(MascotCompanionScript.State.CELEBRATING)
		
		# Animate mascot jumping to center screen
		var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
		tween.tween_property(mascot, "position", viewport_center, 0.6)
			
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(victory_modal):
		victory_modal.show_victory(
			moves,
			par_moves,
			result.get("is_perfect", false),
			result.get("best_moves", moves),
			current_level_id + 1
		)

func _on_next_level_pressed() -> void:
	var next_id := current_level_id + 1
	if next_id > LevelDatabaseScript.get_total_levels():
		back_to_levels_requested.emit()
	else:
		load_level_by_id(next_id)

func restart_level() -> void:
	if audio_service: audio_service.play_ui_tap()
	load_level_by_id(current_level_id)

func _on_back_pressed() -> void:
	if audio_service: audio_service.play_ui_tap()
	back_to_levels_requested.emit()

func _on_pause_pressed() -> void:
	if audio_service: audio_service.play_ui_tap()
	puzzle_controller.is_active = false
	pause_modal.show_modal()

func _on_hint_pressed() -> void:
	puzzle_controller.request_hint()

func _fire_confetti(pos: Vector2) -> void:
	# Create two bursts for depth
	for i in range(2):
		var confetti = CPUParticles2D.new()
		confetti.emitting = false
		confetti.one_shot = true
		confetti.explosiveness = 0.95
		confetti.lifetime = 2.5
		confetti.direction = Vector2(0, -1)
		confetti.spread = 60.0
		confetti.gravity = Vector2(0, 400.0)
		confetti.initial_velocity_min = 400.0 + (i * 200)
		confetti.initial_velocity_max = 800.0 + (i * 200)
		confetti.scale_amount_min = 12.0
		confetti.scale_amount_max = 18.0
		# Simulate 3D flipping by aligning Y to velocity
		confetti.particle_flag_align_y = true
		
		# Colorful pastel palette
		var colors = PackedColorArray([
			Color(0.95, 0.45, 0.45), # Red
			Color(0.45, 0.95, 0.45), # Green
			Color(0.45, 0.65, 0.95), # Blue
			Color(0.95, 0.95, 0.35), # Yellow
			Color(0.85, 0.45, 0.95), # Purple
		])
		
		# Unfortunately CPUParticles doesn't easily support multiple random colors without a gradient,
		# so we create one emitter per color to make it look truly premium!
		for c in colors:
			var c_burst = confetti.duplicate()
			c_burst.color = c
			c_burst.amount = 12
			c_burst.position = pos
			c_burst.z_index = 200
			add_child(c_burst)
			c_burst.emitting = true
			
			var tween = create_tween()
			tween.tween_callback(c_burst.queue_free).set_delay(3.0)
			
		confetti.free()
