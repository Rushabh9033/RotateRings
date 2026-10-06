extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var fan = Board._spoke_fan(54.0, Board.C, 0.0, 0, 5, 2, true, 1)
    var flat = []
    var edges = []
    Board._walk(fan, Vector2.ZERO, flat, edges)
    print("Rings: ", flat.size())
    quit()
