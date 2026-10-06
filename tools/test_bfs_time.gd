extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    Board._defer_solve = true
    var def = Board.build(6)
    var built = Board._spawn(def)
    var t1 = Time.get_ticks_msec()
    BFSSolver.solve_bfs(built.pieces, built.links)
    var t2 = Time.get_ticks_msec()
    print("BFS took ", (t2 - t1), " ms")
    quit()
