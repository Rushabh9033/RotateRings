extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    Board._defer_solve = true
    for level_id in [6, 10, 20, 30, 40, 50]:
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        var has_blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                has_blocked = true
                print("L%d Piece %s blocked at start!" % [level_id, piece.piece_id])
        if not has_blocked:
            var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
            var moves = solved.get("path", []).size()
            print("Level %d has no collisions and takes %d moves" % [level_id, moves])
        for piece in built.pieces: piece.free()
    quit()
