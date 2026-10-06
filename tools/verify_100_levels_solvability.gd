extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const PuzzleActionClass = preload("res://gameplay/puzzle_action.gd")

func _init():
	Board._defer_solve = true
	print("==================================================================================")
	print("STARTING FULL 100-LEVEL AUTHORITATIVE SOLVABILITY & REPLAY SUITE")
	print("==================================================================================")
	
	var total_tested := 0
	var total_solved := 0
	var total_replayed := 0
	var failed_levels: Array[int] = []
	var report_rows: Array[String] = []
	
	report_rows.append("# Rotate Rings Campaign 100-Level Verification Report")
	report_rows.append("")
	report_rows.append("Engine Version: Godot 4.7.2.stable.official.ed1daf0bf")
	report_rows.append("Verification Type: Pure Action-Driven BFS Solver & Pure Replay Proof Engine")
	report_rows.append("")
	report_rows.append("| Level ID | Piece Count | Connector Count | Optimal Moves | Path Length | Visited States | Solver Pass | Replay Pass |")
	report_rows.append("| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |")
	
	for lvl in range(1, 101):
		total_tested += 1
		var def = Board.build(lvl)
		if def == null or def.pieces.is_empty():
			print("LEVEL ", lvl, ": FAILED TO BUILD!")
			failed_levels.append(lvl)
			report_rows.append("| %d | 0 | 0 | 0 | 0 | 0 | FAIL | FAIL |" % lvl)
			continue
			
		var pure_start = BFSSolverScript._to_pure_state(def.pieces, def.links)
		var res = BFSSolverScript.solve_bfs(pure_start)
		
		var solver_pass: bool = bool(res.solved)
		var replay_pass := false
		var path_len: int = res.path.size()
		var visited_cnt: int = res.get("visited_states", 0)
		var opt_moves: int = res.get("moves", 0)
		
		if solver_pass:
			total_solved += 1
			# Replay proof check using pure state apply_action
			var fresh_replay_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
			PuzzleRules.resolve_pure_releases(fresh_replay_state)
			var step_ok := true
			
			for step in res.path:
				var act = PuzzleActionClass.from_dict(step)
				var step_res = PuzzleRules.apply_action(fresh_replay_state, act)
				if not bool(step_res.applied):
					step_ok = false
					break
				fresh_replay_state = step_res.next_state
				
			var won := PuzzleRules.is_pure_state_won(fresh_replay_state)
			if step_ok and won:
				replay_pass = true
				total_replayed += 1
				print("[%3d/100] Level %3d: PASS | Pieces: %2d | Links: %2d | Optimal Moves: %2d | Par: %2d | Visited: %d" % [
					lvl, lvl, def.pieces.size(), def.links.size(), opt_moves, def.par_moves, visited_cnt
				])
			else:
				print("[%3d/100] Level %3d: REPLAY FAIL | Solved by BFS but replay failed! (won=%s)" % [lvl, lvl, won])
				failed_levels.append(lvl)
		else:
			print("[%3d/100] Level %3d: UNSOLVED | Solver could not clear board (Nodes searched: %d)" % [
				lvl, lvl, visited_cnt
			])
			failed_levels.append(lvl)
			
		report_rows.append("| %d | %d | %d | %d | %d | %d | %s | %s |" % [
			lvl, def.pieces.size(), def.links.size(), opt_moves, path_len, visited_cnt,
			"PASS" if solver_pass else "FAIL",
			"PASS" if replay_pass else "FAIL"
		])

	print("==================================================================================")
	print("SUMMARY REPORT:")
	print("  Total Tested:   %d / 100" % total_tested)
	print("  Total Solved:   %d / 100" % total_solved)
	print("  Total Replayed: %d / 100" % total_replayed)
	if failed_levels.is_empty():
		print("  STATUS: 100% PERFECT PASS! ALL 100 LEVELS ARE SOLVABLE AND REPLAY-PROVEN!")
	else:
		print("  STATUS: FAILED LEVELS -> ", failed_levels)
	print("==================================================================================")
	
	# Save validation_report.md
	var report_file = FileAccess.open("res://validation_report.md", FileAccess.WRITE)
	if report_file != null:
		report_file.store_string("\n".join(report_rows))
		report_file.close()
		print("Saved validation_report.md successfully.")
		
	quit()
