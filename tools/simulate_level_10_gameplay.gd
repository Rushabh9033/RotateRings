extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var def = UserLevels.build(10)
	if def == null:
		print("FAIL: could not load level 10 definition")
		quit(1)
		return

	var pieces: Array = []
	var piece_map := {}
	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)
		piece_map[p.piece_id] = p

	var links: Array = []
	for l_def in def.links:
		var l = ConnectorRuntimeScript.new(l_def)
		links.append(l)

	print("=== FULL PLAYTHROUGH SIMULATION OF LEVEL 10 ===")

	# 1. Slide and release all 7 outer sliders
	var sliders_order = [
		"purple_slider_tr", "red_pin_tr", "green_slider_tr",
		"purple_slider_bl", "cyan_pin_bl", "dg_pin_bl", "lg_l_bl"
	]
	for sid in sliders_order:
		var p = piece_map[sid]
		var axis: Vector2 = p.def.motion_axis.normalized()
		var max_dist: float = float(p.def.slide_max)
		var step := Rules.clamp_slide_step(p, axis * max_dist, pieces, links)
		if step.hit_stopper or step.allowed_delta.length() < max_dist - 1.0:
			print("FAIL: slider %s blocked! Allowed: %.1f / %.1f" % [sid, step.allowed_delta.length(), max_dist])
			quit(1)
			return
		p.position += step.allowed_delta
		if not Rules.is_piece_releasable(p, pieces, links):
			print("FAIL: slider %s not releasable after full slide!" % [sid])
			quit(1)
			return
		p.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(p, links)
		print("PASSED: %s slid and released!" % sid)

	# 2. Rotate and release orange_arc_tr
	var o_tr = piece_map["orange_arc_tr"]
	var rot_tr := Rules.clamp_rotation_step(o_tr, -140.0, pieces, links)
	print("orange_arc_tr rotate -140 allowed: %.1f" % rot_tr.allowed_delta)
	o_tr.rotation_degrees += rot_tr.allowed_delta
	var cl_tr := Rules.evaluate_clearance(o_tr, pieces, links)
	print("orange_arc_tr cleared links: ", cl_tr.size())
	for l in cl_tr: Rules.complete_clearance(l)
	if not Rules.is_piece_releasable(o_tr, pieces, links):
		print("FAIL: orange_arc_tr not releasable!")
		quit(1)
		return
	o_tr.state = RingPiece2DScript.State.RELEASED
	Rules.on_piece_released(o_tr, links)
	print("PASSED: orange_arc_tr cleared and released!")

	# 3. Rotate and release orange_arc_bl
	var o_bl = piece_map["orange_arc_bl"]
	var rot_bl := Rules.clamp_rotation_step(o_bl, 140.0, pieces, links)
	print("orange_arc_bl rotate +140 allowed: %.1f" % rot_bl.allowed_delta)
	o_bl.rotation_degrees += rot_bl.allowed_delta
	var cl_bl := Rules.evaluate_clearance(o_bl, pieces, links)
	print("orange_arc_bl cleared links: ", cl_bl.size())
	for l in cl_bl: Rules.complete_clearance(l)
	if not Rules.is_piece_releasable(o_bl, pieces, links):
		print("FAIL: orange_arc_bl not releasable!")
		quit(1)
		return
	o_bl.state = RingPiece2DScript.State.RELEASED
	Rules.on_piece_released(o_bl, links)
	print("PASSED: orange_arc_bl cleared and released!")

	# 4. Slide and release green_pin_inner
	var g_in = piece_map["green_pin_inner"]
	var axis_g: Vector2 = g_in.def.motion_axis.normalized()
	var max_dist_g: float = float(g_in.def.slide_max)
	var step_g := Rules.clamp_slide_step(g_in, axis_g * max_dist_g, pieces, links)
	print("green_pin_inner slide allowed: %.1f / %.1f, hit_stopper: %s" % [step_g.allowed_delta.length(), max_dist_g, step_g.hit_stopper])
	if step_g.hit_stopper or step_g.allowed_delta.length() < max_dist_g - 1.0:
		print("FAIL: green_pin_inner blocked! Allowed: %.1f / %.1f" % [step_g.allowed_delta.length(), max_dist_g])
		quit(1)
		return
	g_in.position += step_g.allowed_delta
	if not Rules.is_piece_releasable(g_in, pieces, links):
		print("FAIL: green_pin_inner not releasable after slide!")
		quit(1)
		return
	g_in.state = RingPiece2DScript.State.RELEASED
	Rules.on_piece_released(g_in, links)
	print("PASSED: green_pin_inner slid and released!")

	# 5. Check cyan_arc_inner release
	var c_in = piece_map["cyan_arc_inner"]
	if not Rules.is_piece_releasable(c_in, pieces, links):
		print("FAIL: cyan_arc_inner not releasable after child released!")
		quit(1)
		return
	c_in.state = RingPiece2DScript.State.RELEASED
	Rules.on_piece_released(c_in, links)
	print("PASSED: cyan_arc_inner released!")

	# 6. Check root anchor cyan_center cascade release
	var released_all = Rules.resolve_releases(pieces, links)
	print("Cascade released count: ", released_all.size())
	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 10 WON: ", won)

	if not won:
		print("FAIL: Level 10 was not won!")
		quit(1)
		return

	print("=== LEVEL 10 COMPLETE PLAYTHROUGH: 100% SUCCESSFUL WIN! ===")
	quit(0)
