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
	if piece != null and piece.get("gaps") != null and piece.gaps.is_empty() and false:
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
	if piece == null or not is_instance_valid(piece):
		return true
	if "state" in piece:
		var st := int(piece.state)
		return st == _RELEASED or st == _RELEASING
	return false

static func bind_connector(link_def, from_pos: Vector2, from_rot_deg: float, to_pos: Vector2, from_radius: float = 0.0) -> void:
	var diff: Vector2 = to_pos - from_pos
	var d := diff.length()
	if d < 1.0:
		link_def.stem_dist = from_radius if from_radius > 0.0 else 88.0
		link_def.collar_angle_deg = fposmod(0.0 - from_rot_deg, 360.0)
	else:
		link_def.stem_dist = d
		link_def.collar_angle_deg = fposmod(rad_to_deg(diff.angle()) - from_rot_deg, 360.0)

static func is_piece_rotatable(piece, _all_pieces: Array, links: Array) -> bool:
	# A piece is rotatable if it is not gone and not a root anchor.
	# The previous version returned false if the piece was a parent
	# with any non-gone child, which deadlocked every level whose root
	# had children (e.g. L2 orange, L3 cyan and orange) -- the user
	# could not rotate the very piece they needed to rotate. The
	# correct rule is: any non-root, non-gone piece can rotate. The
	# collision check (clamp_rotation_step is_piece_overlap_contact)
	# blocks rotations that would physically collide.
	if _is_gone(piece):
		return false
	if piece_role(piece) == PieceRole.ROOT_ANCHOR:
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
	return _accepting_gap(child, rotation_deg, link, pieces) != null

## The parent ring owns the connector (link.def.from_piece_id). joint_color is only how that cuff is drawn.
## A gap clears a connector only when that parent's cuff sits fully in the usable opening and the opening is aimed at that cuff, not at another holder.
static func opening_claims_link(child, rotation_deg: float, link, pieces: Array, links: Array) -> bool:
	var gap = _accepting_gap(child, rotation_deg, link, pieces)
	if gap == null:
		return false
	var mine := _contact_offset_deg(child, rotation_deg, link, pieces, gap)
	var child_id: StringName = child.piece_id
	for other in links:
		if other == link:
			continue
		if other.def.to_piece_id != child_id:
			continue
		if other.state == ConnectorRuntimeScript.State.DETACHED:
			continue
		var other_offset := _contact_offset_deg(child, rotation_deg, other, pieces, gap)
		if other_offset < mine - 0.05:
			return false
	return true

static func _contact_offset_deg(child, rotation_deg: float, link, pieces: Array, gap) -> float:
	var contact_world := cuff_world_angle_deg(child, link, pieces)
	var local_deg := fposmod(contact_world - rotation_deg, 360.0)
	return absf(wrapf(local_deg - float(gap.center_angle_deg), -180.0, 180.0))

static func _accepting_gap(child, rotation_deg: float, link, pieces: Array):
	if child == null or child.gaps == null or child.gaps.is_empty():
		return null
	var contact_world := cuff_world_angle_deg(child, link, pieces)
	var local_deg := fposmod(contact_world - rotation_deg, 360.0)
	var contact_s := PieceGeometry.angle_to_s(local_deg)
	var shape := piece_shape(child)
	var perim := PieceGeometry.contour_length(shape, child.radius)
	var thick := piece_thickness(child)
	var cuff_w := ConnectorRuntimeScript.TANGENTIAL_WIDTH
	var margin := ConnectorRuntimeScript.SAFETY_MARGIN
	for gap in child.gaps:
		var opening := PieceGeometry.usable_opening_length(shape, child.radius, float(gap.width_deg), thick)
		# Add the safety margin to the opening check so the connector sleeve always clears.
		if not PieceGeometry.opening_accepts_cuff(opening + margin, cuff_w, margin):
			continue
		var interval := PieceGeometry.usable_gap_interval_s(shape, child.radius, thick, float(gap.center_angle_deg), float(gap.width_deg))
		if PieceGeometry.cuff_span_inside(interval.x, interval.y, contact_s, cuff_w, perim, margin):
			return gap
	return null

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
		if _is_gone(parent_p) and parent_p != null:
			continue
		if opening_claims_link(piece, piece.rotation_degrees, link, all_pieces, links):
			newly.append(link)
	
	for link in newly:
		link.state = ConnectorRuntimeScript.State.CLEARING
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
		if opening_claims_link(piece, target_rotation_degrees, link, all_pieces, links):
			found.append(link)
	return found

static func complete_clearance(link) -> void:
	if link != null and link.state == ConnectorRuntimeScript.State.CLEARING:
		link.state = ConnectorRuntimeScript.State.DETACHED
		# Pull this cuff off the child so the player can see that one holder let go.
		# The ring itself stays until every one of its connectors has been cleared.
		var pull: float = ConnectorRuntimeScript.retraction_distance(16.0)
		link.current_stem_dist = maxf(0.0, link.current_stem_dist - pull)

static func is_piece_releasable(piece, all_pieces: Array, links: Array) -> bool:
	# Strict two-connector rule: a piece can release ONLY when EVERY link that touches
	# it (incoming or outgoing) has reached DETACHED. Single-pass so the rule is
	# impossible to skip by partial state changes.
	if _is_gone(piece):
		return false
	var p_id: StringName = piece.piece_id if ("piece_id" in piece and piece.piece_id != null) else (piece.id if "id" in piece else &"")
	for link in links:
		if link == null:
			continue
		var from_id: StringName = link.def.from_piece_id if ("def" in link and link.def != null) else StringName(link.from_piece_id)
		var to_id: StringName = link.def.to_piece_id if ("def" in link and link.def != null) else StringName(link.to_piece_id)
		if from_id != p_id and to_id != p_id:
			continue
		var l_state: int = int(link.state) if "state" in link else (ConnectorRuntimeScript.State.DETACHED if ("is_detached" in link and link.is_detached) else ConnectorRuntimeScript.State.ENGAGED)
		if l_state != ConnectorRuntimeScript.State.DETACHED:
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
		# Once the child is gone, a long bar has nothing left to hold. Park it on
		# the parent so it cannot sweep through the board. Short grips stay out;
		# a freed ring still cannot turn that cuff into a neighbor.
		if link.def.to_piece_id == p_id and float(link.def.stem_dist) > 300.0:
			link.current_stem_dist = 0.0

static func initialize_puzzle_state(pieces: Array, links: Array) -> Array:
	return resolve_releases(pieces, links)

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
		if not opening_claims_link(piece, piece.rotation_degrees, link, pieces, links):
			continue
		for gap in piece.gaps:
			var target := alignment_rotation_deg(piece, link, pieces, gap)
			if not opening_claims_link(piece, target, link, pieces, links):
				continue
			var delta := wrapf(target - piece.rotation_degrees, -180.0, 180.0)
			if absf(delta) < best_abs:
				best_abs = absf(delta)
				best = delta
				found = true
	if not found:
		return 0.0
	return best

static func clamp_slide_step(piece: Node2D, step_delta: Vector2, all_pieces: Array, links: Array) -> Dictionary:
	if not is_instance_valid(piece):
		return { "allowed_delta": Vector2.ZERO, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }
	
	var saved_pos := piece.position
	var target_dist := step_delta.length()
	if target_dist < 0.001:
		return { "allowed_delta": Vector2.ZERO, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }
		
	var sign_vec := step_delta.normalized()
	var safe := 0.0
	var hit := false
	var contact := Vector2.ZERO
	var contact_color := Color.WHITE
	var stride := 3.0
	
	while safe < target_dist - 0.001:
		var nxt := minf(safe + stride, target_dist)
		piece.position = saved_pos + sign_vec * nxt
		var block: Dictionary = _overlap_contact(piece, all_pieces, links)
		if bool(block.blocking):
			var lo := safe
			var hi := nxt
			var hit_info := block
			for _i in 8:
				var mid := (lo + hi) * 0.5
				piece.position = saved_pos + sign_vec * mid
				var mid_block = _overlap_contact(piece, all_pieces, links)
				if bool(mid_block.blocking):
					hi = mid
					hit_info = mid_block
				else:
					lo = mid
			safe = lo
			hit = true
			contact = hit_info.point
			contact_color = hit_info.color
			break
		safe = nxt
	
	piece.position = saved_pos
	return { "allowed_delta": sign_vec * safe, "hit_stopper": hit, "contact_point": contact, "contact_color": contact_color }

static func clamp_rotation_step(piece: Node2D, step_delta_deg: float, all_pieces: Array, links: Array) -> Dictionary:
	if not is_instance_valid(piece):
		return { "allowed_delta": 0.0, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }
	# Note: do NOT early-exit on is_piece_rotatable. A parent with live
	# children can still rotate as long as the rotation doesn't physically
	# collide with anything — that's what _overlap_contact below checks.
	# The old early-exit made every parent-piece un-draggable, which
	# deadlocked every level whose root has a child link.
	var saved := piece.rotation_degrees
	var delta := step_delta_deg
	if absf(delta) < 0.001:
		return { "allowed_delta": 0.0, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }
	var sign := signf(delta)
	var target_abs := absf(delta)
	var safe := 0.0
	var hit := false
	var contact := Vector2.ZERO
	var contact_color := Color.WHITE
	var stride := 3.0
	while safe < target_abs - 0.001:
		var nxt := minf(safe + stride, target_abs)
		piece.rotation_degrees = saved + sign * nxt
		var block: Dictionary = _overlap_contact(piece, all_pieces, links)
		if bool(block.blocking):
			var lo := safe
			var hi := nxt
			var hit_info := block
			for _i in 8:
				var mid := (lo + hi) * 0.5
				piece.rotation_degrees = saved + sign * mid
				var mid_block: Dictionary = _overlap_contact(piece, all_pieces, links)
				if bool(mid_block.blocking):
					hi = mid
					hit_info = mid_block
				else:
					lo = mid
			piece.rotation_degrees = saved + sign * lo
			if bool(_overlap_contact(piece, all_pieces, links).blocking):
				lo = 0.0
			safe = lo
			hit = true
			contact = hit_info.get("point", Vector2.ZERO)
			contact_color = hit_info.get("color", Color.WHITE)
			break
		safe = nxt
	piece.rotation_degrees = saved
	if hit and safe < 0.2:
		safe = 0.0
	return {
		"allowed_delta": sign * safe,
		"hit_stopper": hit,
		"contact_point": contact,
		"contact_color": contact_color,
	}

static func _is_linked_pair(a, b, links: Array) -> bool:
	var a_id: StringName = a.piece_id if ("piece_id" in a and a.piece_id != null) else (a.id if "id" in a else &"")
	var b_id: StringName = b.piece_id if ("piece_id" in b and b.piece_id != null) else (b.id if "id" in b else &"")
	for link in links:
		if int(link.state if "state" in link else 0) == ConnectorRuntimeScript.State.DETACHED:
			continue
		var from_id: StringName = link.def.from_piece_id if ("def" in link and link.def != null) else StringName(link.from_piece_id)
		var to_id: StringName = link.def.to_piece_id if ("def" in link and link.def != null) else StringName(link.to_piece_id)
		if (from_id == a_id and to_id == b_id) or (from_id == b_id and to_id == a_id):
			return true
	return false

## True when the piece's current rotation puts a solid body through another solid body.
static func pose_blocked(piece, pieces: Array, links: Array) -> bool:
	return bool(_overlap_contact(piece, pieces, links).blocking)

static func _overlap_contact(piece, pieces: Array, links: Array) -> Dictionary:
	var clear := { "blocking": false, "point": Vector2.ZERO, "color": Color.WHITE }
	if _is_gone(piece):
		return clear
	var margin := ConnectorRuntimeScript.BODY_MARGIN
	for other in pieces:
		if other == piece or _is_gone(other):
			continue
		if _is_linked_pair(piece, other, links):
			continue
		if _tubes_overlap(piece, other, 0.0):
			return { "blocking": true, "point": (piece.position + other.position) * 0.5, "color": other.ring_color if "ring_color" in other else Color.WHITE }
	for link in links:
		if not _link_drawn(link, pieces):
			continue
		var moves: bool = (link.def.from_piece_id == piece.piece_id)
		if not moves:
			if link.def.to_piece_id == piece.piece_id:
				continue
			if _cuff_hits_ring(link, piece, pieces, margin):
				return _hit_from_link(link, pieces)
			continue
		for other_link in links:
			if other_link == link or not _link_drawn(other_link, pieces):
				continue
			if other_link.def.from_piece_id == link.def.from_piece_id:
				continue # Connectors on the same parent ring rotate in rigid lockstep and never collide with each other!
			if _cuffs_overlap(link, other_link, pieces, margin) or _stem_hits_cuff(link, other_link, pieces, margin):
				return _hit_from_link(other_link, pieces)
		for other in pieces:
			if _is_gone(other):
				continue
			if other.piece_id == link.def.from_piece_id:
				continue
			if other.piece_id == link.def.to_piece_id:
				continue
			if _cuff_hits_ring(link, other, pieces, margin) or _stem_hits_ring(link, other, pieces, margin):
				return { "blocking": true, "point": _cuff_pose(link, pieces).center, "color": other.ring_color }
	return clear

static func _hit_from_link(link, pieces: Array) -> Dictionary:
	var pose: Dictionary = _cuff_pose(link, pieces)
	var parent = get_piece_by_id(link.def.from_piece_id, pieces)
	var color := Color.WHITE
	if parent != null and "ring_color" in parent:
		color = parent.ring_color
	return { "blocking": true, "point": pose.center, "color": color }

static func _link_drawn(link, pieces: Array) -> bool:
	if link.state == ConnectorRuntimeScript.State.DETACHED:
		return false
	if float(link.current_stem_dist) <= 1.0:
		return false
	var parent = get_piece_by_id(link.def.from_piece_id, pieces)
	return not _is_gone(parent)

static func _cuff_pose(link, pieces: Array) -> Dictionary:
	var parent = get_piece_by_id(link.def.from_piece_id, pieces)
	var child = get_piece_by_id(link.def.to_piece_id, pieces)
	var world := deg_to_rad(parent.rotation_degrees + link.def.collar_angle_deg)
	var dir := Vector2.from_angle(world)
	var child_r := 72.0
	if child != null:
		child_r = PieceGeometry.get_world_boundary_distance(piece_shape(child), child.radius, child.rotation, dir.angle() + PI)
	var center: Vector2 = parent.position + dir * (link.current_stem_dist - child_r)
	var tangent := Vector2(-dir.y, dir.x)
	var radial := -dir
	return {
		"center": center,
		"tangent": tangent,
		"radial": radial,
		"dir": dir,
		"half_x": ConnectorRuntimeScript.TANGENTIAL_WIDTH * 0.5,
		"half_y": ConnectorRuntimeScript.RADIAL_DEPTH * 0.5,
		"parent": parent,
	}

static func _cuffs_overlap(a, b, pieces: Array, margin: float) -> bool:
	var pa: Dictionary = _cuff_pose(a, pieces)
	var pb: Dictionary = _cuff_pose(b, pieces)
	return PieceGeometry.obb_overlaps(pa.center, pa.tangent, pa.radial, pa.half_x, pa.half_y, pb.center, pb.tangent, pb.radial, pb.half_x, pb.half_y, margin)

static func _cuff_hits_ring(link, ring, pieces: Array, margin: float) -> bool:
	var pose: Dictionary = _cuff_pose(link, pieces)
	var outer: float = ring.radius + piece_thickness(ring) * 0.5
	if pose.center.distance_to(ring.position) > outer + ConnectorRuntimeScript.TANGENTIAL_WIDTH + margin:
		return false
	for ix in range(-1, 2):
		for iy in range(-1, 2):
			var sample: Vector2 = pose.center + pose.tangent * (float(ix) * pose.half_x) + pose.radial * (float(iy) * pose.half_y)
			if _point_on_tube(ring, sample, margin):
				return true
	return _ring_samples_hit_obb(ring, pose, margin)

static func _stem_hits_cuff(link, other, pieces: Array, margin: float) -> bool:
	var pose: Dictionary = _cuff_pose(other, pieces)
	var stem_r := ConnectorRuntimeScript.STEM_RADIUS
	for point in _stem_samples(link, pieces):
		if PieceGeometry.point_in_obb(point, pose.center, pose.tangent, pose.radial, pose.half_x, pose.half_y, margin + stem_r):
			return true
	return false

static func _stem_hits_ring(link, ring, pieces: Array, margin: float) -> bool:
	var stem_r := ConnectorRuntimeScript.STEM_RADIUS
	for point in _stem_samples(link, pieces):
		if _point_on_tube(ring, point, margin + stem_r):
			return true
	return false

static func _stem_samples(link, pieces: Array) -> Array:
	var parent = get_piece_by_id(link.def.from_piece_id, pieces)
	var pose: Dictionary = _cuff_pose(link, pieces)
	var dir: Vector2 = pose.dir
	var local := deg_to_rad(link.def.collar_angle_deg)
	var boundary := PieceGeometry.get_boundary_distance(piece_shape(parent), parent.radius, local)
	var start: Vector2 = parent.position + dir * (boundary + piece_thickness(parent) * 0.5 + ConnectorRuntimeScript.BODY_MARGIN)
	var finish: Vector2 = pose.center
	var span := finish - start
	var length := span.length()
	if length < 1.0:
		return []
	var steps := maxi(int(length / 8.0), 1)
	var points: Array = []
	for i in range(steps + 1):
		points.append(start.lerp(finish, float(i) / float(steps)))
	return points

static func _tubes_overlap(a, b, margin: float) -> bool:
	var reach: float = a.radius + b.radius + piece_thickness(a) * 0.5 + piece_thickness(b) * 0.5 + margin
	if a.position.distance_to(b.position) > reach:
		return false
	var step := 8.0
	if _tube_samples_hit(a, b, step, margin):
		return true
	return _tube_samples_hit(b, a, step, margin)

static func _tube_samples_hit(source, target, step_deg: float, margin: float) -> bool:
	var arcs: Array = RingGeometry.get_solid_arcs(source.gaps if source.gaps != null else [])
	if arcs.is_empty():
		return false
	for arc in arcs:
		var length_rad := float(arc.length) if arc.get("length") != null else float(arc.end) - float(arc.start)
		var count := maxi(int(rad_to_deg(length_rad) / step_deg), 1)
		for i in range(count + 1):
			var local := float(arc.start) + length_rad * float(i) / float(count)
			var boundary := PieceGeometry.get_boundary_distance(piece_shape(source), source.radius, local)
			var dir := Vector2.from_angle(source.rotation + local)
			var half := piece_thickness(source) * 0.5
			for radius_off in [-half, 0.0, half]:
				var point: Vector2 = source.position + dir * (boundary + radius_off)
				if _point_on_tube(target, point, margin):
					return true
	return false

static func _ring_samples_hit_obb(ring, pose: Dictionary, margin: float) -> bool:
	var arcs: Array = RingGeometry.get_solid_arcs(ring.gaps if ring.gaps != null else [])
	for arc in arcs:
		var length_rad := float(arc.length) if arc.get("length") != null else float(arc.end) - float(arc.start)
		var count := maxi(int(rad_to_deg(length_rad) / 10.0), 1)
		for i in range(count + 1):
			var local := float(arc.start) + length_rad * float(i) / float(count)
			var boundary := PieceGeometry.get_boundary_distance(piece_shape(ring), ring.radius, local)
			var dir := Vector2.from_angle(ring.rotation + local)
			var half := piece_thickness(ring) * 0.5
			for radius_off in [-half, 0.0, half]:
				var point: Vector2 = ring.position + dir * (boundary + radius_off)
				if PieceGeometry.point_in_obb(point, pose.center, pose.tangent, pose.radial, pose.half_x, pose.half_y, margin):
					return true
	return false

static func _point_on_tube(ring, point: Vector2, margin: float) -> bool:
	return PieceGeometry.point_hits_tube(piece_shape(ring), ring.radius, piece_thickness(ring), ring.rotation, ring.gaps if ring.gaps != null else [], ring.position, point, margin)

static func apply_settled_rotation(piece, target_rotation_deg: float, pieces: Array, links: Array, direction: int = 0) -> Dictionary:
	var result := {
		"applied": false,
		"cleared": [],
		"released": [],
		"won": false,
	}
	if _is_gone(piece):
		return result
	var delta := wrapf(target_rotation_deg - piece.rotation_degrees, -180.0, 180.0)
	if direction != 0:
		if direction > 0 and delta < 0:
			delta += 360.0
		elif direction < 0 and delta > 0:
			delta -= 360.0
	var clamped: Dictionary = clamp_rotation_step(piece, delta, pieces, links)
	var allowed: float = float(clamped.get("allowed_delta", 0.0))
	if bool(clamped.get("hit_stopper", false)) and absf(allowed - delta) > 0.5:
		return result
			
	piece.rotation_degrees = fposmod(piece.rotation_degrees + allowed, 360.0)
	if "current_angle_deg" in piece:
		piece.current_angle_deg = piece.rotation_degrees
	result["applied"] = true
	var clearing: Array = evaluate_clearance(piece, pieces, links)
	for link in clearing:
		complete_clearance(link)
	result["cleared"] = clearing
	result["released"] = resolve_releases(pieces, links)
	result["won"] = is_puzzle_won(pieces, links)
	return result

static func is_piece_near_alignment(piece, all_pieces: Array, links: Array, override_rot_deg: float = NAN) -> bool:
	if _is_gone(piece):
		return false
	var p_id: StringName = piece.piece_id if ("piece_id" in piece and piece.piece_id != null) else (piece.id if "id" in piece else &"")
	for link in links:
		var from_id: StringName = link.def.from_piece_id if ("def" in link and link.def != null) else StringName(link.from_piece_id)
		var to_id: StringName = link.def.to_piece_id if ("def" in link and link.def != null) else StringName(link.to_piece_id)
		var l_state: int = int(link.state) if "state" in link else (ConnectorRuntimeScript.State.DETACHED if ("is_detached" in link and link.is_detached) else ConnectorRuntimeScript.State.ENGAGED)
		if to_id != p_id or l_state != ConnectorRuntimeScript.State.ENGAGED:
			continue
		var contact := cuff_world_angle_deg(piece, link, all_pieces)
		var rot_deg: float = override_rot_deg if not is_nan(override_rot_deg) else (float(piece.rotation_degrees) if "rotation_degrees" in piece else float(piece.rotation_deg))
		var local_deg := fposmod(contact - rot_deg, 360.0)
		var gaps: Array = piece.gaps if "gaps" in piece and piece.gaps != null else []
		for gap in gaps:
			if gap == null: continue
			var center_deg: float = float(gap.get("center_angle_deg", 0.0)) if gap is Dictionary else float(gap.center_angle_deg)
			var width_deg: float = float(gap.get("width_deg", 0.0)) if gap is Dictionary else float(gap.width_deg)
			var dist := absf(wrapf(local_deg - center_deg, -180.0, 180.0))
			if dist <= width_deg * 0.5 + 5.0:
				return true
	return false

static func get_piece_by_id(id: StringName, pieces: Array):
	for piece in pieces:
		if piece != null and is_instance_valid(piece):
			var pid: StringName = piece.piece_id if ("piece_id" in piece and piece.piece_id != null) else (piece.id if "id" in piece else &"")
			if pid == id:
				return piece
	return null

# ==============================================================================
# PURE PUZZLE STATE ACTION-DRIVEN API (Zero Node2D / SceneTree Dependency)
# ==============================================================================

static func apply_action(state, action) -> Dictionary:
	var result := {
		"applied": false,
		"cleared_links": [],
		"released_pieces": [],
		"won": false,
		"next_state": null
	}
	if state == null or action == null:
		return result
		
	var pid: StringName = action.piece_id
	if not state.pieces.has(pid):
		return result
		
	var p: Dictionary = state.pieces[pid]
	if int(p.get("state", 0)) == _RELEASED:
		return result
		
	if not is_pure_piece_rotatable(state, pid):
		return result
		
	var next_state = state.clone()
	var next_p: Dictionary = next_state.pieces[pid]
	
	var start_rot: float = float(next_p.get("rotation_deg", 0.0))
	var target_rot: float = float(action.target_orientation)
	var delta: float = wrapf(target_rot - start_rot, -180.0, 180.0)
	
	if absf(delta) > 0.001:
		if action.direction == -1 and delta > 0.0:
			delta -= 360.0
		elif action.direction == 1 and delta < 0.0:
			delta += 360.0
	else:
		delta = 0.0
		
	next_p["rotation_deg"] = fposmod(start_rot + delta, 360.0)
	next_state.move_count += 1
	
	# Evaluate clearances & cascades
	var cleared: Array = evaluate_pure_clearance(next_state, pid)
	for cid in cleared:
		next_state.connectors[cid]["state"] = 2 # DETACHED
		
	var released: Array = resolve_pure_releases(next_state)
	var won: bool = is_pure_state_won(next_state)
	
	if won:
		next_state.status = &"WON"
		
	result["applied"] = true
	result["cleared_links"] = cleared
	result["released_pieces"] = released
	result["won"] = won
	result["next_state"] = next_state
	return result

static func is_pure_piece_rotatable(state, pid: StringName) -> bool:
	if not state.pieces.has(pid):
		return false
	var p: Dictionary = state.pieces[pid]
	if int(p.get("state", 0)) == _RELEASED:
		return false
		
	# A piece cannot rotate if any outgoing child link is in CLEARING state
	for cid in state.connectors.keys():
		var conn: Dictionary = state.connectors[cid]
		var from_id: StringName = StringName(conn.get("from_piece_id", &""))
		var to_id: StringName = StringName(conn.get("to_piece_id", &""))
		var c_st: int = int(conn.get("state", 0))
		
		if to_id == pid and c_st == 1: # CLEARING
			return false
		if from_id == pid and c_st != 2: # ENGAGED
			var child: Dictionary = state.pieces.get(to_id, {})
			if int(child.get("state", 0)) != _RELEASED:
				return false
	return true

static func is_pure_piece_releasable(state, pid: StringName) -> bool:
	if not state.pieces.has(pid):
		return false
	var p: Dictionary = state.pieces[pid]
	if int(p.get("state", 0)) == _RELEASED:
		return false
		
	# 1. Outgoing child constraints: piece cannot release if any attached child is not gone
	for cid in state.connectors.keys():
		var conn: Dictionary = state.connectors[cid]
		var from_id: StringName = StringName(conn.get("from_piece_id", &""))
		var to_id: StringName = StringName(conn.get("to_piece_id", &""))
		var c_st: int = int(conn.get("state", 0))
		
		if from_id == pid and c_st != 2:
			var child: Dictionary = state.pieces.get(to_id, {})
			if int(child.get("state", 0)) != _RELEASED:
				return false

	# 2. Incoming parent constraints: open rings require all incoming links to be DETACHED
	for cid in state.connectors.keys():
			var conn: Dictionary = state.connectors[cid]
			var to_id: StringName = StringName(conn.get("to_piece_id", &""))
			var c_st: int = int(conn.get("state", 0))
			
			if to_id == pid and c_st != 2:
				return false

	return true

static func evaluate_pure_clearance(state, pid: StringName) -> Array:
	var cleared: Array = []
	if not state.pieces.has(pid):
		return cleared
	var child: Dictionary = state.pieces[pid]
	var gaps: Array = child.get("gaps", [])
	if gaps.is_empty():
		return cleared
		
	var shape: int = int(child.get("shape_type", 0))
	var radius: float = float(child.get("radius", 68.0))
	var thick: float = float(child.get("thickness", 24.0))
	var rot_deg: float = float(child.get("rotation_deg", 0.0))
	var child_pos: Vector2 = child.get("position", Vector2.ZERO)
	
	for cid in state.connectors.keys():
		var conn: Dictionary = state.connectors[cid]
		if StringName(conn.get("to_piece_id", &"")) != pid:
			continue
		if int(conn.get("state", 0)) != 0: # Must be ENGAGED
			continue
			
		var parent_id: StringName = StringName(conn.get("from_piece_id", &""))
		var parent: Dictionary = state.pieces.get(parent_id, {})
		if parent.is_empty() or int(parent.get("state", 0)) == _RELEASED:
			continue
			
		var collar_deg: float = float(conn.get("collar_angle_deg", 0.0))
		var stem_dist: float = float(conn.get("stem_dist", 0.0))
		var parent_rot: float = float(parent.get("rotation_deg", 0.0))
		var parent_pos: Vector2 = parent.get("position", Vector2.ZERO)
		
		var world_rad: float = deg_to_rad(parent_rot + collar_deg)
		var dir := Vector2.from_angle(world_rad)
		var child_r: float = PieceGeometry.get_world_boundary_distance(shape, radius, deg_to_rad(rot_deg), dir.angle() + PI)
		var pos_cuff: Vector2 = parent_pos + dir * (stem_dist - child_r)
		var rel: Vector2 = pos_cuff - child_pos
		if rel.length_squared() < 0.0001:
			continue
			
		var contact_world := fposmod(rad_to_deg(rel.angle()), 360.0)
		var local_deg := fposmod(contact_world - rot_deg, 360.0)
		var contact_s := PieceGeometry.angle_to_s(local_deg)
		var perim := PieceGeometry.contour_length(shape, radius)
		var cuff_w := ConnectorRuntimeScript.TANGENTIAL_WIDTH
		var margin := ConnectorRuntimeScript.SAFETY_MARGIN
		
		for gap in gaps:
			var width_deg := float(gap.get("width_deg", 0.0))
			var center_deg := float(gap.get("center_angle_deg", 0.0))
			var opening := PieceGeometry.usable_opening_length(shape, radius, width_deg, thick)
			# Margin-padded opening check so larger sleeves still fit comfortably.
			if not PieceGeometry.opening_accepts_cuff(opening + margin, cuff_w, margin):
				continue
			var interval := PieceGeometry.usable_gap_interval_s(shape, radius, thick, center_deg, width_deg)
			if PieceGeometry.cuff_span_inside(interval.x, interval.y, contact_s, cuff_w, perim, margin):
				cleared.append(cid)
				break
	return cleared

static func resolve_pure_releases(state) -> Array:
	var released: Array = []
	var changed := true
	while changed:
		changed = false
		for pid in state.pieces.keys():
			var p: Dictionary = state.pieces[pid]
			if int(p.get("state", 0)) == _RELEASED:
				continue
			if not is_pure_piece_releasable(state, pid):
				continue
				
			p["state"] = _RELEASED
			state.released_piece_count += 1
			released.append(pid)
			
			# Detach connectors owned by or holding this piece
			for cid in state.connectors.keys():
				var conn: Dictionary = state.connectors[cid]
				var from_id: StringName = StringName(conn.get("from_piece_id", &""))
				var to_id: StringName = StringName(conn.get("to_piece_id", &""))
				if from_id == pid or to_id == pid:
					conn["state"] = 2 # DETACHED
			changed = true
	return released

static func is_pure_state_won(state) -> bool:
	if state == null or state.pieces.is_empty():
		return false
	for pid in state.pieces.keys():
		if int(state.pieces[pid].get("state", 0)) != _RELEASED:
			return false
	return true

