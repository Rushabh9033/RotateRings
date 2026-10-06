extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = false
	print("==========================================")
	print("RUNNING SOLVER & REPLAY PROOF TEST")
	print("==========================================")
	
	for lvl in range(1, 5):
		var def = Board.build(lvl)
		var pieces = def.pieces
		var links = def.links
		
		# Solve level
		var res = BFSSolverScript.solve_bfs(pieces, links)
		print("Level ", lvl, " Solver Result: solved=", res.solved, " moves=", res.moves, " path=", res.path)
		
		if bool(res.solved):
			# Replay optimal solution from scratch to prove 100% correctness
			var replay_pieces = def.pieces.duplicate(true)
			var replay_links = def.links.duplicate(true)
			
			var direct_clears := 0
			for step in res.path:
				var move = { "piece_id": step.piece_id, "target_rot": step.target_rot }
				var p = PuzzleRules.get_piece_by_id(move.piece_id, replay_pieces)
				if p != null:
					var apply_res = PuzzleRules.apply_settled_rotation(p, move.target_rot, replay_pieces, replay_links)
					if bool(apply_res.applied):
						direct_clears += 1
						
			var won := PuzzleRules.is_puzzle_won(replay_pieces, replay_links)
			print("Level ", lvl, " Replay Proof: won=", won, " (Direct Clears=", direct_clears, ")")
			if not won:
				print("ERROR: Level ", lvl, " replay failed!")
		else:
			print("ERROR: Level ", lvl, " not solved by BFS!")

	print("==========================================")
	quit()
