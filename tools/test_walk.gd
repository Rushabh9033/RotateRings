extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    for i in range(flat.size()):
        var node = flat[i]
        print("ring_%d: r=%f pos=%s" % [i, node.r, node.pos])
    quit()
