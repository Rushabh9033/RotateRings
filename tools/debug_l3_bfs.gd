extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const Solver = preload("res://tools/bfs_solver.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(3)
	var built = Board._spawn(def)
	var pieces = built.pieces
	var links = built.links
	
	print("Step 0: Initial Level 3 state:")
	for p in pieces:
		print("  ", p.piece_id, ": rotatable=", PuzzleRules.is_piece_rotatable(p, pieces, links), " rotation=", p.rotation_degrees)
		
	# Apply move 1: rotate ring_3 to 240
	var r3 = PuzzleRules.get_piece_by_id(&"ring_3", pieces)
	var res1 = PuzzleRules.apply_settled_rotation(r3, 240.0, pieces, links)
	print("Move 1 applied: released=", res1.released)
	print("Step 1: State after move 1:")
	for p in pieces:
		print("  ", p.piece_id, ": state=", p.state, " rotatable=", PuzzleRules.is_piece_rotatable(p, pieces, links), " rotation=", p.rotation_degrees)
	for l in links:
		print("  Link ", l.def.id, " state=", l.state)
		
	# Apply move 2: rotate ring_2 to its alignment angle
	var r2 = PuzzleRules.get_piece_by_id(&"ring_2", pieces)
	var link1 = links[1]
	var cuff_angle = PuzzleRules.cuff_world_angle_deg(r2, link1, pieces)
	print("ring_2 cuff_world_angle_deg=", cuff_angle)
	var target_rot2 = PuzzleRules.alignment_rotation_deg(r2, link1, pieces, r2.gaps[0])
	print("Move 2: ring_2 target_rot2=", target_rot2)
	var delta2 = wrapf(target_rot2 - r2.rotation_degrees, -180.0, 180.0)
	var clamped2 = PuzzleRules.clamp_rotation_step(r2, delta2, pieces, links)
	print("Move 2 delta2=", delta2, " clamped2=", clamped2)
	var res2 = PuzzleRules.apply_settled_rotation(r2, target_rot2, pieces, links)
	print("Move 2 applied: released=", res2.released)
	print("Step 2: State after move 2:")
	for p in pieces:
		print("  ", p.piece_id, ": state=", p.state, " rotatable=", PuzzleRules.is_piece_rotatable(p, pieces, links), " rotation=", p.rotation_degrees)
	for l in links:
		print("  Link ", l.def.id, " state=", l.state)

	quit()
