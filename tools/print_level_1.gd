extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var def = Board.build(1)
    for piece in def.pieces:
        print(piece.id, " r=", piece.radius, " thick=", piece.thickness, " pos=", piece.position)
    for link in def.links:
        print(link.from_piece_id, " to ", link.to_piece_id, " stem_dist=", link.stem_dist)
    quit()
