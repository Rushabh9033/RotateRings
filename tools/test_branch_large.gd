extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    for moves in [10, 20, 30, 40, 50, 54]:
        var root = Board._closed(76.0, Board.C, [])
        var q = [{"node": root, "heading": 0.0}]
        var num_rings = 1
        var salt = moves * 13
        
        while num_rings < moves:
            var current = q.pop_front()
            var node = current["node"]
            var heading = current["heading"]
            
            var branches = 1
            if (num_rings + salt) % 3 == 0 and num_rings + 1 < moves:
                branches = 2
                node.gaps = 2
            
            for i in range(branches):
                var next_heading = heading + (60.0 if i == 0 else -60.0)
                if branches == 1:
                    next_heading = heading + (30.0 if (num_rings + salt) % 2 == 0 else -30.0)
                    
                var child = Board._leaf(56.0 + float((num_rings + salt) % 3) * 4.0, 120.0 + float((num_rings * 7) % 24))
                node.kids.append([next_heading, child])
                q.append({"node": child, "heading": next_heading})
                num_rings += 1
                if num_rings >= moves:
                    break
                    
        var flat = []
        var edges = []
        Board._walk(root, Vector2.ZERO, flat, edges)
        Board._fit(flat)
        var def = Board.LevelDefinitionScript.new()
        def.level_id = 6
        def.pieces = Board._pieces_from(flat)
        def.links = Board._links_from(flat, edges)
        Board._set_rest_angles(def)
        var built = Board._spawn(def)
        
        var Rules = preload("res://gameplay/puzzle_rules.gd")
        var blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                blocked = true
                break
        
        if not blocked:
            print("Moves ", moves, " -> Clean!")
        else:
            print("Moves ", moves, " -> BLOCKED")
            
        for piece in built.pieces: piece.free()
    quit()
