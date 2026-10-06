extends SceneTree
const Band = preload("res://data/band_26_50.gd")
const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
func _init():
    for level_id in [6, 10, 20, 30, 40, 50]:
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
        
        var has_blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                print("L%d Blocked: %s" % [level_id, piece.piece_id])
                has_blocked = true
        if not has_blocked:
            print("L%d Clean!" % level_id)
        for piece in built.pieces: piece.free()
    quit()
