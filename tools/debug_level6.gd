extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(6)
	var built = Board._spawn(def)
	print("TESTING LEVEL 6 SOLVER WITH UPDATED CLOSED HUB RULE:")
	var res = BFSSolverScript.solve_bfs(built.pieces, built.links)
	print("Level 6 Solver Result: solved=", res.solved, " moves=", res.get("moves", -1), " visited=", res.get("visited_states", 0))
	if res.solved:
		print("Path: ", res.path)
	Board._free_nodes(built.pieces)
	quit()
