extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")

func _init():
	Board._defer_solve = true
	var def = Board.build(3)
	var built = Board._spawn(def)
	var pieces = built.pieces
	var links = built.links
	
	print("Level 3 debug info:")
	for p in pieces:
		var rotatable = PuzzleRules.is_piece_rotatable(p, pieces, links)
		print("Piece ", p.piece_id, ": state=", p.state, " rotatable=", rotatable, " rotation=", p.rotation_degrees, " gaps=", p.gaps.size())
		
	for l in links:
		print("Link ", l.def.id, ": from=", l.def.from_piece_id, " to=", l.def.to_piece_id, " state=", l.state)
		
	var r3 = PuzzleRules.get_piece_by_id(&"ring_3", pieces)
	var link0 = links[0]
	var gap = r3.gaps[0]
	var target_rot = PuzzleRules.alignment_rotation_deg(r3, link0, pieces, gap)
	var delta = wrapf(target_rot - r3.rotation_degrees, -180.0, 180.0)
	print("ring_3 target_rot=", target_rot, " delta=", delta)
	var res = PuzzleRules.apply_settled_rotation(r3, target_rot, pieces, links)
	print("apply_settled_rotation result: ", res)
	print("After move: ring_3 state=", r3.state)
	print("After move: ring_2 rotatable=", PuzzleRules.is_piece_rotatable(pieces[2], pieces, links))
	quit()
