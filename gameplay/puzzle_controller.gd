extends Node2D
class_name PuzzleController
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")

const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const DragRotationControllerScript = preload("res://gameplay/drag_rotation_controller.gd")
const ReleaseAnimatorScript = preload("res://gameplay/release_animator.gd")
const HintControllerScript = preload("res://gameplay/hint_controller.gd")
const LevelDefinitionScript = preload("res://data/level_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const AudioServiceScript = preload("res://app/audio_service.gd")
const HapticServiceScript = preload("res://app/haptic_service.gd")
const CollisionSparkBurstScript = preload("res://gameplay/collision_spark_burst.gd")
const PuzzleStateScript = preload("res://gameplay/puzzle_state.gd")

signal moves_updated(moves: int, par_moves: int)
signal level_completed(moves: int, par_moves: int, used_hint: bool)
signal piece_count_updated(remaining: int)

var board = PuzzleStateScript.new()
var active_pieces: Array[Node2D] = []
var active_links: Array = []
var current_level_def = null

var move_count: int = 0
var used_hint: bool = false
var is_active: bool = false
var _intro_token: int = 0
var _is_intro_done: bool = false

var drag_controller: Node
var release_animator: Node
var hint_controller: Node
var audio_service: Node
var haptic_service: Node

class ConnectorLayer extends Node2D:
	var draw_callback: Callable
	func _draw() -> void:
		if draw_callback.is_valid():
			draw_callback.call(self)

var stems_layer: ConnectorLayer
var pieces_container: Node2D
var cuffs_layer: ConnectorLayer

# PERFORMANCE: dirty flag — only actually draw when something changed.
# This eliminates the #1 CPU hog: unconditional queue_redraw every frame.
var _connectors_dirty: bool = false
var _drop_anim_end_time: float = 0.0  # keep dirty during intro drop

func _redraw_connectors() -> void:
	_connectors_dirty = true

func _ready() -> void:
	stems_layer = ConnectorLayer.new()
	stems_layer.name = "StemsLayer"
	stems_layer.z_index = 0
	stems_layer.draw_callback = _on_stems_layer_draw
	add_child(stems_layer)

	pieces_container = Node2D.new()
	pieces_container.name = "PiecesContainer"
	pieces_container.z_index = 2
	add_child(pieces_container)

	cuffs_layer = ConnectorLayer.new()
	cuffs_layer.name = "CuffsLayer"
	cuffs_layer.z_index = 20
	cuffs_layer.draw_callback = _on_cuffs_layer_draw
	add_child(cuffs_layer)

	drag_controller = DragRotationControllerScript.new()
	add_child(drag_controller)
	drag_controller.move_counted.connect(_on_move_counted)
	drag_controller.piece_selected.connect(func(_p): if hint_controller and hint_controller.current_hand: hint_controller.current_hand.stop())
	drag_controller.piece_drag_ended.connect(_on_piece_drag_ended)
	drag_controller.collision_occurred.connect(_on_collision_occurred)

	release_animator = ReleaseAnimatorScript.new()
	add_child(release_animator)

	hint_controller = HintControllerScript.new()
	add_child(hint_controller)

func _process(_delta: float) -> void:
	# Only flush the dirty flag — never draw unconditionally.
	# Also keep redrawing during the drop intro animation (ring positions change).
	if Time.get_ticks_msec() / 1000.0 < _drop_anim_end_time:
		_connectors_dirty = true
	if _connectors_dirty:
		_connectors_dirty = false
		if is_instance_valid(stems_layer): stems_layer.queue_redraw()
		if is_instance_valid(cuffs_layer): cuffs_layer.queue_redraw()

func setup(audio: Node, haptic: Node) -> void:
	audio_service = audio
	haptic_service = haptic
	drag_controller.setup(audio, haptic)
	release_animator.setup(audio, haptic)
	hint_controller.setup(audio)

func load_level(def) -> void:
	if def == null:
		push_warning("PuzzleController.load_level received null and did not substitute Level 1.")
		return
	current_level_def = def
	move_count = 0
	used_hint = false
	is_active = false
	if release_animator and release_animator.has_method("reset_combo"):
		release_animator.reset_combo()

	for child in pieces_container.get_children():
		child.queue_free()
	active_pieces.clear()
	active_links.clear()

	var par: int = def.par_moves if def else 1
	moves_updated.emit(move_count, par)

	var piece_map := {}
	var drop_delay: float = 0.0
	
	for p_def in def.pieces:
		var p_node = RingPiece2DScript.new()
		p_node.setup(p_def)
		p_node.z_index = int(p_def.z_index)
		# Start above screen
		p_node.position = p_def.position + Vector2(0, -1200)
		p_node.modulate.a = 0.0
		
		var drop_tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		drop_tween.tween_property(p_node, "position", p_def.position, 0.8).set_delay(drop_delay)
		drop_tween.parallel().tween_property(p_node, "modulate:a", 1.0, 0.3).set_delay(drop_delay)
		
		# Small shadow flare on impact
		var flare_tween = create_tween().set_trans(Tween.TRANS_SPRING)
		flare_tween.tween_property(p_node, "shadow_offset_mult", 2.0, 0.1).set_delay(drop_delay + 0.7)
		flare_tween.tween_property(p_node, "shadow_offset_mult", 1.0, 0.3)
		
		drop_delay += 0.08
		
		p_node.rotation_changed.connect(_on_piece_rotated)
		pieces_container.add_child(p_node)
		active_pieces.append(p_node)
		piece_map[p_def.id] = p_node

	for l_def in def.links:
		var link = l_def.duplicate()
		var from_def = null
		var to_def = null
		for pd in def.pieces:
			if pd.id == link.from_piece_id: from_def = pd
			if pd.id == link.to_piece_id: to_def = pd
		if from_def and to_def:
			var from_p = piece_map.get(link.from_piece_id)
			var to_p = piece_map.get(link.to_piece_id)
			if from_p and to_p:
				from_p.role = 1 if from_p.gaps.is_empty() else 0
				to_p.role = 1 if to_p.gaps.is_empty() else 0
			# Use definition positions. The drop tween has not reached them yet.
			PuzzleRulesScript.bind_connector(link, from_def.position, from_def.start_angle_deg, to_def.position)
		active_links.append(ConnectorRuntime.new(link))

	board.pieces = active_pieces
	board.links = active_links

	# Keep connectors dirty for the full drop animation duration so falling rings stay connected
	var total_drop_time: float = drop_delay + 1.2
	_drop_anim_end_time = Time.get_ticks_msec() / 1000.0 + total_drop_time
	
	_intro_token += 1
	var expected_token = _intro_token
	_is_intro_done = false
	get_tree().create_timer(total_drop_time).timeout.connect(func():
		if _intro_token == expected_token:
			_is_intro_done = true
			is_active = true
	)

	hint_controller.set_level(def, active_pieces, active_links)
	_redraw_connectors()
	piece_count_updated.emit(active_pieces.size())

func get_puzzle_bounds() -> Rect2:
	if not current_level_def or not "pieces" in current_level_def or current_level_def.pieces.is_empty():
		return Rect2(0, 0, 0, 0)
	
	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	
	for p_def in current_level_def.pieces:
		var pos = p_def.position
		var r = p_def.radius + p_def.thickness * 1.5
		
		min_pos.x = minf(min_pos.x, pos.x - r)
		min_pos.y = minf(min_pos.y, pos.y - r)
		max_pos.x = maxf(max_pos.x, pos.x + r)
		max_pos.y = maxf(max_pos.y, pos.y + r)
		
	return Rect2(min_pos, max_pos - min_pos)

func _input(event: InputEvent) -> void:
	if not is_active: return
	if drag_controller.handle_input(event, active_pieces, active_links):
		get_viewport().set_input_as_handled()

func _on_piece_rotated(piece: Node2D, _angle: float) -> void:
	_redraw_connectors()

	# Only provide visual hint during rotation (NEVER UNLOCK OR DETACH MID-DRAG!)
	if piece.state == RingPiece2DScript.State.ROTATING:
		if PuzzleRulesScript.is_piece_near_alignment(piece, active_pieces, active_links):
			piece.state = RingPiece2DScript.State.NEAR_VALID
			piece.queue_redraw()
		elif piece.state == RingPiece2DScript.State.NEAR_VALID:
			piece.state = RingPiece2DScript.State.ROTATING
			piece.queue_redraw()

func _on_move_counted(_piece: Node2D) -> void:
	move_count += 1
	var par: int = current_level_def.par_moves if current_level_def else 1
	moves_updated.emit(move_count, par)

func _on_piece_drag_ended(piece: Node2D) -> void:
	_redraw_connectors()
	check_unlock_on_drag_ended(piece)

func _on_collision_occurred(pos: Vector2, color: Color) -> void:
	var sparks = CollisionSparkBurstScript.new()
	add_child(sparks)
	sparks.setup(pos, color)

func check_unlock_on_drag_ended(piece: Node2D) -> void:
	if not is_instance_valid(piece): return
	if piece.state == RingPiece2DScript.State.RELEASED or piece.state == RingPiece2DScript.State.RELEASING:
		return

	var snap := PuzzleRulesScript.snap_assist_delta(piece, active_pieces, active_links)
	if absf(snap) > 0.05:
		var clamped: Dictionary = PuzzleRulesScript.clamp_rotation_step(piece, snap, active_pieces, active_links)
		var allowed := float(clamped.allowed_delta)
		if absf(allowed) > 0.05:
			piece.rotation_degrees += allowed
			piece.current_angle_deg = fposmod(piece.rotation_degrees, 360.0)
			piece.queue_redraw()

	var newly_clearing = PuzzleRulesScript.evaluate_clearance(piece, active_pieces, active_links)
	if newly_clearing.size() > 0:
		# Opening already fits on the settled pose. Shatter now; the parent cuff stays extended.
		for link in newly_clearing:
			PuzzleRulesScript.complete_clearance(link)
			var child_p = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, active_pieces)
			var parent_p = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, active_pieces)
			if is_instance_valid(child_p):
				_release_if_legal.call_deferred(child_p)
			if is_instance_valid(parent_p):
				_release_if_legal.call_deferred(parent_p)
		if audio_service and audio_service.has_method("play_rotation_tick"):
			audio_service.play_rotation_tick(1.6)
		_redraw_connectors()
		return

	_release_if_legal(piece)

func check_unlock_for_piece(piece: Node2D) -> void:
	check_unlock_on_drag_ended(piece)

func _release_if_legal(piece: Node2D) -> void:
	if not is_instance_valid(piece):
		return
	if not PuzzleRulesScript.is_piece_releasable(piece, active_pieces, active_links):
		return
	if haptic_service and haptic_service.has_method("trigger_selection"):
		haptic_service.trigger_selection()
	_redraw_connectors()
	unlock_and_release_piece(piece, true)

func unlock_and_release_piece(piece: Node2D, is_direct: bool = false) -> void:
	if not is_instance_valid(piece): return
	if piece.state == RingPiece2DScript.State.RELEASING or piece.state == RingPiece2DScript.State.RELEASED:
		return
	piece.set_meta("release_reason", PuzzleRulesScript.release_reason(piece, active_pieces, active_links))
	PuzzleRulesScript.on_piece_released(piece, active_links)
	piece.state = RingPiece2DScript.State.RELEASING
	piece.is_interactive = false

	_redraw_connectors()
	release_animator.animate_release(piece, _on_piece_release_completed, is_direct)

func _on_piece_release_completed(piece: Node2D) -> void:
	active_pieces.erase(piece)
	
	# Only remove links where this piece was the PARENT.
	# If it was the CHILD, keep the link so the parent can draw its stub!
	var links_to_keep = []
	for link in active_links:
		if link.def.from_piece_id != piece.piece_id:
			links_to_keep.append(link)
	active_links = links_to_keep
	board.links = active_links
	
	piece_count_updated.emit(active_pieces.size())
	_redraw_connectors()

	var remaining = active_pieces.filter(func(p):
		return is_instance_valid(p) and \
			p.state != RingPiece2DScript.State.RELEASED and \
			p.state != RingPiece2DScript.State.RELEASING
	)

	if PuzzleRulesScript.is_puzzle_won(active_pieces, active_links) or remaining.is_empty():
		if is_active:
			is_active = false
			var par: int = current_level_def.par_moves if current_level_def else 1
			level_completed.emit(move_count, par, used_hint)
		return

	_check_cascade_releases()

func _check_cascade_releases() -> void:
	var remaining = active_pieces.filter(func(p):
		return is_instance_valid(p) and \
			p.state != RingPiece2DScript.State.RELEASED and \
			p.state != RingPiece2DScript.State.RELEASING
	)
	var cascade_idx := 0
	for p in remaining:
		if PuzzleRulesScript.is_piece_releasable(p, active_pieces, active_links):
			var captured_id: StringName = p.piece_id
			var delay: float = 0.40 + (cascade_idx * 0.25)
			cascade_idx += 1
			get_tree().create_timer(delay).timeout.connect(func():
				var live = PuzzleRulesScript.get_piece_by_id(captured_id, active_pieces)
				if is_instance_valid(live) and PuzzleRulesScript.is_piece_releasable(live, active_pieces, active_links):
					unlock_and_release_piece(live)
			)

func resume_game() -> void:
	if _is_intro_done:
		is_active = true

func request_hint() -> void:
	used_hint = true
	hint_controller.trigger_hint()

func restart_level() -> void:
	if current_level_def:
		load_level(current_level_def)

func _get_child_boundary_distance(link: ConnectorRuntime, dir: Vector2) -> float:
	var shape_type = 0
	var r = 72.0
	var rot = 0.0
	var to_p = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, active_pieces)
	if is_instance_valid(to_p):
		shape_type = to_p.def.shape_type if to_p.get("def") and "shape_type" in to_p.def else 0
		r = to_p.radius
		rot = to_p.global_rotation
	elif current_level_def:
		for p_def in current_level_def.pieces:
			if p_def.id == link.def.to_piece_id:
				shape_type = p_def.shape_type if "shape_type" in p_def else 0
				r = p_def.radius
				rot = deg_to_rad(p_def.start_angle_deg)
				break
	return PieceGeometry.get_world_boundary_distance(shape_type, r, rot, dir.angle() + PI)


func _on_stems_layer_draw(ci: CanvasItem) -> void:
	for link in active_links:
		var from_p = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, active_pieces)
		if not is_instance_valid(from_p): continue
		if from_p.state == RingPiece2DScript.State.RELEASED or from_p.state == RingPiece2DScript.State.RELEASING:
			continue
		if float(link.current_stem_dist) <= 1.0:
			continue

		var world_angle_rad := deg_to_rad(from_p.rotation_degrees + link.def.collar_angle_deg)
		var dir := Vector2.from_angle(world_angle_rad)
		var parent_shape = from_p.def.shape_type if from_p.get("def") and "shape_type" in from_p.def else 0
		var pos_stem_start: Vector2 = from_p.position + dir * PieceGeometry.get_boundary_distance(parent_shape, from_p.radius, deg_to_rad(link.def.collar_angle_deg))

		# FIX Bug 1 (Update): Users want the FULL connector (stem + cuff) to remain 
		# even when the child ring breaks away.
		var child_r: float = _get_child_boundary_distance(link, dir)
		var pos_cuff: Vector2 = from_p.position + dir * (link.current_stem_dist - child_r)

		var collar_color: Color = from_p.ring_color if link.def.joint_color == Color.TRANSPARENT else link.def.joint_color
		var c_dark = collar_color.darkened(0.22)
		var c_main = collar_color.lightened(0.02)
		var c_light = collar_color.lightened(0.25)
		c_light.a = 0.85
		var stem_thickness := ConnectorRuntime.STEM_RADIUS * 2.0

		# 1. Soft drop shadow cast strictly downwards
		ci.draw_line(pos_stem_start + Vector2(0, 6.0), pos_cuff + Vector2(0, 6.0), Color(0.20, 0.14, 0.10, 0.12), stem_thickness + 2.0, true)
		# 2. Darker lower base
		ci.draw_line(pos_stem_start + Vector2(0, 2.5), pos_cuff + Vector2(0, 2.5), c_dark, stem_thickness, true)
		# 3. Main stem body
		ci.draw_line(pos_stem_start, pos_cuff, c_main, stem_thickness, true)
		# 4. Highlight bevel
		ci.draw_line(pos_stem_start + Vector2(-1.5, -1.5), pos_cuff + Vector2(-1.5, -1.5), c_light, stem_thickness - 6.0, true)

		# 5. Flared weld / fillet base at ring outer perimeter
		var r_outer: float = PieceGeometry.get_boundary_distance(parent_shape, from_p.radius, deg_to_rad(link.def.collar_angle_deg)) + (from_p.thickness * 0.5)
		var weld_center: Vector2 = from_p.position + dir * (r_outer - 1.0)
		var weld_radius: float = stem_thickness * 0.85
		ci.draw_circle(weld_center + Vector2(0, 2.5), weld_radius, c_dark)
		ci.draw_circle(weld_center, weld_radius, c_main)
		ci.draw_circle(weld_center + Vector2(-1.0, -1.0), weld_radius * 0.6, c_light)

func _on_cuffs_layer_draw(ci: CanvasItem) -> void:
	for link in active_links:
		var from_p = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, active_pieces)
		if not is_instance_valid(from_p): continue
		if from_p.state == RingPiece2DScript.State.RELEASED or from_p.state == RingPiece2DScript.State.RELEASING:
			continue
		if float(link.current_stem_dist) <= 1.0:
			continue

		var world_angle_rad := deg_to_rad(from_p.rotation_degrees + link.def.collar_angle_deg)
		var dir := Vector2.from_angle(world_angle_rad)
		var child_r: float = _get_child_boundary_distance(link, dir)
		var pos_cuff: Vector2 = from_p.position + dir * (link.current_stem_dist - child_r)

		var tangent := Vector2(-dir.y, dir.x)
		var collar_color: Color = from_p.ring_color if link.def.joint_color == Color.TRANSPARENT else link.def.joint_color
		var c_dark = collar_color.darkened(0.22)
		var c_main = collar_color.lightened(0.02)
		var c_light = collar_color.lightened(0.25)
		c_light.a = 0.85

		var sleeve_tangent_span := ConnectorRuntime.TANGENTIAL_WIDTH
		var sleeve_radial_depth := ConnectorRuntime.RADIAL_DEPTH
		var half_st := sleeve_tangent_span * 0.5
		var half_rd := sleeve_radial_depth * 0.5
		var cuff_corner_r := 5.0

		ci.draw_set_transform(pos_cuff, tangent.angle(), Vector2.ONE)

		# 1. Soft drop shadow
		_draw_rounded_rect(ci, Rect2(-half_st, -half_rd + 6.0, sleeve_tangent_span, sleeve_radial_depth), Color(0.20, 0.14, 0.10, 0.12), cuff_corner_r)

		# 2. Darker lower base
		_draw_rounded_rect(ci, Rect2(-half_st, -half_rd + 2.5, sleeve_tangent_span, sleeve_radial_depth), c_dark, cuff_corner_r)

		# 3. Main collar body
		_draw_rounded_rect(ci, Rect2(-half_st, -half_rd, sleeve_tangent_span, sleeve_radial_depth), c_main, cuff_corner_r)

		# 4. Highlight bevel (shifted up and slightly smaller)
		_draw_rounded_rect(ci, Rect2(-half_st + 1.5, -half_rd - 1.0, sleeve_tangent_span - 3.0, sleeve_radial_depth - 4.0), c_light, cuff_corner_r * 0.8)

		ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_rounded_rect(ci: CanvasItem, rect: Rect2, color: Color, radius: float) -> void:
	var r := minf(radius, minf(rect.size.x * 0.5, rect.size.y * 0.5))
	var sb = StyleBoxFlat.new()
	sb.bg_color = color
	sb.corner_radius_top_left = int(r)
	sb.corner_radius_top_right = int(r)
	sb.corner_radius_bottom_left = int(r)
	sb.corner_radius_bottom_right = int(r)
	sb.anti_aliasing = true
	sb.draw(ci.get_canvas_item(), rect)
