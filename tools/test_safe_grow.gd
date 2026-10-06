extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    
    var found = Board._deep_tip(root, Vector2.ZERO)
    var safe_tip = found.node
    var dist = found.pos.length()
    print("Tip dist: %f" % dist)
    
    if dist > 110.0:
        var current_heading = rad_to_deg(found.pos.angle())
        for i in range(5):
            var leaf := Board._leaf(56.0, 120.0)
            safe_tip.kids.append([current_heading + (15.0 if i%2==0 else -15.0), leaf])
            safe_tip = leaf
            
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
        var blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                print("Blocked: ", piece.piece_id)
                blocked = true
        if not blocked:
            print("Clean!")
    else:
        print("No safe tip found!")
    quit()
