extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")

func _init():
    Board._defer_solve = true
    
    # Sort levels 6-50 by their base moves
    var base_moves = {}
    for level_id in range(6, 51):
        var root = Board._authored(level_id)
        var flat = []
        var edges = []
        Board._walk(root, Vector2.ZERO, flat, edges)
        Board._fit(flat)
        var def = Board.LevelDefinitionScript.new()
        def.level_id = level_id
        def.pieces = Board._pieces_from(flat)
        def.links = Board._links_from(flat, edges)
        Board._set_rest_angles(def)
        var built = Board._spawn(def)
        var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
        base_moves[level_id] = solved.get("path", []).size()
        for piece in built.pieces: piece.free()
        print("L%d: base %d" % [level_id, base_moves[level_id]])
    
    var sorted_levels = []
    for level_id in base_moves.keys():
        sorted_levels.append({"id": level_id, "moves": base_moves[level_id]})
    
    sorted_levels.sort_custom(func(a, b): return a.moves < b.moves)
    
    # Now we have sorted_levels from 4 moves to 14 moves.
    # We want to scale them from 10 moves (for new level 6) to roughly 20 moves (for new level 50).
    var target_counts = []
    var new_order = []
    
    var current_target = 10
    for i in range(sorted_levels.size()):
        var target = current_target + int(i / 5) # increase by 1 every 5 levels -> 10 to 18
        var base = sorted_levels[i].moves
        var extra = maxi(0, target - base)
        target_counts.append(extra)
        new_order.append(sorted_levels[i].id)
        
    print("var reorder_map: Array[int] = ", new_order)
    print("var grow_counts: Array[int] = ", target_counts)
    quit()
