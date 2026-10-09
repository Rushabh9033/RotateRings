extends RefCounted
class_name BFSSolver

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")
const PuzzleStateScript = preload("res://gameplay/puzzle_state.gd")
const PuzzleActionScript = preload("res://gameplay/puzzle_action.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")

static func _to_pure_state(input_pieces, input_links = null) -> PuzzleStateScript:
	if input_pieces is PuzzleStateScript:
		return input_pieces.clone()
		
	var state = PuzzleStateScript.new()
	
	if input_pieces is Dictionary:
		for k in input_pieces.keys():
			var item = input_pieces[k]
			if item is Dictionary:
				state.pieces[k] = item.duplicate(true)
		if input_links is Dictionary:
			for k in input_links.keys():
				var item = input_links[k]
				if item is Dictionary:
					state.connectors[k] = item.duplicate(true)
		return state
		
	if input_pieces is Array:
		for p in input_pieces:
			if p == null or not is_instance_valid(p): continue
			var pid: StringName = p.piece_id if "piece_id" in p else StringName(p.id)
			var gaps_data: Array = []
			if p.gaps != null:
				for g in p.gaps:
					if g is Dictionary:
						gaps_data.append(g.duplicate(true))
					else:
						gaps_data.append({
							"center_angle_deg": float(g.center_angle_deg),
							"width_deg": float(g.width_deg),
							"depth": float(g.depth) if "depth" in g else 6.0
						})
			var rot_val := 0.0
			if "rotation_degrees" in p:
				rot_val = float(p.rotation_degrees)
			elif "rotation_deg" in p:
				rot_val = float(p.rotation_deg)
			# Authored rotation always wins over a 0 default — the runtime's
			# load_level() initializes current_angle_deg from start_angle_deg,
			# so a PieceDefinition with no explicit rotation_degrees would
			# otherwise start at 0 in the solver but at start_angle_deg in
			# gameplay, breaking BFS/play parity.
			elif "start_angle_deg" in p:
				rot_val = float(p.start_angle_deg)
				
			var st_val := 0
			if "state" in p:
				st_val = int(p.state)

			var pos_val := Vector2.ZERO
			if "position" in p:
				pos_val = p.position

			state.pieces[pid] = {
				"id": pid,
				"piece_id": pid,
				"position": pos_val,
				"radius": float(p.radius),
				"thickness": float(p.thickness) if "thickness" in p else 24.0,
				"rotation_deg": rot_val,
				"state": st_val,
				"gaps": gaps_data,
				"shape_type": int(p.shape_type) if "shape_type" in p else 0,
				"role": int(p.role) if "role" in p else PuzzleRulesScript.piece_role(p)
			}
			
	if input_links is Array:
		for l in input_links:
			if l == null: continue
			var lid: StringName = l.def.id if ("def" in l and l.def != null) else StringName(l.id)
			var from_id: StringName = l.def.from_piece_id if ("def" in l and l.def != null) else StringName(l.from_piece_id)
			var to_id: StringName = l.def.to_piece_id if ("def" in l and l.def != null) else StringName(l.to_piece_id)
			var collar: float = float(l.def.collar_angle_deg if ("def" in l and l.def != null) else l.collar_angle_deg)
			var dist: float = float(l.def.stem_dist if ("def" in l and l.def != null) else l.stem_dist)
			var link_st := 0
			if "state" in l:
				link_st = int(l.state)
			elif "is_detached" in l and bool(l.is_detached):
				link_st = 2
			state.connectors[lid] = {
				"id": lid,
				"from_piece_id": from_id,
				"to_piece_id": to_id,
				"collar_angle_deg": collar,
				"stem_dist": dist,
				"state": link_st
			}
	return state

static func _calc_incoming_target_rot(piece: Dictionary, parent: Dictionary, conn: Dictionary, gap: Dictionary) -> float:
	var shape: int = int(piece.get("shape_type", 0))
	var radius: float = float(piece.get("radius", 68.0))
	var start_rot: float = float(piece.get("rotation_deg", 0.0))
	var parent_rot: float = float(parent.get("rotation_deg", 0.0))
	var collar_deg: float = float(conn.get("collar_angle_deg", 0.0))
	var stem_dist: float = float(conn.get("stem_dist", 0.0))
	var world_rad: float = deg_to_rad(parent_rot + collar_deg)
	var dir := Vector2.from_angle(world_rad)
	var parent_pos: Vector2 = parent.get("position", Vector2.ZERO)
	var child_pos: Vector2 = piece.get("position", Vector2.ZERO)
	var center_deg: float = float(gap.get("center_angle_deg", 0.0))
	
	var rot_guess: float = start_rot
	for iter in range(3):
		var child_r: float = PieceGeometry.get_world_boundary_distance(shape, radius, deg_to_rad(rot_guess), dir.angle() + PI)
		var pos_cuff: Vector2 = parent_pos + dir * (stem_dist - child_r)
		var rel: Vector2 = pos_cuff - child_pos
		if rel.length_squared() < 0.0001:
			break
		var contact_world := fposmod(rad_to_deg(rel.angle()), 360.0)
		rot_guess = fposmod(contact_world - center_deg, 360.0)
	return rot_guess

static func solve_bfs(input_pieces, input_links = null) -> Dictionary:
	var start_state := _to_pure_state(input_pieces, input_links)
	
	# Initial auto-clearance and release on initial state setup
	var initial_state = start_state.clone()
	PuzzleRulesScript.resolve_pure_releases(initial_state)
	
	if PuzzleRulesScript.is_pure_state_won(initial_state):
		return {
			"solved": true,
			"moves": 0,
			"path": [],
			"visited_states": 1
		}
		
	var start_hash: String = initial_state.get_hash()
	var queue: Array = [{
		"state": initial_state,
		"path": []
	}]
	
	var visited: Dictionary = { start_hash: true }
	var max_steps := 50000
	var step_count := 0
	
	while queue.size() > 0 and step_count < max_steps:
		step_count += 1
		var curr: Dictionary = queue.pop_front()
		var curr_state: PuzzleStateScript = curr["state"]
		var curr_path: Array = curr["path"]
		
		# Check win
		if PuzzleRulesScript.is_pure_state_won(curr_state):
			return {
				"solved": true,
				"moves": curr_state.move_count,
				"path": curr_path,
				"visited_states": visited.size()
			}
			
		# Generate legal candidate moves strictly via pure state
		for pid in curr_state.pieces.keys():
			var piece: Dictionary = curr_state.pieces[pid]
			if int(piece.get("state", 0)) == 6: continue # RELEASED
			if not PuzzleRulesScript.is_pure_piece_rotatable(curr_state, pid): continue
			
			var start_rot: float = float(piece.get("rotation_deg", 0.0))
			var gaps: Array = piece.get("gaps", [])
			var targets: Array[float] = []
			
			# 1. Incoming connectors: target rotations that align piece's gaps with incoming parent cuffs
			for cid in curr_state.connectors.keys():
				var conn: Dictionary = curr_state.connectors[cid]
				if StringName(conn.get("to_piece_id", &"")) == pid and int(conn.get("state", 0)) == 0:
					var parent_id: StringName = StringName(conn.get("from_piece_id", &""))
					var parent: Dictionary = curr_state.pieces.get(parent_id, {})
					if not parent.is_empty() and int(parent.get("state", 0)) != 6:
						for gap in gaps:
							var target_rot := _calc_incoming_target_rot(piece, parent, conn, gap)
							targets.append(target_rot)

			# 2. Outgoing connectors: target rotations that align piece's gaps with outgoing child cuffs
			for cid in curr_state.connectors.keys():
				var conn: Dictionary = curr_state.connectors[cid]
				if StringName(conn.get("from_piece_id", &"")) == pid and int(conn.get("state", 0)) == 0:
					var child_id: StringName = StringName(conn.get("to_piece_id", &""))
					var child: Dictionary = curr_state.pieces.get(child_id, {})
					if not child.is_empty() and int(child.get("state", 0)) != 6:
						var collar_deg: float = float(conn.get("collar_angle_deg", 0.0))
						var world_rad: float = deg_to_rad(start_rot + collar_deg)
						for gap in gaps:
							var target_rot := fposmod(rad_to_deg(world_rad) - float(gap.get("center_angle_deg", 0.0)), 360.0)
							targets.append(target_rot)

			# 3. Fallback snap angles if no alignment targets exist
			if targets.is_empty():
				for snap_deg in [0.0, 90.0, 180.0, 270.0]:
					targets.append(snap_deg)
				
			# Test each unique target rotation
			var tested_targets: Dictionary = {}
			for target_rot in targets:
				var t_clean := fposmod(target_rot, 360.0)
				if tested_targets.has(t_clean): continue
				tested_targets[t_clean] = true
				
				var delta := wrapf(t_clean - start_rot, -180.0, 180.0)
				if absf(delta) < 0.1: continue
				
				var act := PuzzleActionScript.new(pid, start_rot, t_clean, 1 if delta >= 0 else -1)
				var res := PuzzleRulesScript.apply_action(curr_state, act)
				if bool(res.applied) and res.next_state != null:
					var next_st: PuzzleStateScript = res.next_state
					var next_hash: String = next_st.get_hash()
					if not visited.has(next_hash):
						visited[next_hash] = true
						var next_path = curr_path.duplicate()
						next_path.append({
							"piece_id": pid,
							"start_orientation": start_rot,
							"target_orientation": t_clean,
							"target_rot": t_clean,
							"direction": act.direction
						})
						queue.append({
							"state": next_st,
							"path": next_path
						})

	# Either the BFS exhausted max_steps or the queue drained without finding a solution.
	# Warn so hand-design can investigate — the level may have an illegal move or be unsolvable in
	# the approximation the solver searches.
	push_warning("BFS: level not solved after %d steps (visited=%d) — check for unreachable parity"
			% [max_steps, visited.size()])
	return {
		"solved": false,
		"moves": 0,
		"path": [],
		"visited_states": visited.size()
	}

# Hand-design helper: returns the list of legal rotation moves for the current state.
# Each entry: { piece_id, from_rot, to_rot, delta_deg }. Used by tools/test_get_moves.gd etc.
static func _get_moves(pieces: Array, links: Array = []) -> Array:
	var initial: PuzzleStateScript = _to_pure_state(pieces, links)
	if initial == null:
		return []
	var moves: Array = []
	for pid in initial.pieces.keys():
		var p: Dictionary = initial.pieces[pid]
		if int(p.get("state", 0)) == 6: # RELEASED
			continue
		if not PuzzleRulesScript.is_pure_piece_rotatable(initial, pid):
			continue
		var start_rot: float = float(p.get("rotation_deg", 0.0))
		var targets: Array = []
		# Incoming connectors: align gaps with parent cuffs.
		for cid in initial.connectors.keys():
			var conn: Dictionary = initial.connectors[cid]
			if StringName(conn.get("to_piece_id", &"")) == pid and int(conn.get("state", 0)) == 0:
				var parent_id: StringName = StringName(conn.get("from_piece_id", &""))
				var parent: Dictionary = initial.pieces.get(parent_id, {})
				if not parent.is_empty() and int(parent.get("state", 0)) != 6:
					for gap in p.get("gaps", []):
						targets.append(_calc_incoming_target_rot(p, parent, conn, gap))
		# Outgoing connectors: align gaps with outgoing child cuffs.
		for cid in initial.connectors.keys():
			var conn: Dictionary = initial.connectors[cid]
			if StringName(conn.get("from_piece_id", &"")) == pid and int(conn.get("state", 0)) == 0:
				var child_id: StringName = StringName(conn.get("to_piece_id", &""))
				if not initial.pieces.has(child_id):
					continue
				if int(initial.pieces[child_id].get("state", 0)) == 6:
					continue
				var collar_deg: float = float(conn.get("collar_angle_deg", 0.0))
				var world_rad: float = deg_to_rad(start_rot + collar_deg)
				for gap in p.get("gaps", []):
					targets.append(fposmod(rad_to_deg(world_rad) - float(gap.get("center_angle_deg", 0.0)), 360.0))
		# Fallback snap angles.
		if targets.is_empty():
			for snap_deg in [0.0, 90.0, 180.0, 270.0]:
				targets.append(snap_deg)
		var seen: Dictionary = {}
		for t in targets:
			var cleaned: float = fposmod(float(t), 360.0)
			if seen.has(cleaned):
				continue
			seen[cleaned] = true
			var delta := wrapf(cleaned - start_rot, -180.0, 180.0)
			if absf(delta) < 0.1:
				continue
			moves.append({
				"piece_id": pid,
				"from_rot": start_rot,
				"to_rot": cleaned,
				"delta_deg": delta,
			})
	return moves

# Hand-design helper: returns a list of RingPiece2D nodes — converts PieceDefinition
# entries to runtime pieces on demand. Used by debug_level13.gd.
static func _normalize_pieces(pieces: Array) -> Array:
	var out: Array = []
	for p in pieces:
		if p is RingPiece2DScript:
			out.append(p)
		elif p is PieceDefinitionScript:
			var node: RingPiece2DScript = RingPiece2DScript.new()
			node.setup(p)
			out.append(node)
		else:
			out.append(p)
	return out
