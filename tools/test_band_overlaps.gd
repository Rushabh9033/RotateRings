extends SceneTree
const Band = preload("res://data/band_26_50.gd")
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    var level_id = 6
    var moves = level_id + 4
    var root = Band._snake(level_id, moves)
    
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    var def = Board.LevelDefinitionScript.new()
    def.level_id = level_id
    def.pieces = Board._pieces_from(flat)
    def.links = Board._links_from(flat, edges)
    Board._set_rest_angles(def)
    var built = Board._spawn(def)
    
    for piece in built.pieces:
        for other in built.pieces:
            if piece != other and Rules._tubes_overlap(piece, other, 2.0):
                print(piece.piece_id, " overlaps ", other.piece_id)
    quit()
