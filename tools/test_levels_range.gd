extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    Board._defer_solve = true
    for lvl in range(1, 11):
        var def = Board.build(lvl)
        print("Level ", lvl, " built successfully with ", def.pieces.size(), " pieces!")
    quit()
