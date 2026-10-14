extends Node2D
class_name HammerAnimator

const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")

signal targeting_cancelled
signal smash_completed

var puzzle_controller = null
var audio_service: Node = null
var gameplay_screen = null

var is_targeting: bool = false
var is_striking: bool = false
var hover_target: Node2D = null

var hammer_sprite: Sprite2D = null
var shockwave_drawer: Node2D = null

var time_passed: float = 0.0
var pointer_pos: Vector2 = Vector2.ZERO

class ShockwaveNode extends Node2D:
	var center: Vector2 = Vector2.ZERO
	var radius: float = 0.0
	var max_radius: float = 240.0
	var alpha: float = 1.0
	var ring_color: Color = Color(1.0, 0.88, 0.45)

	func _draw() -> void:
		if alpha <= 0.001 or radius <= 0.0:
			return
		var c := ring_color
		c.a = alpha * 0.75
		draw_arc(center, radius, 0, TAU, 48, c, 6.0 * alpha + 1.0, true)
		var c_inner := Color(1.0, 1.0, 1.0, alpha * 0.9)
		draw_arc(center, maxf(1.0, radius - 4.0), 0, TAU, 36, c_inner, 3.0 * alpha, true)

func _ready() -> void:
	z_index = 150
	hammer_sprite = Sprite2D.new()
	hammer_sprite.texture = load("res://art/tools/hammer_tool.png")
	# Texture is 256x256, scale to ~96x96 px
	var target_size := 96.0
	var tex_w: float = hammer_sprite.texture.get_width() if hammer_sprite.texture else 256.0
	var s_val: float = target_size / tex_w
	hammer_sprite.scale = Vector2(s_val, s_val)
	# Center pivot near handle top for natural swing rotation
	hammer_sprite.offset = Vector2(-15.0, -25.0)
	hammer_sprite.visible = false
	add_child(hammer_sprite)

	shockwave_drawer = ShockwaveNode.new()
	add_child(shockwave_drawer)

func setup(gp_screen, pc, audio: Node = null) -> void:
	gameplay_screen = gp_screen
	puzzle_controller = pc
	audio_service = audio

func start_targeting() -> void:
	is_targeting = true
	is_striking = false
	time_passed = 0.0
	hover_target = null
	pointer_pos = get_global_mouse_position()

	hammer_sprite.position = pointer_pos + Vector2(40.0, -60.0)
	hammer_sprite.rotation_degrees = -20.0
	hammer_sprite.modulate.a = 0.0
	hammer_sprite.visible = true

	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(hammer_sprite, "scale", Vector2(96.0 / 256.0, 96.0 / 256.0) * 1.15, 0.18)
	tw.tween_property(hammer_sprite, "scale", Vector2(96.0 / 256.0, 96.0 / 256.0), 0.12)

func cancel_targeting() -> void:
	if not is_targeting or is_striking:
		return
	is_targeting = false
	_clear_hover()
	if is_instance_valid(hammer_sprite):
		var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(hammer_sprite, "modulate:a", 0.0, 0.15)
		tw.tween_callback(func(): hammer_sprite.visible = false)
	targeting_cancelled.emit()

func _process(delta: float) -> void:
	if not is_targeting or is_striking:
		return
	time_passed += delta
	var target_pos := get_global_mouse_position()
	pointer_pos = pointer_pos.lerp(target_pos, delta * 20.0)

	# Gentle floating hover bobbing
	var bob := sin(time_passed * 6.5) * 8.0
	var float_rot := -20.0 + sin(time_passed * 5.0) * 4.0
	hammer_sprite.position = pointer_pos + Vector2(35.0, -55.0 + bob)
	hammer_sprite.rotation_degrees = float_rot

	# Check hover over piece
	_update_hover(target_pos)

func _update_hover(pos: Vector2) -> void:
	if puzzle_controller == null or puzzle_controller.active_pieces.is_empty():
		_clear_hover()
		return
	var hit = _find_hit_piece(pos)
	if hit != hover_target:
		_clear_hover()
		hover_target = hit
		if is_instance_valid(hover_target) and hover_target.has_method("set_hold_rim"):
			hover_target.set_hold_rim(true)

func _clear_hover() -> void:
	if is_instance_valid(hover_target) and hover_target.has_method("set_hold_rim"):
		hover_target.set_hold_rim(false)
	hover_target = null

func _input(event: InputEvent) -> void:
	if not is_targeting or is_striking:
		return

	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
	   (event is InputEventScreenTouch and event.pressed):
		var click_pos: Vector2 = event.position if event is InputEventScreenTouch else event.global_position
		
		# Let taps on top HUD corner buttons (pause/settings or back) or bottom HUD (cards) pass through to UI buttons
		var vp_rect := get_viewport_rect()
		if click_pos.y > vp_rect.size.y - 130.0:
			return
		if click_pos.y < 110.0 and (click_pos.x > vp_rect.size.x - 110.0 or click_pos.x < 110.0):
			return

		var hit = _find_hit_piece(click_pos)
		if hit != null:
			get_viewport().set_input_as_handled()
			execute_smash(hit)
		else:
			# Clicked empty space in puzzle area: absorb to prevent drag,
			# but DO NOT cancel targeting! Keep hammer floating for the player.
			get_viewport().set_input_as_handled()

func handle_input(event: InputEvent) -> bool:
	if not is_targeting or is_striking:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit = _find_hit_piece(event.global_position)
		if hit != null:
			execute_smash(hit)
			return true
		else:
			return true
	elif event is InputEventScreenTouch and event.pressed:
		var hit = _find_hit_piece(event.position)
		if hit != null:
			execute_smash(hit)
			return true
		else:
			return true
	return false

func _find_hit_piece(global_pt: Vector2) -> Node2D:
	if puzzle_controller == null or puzzle_controller.active_pieces.is_empty():
		return null

	# Primary: use exact geometry distance calculation from drag_controller if available
	if puzzle_controller.drag_controller and puzzle_controller.drag_controller.has_method("resolve_hit"):
		var hit = puzzle_controller.drag_controller.resolve_hit(global_pt, puzzle_controller.active_pieces)
		if hit != null and is_instance_valid(hit):
			return hit

	# Fallback: find closest active non-released ring within generous touch radius
	var best_p: Node2D = null
	var min_dist: float = INF
	for p in puzzle_controller.active_pieces:
		if not is_instance_valid(p): continue
		if p.state == RingPiece2DScript.State.RELEASED or p.state == RingPiece2DScript.State.RELEASING: continue
		var p_scale: float = p.global_scale.x if "global_scale" in p else 1.0
		var r: float = float(p.radius) if "radius" in p else 64.0
		var d: float = (global_pt - p.global_position).length()
		var reach: float = r * p_scale + 54.0
		if d <= reach and d < min_dist:
			min_dist = d
			best_p = p
	return best_p

func execute_smash(target_piece: Node2D) -> void:
	is_striking = true
	is_targeting = false
	_clear_hover()

	# Gather target + 1 to 2 closest or connected rings
	var victims: Array[Node2D] = [target_piece]
	var victim_candidates: Array[Node2D] = []

	# Check connected pieces first
	for link in puzzle_controller.active_links:
		if link.state == ConnectorRuntimeScript.State.ENGAGED:
			var p_from = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, puzzle_controller.active_pieces)
			var p_to = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, puzzle_controller.active_pieces)
			if p_from == target_piece and p_to and not (p_to in victims):
				victim_candidates.append(p_to)
			elif p_to == target_piece and p_from and not (p_from in victims):
				victim_candidates.append(p_from)

	# If candidates < 2, add closest by distance
	for p in puzzle_controller.active_pieces:
		if not is_instance_valid(p) or p in victims or p in victim_candidates:
			continue
		if p.state == RingPiece2DScript.State.RELEASED or p.state == RingPiece2DScript.State.RELEASING:
			continue
		var dist: float = (p.global_position - target_piece.global_position).length()
		if dist <= 220.0:
			victim_candidates.append(p)

	# Pick 1 or 2 victim neighbors
	victim_candidates.sort_custom(func(a, b):
		return (a.global_position - target_piece.global_position).length() < (b.global_position - target_piece.global_position).length()
	)
	var max_extra := mini(2, victim_candidates.size())
	for i in range(max_extra):
		victims.append(victim_candidates[i])

	var hit_center: Vector2 = target_piece.global_position
	var base_scale := Vector2(96.0 / 256.0, 96.0 / 256.0)

	if audio_service and audio_service.has_method("play_hammer_swing"):
		audio_service.play_hammer_swing()

	# Unity-Level Animation Sequence
	var tw := create_tween()

	# Phase 1: Windup & Pullback (0.16s)
	var windup_pos := hit_center + Vector2(30.0, -95.0)
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "position", windup_pos, 0.16)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", -65.0, 0.16)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 1.35, 0.16)

	# Phase 2: Power Slam (0.10s)
	tw.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(hammer_sprite, "position", hit_center + Vector2(8.0, -18.0), 0.10)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", 24.0, 0.10)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 1.18, 0.10)

	# Phase 3: Impact Blast, Shockwave & Shatter Callback
	tw.tween_callback(func():
		_trigger_impact_fx(hit_center, victims)
	)

	# Phase 4: Rebound & Fade (0.24s)
	tw.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "position", hit_center + Vector2(16.0, -42.0), 0.14)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", -12.0, 0.14)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 0.95, 0.14)
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(hammer_sprite, "modulate:a", 0.0, 0.14)
	tw.tween_callback(func():
		hammer_sprite.visible = false
		is_striking = false
		smash_completed.emit()
	)

func _trigger_impact_fx(hit_center: Vector2, victims: Array[Node2D]) -> void:
	if audio_service and audio_service.has_method("play_hammer_impact"):
		audio_service.play_hammer_impact()

	# 1. Screen Shake
	if gameplay_screen and gameplay_screen.has_method("shake_screen"):
		gameplay_screen.shake_screen(9.0, 0.24)
	elif puzzle_controller:
		var orig_pos = puzzle_controller.position
		var stw := create_tween()
		for i in 6:
			var off := Vector2(randf_range(-7.0, 7.0), randf_range(-7.0, 7.0))
			stw.tween_property(puzzle_controller, "position", orig_pos + off, 0.03)
		stw.tween_property(puzzle_controller, "position", orig_pos, 0.04)

	# 2. Shockwave Expansion
	if is_instance_valid(shockwave_drawer):
		var sw = shockwave_drawer as ShockwaveNode
		sw.center = to_local(hit_center)
		sw.radius = 10.0
		sw.alpha = 1.0
		var sw_tw := create_tween()
		sw_tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		sw_tw.tween_property(sw, "radius", 230.0, 0.32)
		sw_tw.parallel().tween_property(sw, "alpha", 0.0, 0.32)
		sw_tw.tween_callback(func():
			sw.radius = 0.0
			sw.queue_redraw()
		)
		var ticker := create_tween().set_loops(16)
		ticker.tween_callback(sw.queue_redraw).set_delay(0.02)

	# 3. Particle Star Burst
	_spawn_spark_burst(hit_center)

	# 4. Shatter & Drop Victims
	_shatter_and_drop_rings(victims)

func _spawn_spark_burst(pos: Vector2) -> void:
	var burst := CPUParticles2D.new()
	burst.global_position = pos
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.lifetime = 0.65
	burst.amount = 24
	burst.spread = 180.0
	burst.gravity = Vector2(0, 520.0)
	burst.initial_velocity_min = 180.0
	burst.initial_velocity_max = 420.0
	burst.angular_velocity_min = -360.0
	burst.angular_velocity_max = 360.0
	burst.scale_amount_min = 4.0
	burst.scale_amount_max = 8.5
	burst.color = Color(1.0, 0.88, 0.28)
	burst.z_index = 160
	add_child(burst)
	burst.emitting = true
	get_tree().create_timer(0.9).timeout.connect(burst.queue_free)

func _shatter_and_drop_rings(victims: Array[Node2D]) -> void:
	# 1. Immediately break links connected to all victim pieces
	for link in puzzle_controller.active_links:
		for v in victims:
			if link.def.from_piece_id == v.piece_id or link.def.to_piece_id == v.piece_id:
				link.state = ConnectorRuntimeScript.State.DETACHED
				link.current_stem_dist = 0.0

	puzzle_controller._connectors_dirty = true
	if is_instance_valid(puzzle_controller.stems_layer): puzzle_controller.stems_layer.queue_redraw()
	if is_instance_valid(puzzle_controller.cuffs_layer): puzzle_controller.cuffs_layer.queue_redraw()

	# 2. Flash, shatter and drop each victim ring
	for v in victims:
		if not is_instance_valid(v): continue
		v.state = RingPiece2DScript.State.RELEASING

		# Kill any in-flight state tweens
		if v.get("_state_tween") != null and is_instance_valid(v._state_tween):
			v._state_tween.kill()

		# Dramatic white flash
		v.modulate = Color(3.5, 3.5, 3.5, 1.0)
		var flash_tw := create_tween()
		flash_tw.tween_property(v, "modulate", Color.WHITE, 0.10)

		# Spawn colored ceramic shard particles for this ring
		_spawn_ring_shards(v.global_position, v.ring_color)

		# Physical gravity drop & wild spin
		var drop_tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		var spin_dir := randf_range(-4.0, 4.0)
		drop_tw.tween_property(v, "position:y", v.position.y + 750.0, 0.48)
		drop_tw.parallel().tween_property(v, "position:x", v.position.x + randf_range(-40.0, 40.0), 0.48)
		drop_tw.parallel().tween_property(v, "rotation", v.rotation + spin_dir, 0.48)
		drop_tw.parallel().tween_property(v, "scale", v.scale * 0.72, 0.48)
		drop_tw.parallel().tween_property(v, "modulate:a", 0.0, 0.42)

		# Free piece after drop
		drop_tw.tween_callback(func(p = v):
			if is_instance_valid(p):
				p.state = RingPiece2DScript.State.RELEASED
				PuzzleRulesScript.on_piece_released(p, puzzle_controller.active_links)
				puzzle_controller.active_pieces.erase(p)
				p.queue_free()
				_check_after_smash()
		)

func _spawn_ring_shards(pos: Vector2, ring_col: Color) -> void:
	var shards := CPUParticles2D.new()
	shards.global_position = pos
	shards.one_shot = true
	shards.explosiveness = 0.92
	shards.lifetime = 0.55
	shards.amount = 18
	shards.spread = 180.0
	shards.gravity = Vector2(0, 680.0)
	shards.initial_velocity_min = 140.0
	shards.initial_velocity_max = 360.0
	shards.angular_velocity_min = -500.0
	shards.angular_velocity_max = 500.0
	shards.scale_amount_min = 5.0
	shards.scale_amount_max = 12.0
	shards.color = ring_col.lightened(0.15)
	shards.z_index = 145
	add_child(shards)
	shards.emitting = true
	get_tree().create_timer(0.8).timeout.connect(shards.queue_free)

func _check_after_smash() -> void:
	if puzzle_controller == null: return
	puzzle_controller._connectors_dirty = true
	if is_instance_valid(puzzle_controller.stems_layer): puzzle_controller.stems_layer.queue_redraw()
	if is_instance_valid(puzzle_controller.cuffs_layer): puzzle_controller.cuffs_layer.queue_redraw()

	# Resolve any subsequent cascading releases
	var cascaded = PuzzleRulesScript.resolve_releases(puzzle_controller.active_pieces, puzzle_controller.active_links)
	if not cascaded.is_empty():
		for p in cascaded:
			if is_instance_valid(p):
				p.state = RingPiece2DScript.State.RELEASING
				var tw := create_tween()
				tw.tween_property(p, "position:y", p.position.y + 600.0, 0.45)
				tw.parallel().tween_property(p, "modulate:a", 0.0, 0.40)
				tw.tween_callback(func(dead_p = p):
					if is_instance_valid(dead_p):
						dead_p.state = RingPiece2DScript.State.RELEASED
						PuzzleRulesScript.on_piece_released(dead_p, puzzle_controller.active_links)
						puzzle_controller.active_pieces.erase(dead_p)
						dead_p.queue_free()
				)

	puzzle_controller.piece_count_updated.emit(puzzle_controller.active_pieces.size())

	# Check win condition
	if PuzzleRulesScript.is_puzzle_won(puzzle_controller.active_pieces, puzzle_controller.active_links):
		puzzle_controller._on_all_pieces_released()
