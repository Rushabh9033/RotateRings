extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    Board._defer_solve = true
    var def = Board.build(6)
    var built = Board._spawn(def)
    for piece in built.pieces:
        if Rules.pose_blocked(piece, built.pieces, built.links):
            print(piece.piece_id, " is blocked initially!")
    quit()
