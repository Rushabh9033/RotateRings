extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 12 SIMULATION START ===")
	var def = UserLevels.build(12)
	if def == null:
		print("FAIL: could not load level 12 definition")
		quit(1)
		return

	var pieces: Array = []
	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)

	var links: Array = []
	for l_def in def.links:
		var l = ConnectorRuntimeScript.new(l_def)
		links.append(l)

	# 1. Zero initial tube collisions between rings
	for i in range(pieces.size()):
		for j in range(i + 1, pieces.size()):
			var p1 = pieces[i]
			var p2 = pieces[j]
			var is_linked := false
			for link in links:
				if (link.def.from_piece_id == p1.piece_id and link.def.to_piece_id == p2.piece_id) or \
				   (link.def.from_piece_id == p2.piece_id and link.def.to_piece_id == p1.piece_id):
					is_linked = true
					break
			if not is_linked and Rules._tubes_overlap(p1, p2, 0.0):
				print("FAIL: initial tube collision between %s and %s" % [p1.piece_id, p2.piece_id])
				quit(1)
				return

	print("PASS: Zero initial tube collisions between rings!")

	# 2. Check rotatability of all playable pieces
	for p in pieces:
		var rotatable = Rules.is_piece_rotatable(p, pieces, links)
		print("Piece %s: rotatable=%s, role=%d" % [p.piece_id, rotatable, Rules.piece_role(p)])

	# 3. Simulate realistic gameplay playthrough:
	# Step A: Slide out initial clear sliders:
	# red_slider_top slides up-left freely
	var r_slider = Rules.get_piece_by_id(&"red_slider_top", pieces)
	r_slider.position = r_slider.def.position + r_slider.def.motion_axis.normalized() * r_slider.def.slide_max
	assert(Rules.is_piece_releasable(r_slider, pieces, links))
	r_slider.state = RingPiece2DScript.State.RELEASED
	print("Released red_slider_top")

	# orange_slider_tl slides up-right freely once red is cleared
	var o_slider = Rules.get_piece_by_id(&"orange_slider_tl", pieces)
	o_slider.position = o_slider.def.position + o_slider.def.motion_axis.normalized() * o_slider.def.slide_max
	assert(Rules.is_piece_releasable(o_slider, pieces, links))
	o_slider.state = RingPiece2DScript.State.RELEASED
	print("Released orange_slider_tl")

	# blue_slider_mid slides up-right freely
	var b_slider = Rules.get_piece_by_id(&"blue_slider_mid", pieces)
	b_slider.position = b_slider.def.position + b_slider.def.motion_axis.normalized() * b_slider.def.slide_max
	assert(Rules.is_piece_releasable(b_slider, pieces, links))
	b_slider.state = RingPiece2DScript.State.RELEASED
	print("Released blue_slider_mid")

	# Step B: Clear bottom leaves:
	# cyan_bot_left held by green_mid_left
	var c_bl = Rules.get_piece_by_id(&"cyan_bot_left", pieces)
	var l_g_cbl = null
	for l in links:
		if l.def.to_piece_id == &"cyan_bot_left": l_g_cbl = l; break
	var rot_cbl = Rules.alignment_rotation_deg(c_bl, l_g_cbl, pieces, c_bl.gaps[0])
	var res_cbl = Rules.apply_settled_rotation(c_bl, rot_cbl, pieces, links)
	print("Cleared cyan_bot_left: %s, released: %s" % [res_cbl.cleared, res_cbl.released])

	# orange_bot_right held by cyan_mid_right
	var o_br = Rules.get_piece_by_id(&"orange_bot_right", pieces)
	var l_c_obr = null
	for l in links:
		if l.def.to_piece_id == &"orange_bot_right": l_c_obr = l; break
	var rot_obr = 0.0
	for a in range(10, 80, 2):
		var ag = Rules._accepting_gap(o_br, float(a), l_c_obr, pieces)
		var cl = Rules.clamp_rotation_step(o_br, float(a), pieces, links)
		if ag != null and absf(cl.allowed_delta - float(a)) < 0.1:
			print("Found clearance angle for orange_bot_right: %d deg" % [a])
			rot_obr = float(a)
			break
	var res_obr = Rules.apply_settled_rotation(o_br, rot_obr, pieces, links)
	print("Cleared orange_bot_right: %s, released: %s" % [res_obr.cleared, res_obr.released])

	# purple_slider_bot slides rightward into empty space vacated by orange_bot_right
	var p_slider = Rules.get_piece_by_id(&"purple_slider_bot", pieces)
	p_slider.position = p_slider.def.position + p_slider.def.motion_axis.normalized() * p_slider.def.slide_max
	assert(Rules.is_piece_releasable(p_slider, pieces, links))
	p_slider.state = RingPiece2DScript.State.RELEASED
	print("Released purple_slider_bot")

	# Step C: Clear middle pieces:
	# green_mid_left held by cyan_top_left
	var g_ml = Rules.get_piece_by_id(&"green_mid_left", pieces)
	var l_c_gml = null
	for l in links:
		if l.def.to_piece_id == &"green_mid_left": l_c_gml = l; break
	var rot_gml = Rules.alignment_rotation_deg(g_ml, l_c_gml, pieces, g_ml.gaps[0])
	var res_gml = Rules.apply_settled_rotation(g_ml, rot_gml, pieces, links)
	print("Cleared green_mid_left: %s, released: %s" % [res_gml.cleared, res_gml.released])

	# cyan_mid_right held by green_top_right
	var c_mr = Rules.get_piece_by_id(&"cyan_mid_right", pieces)
	var l_g_cmr = null
	for l in links:
		if l.def.to_piece_id == &"cyan_mid_right": l_g_cmr = l; break
	var rot_cmr = Rules.alignment_rotation_deg(c_mr, l_g_cmr, pieces, c_mr.gaps[0])
	var res_cmr = Rules.apply_settled_rotation(c_mr, rot_cmr, pieces, links)
	print("Cleared cyan_mid_right: %s, released: %s" % [res_cmr.cleared, res_cmr.released])
	if l_g_cmr != null:
		l_g_cmr.current_stem_dist = 0.0

	# Step D: Clear green_top_right held by blue_top_mid
	var g_tr = Rules.get_piece_by_id(&"green_top_right", pieces)
	var l_b_gtr = null
	for l in links:
		if l.def.to_piece_id == &"green_top_right": l_b_gtr = l; break
	var rot_gtr = Rules.alignment_rotation_deg(g_tr, l_b_gtr, pieces, g_tr.gaps[0])
	var cl_gtr = Rules.clamp_rotation_step(g_tr, rot_gtr, pieces, links)
	print("g_tr rot_gtr: %s, cl_gtr: %s" % [rot_gtr, cl_gtr])
	var res_gtr = Rules.apply_settled_rotation(g_tr, rot_gtr, pieces, links)
	print("Cleared green_top_right: %s, released: %s" % [res_gtr.cleared, res_gtr.released])

	# Step E: Release remaining root rings if not already released via cascade
	for r_id in [&"cyan_top_left", &"blue_top_mid"]:
		var r = Rules.get_piece_by_id(r_id, pieces)
		if r != null and not Rules._is_gone(r):
			if Rules.is_piece_releasable(r, pieces, links):
				r.state = RingPiece2DScript.State.RELEASED
				print("Released root ring: %s" % [r_id])

	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 12 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 12 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 12 did not report won")
		quit(1)
