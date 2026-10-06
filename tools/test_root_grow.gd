extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var root = Board._raw_authored(11) # 4 moves
    
    var leaf = Board._leaf(56.0, 120.0)
    root.kids.append([180.0, leaf]) # Try adding a branch at 180 degrees from root
    
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    var def = Board.LevelDefinitionScript.new()
    def.level_id = 6
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
        var BFSSolver = preload("res://tools/bfs_solver.gd")
        var solved = BFSSolver.solve_bfs(built.pieces, built.links)
        print("Clean! Takes moves: ", solved.get("path", []).size())
    quit()
