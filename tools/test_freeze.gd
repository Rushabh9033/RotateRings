extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    print("Building level 1...")
    Board.build(1)
    print("Building level 6...")
    Board.build(6)
    print("Building level 10...")
    Board.build(10)
    print("Done!")
    quit()
