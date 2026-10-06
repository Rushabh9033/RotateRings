extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const PuzzleActionClass = preload("res://gameplay/puzzle_action.gd")

func _init():
	Board._defer_solve = true
	var bad_levels: Array[int] = [23, 36, 57, 58, 72]
	print("==================================================================================")
	print("DEBUGGING REPLAY FAILURES WITH INITIAL AUTO-RELEASE RESOLUTION")
	print("==================================================================================")
	
	for lvl in bad_levels:
		var def = Board.build(lvl)
		var pure_start = BFSSolverScript._to_pure_state(def.pieces, def.links)
		var res = BFSSolverScript.solve_bfs(pure_start)
		print("\n--- LEVEL %d --- Solved: %s | Moves: %d | Visited: %d" % [lvl, res.solved, res.moves, res.get("visited_states", 0)])
		
		var replay_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
		# Resolve initial auto-releases on start state
		PuzzleRules.resolve_pure_releases(replay_state)
		
		var step_idx := 0
		var replay_ok := true
		for step in res.path:
			step_idx += 1
			var act = PuzzleActionClass.from_dict(step)
			var step_res = PuzzleRules.apply_action(replay_state, act)
			print("  Step %d: piece=%s target=%.1f° applied=%s released=%s" % [
				step_idx, act.piece_id, act.target_orientation, step_res.applied, step_res.released_pieces
			])
			if not bool(step_res.applied):
				print("    -> REPLAY FAILED ON STEP %d! Piece %s rotatable=%s" % [
					step_idx, act.piece_id, PuzzleRules.is_pure_piece_rotatable(replay_state, act.piece_id)
				])
				replay_ok = false
				break
			replay_state = step_res.next_state
			
		var won := PuzzleRules.is_pure_state_won(replay_state)
		print("  Final Replay OK: %s | Won: %s" % [replay_ok, won])
		
	quit()
