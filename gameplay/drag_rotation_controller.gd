extends Node
class_name DragRotationController

signal move_counted(piece: Node2D)
signal piece_selected(piece: Node2D)
signal piece_drag_ended(piece: Node2D)
signal collision_occurred(contact_pos: Vector2, color: Color)

const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")

var selected_piece: Node2D = null
var is_dragging: bool = false

var last_pointer_angle_deg: float = 0.0
var accumulated_drag_deg: float = 0.0
var last_tick_angle_deg: float = 0.0

var audio_service: Node = null
var haptic_service: Node = null

var current_active_pieces: Array = []
var current_active_links: Array = []
var last_collision_feedback_time: float = 0.0

func setup(audio: Node, haptic: Node) -> void:
	audio_service = audio
	haptic_service = haptic

func handle_input(event: InputEvent, active_pieces: Array, active_links: Array = []) -> bool:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var hit_piece = resolve_hit(event.global_position, active_pieces)
				if hit_piece:
					if not PuzzleRulesScript.is_piece_rotatable(hit_piece, active_pieces, active_links):
						jiggle_locked_piece(hit_piece)
						return true
					start_drag(hit_piece, event.global_position, active_pieces, active_links)
					return true
			else:
				if is_dragging:
					end_drag()
					return true

	elif event is InputEventScreenTouch:
		if event.pressed:
			var hit_piece = resolve_hit(event.position, active_pieces)
			if hit_piece:
				if not PuzzleRulesScript.is_piece_rotatable(hit_piece, active_pieces, active_links):
					jiggle_locked_piece(hit_piece)
					return true
				start_drag(hit_piece, event.position, active_pieces, active_links)
				return true
		else:
			if is_dragging:
				end_drag()
				return true

	elif (event is InputEventMouseMotion or event is InputEventScreenDrag) and is_dragging:
		var pos: Vector2 = event.position if event is InputEventScreenDrag else event.global_position
		update_drag(pos)
		return true

	return false

func jiggle_locked_piece(piece: Node2D) -> void:
	if not is_instance_valid(piece): return

	# Prevent multiple overlapping jiggle tweens on the same piece
	if piece.has_meta("is_jiggling") and piece.get_meta("is_jiggling"):
		return
	piece.set_meta("is_jiggling", true)

	if audio_service and audio_service.has_method("play_lock_rattle"):
		audio_service.play_lock_rattle()
	if haptic_service and haptic_service.has_method("trigger_selection"):
		haptic_service.trigger_selection()

	# Emit collision particles at the blocking cuff contact point
	for link in current_active_links:
		if link.to_piece_id == piece.piece_id and not link.is_detached:
			var parent_p = PuzzleRulesScript.get_piece_by_id(link.from_piece_id, current_active_pieces)
			if is_instance_valid(parent_p):
				var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
				var dir := Vector2.from_angle(world_angle_rad)
				var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - piece.radius)
				var c: Color = piece.ring_color if "ring_color" in piece else Color.WHITE
				# Convert the local puzzle container pos_cuff to global position for particle spawning
				var global_pos_cuff: Vector2 = piece.get_parent().to_global(pos_cuff)
				collision_occurred.emit(global_pos_cuff, c)
				break

	var orig_rot := piece.rotation_degrees
	var apply_rot = func(rot: float):
		if is_instance_valid(piece):
			piece.rotation_degrees = rot
			piece.current_angle_deg = fposmod(rot, 360.0)
			piece.rotation_changed.emit(piece, piece.current_angle_deg)
			piece.queue_redraw()

	var tween := piece.create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(apply_rot, orig_rot, orig_rot + 4.0, 0.04)
	tween.tween_method(apply_rot, orig_rot + 4.0, orig_rot - 4.0, 0.08)
	tween.tween_method(apply_rot, orig_rot - 4.0, orig_rot + 2.0, 0.05)
	tween.tween_method(apply_rot, orig_rot + 2.0, orig_rot, 0.04)
	tween.finished.connect(func():
		if is_instance_valid(piece):
			apply_rot.call(orig_rot)
			piece.set_meta("is_jiggling", false)
	)

func resolve_hit(global_pt: Vector2, pieces: Array):
	var valid_pieces = pieces.filter(func(p):
		return is_instance_valid(p) and p.is_interactive and \
			p.state != RingPiece2DScript.State.RELEASED and \
			p.state != RingPiece2DScript.State.RELEASING
	)
	if valid_pieces.is_empty():
		return null

	var best_piece: Node2D = null
	var min_dist: float = INF

	for p in valid_pieces:
		var global_scale_factor: float = p.global_scale.x
		var global_radius: float = p.radius * global_scale_factor
		var global_thickness: float = (float(p.get("thickness")) if p.get("thickness") != null else 12.0) * global_scale_factor
		var dist_from_center: float = (global_pt - p.global_position).length()
		var dist_to_tube: float = absf(dist_from_center - global_radius)

		# Best match: closest tube within generous touch band (thickness + margin)
		var touch_margin: float = global_thickness + (52.0 * global_scale_factor)
		if dist_to_tube < min_dist and dist_to_tube <= touch_margin:
			min_dist = dist_to_tube
			best_piece = p

	# Fallback: if finger is inside a ring's hollow center
	if not best_piece:
		var min_center_dist := INF
		for p in valid_pieces:
			var global_scale_factor: float = p.global_scale.x
			var global_radius: float = p.radius * global_scale_factor
			var global_thickness: float = (float(p.get("thickness")) if p.get("thickness") != null else 12.0) * global_scale_factor
			var c_dist: float = (global_pt - p.global_position).length()
			if c_dist <= (global_radius + global_thickness) and c_dist < min_center_dist:
				min_center_dist = c_dist
				best_piece = p

	return best_piece

func start_drag(piece: Node2D, global_pt: Vector2, active_pieces: Array = [], active_links: Array = []) -> void:
	selected_piece = piece
	is_dragging = true
	current_active_pieces = active_pieces
	current_active_links = active_links
	piece.state = RingPiece2DScript.State.SELECTED

	var offset: Vector2 = global_pt - piece.global_position
	last_pointer_angle_deg = rad_to_deg(offset.angle())
	accumulated_drag_deg = 0.0
	last_tick_angle_deg = piece.rotation_degrees

	if audio_service and audio_service.has_method("play_piece_select"):
		audio_service.play_piece_select()
	if haptic_service and haptic_service.has_method("trigger_selection"):
		haptic_service.trigger_selection()

	piece_selected.emit(piece)
	piece.queue_redraw()

func update_drag(global_pt: Vector2) -> void:
	if not selected_piece or not is_instance_valid(selected_piece):
		is_dragging = false
		return

	var piece := selected_piece  # Capture local ref before any cancels

	if piece.state == RingPiece2DScript.State.RELEASED or piece.state == RingPiece2DScript.State.RELEASING:
		cancel_drag()
		return

	var offset: Vector2 = global_pt - piece.global_position
	if offset.length_squared() < 9.0:
		return

	var current_pointer_angle_deg := rad_to_deg(offset.angle())
	var step_delta_deg := wrapf(current_pointer_angle_deg - last_pointer_angle_deg, -180.0, 180.0)
	last_pointer_angle_deg = current_pointer_angle_deg

	# Check physical connector collision
	var clamp_res := PuzzleRulesScript.clamp_rotation_step(
		piece,
		step_delta_deg,
		current_active_pieces,
		current_active_links
	)
	var allowed_delta: float = float(clamp_res["allowed_delta"])
	var hit_stopper: bool = bool(clamp_res["hit_stopper"])

	if hit_stopper and absf(step_delta_deg) > 0.05:
		var pt: Vector2 = clamp_res.get("contact_point", Vector2.ZERO)
		var col: Color = clamp_res.get("contact_color", Color.WHITE)
		_trigger_collision_feedback(pt, col)

	piece.state = RingPiece2DScript.State.ROTATING
	piece.rotation_degrees += allowed_delta
	piece.current_angle_deg = fposmod(piece.rotation_degrees, 360.0)
	accumulated_drag_deg += absf(allowed_delta)

	# Rotation tick audio/haptic every ~15deg
	var tick_diff := absf(wrapf(piece.rotation_degrees - last_tick_angle_deg, -180.0, 180.0))
	if tick_diff >= 15.0:
		if audio_service and audio_service.has_method("play_rotation_tick"):
			audio_service.play_rotation_tick(1.0)
		if haptic_service and haptic_service.has_method("trigger_rotation_tick"):
			haptic_service.trigger_rotation_tick()
		last_tick_angle_deg = piece.rotation_degrees

	piece.rotation_changed.emit(piece, piece.current_angle_deg)

	# Safe redraw: only if still valid and not released
	if is_instance_valid(piece) and \
		piece.state != RingPiece2DScript.State.RELEASED and \
		piece.state != RingPiece2DScript.State.RELEASING:
		piece.queue_redraw()

func _trigger_collision_feedback(contact_pos: Vector2 = Vector2.ZERO, color: Color = Color.WHITE) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_collision_feedback_time < 0.12:
		return
	last_collision_feedback_time = now
	if audio_service and audio_service.has_method("play_connector_touch"):
		audio_service.play_connector_touch()
	elif audio_service and audio_service.has_method("play_lock_rattle"):
		audio_service.play_lock_rattle()
	if haptic_service and haptic_service.has_method("trigger_selection"):
		haptic_service.trigger_selection()
	if contact_pos != Vector2.ZERO:
		collision_occurred.emit(contact_pos, color)

func cancel_drag() -> void:
	is_dragging = false
	selected_piece = null

func end_drag() -> void:
	if not selected_piece or not is_instance_valid(selected_piece):
		is_dragging = false
		return

	is_dragging = false
	var piece := selected_piece
	selected_piece = null

	if accumulated_drag_deg >= 5.0:
		move_counted.emit(piece)

	# Snap to nearest 10deg step for clean feel, respecting collision blockers
	var snap_step := 10.0
	var target_snap := roundf(piece.rotation_degrees / snap_step) * snap_step
	var snap_delta := target_snap - piece.rotation_degrees
	var clamp_snap := PuzzleRulesScript.clamp_rotation_step(
		piece,
		snap_delta,
		current_active_pieces,
		current_active_links
	)
	var snapped_angle := piece.rotation_degrees + float(clamp_snap["allowed_delta"])

	var tween = piece.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(piece, "rotation_degrees", snapped_angle, 0.12)
	tween.finished.connect(func():
		if is_instance_valid(piece):
			piece.current_angle_deg = fposmod(piece.rotation_degrees, 360.0)
			if piece.state != RingPiece2DScript.State.RELEASED and piece.state != RingPiece2DScript.State.RELEASING:
				piece.state = RingPiece2DScript.State.IDLE
			piece.queue_redraw()
			piece_drag_ended.emit(piece)
	)
