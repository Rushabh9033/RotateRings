extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")

func _init():
    Board._defer_solve = true
    var log = FileAccess.open("res://_godot_test_out/difficulty.csv", FileAccess.WRITE)
    for level_id in range(6, 16):
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
        var path = solved.get("path", [])
        var moves = path.size()
        print("Level %d: %d moves" % [level_id, moves])
        log.store_line("%d,%d" % [level_id, moves])
        for piece in built.pieces:
            piece.free()
    log.close()
    quit()
