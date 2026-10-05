extends RefCounted
class_name PuzzleRuleEngine

const PieceGeometry = preload("res://gameplay/piece_geometry.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")

enum PieceRole {
	NORMAL,
	ROOT_ANCHOR,
	EXIT,
	SPECIAL,
}

enum ReleaseReason {
	NONE,
	PLAYER_CLEAR,
	ROOT_COMPLETE,
	EXIT_COMPLETE,
}

const _RELEASED := 6
const _RELEASING := 5

static func infer_role(gaps: Array) -> int:
	if gaps.is_empty():
		return PieceRole.ROOT_ANCHOR
	return PieceRole.NORMAL

static func piece_role(piece) -> int:
	if piece != null and "role" in piece:
		return int(piece.role)
	if piece != null and piece.get("gaps") != null and piece.gaps.is_empty():
		return PieceRole.ROOT_ANCHOR
	return PieceRole.NORMAL

static func piece_shape(piece) -> int:
	if piece != null and "shape_type" in piece:
		return int(piece.shape_type)
	return 0

static func piece_thickness(piece) -> float:
	if piece != null and piece.get("thickness") != null:
		return float(piece.thickness)
	return 24.0

static func _is_gone(piece) -> bool:
	return piece == null or not is_instance_valid(piece) or piece.state == _RELEASED or piece.state == _RELEASING

static func bind_connector(link_def, from_pos: Vector2, from_rot_deg: float, to_pos: Vector2) -> void:
	var diff: Vector2 = to_pos - from_pos
	link_def.stem_dist = diff.length()
	link_def.collar_angle_deg = fposmod(rad_to_deg(diff.angle()) - from_rot_deg, 360.0)

static func is_piece_rotatable(piece, _all_pieces: Array, links: Array) -> bool:
	if _is_gone(piece):
		return false
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.to_piece_id == p_id and link.state == ConnectorRuntimeScript.State.CLEARING:
			return false
		if link.def.from_piece_id != p_id:
			continue
		if link.state == ConnectorRuntimeScript.State.DETACHED:
			continue
		var child = get_piece_by_id(link.def.to_piece_id, _all_pieces)
		if not _is_gone(child):
			return false
	return true

static func cuff_world_angle_deg(child, link, pieces: Array) -> float:
	var parent_p = get_piece_by_id(link.def.from_piece_id, pieces)
	if _is_gone(parent_p) and parent_p == null:
		return 0.0
	var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.def.collar_angle_deg)
	var dir := Vector2.from_angle(world_rad)
	var child_r: float = PieceGeometry.get_world_boundary_distance(piece_shape(child), child.radius, child.rotation, dir.angle() + PI)
	var pos_cuff: Vector2 = parent_p.position + dir * (link.def.stem_dist - child_r)
	var rel: Vector2 = pos_cuff - child.position
	if rel.length_squared() < 0.0001:
		return 0.0
	return fposmod(rad_to_deg(rel.angle()), 360.0)

static func alignment_rotation_deg(child, link, pieces: Array, gap) -> float:
	var contact := cuff_world_angle_deg(child, link, pieces)
	return fposmod(contact - float(gap.center_angle_deg), 360.0)

static func connector_fits(child, rotation_deg: float, link, pieces: Array) -> bool:
	if child == null or child.gaps == null or child.gaps.is_empty():
		return false
	var contact_world := cuff_world_angle_deg(child, link, pieces)
	var local_deg := fposmod(contact_world - rotation_deg, 360.0)
	var contact_s := PieceGeometry.angle_to_s(local_deg)
	var shape := piece_shape(child)
	var perim := PieceGeometry.contour_length(shape, child.radius)
	var cuff_w := ConnectorRuntimeScript.TANGENTIAL_WIDTH
	var margin := ConnectorRuntimeScript.SAFETY_MARGIN
	for gap in child.gaps:
		var opening := PieceGeometry.opening_length(shape, child.radius, float(gap.width_deg))
		if not PieceGeometry.opening_accepts_cuff(opening, cuff_w, margin):
			continue
		var interval := PieceGeometry.gap_interval_s(float(gap.center_angle_deg), float(gap.width_deg))
		if PieceGeometry.cuff_span_inside(interval.x, interval.y, contact_s, cuff_w, perim, margin):
			return true
	return false

static func evaluate_clearance(piece, all_pieces: Array, links: Array) -> Array:
	var newly: Array = []
	if _is_gone(piece):
		return newly
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.to_piece_id != p_id:
			continue
		if link.state != ConnectorRuntimeScript.State.ENGAGED:
			continue
		var parent_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
		if _is_gone(parent_p):
			continue
		if connector_fits(piece, piece.rotation_degrees, link, all_pieces):
			link.state = ConnectorRuntimeScript.State.CLEARING
			newly.append(link)
	return newly

static func evaluate_clearance_hypothetical(piece, target_rotation_degrees: float, all_pieces: Array, links: Array) -> Array:
	var found: Array = []
	if _is_gone(piece):
		return found
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.to_piece_id != p_id:
			continue
		if link.state != ConnectorRuntimeScript.State.ENGAGED:
			continue
		if connector_fits(piece, target_rotation_degrees, link, all_pieces):
			found.append(link)
	return found

static func complete_clearance(link) -> void:
	if link != null and link.state == ConnectorRuntimeScript.State.CLEARING:
		link.state = ConnectorRuntimeScript.State.DETACHED

static func retraction_distance(tube_thickness: float) -> float:
	return ConnectorRuntimeScript.retraction_distance(tube_thickness)

static func is_piece_releasable(piece, all_pieces: Array, links: Array) -> bool:
	if _is_gone(piece):
		return false
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.from_piece_id == p_id and link.state != ConnectorRuntimeScript.State.DETACHED:
			var child = get_piece_by_id(link.def.to_piece_id, all_pieces)
			if not _is_gone(child):
				return false
		if link.def.to_piece_id == p_id and link.state != ConnectorRuntimeScript.State.DETACHED:
			var parent_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
			if not _is_gone(parent_p):
				return false
	return true

static func release_reason(piece, _all_pieces: Array, _links: Array) -> int:
	var role := piece_role(piece)
	if role == PieceRole.ROOT_ANCHOR:
		return ReleaseReason.ROOT_COMPLETE
	if role == PieceRole.EXIT:
		return ReleaseReason.EXIT_COMPLETE
	return ReleaseReason.PLAYER_CLEAR

static func on_piece_released(piece, links: Array) -> void:
	if piece == null:
		return
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.from_piece_id == p_id or link.def.to_piece_id == p_id:
			link.state = ConnectorRuntimeScript.State.DETACHED

static func resolve_releases(pieces: Array, links: Array) -> Array:
	var released: Array = []
	var changed := true
	while changed:
		changed = false
		for piece in pieces:
			if _is_gone(piece):
				continue
			if not is_piece_releasable(piece, pieces, links):
				continue
			var reason := release_reason(piece, pieces, links)
			piece.set_meta("release_reason", reason)
			piece.state = _RELEASED
			on_piece_released(piece, links)
			released.append(piece)
			changed = true
	return released

static func is_puzzle_won(pieces: Array, links: Array) -> bool:
	var any_piece := false
	for piece in pieces:
		if piece == null or not is_instance_valid(piece):
			continue
		any_piece = true
		if not _is_gone(piece):
			return false
	if not any_piece:
		return false
	for link in links:
		if link.state == ConnectorRuntimeScript.State.DETACHED:
			continue
		var parent_p = get_piece_by_id(link.def.from_piece_id, pieces)
		var child = get_piece_by_id(link.def.to_piece_id, pieces)
		if _is_gone(parent_p) and _is_gone(child):
			continue
		return false
	return true

static func snap_assist_delta(piece, pieces: Array, links: Array) -> float:
	if _is_gone(piece):
		return 0.0
	var best := 0.0
	var best_abs := INF
	var found := false
	for link in links:
		if link.def.to_piece_id != piece.piece_id:
			continue
		if link.state != ConnectorRuntimeScript.State.ENGAGED:
			continue
		if not connector_fits(piece, piece.rotation_degrees, link, pieces):
			continue
		for gap in piece.gaps:
			var target := alignment_rotation_deg(piece, link, pieces, gap)
			if not connector_fits(piece, target, link, pieces):
				continue
			var delta := wrapf(target - piece.rotation_degrees, -180.0, 180.0)
			if absf(delta) < best_abs:
				best_abs = absf(delta)
				best = delta
				found = true
	if not found:
		return 0.0
	return best

static func clamp_rotation_step(piece: Node2D, step_delta_deg: float, all_pieces: Array, links: Array) -> Dictionary:
	if not is_instance_valid(piece):
		return { "allowed_delta": 0.0, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }
	if not is_piece_rotatable(piece, all_pieces, links):
		var blocked_at := piece.position
		if piece.is_inside_tree():
			blocked_at = piece.global_position
		return { "allowed_delta": 0.0, "hit_stopper": true, "contact_point": blocked_at, "contact_color": Color.WHITE }
	return { "allowed_delta": step_delta_deg, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }

static func apply_settled_rotation(piece, target_rotation_deg: float, pieces: Array, links: Array) -> Dictionary:
	var result := {
		"applied": false,
		"cleared": [],
		"released": [],
		"won": false,
	}
	if _is_gone(piece):
		return result
	var delta := wrapf(target_rotation_deg - piece.rotation_degrees, -180.0, 180.0)
	var clamped: Dictionary = clamp_rotation_step(piece, delta, pieces, links)
	if bool(clamped["hit_stopper"]):
		return result
	if absf(float(clamped["allowed_delta"]) - delta) > 0.5:
		return result
	piece.rotation_degrees += float(clamped["allowed_delta"])
	if "current_angle_deg" in piece:
		piece.current_angle_deg = fposmod(piece.rotation_degrees, 360.0)
	result["applied"] = true
	var clearing: Array = evaluate_clearance(piece, pieces, links)
	for link in clearing:
		complete_clearance(link)
	result["cleared"] = clearing
	result["released"] = resolve_releases(pieces, links)
	result["won"] = is_puzzle_won(pieces, links)
	return result

static func is_piece_near_alignment(piece, all_pieces: Array, links: Array) -> bool:
	if _is_gone(piece):
		return false
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.to_piece_id != p_id or link.state != ConnectorRuntimeScript.State.ENGAGED:
			continue
		var contact := cuff_world_angle_deg(piece, link, all_pieces)
		var local_deg := fposmod(contact - piece.rotation_degrees, 360.0)
		for gap in piece.gaps:
			var dist := absf(wrapf(local_deg - float(gap.center_angle_deg), -180.0, 180.0))
			if dist <= float(gap.width_deg) * 0.5:
				return true
	return false

static func get_piece_by_id(id: StringName, pieces: Array):
	for piece in pieces:
		if is_instance_valid(piece) and piece.piece_id == id:
			return piece
	return null
