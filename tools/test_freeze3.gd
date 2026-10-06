extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    print("Building level 6...")
    var def = Board.LevelDefinitionScript.new()
    def.level_id = 6
    var spec = Board._spec(6)
    var root = spec.root
    Board._paint(root, 6 % Board._PALETTE.size(), -1)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    def.pieces = Board._pieces_from(flat)
    def.links = Board._links_from(flat, edges)
    Board._set_rest_angles(def)
    var built = Board._spawn(def)
    print("Calling BFS...")
    BFSSolver.solve_bfs(built.pieces, built.links)
    print("BFS done!")
    quit()
