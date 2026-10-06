extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    Board._defer_solve = true
    var ok := 0
    for lvl in range(1, 101):
        var def = Board.build(lvl)
        if def != null and def.pieces.size() > 0:
            ok += 1
    print("Successfully built ", ok, " / 100 levels!")
    quit()
