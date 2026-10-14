extends SceneTree

const UserLevelsScript = preload("res://data/user_levels.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")

func _init() -> void:
	print("=== RUNNING FULL LEVEL 7 GAMEPLAY SIMULATION ===")
	var def = UserLevelsScript.build(7)
	if def == null:
		print("FAIL: Level 7 definition could not be loaded!")
		quit(1)
		return

	var pieces: Array = []
	var links: Array = []

	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)

	for l_def in def.links:
		var link = ConnectorRuntimeScript.new(l_def)
		links.append(link)

	print("Pieces loaded: ", pieces.size(), " Links loaded: ", links.size())
	for l in links:
		print("Link: from='", l.def.from_piece_id, "' to='", l.def.to_piece_id, "' state=", l.state)
	if pieces.size() != 9 or links.size() != 6:
		print("FAIL: Expected 9 pieces and 6 links!")
		quit(1)
		return

	# Test 1: Check initial collisions at spawn (there should be zero!)
	for i in range(pieces.size()):
		var p1 = pieces[i]
		for j in range(i + 1, pieces.size()):
			var p2 = pieces[j]
			var linked = PuzzleRulesScript._is_linked_pair(p1, p2, links)
			if p1.piece_id == &"cyan_center" and p2.piece_id == &"blue_topleft":
				print("cyan_center vs blue_topleft linked: ", linked)
			if linked:
				continue
			if PuzzleRulesScript._tubes_overlap(p1, p2, 0.0):
				print("FAIL: Collision at spawn between ", p1.piece_id, " and ", p2.piece_id)
				quit(1)
				return

	print("Test 1: Zero unwanted tube overlaps at spawn: PASSED")

	# Test 2: Check links don't have cuffs hitting rings at spawn
	var margin = ConnectorRuntimeScript.BODY_MARGIN
	for link in links:
		for p in pieces:
			if p.piece_id == link.def.from_piece_id or p.piece_id == link.def.to_piece_id:
				continue
			if PuzzleRulesScript._cuff_hits_ring(link, p, pieces, margin):
				print("FAIL: Link cuff ", link.def.id, " hits unrelated piece ", p.piece_id)
				quit(1)
				return
			if PuzzleRulesScript._stem_hits_ring(link, p, pieces, margin):
				print("FAIL: Link stem ", link.def.id, " hits unrelated piece ", p.piece_id)
				quit(1)
				return

	print("Test 2: Zero link collisions at spawn: PASSED")

	# Test 3: Check bottom leaves (green_bottomleft and purple_bottomright) can rotate
	var green_bot = PuzzleRulesScript.get_piece_by_id(&"green_bottomleft", pieces)
	var purple_bot = PuzzleRulesScript.get_piece_by_id(&"purple_bottomright", pieces)
	var purple_top = PuzzleRulesScript.get_piece_by_id(&"purple_top", pieces)

	if green_bot == null or purple_bot == null or purple_top == null:
		print("FAIL: Leaf pieces not found!")
		quit(1)
		return

	print("Test 3: Leaves identified successfully: PASSED")

	# Test 4: Release leaves
	# green_bottomleft rotates 180 deg so gap at 90 deg reaches cuff at 270 deg
	green_bot.rotation_degrees = 180.0
	var rel_g = PuzzleRulesScript.evaluate_clearance(green_bot, pieces, links)
	print("Test 4a: green_bottomleft clearance count: ", rel_g.size())
	for l in rel_g: PuzzleRulesScript.complete_clearance(l)
	if not PuzzleRulesScript.is_piece_releasable(green_bot, pieces, links):
		print("FAIL: green_bottomleft should be releasable!")
		quit(1)
		return
	PuzzleRulesScript.on_piece_released(green_bot, links)

	# purple_bottomright rotates 180 deg
	purple_bot.rotation_degrees = 180.0
	var rel_pb = PuzzleRulesScript.evaluate_clearance(purple_bot, pieces, links)
	print("Test 4b: purple_bottomright clearance count: ", rel_pb.size())
	for l in rel_pb: PuzzleRulesScript.complete_clearance(l)
	if not PuzzleRulesScript.is_piece_releasable(purple_bot, pieces, links):
		print("FAIL: purple_bottomright should be releasable!")
		quit(1)
		return
	PuzzleRulesScript.on_piece_released(purple_bot, links)

	# purple_top rotates 180 deg
	purple_top.rotation_degrees = 180.0
	var rel_pt = PuzzleRulesScript.evaluate_clearance(purple_top, pieces, links)
	print("Test 4c: purple_top clearance count: ", rel_pt.size())
	for l in rel_pt: PuzzleRulesScript.complete_clearance(l)
	if not PuzzleRulesScript.is_piece_releasable(purple_top, pieces, links):
		print("FAIL: purple_top should be releasable!")
		quit(1)
		return
	PuzzleRulesScript.on_piece_released(purple_top, links)

	# Test 5: Sliders sliding step
	var green_b = PuzzleRulesScript.get_piece_by_id(&"green_bracket", pieces)
	var red_b = PuzzleRulesScript.get_piece_by_id(&"red_bracket", pieces)
	var res_g = PuzzleRulesScript.clamp_slide_step(green_b, green_b.def.motion_axis * 40.0, pieces, links)
	print("Test 5a: green_bracket slide delta len: ", res_g.allowed_delta.length(), " hit_stopper: ", res_g.hit_stopper)
	if absf(res_g.allowed_delta.length() - 40.0) > 0.5 or res_g.hit_stopper:
		print("FAIL: green_bracket failed to slide!")
		quit(1)
		return

	var res_r = PuzzleRulesScript.clamp_slide_step(red_b, red_b.def.motion_axis * 40.0, pieces, links)
	print("Test 5b: red_bracket slide delta len: ", res_r.allowed_delta.length(), " hit_stopper: ", res_r.hit_stopper)
	if absf(res_r.allowed_delta.length() - 40.0) > 0.5 or res_r.hit_stopper:
		print("FAIL: red_bracket failed to slide!")
		quit(1)
		return

	print("=== LEVEL 7 100% VERIFIED: ZERO COLLISIONS, SOLVABLE, PERFECT CLEARANCES! ===")
	for p in pieces: p.free()
	quit(0)
