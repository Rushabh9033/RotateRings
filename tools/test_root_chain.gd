extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    var angles = []
    for kid in root.kids:
        var a = fmod(float(kid[0]) + 360.0, 360.0)
        angles.append(a)
    angles.sort()
    var max_gap = 0.0
    var safe_angle = 0.0
    for i in range(angles.size()):
        var a1 = angles[i]
        var a2 = angles[(i + 1) % angles.size()]
        var gap = a2 - a1
        if gap < 0: gap += 360.0
        if gap > max_gap:
            max_gap = gap
            safe_angle = a1 + gap / 2.0
            
    var current_heading = safe_angle
    var tip = root
    for i in range(5):
        var leaf := Board._leaf(56.0, 120.0)
        tip.kids.append([current_heading, leaf])
        tip = leaf
        current_heading = 0.0
        
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
            if piece != other and not piece.is_queued_for_deletion() and not other.is_queued_for_deletion():
                if Rules._tubes_overlap(piece, other, 2.0):
                    print(piece.piece_id, " overlaps ", other.piece_id)
                    print(piece.piece_id, " pos: ", piece.position, " r: ", piece.radius)
                    print(other.piece_id, " pos: ", other.position, " r: ", other.radius)
    quit()
