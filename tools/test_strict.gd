extends SceneTree
const Board = preload("res://data/campaign_board.gd")

static func _is_flat_clean(flat: Array) -> bool:
    for i in range(flat.size()):
        for j in range(i + 1, flat.size()):
            var a = flat[i]
            var b = flat[j]
            var dist = a.pos.distance_to(b.pos)
            var reach = a.r + b.r + 16.0 + 2.0
            
            # Allow parent-child to overlap!
            var is_link = false
            for kid in a.kids:
                if kid[1].get("pos") == b.pos:
                    is_link = true
            for kid in b.kids:
                if kid[1].get("pos") == a.pos:
                    is_link = true
                    
            if not is_link and dist <= reach:
                return false
    return true

func _init():
    for moves in range(10, 55):
        var found = false
        for salt in range(100):
            var root = Board._closed(76.0, Board.C, [])
            var q = [{"node": root, "heading": 0.0}]
            var num_rings = 1
            
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
            
            if _is_flat_clean(flat):
                found = true
                print("Moves ", moves, " -> Salt ", salt)
                break
                
        if not found:
            print("Moves ", moves, " -> FAILED ALL SALTS")
            
    quit()
