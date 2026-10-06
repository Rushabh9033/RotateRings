extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    Board._defer_solve = true
    var def = Board.build(6)
    var built = Board._spawn(def)
    print("Pieces: ", built.pieces.size(), " Links: ", built.links.size())
    for p in built.pieces:
        print(p.piece_id, " rot: ", p.rotation_degrees)
    var solved = BFSSolver.solve_bfs(built.pieces, built.links)
    print("Path: ", solved.get("path", []))
    quit()
