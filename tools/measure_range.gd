extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")

func _init():
    Board._defer_solve = true
    var args = OS.get_cmdline_user_args()
    var start = int(args[0])
    var end = int(args[1])
    var log = FileAccess.open("res://_godot_test_out/diff_%d_%d.csv" % [start, end], FileAccess.WRITE)
    for level_id in range(start, end + 1):
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
        var path = solved.get("path", [])
        var moves = path.size()
        print("L%d: %d" % [level_id, moves])
        log.store_line("%d,%d" % [level_id, moves])
        log.flush()
        for piece in built.pieces:
            piece.free()
    log.close()
    quit()
