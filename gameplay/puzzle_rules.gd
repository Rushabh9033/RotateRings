extends RefCounted
class_name PuzzleRules
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")

# Evaluates whether a piece is currently allowed to rotate
static func is_piece_rotatable(
	piece,
	all_pieces: Array,
	links: Array
) -> bool:
	if not piece or piece.state == 6 or piece.state == 5: # RELEASED or RELEASING
		return false
		
	var p_id: StringName = piece.piece_id
	
	# Parents can rotate, as long as they dont hit anything.
				
	# If any incoming collar is currently clearing/retracting, lock rotation temporarily.
	for link in links:
		if link.def.to_piece_id == p_id and link.state == ConnectorRuntime.State.CLEARING:
			return false
				
	return true

# Evaluates whether a piece is completely free to release/shatter
static func evaluate_clearance(piece, all_pieces: Array, links: Array) -> Array:
	var newly_detached = []
	if not piece or piece.state == 6 or piece.state == 5:
		return newly_detached
		
	var p_id: StringName = piece.piece_id
	
	for link in links:
		if link.def.to_piece_id == p_id and link.state != ConnectorRuntime.State.DETACHED:
			var from_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
			if from_p and from_p.state != 6 and from_p.state != 5:
				var world_angle_rad: float = deg_to_rad(from_p.rotation_degrees + link.def.collar_angle_deg)
				var dir := Vector2.from_angle(world_angle_rad)
				var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
				var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
				var pos_cuff: Vector2 = from_p.position + dir * (link.def.stem_dist - child_r)
				var cuff_rel: Vector2 = pos_cuff - piece.position
				var angle_on_piece_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
				
				var is_aligned = false
				for gap in piece.gaps:
					var gap_world_center := fposmod(piece.rotation_degrees + gap.center_angle_deg, 360.0)
					var dist: float = absf(wrapf(angle_on_piece_deg - gap_world_center, -180.0, 180.0))
					if dist <= link.def.clearance_tolerance_deg:
						is_aligned = true
						break
				
				if is_aligned:
					link.state = ConnectorRuntime.State.CLEARING
					newly_detached.append(link)
					
	return newly_detached

# Evaluates whether rotating to a specific angle would clear any connectors
static func evaluate_clearance_hypothetical(piece, target_rotation_degrees: float, all_pieces: Array, links: Array) -> Array:
	var newly_detached = []
	if not piece or piece.state == 6 or piece.state == 5:
		return newly_detached
		
	var p_id: StringName = piece.piece_id
	
	for link in links:
		if link.def.to_piece_id == p_id and link.state != ConnectorRuntime.State.DETACHED:
			var from_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
			if from_p and from_p.state != 6 and from_p.state != 5:
				var world_angle_rad: float = deg_to_rad(from_p.rotation_degrees + link.def.collar_angle_deg)
				var dir := Vector2.from_angle(world_angle_rad)
				var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
				var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
				var pos_cuff: Vector2 = from_p.position + dir * (link.def.stem_dist - child_r)
				var cuff_rel: Vector2 = pos_cuff - piece.position
				var angle_on_piece_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
				
				var is_cleared := false
				for gap in piece.gaps:
					var gap_world_angle := fposmod(target_rotation_degrees + gap.center_angle_deg, 360.0)
					if abs(angle_difference(deg_to_rad(angle_on_piece_deg), deg_to_rad(gap_world_angle))) <= deg_to_rad(link.def.clearance_tolerance_deg):
						is_cleared = true
						break
				if is_cleared:
					newly_detached.append(link)
					
	return newly_detached

static func is_piece_releasable(piece, all_pieces: Array, links: Array) -> bool:
	if not piece or piece.state == 6 or piece.state == 5:
		return false
		
	var p_id: StringName = piece.piece_id
	
	for link in links:
		if link.def.from_piece_id == p_id and link.state != ConnectorRuntime.State.DETACHED:
			var child_p = get_piece_by_id(link.def.to_piece_id, all_pieces)
			if child_p and child_p.state != 6 and child_p.state != 5:
				return false
				
	for link in links:
		if link.def.to_piece_id == p_id and link.state != ConnectorRuntime.State.DETACHED:
			var from_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
			if from_p and from_p.state != 6 and from_p.state != 5:
				return false
					
	if piece.has_meta("had_children_initially") or piece.has_meta("had_parents_initially"):
		return true
		
	var target_exit: float = float(piece.get("target_exit_angle_deg")) if piece.get("target_exit_angle_deg") != null else 0.0
	return piece.is_angle_in_any_gap(target_exit)

# Evaluates whether a piece is near valid alignment with any incoming collar
static func is_piece_near_alignment(
	piece,
	all_pieces: Array,
	links: Array
) -> bool:
	if not piece or piece.state == 6:
		return false
		
	var p_id: StringName = piece.piece_id
	for link in links:
		if link.def.to_piece_id == p_id and link.state != ConnectorRuntime.State.DETACHED:
			var from_p = get_piece_by_id(link.def.from_piece_id, all_pieces)
			if from_p and from_p.state != 6 and from_p.state != 5:
				var world_angle_rad: float = deg_to_rad(from_p.rotation_degrees + link.def.collar_angle_deg)
				var dir := Vector2.from_angle(world_angle_rad)
				var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
				var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
				var pos_cuff: Vector2 = from_p.position + dir * (link.def.stem_dist - child_r)
				var diff: Vector2 = pos_cuff - piece.position
				var angle_on_piece_deg: float = fposmod(rad_to_deg(diff.angle()), 360.0)
				if piece.is_angle_near_gap(angle_on_piece_deg, 20.0):
					return true
	return false

static func get_piece_by_id(id: StringName, pieces: Array):
	for p in pieces:
		if is_instance_valid(p) and p.piece_id == id:
			return p
	return null

# Evaluates allowed rotation delta and detects connector-to-connector physical collisions.
# Prevents any outgoing stem on piece from rotating through incoming cuffs attached to piece.
static func clamp_rotation_step(
	piece: Node2D,
	step_delta_deg: float,
	all_pieces: Array,
	links: Array
) -> Dictionary:
	if not is_instance_valid(piece) or absf(step_delta_deg) < 0.0001:
		return { "allowed_delta": step_delta_deg, "hit_stopper": false, "contact_point": Vector2.ZERO, "contact_color": Color.WHITE }

	var curr_rot: float = piece.rotation_degrees
	var col_threshold: float = 24.0

	var max_pos_delta: float = 360.0
	var min_neg_delta: float = -360.0
	var pos_limiter_link_out = null
	var pos_limiter_parent = null
	var neg_limiter_link_out = null
	var neg_limiter_parent = null

	# Prevent the parent from rotating if it has an attached stem inside a non-concentric child!
	# The stem is physically trapped in the child's track, so the parent cannot rotate at all.
	for link_out in links:
		if link_out.def.from_piece_id == piece.piece_id and link_out.state != ConnectorRuntime.State.DETACHED:
			var child_p = get_piece_by_id(link_out.def.to_piece_id, all_pieces)
			if is_instance_valid(child_p) and child_p.state != 6 and child_p.state != 5:
				# If not concentric, locked!
				if piece.position.distance_to(child_p.position) > 1.0:
					return { "allowed_delta": 0.0, "hit_stopper": true, "contact_point": piece.global_position, "contact_color": Color.WHITE }


	# Prevent the gap from rotating away from a detached incoming stem (which traps the gap until parent shatters)
	for link_in in links:
		if link_in.def.to_piece_id != piece.piece_id:
			continue
		if link_in.state != ConnectorRuntime.State.DETACHED:
			continue
			
		var parent_p = get_piece_by_id(link_in.def.from_piece_id, all_pieces)
		if not is_instance_valid(parent_p) or parent_p.state == 6 or parent_p.state == 5:
			continue # Parent is gone, stem is gone
			
		var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link_in.def.collar_angle_deg)
		var dir := Vector2.from_angle(world_angle_rad)
		var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
		var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
		var pos_cuff: Vector2 = parent_p.position + dir * (link_in.def.stem_dist - child_r)
		var cuff_rel: Vector2 = pos_cuff - piece.position
		var cuff_angle_world: float = fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
		
		var trapped = false
		for gap in piece.gaps:
			var gap_world = curr_rot + gap.center_angle_deg
			var d_curr = wrapf(gap_world - cuff_angle_world, -180.0, 180.0)
			
			if abs(d_curr) < 45.0: # Stem is inside this gap
				var gap_width = link_in.def.clearance_tolerance_deg
				var dist_pos = gap_width - d_curr
				var dist_neg = -gap_width - d_curr
				if dist_pos < max_pos_delta:
					max_pos_delta = dist_pos
					pos_limiter_link_out = null
					pos_limiter_parent = parent_p
				if dist_neg > min_neg_delta:
					min_neg_delta = dist_neg
					neg_limiter_link_out = null
					neg_limiter_parent = parent_p
				trapped = true
				break



	# Prevent the parent from rotating a detached outgoing stem through a child's solid body.
	# The stem is trapped inside the child's gap until the child shatters or moves away (which it can't).
	for link_out in links:
		if link_out.def.from_piece_id != piece.piece_id:
			continue
		if link_out.state != ConnectorRuntime.State.DETACHED:
			continue
			
		var child_p = get_piece_by_id(link_out.def.to_piece_id, all_pieces)
		if not is_instance_valid(child_p) or child_p.state == 6 or child_p.state == 5:
			continue # Child is gone, stem is free to move
			
		# The stem is currently inside ONE of the child's gaps. We need to clamp the parent's rotation
		# so the stem doesn't leave that gap.
		# When the parent rotates by `delta`, the stem's world position changes.
		# We must restrict `delta` so the stem remains within the child's gap.
		
		# Let's approximate: the stem's world angle relative to the child must be near the child's gap.
		var stem_offset = link_out.def.collar_angle_deg
		var stem_world = curr_rot + stem_offset
		var world_angle_rad: float = deg_to_rad(stem_world)
		var dir := Vector2.from_angle(world_angle_rad)
		var shape_type = child_p.def.shape_type if child_p.get("def") and "shape_type" in child_p.def else 0
		var child_r = PieceGeometry.get_world_boundary_distance(shape_type, child_p.radius, child_p.rotation, dir.angle() + PI)
		var pos_cuff: Vector2 = piece.position + dir * (link_out.def.stem_dist - child_r)
		var cuff_rel: Vector2 = pos_cuff - child_p.position
		var cuff_angle_world: float = fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
		
		# Find the gap the stem is in
		for gap in child_p.gaps:
			var gap_world = child_p.rotation_degrees + gap.center_angle_deg
			var d_curr = wrapf(gap_world - cuff_angle_world, -180.0, 180.0)
			
			if abs(d_curr) < 45.0: # Stem is inside this gap
				# If the parent rotates by delta, cuff_angle_world changes by roughly delta (if concentric).
				# If not concentric, it changes by some amount.
				# To be perfectly accurate, we should test the exact delta, but as a linear approximation, 
				# we can assume the angular change is roughly proportional.
				# Actually, the simplest fix is to just heavily restrict the parent's movement if it's trapped.
				# A trapped stem shouldn't move much at all. Let's just lock it to the gap's tolerance.
				var gap_width = link_out.def.clearance_tolerance_deg
				var dist_pos = gap_width - d_curr
				var dist_neg = -gap_width - d_curr
				if dist_pos < max_pos_delta:
					max_pos_delta = dist_pos
					pos_limiter_link_out = link_out
					pos_limiter_parent = piece
				if dist_neg > min_neg_delta:
					min_neg_delta = dist_neg
					neg_limiter_link_out = link_out
					neg_limiter_parent = piece
				break

	for link_out in links:
		if link_out.def.from_piece_id != piece.piece_id:
			continue
		if link_out.state == ConnectorRuntime.State.DETACHED:
			continue
		var stem_offset: float = link_out.def.collar_angle_deg

		for link_in in links:
			if link_in.def.to_piece_id != piece.piece_id:
				continue
			if link_in.state == ConnectorRuntime.State.DETACHED:
				continue

			var parent_p = get_piece_by_id(link_in.def.from_piece_id, all_pieces)
			if not is_instance_valid(parent_p) or parent_p.state == 6 or parent_p.state == 5:
				continue

			var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link_in.def.collar_angle_deg)
			var dir := Vector2.from_angle(world_angle_rad)
			var shape_type = piece.def.shape_type if piece.get("def") and "shape_type" in piece.def else 0
			var child_r = PieceGeometry.get_world_boundary_distance(shape_type, piece.radius, piece.rotation, dir.angle() + PI)
			var pos_cuff: Vector2 = parent_p.position + dir * (link_in.def.stem_dist - child_r)
			var cuff_rel: Vector2 = pos_cuff - piece.position
			var cuff_angle_world: float = fposmod(rad_to_deg(cuff_rel.angle()), 360.0)

			var stem_world := curr_rot + stem_offset
			var d_curr := wrapf(stem_world - cuff_angle_world, -180.0, 180.0)

			if d_curr > col_threshold:
				var dist_neg := -(d_curr - col_threshold)
				if dist_neg > min_neg_delta:
					min_neg_delta = dist_neg
					neg_limiter_link_out = link_out
					neg_limiter_parent = parent_p
				var dist_pos := (360.0 - d_curr - col_threshold)
				if dist_pos < max_pos_delta:
					max_pos_delta = dist_pos
					pos_limiter_link_out = link_out
					pos_limiter_parent = parent_p
			elif d_curr < -col_threshold:
				var dist_pos := (-col_threshold - d_curr)
				if dist_pos < max_pos_delta:
					max_pos_delta = dist_pos
					pos_limiter_link_out = link_out
					pos_limiter_parent = parent_p
				var dist_neg := -(360.0 + d_curr - col_threshold)
				if dist_neg > min_neg_delta:
					min_neg_delta = dist_neg
					neg_limiter_link_out = link_out
					neg_limiter_parent = parent_p
			else:
				if d_curr >= 0.0:
					if 0.0 > min_neg_delta:
						min_neg_delta = 0.0
						neg_limiter_link_out = link_out
						neg_limiter_parent = parent_p
				else:
					if 0.0 < max_pos_delta:
						max_pos_delta = 0.0
						pos_limiter_link_out = link_out
						pos_limiter_parent = parent_p

	var allowed_delta := step_delta_deg
	var hit_stopper := false
	var hit_contact_point := Vector2.ZERO
	var hit_contact_color := Color(1.0, 0.90, 0.20, 1.0) # Brilliant golden star color

	var active_limiter_link_out = null
	var active_limiter_parent = null

	if step_delta_deg > max_pos_delta:
		allowed_delta = max_pos_delta
		hit_stopper = true
		active_limiter_link_out = pos_limiter_link_out
		active_limiter_parent = pos_limiter_parent
	elif step_delta_deg < min_neg_delta:
		allowed_delta = min_neg_delta
		hit_stopper = true
		active_limiter_link_out = neg_limiter_link_out
		active_limiter_parent = neg_limiter_parent

	if hit_stopper and active_limiter_link_out != null and is_instance_valid(active_limiter_parent):
		var blocked_rot := curr_rot + allowed_delta
		var blocked_stem_angle_rad := deg_to_rad(blocked_rot + active_limiter_link_out.def.collar_angle_deg)
		var stem_dir := Vector2.from_angle(blocked_stem_angle_rad)
		var child_p = get_piece_by_id(active_limiter_link_out.def.to_piece_id, all_pieces)
		var shape_type = child_p.def.shape_type if child_p and child_p.get("def") and "shape_type" in child_p.def else 0
		var c_rot = child_p.rotation if child_p else 0.0
		var child_r: float = PieceGeometry.get_world_boundary_distance(shape_type, child_p.radius if child_p else 76.0, c_rot, stem_dir.angle() + PI)
		var pos_stem_head: Vector2 = piece.position + stem_dir * (active_limiter_link_out.def.stem_dist - child_r)

		var to_head: Vector2 = pos_stem_head - active_limiter_parent.position
		var parent_thickness: float = active_limiter_parent.thickness if "thickness" in active_limiter_parent else 24.0
		var p_shape = active_limiter_parent.def.shape_type if active_limiter_parent.get("def") and "shape_type" in active_limiter_parent.def else 0
		var parent_outer_r: float = PieceGeometry.get_world_boundary_distance(p_shape, active_limiter_parent.radius, active_limiter_parent.rotation, to_head.angle()) + parent_thickness * 0.5
		var contact_on_parent: Vector2 = active_limiter_parent.position + to_head.normalized() * parent_outer_r

		# Exact contact interface between the connector head and the collided ring rim (local space)
		var local_contact_point = (pos_stem_head + contact_on_parent) * 0.5
		if piece.get_parent():
			hit_contact_point = piece.get_parent().to_global(local_contact_point)
		else:
			hit_contact_point = local_contact_point
	elif hit_stopper:
		if piece.is_inside_tree():
			hit_contact_point = piece.global_position
		else:
			hit_contact_point = piece.position

	return {
		"allowed_delta": allowed_delta,
		"hit_stopper": hit_stopper,
		"contact_point": hit_contact_point,
		"contact_color": hit_contact_color
	}
