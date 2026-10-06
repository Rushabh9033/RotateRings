extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Solver = preload("res://tools/bfs_solver.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = true
	print("==========================================")
	print("RUNNING STANDALONE SOLVER REPLAY TEST")
	print("==========================================")
	
	for lvl in range(1, 6):
		var def = Board.build(lvl)
		var built = Board._spawn(def)
		var pieces = built.pieces
		var links = built.links
		
		# Solve level using pure Solver
		var res = Solver.solve_bfs(pieces, links)
		print("Level ", lvl, " Solver Result: solved=", res.solved, " moves=", res.moves, " path=", res.path)
		
		if bool(res.get("solved", false)):
			# Replay optimal solution from scratch to prove 100% correctness
			var replay_built = Board._spawn(def)
			var replay_pieces = replay_built.pieces
			var replay_links = replay_built.links
			
			var direct_clears := 0
			for step in res.path:
				var move = { "piece_id": step.piece_id, "target_rot": step.target_rot }
				var p = Rules.get_piece_by_id(move.piece_id, replay_pieces)
				if p != null:
					var apply_res = Rules.apply_settled_rotation(p, move.target_rot, replay_pieces, replay_links)
					if bool(apply_res.applied):
						direct_clears += 1
						
			var won := Rules.is_puzzle_won(replay_pieces, replay_links)
			print("Level ", lvl, " Replay Proof: won=", won, " (Direct Clears=", direct_clears, ")")
			Board._free_nodes(replay_pieces)
			if not won:
				print("ERROR: Level ", lvl, " replay failed!")
		else:
			print("ERROR: Level ", lvl, " not solved by BFS!")
		Board._free_nodes(pieces)

	print("==========================================")
	quit()
