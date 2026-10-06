extends SceneTree
const Board = preload("res://data/campaign_board.gd")
func _init():
    var def = Board.build(41) # Level 41 is a spoke fan
    var built = Board._spawn(def)
    
    var Rules = preload("res://gameplay/puzzle_rules.gd")
    var blocked = false
    for piece in built.pieces:
        if Rules.pose_blocked(piece, built.pieces, built.links):
            print("Blocked: ", piece.piece_id)
            blocked = true
    if not blocked:
        print("Clean!")
    quit()
