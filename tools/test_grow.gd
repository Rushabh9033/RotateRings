extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var extra = Board._grow_count(6)
    print("Grow count for 6: ", extra)
    var root = Board._raw_authored(11)
    var tips = []
    var arrivals = []
    Board._all_tips(root, -90.0, tips, arrivals)
    print("Tips: ", tips.size())
    quit()
