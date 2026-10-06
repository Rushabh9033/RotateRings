extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(6)
	print("Level 6 pieces count: ", def.pieces.size())
	print("Level 6 links count: ", def.links.size())
	for i in range(def.pieces.size()):
		var p = def.pieces[i]
		print("Piece ", i, ": id=", p.id, " radius=", p.radius, " start_angle=", p.start_angle_deg, " pos=", p.position)
	for i in range(def.links.size()):
		var l = def.links[i]
		print("Link ", i, ": from=", l.from_piece_id, " to=", l.to_piece_id, " collar_angle=", l.collar_angle_deg, " stem_dist=", l.stem_dist)
	quit()
