extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    print("Building level 6...")
    var def = Board.LevelDefinitionScript.new()
    def.level_id = 6
    var spec = Board._spec(6)
    print("Got spec")
    var root = spec.root
    Board._paint(root, 6 % Board._PALETTE.size(), -1)
    var flat = []
    var edges = []
    Board._walk(root, Vector2.ZERO, flat, edges)
    Board._fit(flat)
    print("Walk and fit done")
    def.pieces = Board._pieces_from(flat)
    def.links = Board._links_from(flat, edges)
    print("Pieces and links created")
    Board._set_rest_angles(def)
    print("Rest angles set")
    Board._stamp_solution(def)
    print("Stamp solution done")
    quit()
