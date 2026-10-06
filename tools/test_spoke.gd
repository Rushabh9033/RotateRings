extends SceneTree
const Board = preload("res://data/campaign_board.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
func _init():
    Board._defer_solve = true
    var root = Board._spoke_fan(60.0, Board.O, -8.0, 2, 5, 2)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    var def = Board.LevelDefinitionScript.new()
    def.level_id = 31
    def.pieces = Board._pieces_from(flat)
    def.links = Board._links_from(flat, edges)
    Board._set_rest_angles(def)
    var built = Board._spawn(def)
    var solved: Dictionary = BFSSolver.solve_bfs(built.pieces, built.links)
    var moves = solved.get("path", []).size()
    print("Spoke fan with 5 locks takes ", moves, " moves")
    quit()
