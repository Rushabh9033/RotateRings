extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(13)
	print("LEVEL 13 STEP-BY-STEP TRACE:")
	
	var pieces = BFSSolverScript._normalize_pieces(def.pieces)
	
	# Bind links
	var piece_map := {}
	for p in pieces:
		piece_map[p.piece_id] = p
		
	var links: Array = []
	for l in def.links:
		var link_def = l.duplicate()
		var from_p = piece_map.get(link_def.from_piece_id)
		var to_p = piece_map.get(link_def.to_piece_id)
		if from_p != null and to_p != null:
			PuzzleRules.bind_connector(link_def, from_p.position, from_p.rotation_degrees, to_p.position)
		links.append(ConnectorRuntimeScript.new(link_def))
		
	for p in pieces:
		if PuzzleRules.is_piece_rotatable(p, pieces, links):
			print("Rotatable Piece ", p.piece_id, " gaps: ", p.gaps)
			for l in links:
				if l.def.to_piece_id == p.piece_id and l.state != 2:
					for gap in p.gaps:
						var target_rot: float = PuzzleRules.alignment_rotation_deg(p, l, pieces, gap)
						var claims: bool = PuzzleRules.opening_claims_link(p, target_rot, l, pieces, links)
						var delta := wrapf(target_rot - p.rotation_degrees, -180.0, 180.0)
						var clamped: Dictionary = PuzzleRules.clamp_rotation_step(p, delta, pieces, links)
						print("  -> link ", l.def.id, " (from ", l.def.from_piece_id, ") gap center=", gap.center_angle_deg, " => target_rot=", target_rot, " claims=", claims, " hit_stopper=", clamped.get("hit_stopper", false))
						
	quit()
