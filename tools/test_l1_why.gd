extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    Board._defer_solve = true
    var def = Board.build(1)
    var built = Board._spawn(def)
    for piece in built.pieces:
        var contact = Rules._overlap_contact(piece, built.pieces, built.links)
        if contact.blocking:
            print(piece.piece_id, " blocked by ", contact)
    quit()
