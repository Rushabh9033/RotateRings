extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    Board._defer_solve = true
    for level_id in range(1, 6):
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
        var path = solved.get("path", [])
        print("Level %d: %d moves" % [level_id, path.size()])
    quit()
