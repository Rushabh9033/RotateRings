extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    var def = Board.build(1)
    var built = Board._spawn(def)
    for piece in built.pieces:
        for other in built.pieces:
            if piece == other: continue
            var overlap = Rules._tubes_overlap(piece, other, 2.0)
            if overlap:
                print(piece.piece_id, " overlaps ", other.piece_id)
                var reach = piece.radius + other.radius + 16.0 + 2.0
                print("Dist: ", piece.position.distance_to(other.position), " Reach: ", reach)
    quit()
