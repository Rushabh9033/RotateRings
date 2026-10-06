extends SceneTree

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
    
    var target_counts = []
    var new_order = []
    
    var current_target = 10
    for i in range(sorted_levels.size()):
        var target = current_target + int(i / 3) # increase by 1 every 3 levels -> 10 to 24
        var base = sorted_levels[i].moves
        var extra = maxi(0, target - base)
        target_counts.append(extra)
        new_order.append(sorted_levels[i].id)
        
    print("var reorder_map: Array[int] = ", new_order)
    print("var grow_counts: Array[int] = ", target_counts)
    quit()
