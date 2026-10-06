extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = true
	print("==================================================================================")
	print("RUNNING FULL 100-LEVEL REAL RUNTIME NODE PARITY TEST SUITE")
	print("==================================================================================")
	
	var total_tested := 0
	var total_passed := 0
	var failed_levels: Array[int] = []
	
	for lvl in range(1, 101):
		total_tested += 1
		var def = Board.build(lvl)
		if def == null or def.pieces.is_empty():
			print("[LEVEL %3d] FAILED TO BUILD LEVEL DEFINITION!" % lvl)
			failed_levels.append(lvl)
			continue
			
		# 1. Pure BFS Solver
		var pure_start = BFSSolverScript._to_pure_state(def.pieces, def.links)
		var solve_res = BFSSolverScript.solve_bfs(pure_start)
		
		if not bool(solve_res.solved):
			print("[LEVEL %3d] FAILED: Solver could not find solution!" % lvl)
			failed_levels.append(lvl)
			continue
			
		# 2. Runtime Node Execution
		var built = Board._spawn(def)
		var runtime_pieces: Array = built.pieces
		var runtime_links: Array = built.links
		
		# Resolve initial releases on spawn
		PuzzleRules.resolve_releases(runtime_pieces, runtime_links)
		
		var runtime_ok := true
		var step_count := 0
		
		for step in solve_res.path:
			step_count += 1
			var pid: StringName = StringName(step.piece_id if "piece_id" in step else step["piece_id"])
			var target_rot: float = float(step.target_orientation if "target_orientation" in step else step["target_rot"])
			
			var piece_node = PuzzleRules.get_piece_by_id(pid, runtime_pieces)
			if piece_node == null:
				runtime_ok = false
				break
				
			if not PuzzleRules.is_piece_rotatable(piece_node, runtime_pieces, runtime_links):
				runtime_ok = false
				break
				
			var apply_res = PuzzleRules.apply_settled_rotation(piece_node, target_rot, runtime_pieces, runtime_links)
			if not bool(apply_res.applied):
				runtime_ok = false
				break
				
		var won := PuzzleRules.is_puzzle_won(runtime_pieces, runtime_links)
		Board._free_nodes(runtime_pieces)
		
		if runtime_ok and won:
			total_passed += 1
			print("[%3d/100] Level %3d: PASS | Real Runtime Node Execution Solved & Won | Moves: %2d" % [
				lvl, lvl, solve_res.moves
			])
		else:
			print("[%3d/100] Level %3d: FAIL | Real Runtime Execution Failed (won=%s, ok=%s)" % [lvl, lvl, won, runtime_ok])
			failed_levels.append(lvl)

	print("==================================================================================")
	print("FULL 100-LEVEL RUNTIME NODE PARITY RESULTS: Passed %d / %d Levels" % [total_passed, total_tested])
	if total_passed == total_tested:
		print("STATUS: 100% PERFECT PASS! REAL RUNTIME NODES MATCH SOLVER ON ALL 100 CAMPAIGN LEVELS!")
	else:
		print("STATUS: FAILED LEVELS -> ", failed_levels)
	print("==================================================================================")
	quit()
