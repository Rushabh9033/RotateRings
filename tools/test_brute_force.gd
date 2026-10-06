extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(25)
    var success_angle = -1.0
    var BFSSolver = preload("res://tools/bfs_solver.gd")
    var Rules = preload("res://gameplay/puzzle_rules.gd")
    
    for a in range(0, 360, 15):
        # We need a fresh copy of the root!
        var current_root = Board._raw_authored(25)
        var current_heading = float(a)
        var tip = current_root
        for i in range(5):
            var leaf := Board._leaf(56.0, 120.0)
            tip.kids.append([current_heading, leaf])
            tip = leaf
            current_heading = float(a) # Straight out
            
        var flat = []
        var edges = []
        Board._walk(current_root, Vector2.ZERO, flat, edges)
        Board._fit(flat)
        var def = Board.LevelDefinitionScript.new()
        def.level_id = 10
        def.pieces = Board._pieces_from(flat)
        def.links = Board._links_from(flat, edges)
        Board._set_rest_angles(def)
        var built = Board._spawn(def)
        
        var blocked = false
        for piece in built.pieces:
            if Rules.pose_blocked(piece, built.pieces, built.links):
                blocked = true
                break
        
        for piece in built.pieces: piece.free()
        
        if not blocked:
            success_angle = float(a)
            break
            
    if success_angle >= 0:
        print("FOUND SAFE ANGLE: ", success_angle)
    else:
        print("NO SAFE ANGLE FOUND!")
    quit()
