extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    var base_moves = {
        6: 10, 7: 11, 8: 12, 9: 13, 10: 14,
        11: 4, 12: 5, 13: 5, 14: 6, 15: 6,
    }
    for i in range(16, 31): base_moves[i] = 6
    for i in range(31, 41): base_moves[i] = 7
    for i in range(41, 51): base_moves[i] = 8
    
    var sorted_levels = []
    for level_id in base_moves.keys():
        sorted_levels.append({"id": level_id, "moves": base_moves[level_id]})
    
    sorted_levels.sort_custom(func(a, b): return a.moves < b.moves)
    
    var best_20 = []
    for i in range(20):
        best_20.append(sorted_levels[i].id)
        
    for raw_id in best_20:
        var def = Board.LevelDefinitionScript.new()
        var root = Board._raw_authored(raw_id)
        var flat = []
        var edges = []
        Board._walk(root, Vector2.ZERO, flat, edges)
        Board._fit(flat)
        def.pieces = Board._pieces_from(flat)
        def.links = Board._links_from(flat, edges)
        Board._set_rest_angles(def)
        
        var built = Board._spawn(def)
        var has_blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                has_blocked = true
        if has_blocked:
            print("Raw %d has collisions!" % raw_id)
        else:
            print("Raw %d is CLEAN!" % raw_id)
        for piece in built.pieces: piece.free()
    quit()
