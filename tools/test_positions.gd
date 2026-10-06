extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    
    for i in range(flat.size()):
        if i == 0 or i == 3:
            print("ring_%d pos: %s" % [i, flat[i].pos])
            
    quit()
