extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(11)
	var built = Board._spawn(def)
	
	print("BFS TRAVERSAL FOR LEVEL 11:")
	var pieces = built.pieces
	var links = built.links
	
	var res = BFSSolverScript.solve_bfs(pieces, links)
	print("Level 11 res: ", res)
	
	Board._free_nodes(built.pieces)
	quit()
