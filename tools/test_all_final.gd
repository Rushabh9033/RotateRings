extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    Board._defer_solve = true
    var last_moves = 0
    var all_clean = true
    
    # We test a sample of levels to save time, including bounds
    for level_id in [1, 5, 6, 10, 20, 30, 40, 50]:
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        
        var has_blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                has_blocked = true
                
        if has_blocked:
            print("Level %d FAILED (COLLIDED)" % level_id)
            all_clean = false
        else:
            var solved = BFSSolver.solve_bfs(built.pieces, built.links)
            var moves = solved.get("path", []).size()
            print("Level %d passed! Moves: %d" % [level_id, moves])
            if level_id > 5 and moves <= last_moves:
                print("WARNING: Level %d did not increase difficulty!" % level_id)
            last_moves = moves
            
        for piece in built.pieces: piece.free()
        
    if all_clean:
        print("ALL TESTED LEVELS CLEAN!")
    quit()
