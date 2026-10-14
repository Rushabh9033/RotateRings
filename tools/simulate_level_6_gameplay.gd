extends SceneTree

const UserLevelsScript = preload("res://data/user_levels.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")

func _init():
	print("=== RUNNING FULL LEVEL 6 GAMEPLAY SIMULATION ===")
	var def = UserLevelsScript.build(6)
	if def == null:
		print("FAIL: Could not load Level 6")
		quit(1)
		return

	var pieces: Array = []
	var links: Array = []

	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)

	for l_def in def.links:
		var l = ConnectorRuntimeScript.new(l_def)
		links.append(l)

	print("Pieces loaded:", pieces.size(), "Links loaded:", links.size())

	# Find orange_l and green_l
	var orange_l = null
	var green_l = null
	for p in pieces:
		if p.piece_id == &"orange_l": orange_l = p
		elif p.piece_id == &"green_l": green_l = p

	assert(orange_l != null and green_l != null, "Missing L pieces")

	# Test 1: Orange L downward drag is blocked
	var axis_o = orange_l.def.motion_axis.normalized()
	var base_o = orange_l.def.position
	var cur_o = (orange_l.position - base_o).dot(axis_o)
	var step_o_down = -40.0
	var clamped_o_down = clampf(cur_o + step_o_down, orange_l.def.slide_min, orange_l.def.slide_max)
	var allowed_o_down = clamped_o_down - cur_o
	print("Test 1: Orange L downward drag allowed step:", allowed_o_down)
	if allowed_o_down < -0.001:
		print("FAIL: Orange L was able to slide downward!")
		quit(1)
		return

	# Test 2: Orange L upward drag slides freely
	var step_o_up = 60.0
	var clamped_o_up = clampf(cur_o + step_o_up, orange_l.def.slide_min, orange_l.def.slide_max)
	var allowed_o_up = clamped_o_up - cur_o
	print("Test 2: Orange L upward drag allowed step:", allowed_o_up)
	if absf(allowed_o_up - 60.0) > 0.001:
		print("FAIL: Orange L failed to slide upward!")
		quit(1)
		return

	# Test 3: Green L backward drag is blocked
	var axis_g = green_l.def.motion_axis.normalized()
	var base_g = green_l.def.position
	var cur_g = (green_l.position - base_g).dot(axis_g)
	var step_g_down = -40.0
	var clamped_g_down = clampf(cur_g + step_g_down, green_l.def.slide_min, green_l.def.slide_max)
	var allowed_g_down = clamped_g_down - cur_g
	print("Test 3: Green L backward drag allowed step:", allowed_g_down)
	if allowed_g_down < -0.001:
		print("FAIL: Green L was able to slide backward!")
		quit(1)
		return

	# Test 4: Green L forward drag slides freely
	var step_g_up = 60.0
	var clamped_g_up = clampf(cur_g + step_g_up, green_l.def.slide_min, green_l.def.slide_max)
	var allowed_g_up = clamped_g_up - cur_g
	print("Test 4: Green L forward drag allowed step:", allowed_g_up)
	if absf(allowed_g_up - 60.0) > 0.001:
		print("FAIL: Green L failed to slide forward!")
		quit(1)
		return

	# Test 4b: Real collision sliding step via clamp_slide_step
	var res_slide_o = PuzzleRulesScript.clamp_slide_step(orange_l, axis_o * 40.0, pieces, links)
	print("Test 4b: Orange L clamp_slide_step allowed_delta length:", res_slide_o.allowed_delta.length(), "hit_stopper:", res_slide_o.hit_stopper)
	if absf(res_slide_o.allowed_delta.length() - 40.0) > 0.5 or res_slide_o.hit_stopper:
		print("FAIL: Orange L was blocked from sliding by clamp_slide_step!")
		quit(1)
		return

	var res_slide_g = PuzzleRulesScript.clamp_slide_step(green_l, axis_g * 40.0, pieces, links)
	print("Test 4c: Green L clamp_slide_step allowed_delta length:", res_slide_g.allowed_delta.length(), "hit_stopper:", res_slide_g.hit_stopper)
	if absf(res_slide_g.allowed_delta.length() - 40.0) > 0.5 or res_slide_g.hit_stopper:
		print("FAIL: Green L was blocked from sliding by clamp_slide_step!")
		quit(1)
		return

	# Test 5: Releasability check
	# At rest (disp = 0.0), neither L piece is releasable
	var rel_o_0 = PuzzleRulesScript.is_piece_releasable(orange_l, pieces, links)
	var rel_g_0 = PuzzleRulesScript.is_piece_releasable(green_l, pieces, links)
	print("Test 5: Orange L at rest releasable:", rel_o_0, "Green L at rest releasable:", rel_g_0)
	if rel_o_0 or rel_g_0:
		print("FAIL: L piece should NOT be releasable before sliding out!")
		quit(1)
		return

	# Move Orange L all the way out
	orange_l.position = base_o + axis_o * orange_l.def.slide_max
	var rel_o_max = PuzzleRulesScript.is_piece_releasable(orange_l, pieces, links)
	print("Test 6: Orange L slid to max releasable:", rel_o_max)
	if not rel_o_max:
		print("FAIL: Orange L should be releasable when slid out!")
		quit(1)
		return

	# Move Green L all the way out
	green_l.position = base_g + axis_g * green_l.def.slide_max
	var rel_g_max = PuzzleRulesScript.is_piece_releasable(green_l, pieces, links)
	print("Test 7: Green L slid to max releasable:", rel_g_max)
	if not rel_g_max:
		print("FAIL: Green L should be releasable when slid out!")
		quit(1)
		return

	print("=== ALL 7 TESTS PASSED SUCCESSFULLY! ===")
	for p in pieces: p.free()
	quit(0)
