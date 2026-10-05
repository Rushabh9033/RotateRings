extends RefCounted

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")

static func _get_state_id(pieces: Array, links: Array) -> String:
	var s = ""
	var p_list: Array = pieces.filter(func(p): return p.state != RingPiece2DScript.State.RELEASED)
	p_list.sort_custom(func(a, b): return a.piece_id < b.piece_id)
	for p in p_list:
		s += p.piece_id + ":" + str(snappedf(fposmod(p.rotation_degrees, 360.0), 1.0)) + "|"
	var l_list: Array = links.filter(func(l): return l.state != ConnectorRuntime.State.DETACHED)
	l_list.sort_custom(func(a, b): return a.def.id < b.def.id)
	for l in l_list:
		s += l.def.id + "|"
	return s

static func _clone_state(pieces: Array, links: Array) -> Dictionary:
	var new_p: Array = []
	for p in pieces:
		var n = RingPiece2DScript.new()
		n.piece_id = p.piece_id
		n.radius = p.radius
		n.thickness = p.thickness
		n.position = p.position
		n.rotation_degrees = p.rotation_degrees
		n.state = p.state
		n.gaps = p.gaps.duplicate(true)
		new_p.append(n)
	
	var new_l: Array = []
	for l in links:
		var def_clone = LinkDefinitionScript.new(l.def.id, l.def.from_piece_id, l.def.to_piece_id, l.def.joint_color)
		def_clone.collar_angle_deg = l.def.collar_angle_deg
		def_clone.stem_dist = l.def.stem_dist
		var nl = ConnectorRuntime.new(def_clone)
		nl.state = l.state
		nl.current_stem_dist = l.current_stem_dist
		new_l.append(nl)
	
	return { "pieces": new_p, "links": new_l }

static func _get_moves(pieces: Array, links: Array) -> Array:
	var moves: Array = []
	for p in pieces:
		if p.state == RingPiece2DScript.State.RELEASED: continue
		if not PuzzleRulesScript.is_piece_rotatable(p, pieces, links): continue
		
		var incoming: Array = []
		for l in links:
			if l.def.to_piece_id == p.piece_id and l.state != ConnectorRuntime.State.DETACHED:
				incoming.append(l)
				
		for link in incoming:
			var parent_p = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, pieces)
			if not parent_p or parent_p.state == RingPiece2DScript.State.RELEASED: continue
			
			var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link.def.collar_angle_deg)
			var dir := Vector2.from_angle(world_angle_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.def.stem_dist - p.radius)
			var cuff_rel: Vector2 = pos_cuff - p.position
			var angle_on_child_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			
			for gap in p.gaps:
				var target_rot = angle_on_child_deg - gap.center_angle_deg
				var target_rot_norm = fposmod(target_rot, 360.0)
				var current_rot_norm = fposmod(p.rotation_degrees, 360.0)
				
				var cw_delta = fposmod(target_rot_norm - current_rot_norm, 360.0)
				var ccw_delta = cw_delta - 360.0
				
				var can_cw = false
				var clamp_cw = PuzzleRulesScript.clamp_rotation_step(p, cw_delta, pieces, links)
				if not clamp_cw.hit_stopper or absf(float(clamp_cw.allowed_delta) - cw_delta) < 0.1:
					can_cw = true
					
				var can_ccw = false
				var clamp_ccw = PuzzleRulesScript.clamp_rotation_step(p, ccw_delta, pieces, links)
				if not clamp_ccw.hit_stopper or absf(float(clamp_ccw.allowed_delta) - ccw_delta) < 0.1:
					can_ccw = true
					
				if can_cw or can_ccw:
					moves.append({
						"piece_id": p.piece_id,
						"target_rot": p.rotation_degrees + (cw_delta if can_cw else ccw_delta),
						"link_to_detach": link.def.id
					})
	return moves

static func _cascade_check(pieces: Array, links: Array) -> void:
	var changed = true
	while changed:
		changed = false
		for p in pieces:
			if p.state == RingPiece2DScript.State.RELEASED: continue
			if PuzzleRulesScript.is_piece_releasable(p, pieces, links):
				p.state = RingPiece2DScript.State.RELEASED
				for l in links:
					if l.def.to_piece_id == p.piece_id:
						l.state = ConnectorRuntime.State.DETACHED
					if l.def.from_piece_id == p.piece_id:
						l.state = ConnectorRuntime.State.DETACHED
				changed = true

static func _apply_move(state: Dictionary, move: Dictionary) -> void:
	var p = PuzzleRulesScript.get_piece_by_id(move.piece_id, state.pieces)
	p.rotation_degrees = move.target_rot
	
	for l in state.links:
		if l.def.id == move.link_to_detach:
			l.state = ConnectorRuntime.State.DETACHED
			break
			
	_cascade_check(state.pieces, state.links)

static func solve_bfs(start_pieces: Array, start_links: Array) -> Dictionary:
	_cascade_check(start_pieces, start_links)
	var start_id = _get_state_id(start_pieces, start_links)
	if start_pieces.filter(func(p): return p.state != RingPiece2DScript.State.RELEASED).is_empty():
		return { "solved": true, "moves": 0 }
		
	var queue = [{ "pieces": start_pieces, "links": start_links, "moves": 0 }]
	var visited = { start_id: true }
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		if curr.pieces.filter(func(p): return p.state != RingPiece2DScript.State.RELEASED).is_empty():
			return { "solved": true, "moves": curr.moves }
			
		var moves = _get_moves(curr.pieces, curr.links)
		for m in moves:
			var next_state = _clone_state(curr.pieces, curr.links)
			_apply_move(next_state, m)
			var n_id = _get_state_id(next_state.pieces, next_state.links)
			if not visited.has(n_id):
				visited[n_id] = true
				next_state["moves"] = curr.moves + 1
				queue.append(next_state)
				
	return { "solved": false, "moves": 0 }
