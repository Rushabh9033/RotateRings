extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    var def = Board.LevelDefinitionScript.new()
    def.level_id = 10
    def.pieces = Board._pieces_from(flat)
    def.links = Board._links_from(flat, edges)
    Board._set_rest_angles(def)
    var built = Board._spawn(def)
    
    var Rules = preload("res://gameplay/puzzle_rules.gd")
    for piece in built.pieces:
        for other in built.pieces:
            if piece != other:
                if Rules._tubes_overlap(piece, other, 2.0):
                    print("CLEAN VER: ", piece.piece_id, " overlaps ", other.piece_id)
    print("ring_0 pos: ", built.pieces[0].position)
    print("ring_3 pos: ", built.pieces[3].position)
    quit()
