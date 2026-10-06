extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    Board._defer_solve = true
    var test_cases = [6, 10, 15, 20, 25, 30, 40, 50]
    for level_id in test_cases:
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        var has_blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                has_blocked = true
        if has_blocked:
            print("Level %d COLLIDED" % level_id)
        else:
            var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
            var moves = solved.get("path", []).size()
            print("Level %d takes %d moves" % [level_id, moves])
        for piece in built.pieces: piece.free()
    quit()
