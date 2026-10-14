extends SceneTree
func _init():
    var Board = load("res://data/campaign_board.gd")
    var def = Board.build(1)
    for p in def.pieces:
        print("PIECE: ", p.id, " gaps=", p.gaps.size(), " shape=", p.shape_type)
    for l in def.links:
        print("LINK: ", l.def.from_piece_id, " -> ", l.def.to_piece_id)
    quit()
