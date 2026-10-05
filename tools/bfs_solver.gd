extends RefCounted
const DEBUG = false

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")
const PuzzleStateScript = preload("res://gameplay/puzzle_state.gd")

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
		n.shape_type = p.shape_type
		n.thickness = p.thickness
		n.role = p.role
		n.def = p.def
		if "target_exit_angle_deg" in p:
			n.set("target_exit_angle_deg", p.get("target_exit_angle_deg"))
		if p.has_meta("release_reason"):
			n.set_meta("release_reason", p.get_meta("release_reason"))
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
	
	var board := PuzzleStateScript.new(new_p, new_l)
	return { "pieces": board.pieces, "links": board.links, "board": board }

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
			for gap in p.gaps:
				var target_rot: float = PuzzleRulesScript.alignment_rotation_deg(p, link, pieces, gap)
				if not PuzzleRulesScript.connector_fits(p, target_rot, link, pieces):
					continue
				var delta := wrapf(target_rot - p.rotation_degrees, -180.0, 180.0)
				var clamped: Dictionary = PuzzleRulesScript.clamp_rotation_step(p, delta, pieces, links)
				if bool(clamped.get("hit_stopper", false)):
					continue
				if absf(float(clamped["allowed_delta"]) - delta) > 0.5:
					continue
				moves.append({
					"piece_id": p.piece_id,
					"target_rot": target_rot,
				})
	return moves

static func _apply_move(state: Dictionary, move: Dictionary) -> int:
	var p = PuzzleRulesScript.get_piece_by_id(move.piece_id, state.pieces)
	var result: Dictionary = PuzzleRulesScript.apply_settled_rotation(p, move.target_rot, state.pieces, state.links)
	if not bool(result["applied"]):
		return 0
	return int(result["released"].size())

static func solve_bfs(start_pieces: Array, start_links: Array) -> Dictionary:
	var initial_releases = PuzzleRulesScript.resolve_releases(start_pieces, start_links).size()
	var start_id = _get_state_id(start_pieces, start_links)
	if start_pieces.filter(func(p): return p.state != RingPiece2DScript.State.RELEASED).is_empty():
		return { "solved": true, "moves": 0, "direct_releases": 0, "cascade_releases": initial_releases, "max_cascade": initial_releases }
		
	var start_board := PuzzleStateScript.new(start_pieces, start_links)
	var queue = [{ "pieces": start_board.pieces, "links": start_board.links, "board": start_board, "moves": 0, "direct_releases": 0, "cascade_releases": initial_releases, "max_cascade": initial_releases }]
	var visited = { start_id: true }
	
	while queue.size() > 0:
		var curr = queue.pop_front()
		if PuzzleRulesScript.is_puzzle_won(curr.pieces, curr.links):
			return { "solved": true, "moves": curr.moves, "direct_releases": curr.direct_releases, "cascade_releases": curr.cascade_releases, "max_cascade": curr.max_cascade }
			
		var moves = _get_moves(curr.pieces, curr.links)
		for m in moves:
			var next_state = _clone_state(curr.pieces, curr.links)
			var released_now = _apply_move(next_state, m)
			
			var direct = 0
			var cascade = 0
			if released_now > 0:
				direct = 1
				cascade = released_now - 1
			
			var new_max_cascade = curr.max_cascade
			if cascade > new_max_cascade:
				new_max_cascade = cascade
				
			var n_id = _get_state_id(next_state.pieces, next_state.links)
			if not visited.has(n_id):
				visited[n_id] = true
				next_state["moves"] = curr.moves + 1
				next_state["direct_releases"] = curr.direct_releases + direct
				next_state["cascade_releases"] = curr.cascade_releases + cascade
				next_state["max_cascade"] = new_max_cascade
				queue.append(next_state)
				
	return { "solved": false, "moves": 0 }
