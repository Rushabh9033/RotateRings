extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    var def = Board.build(6)
    var built = Board._spawn(def)
    var moves = BFSSolver._get_moves(built.pieces, built.links)
    print("Level 6 initial moves: ", moves.size())
    quit()
