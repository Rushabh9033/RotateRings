extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 13 SIMULATION START ===")
	var def = UserLevels.build(13)
	if def == null:
		print("FAIL: could not load level 13 definition")
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

	print("PASS: Zero initial tube collisions between non-linked rings!")

	# 2. Check blocker overlaps
	for p1 in pieces:
		for p2 in pieces:
			if p1 == p2: continue
			if Rules._blockers_hit_ring(p1, p2, 0.0):
				print("FAIL: blocker on %s initially hits %s" % [p1.piece_id, p2.piece_id])
				quit(1)
				return
	print("PASS: Zero initial blocker overlaps!")

	# 3. Check rotatability
	for p in pieces:
		var rotatable = Rules.is_piece_rotatable(p, pieces, links)
		print("Piece %s: rotatable=%s, role=%d" % [p.piece_id, rotatable, Rules.piece_role(p)])

	var find_link = func(fid: StringName, tid: StringName):
		for l in links:
			if l.def.from_piece_id == fid and l.def.to_piece_id == tid:
				return l
		return null

	# Step A: Top chain
	var blue_tl = Rules.get_piece_by_id(&"blue_top_left", pieces)
	var l_gt_bt = find_link.call(&"green_top_mid", &"blue_top_left")
	var rot_bt = Rules.alignment_rotation_deg(blue_tl, l_gt_bt, pieces, blue_tl.gaps[0])
	var res_bt = Rules.apply_settled_rotation(blue_tl, rot_bt, pieces, links)
	print("Cleared blue_top_left: %s, released: %s" % [res_bt.cleared, res_bt.released])

	var green_tm = Rules.get_piece_by_id(&"green_top_mid", pieces)
	var l_rt_gt = find_link.call(&"red_top_right", &"green_top_mid")
	var rot_gt = Rules.alignment_rotation_deg(green_tm, l_rt_gt, pieces, green_tm.gaps[0])
	var res_gt = Rules.apply_settled_rotation(green_tm, rot_gt, pieces, links)
	print("Cleared green_top_mid: %s, released: %s" % [res_gt.cleared, res_gt.released])

	# Step C: Central chain
	# cyan_center is dual-held by green_mid_left and red_lower
	var cyan_c = Rules.get_piece_by_id(&"cyan_center", pieces)
	var l_gm_cc = find_link.call(&"green_mid_left", &"cyan_center")
	var l_rl_cc = find_link.call(&"red_lower", &"cyan_center")

	var rot_cc_gm = Rules.alignment_rotation_deg(cyan_c, l_gm_cc, pieces, cyan_c.gaps[0])
	var res_cc1 = Rules.apply_settled_rotation(cyan_c, rot_cc_gm, pieces, links)
	print("Cleared cyan_center (green cuff): %s" % [res_cc1.cleared])

	var rot_cc_rl = Rules.alignment_rotation_deg(cyan_c, l_rl_cc, pieces, cyan_c.gaps[0])
	var res_cc2 = Rules.apply_settled_rotation(cyan_c, rot_cc_rl, pieces, links)
	print("Cleared cyan_center (red cuff): %s, released: %s" % [res_cc2.cleared, res_cc2.released])

	var red_l = Rules.get_piece_by_id(&"red_lower", pieces)
	var l_gb_rl = find_link.call(&"green_bot_left", &"red_lower")
	var rot_rl = Rules.alignment_rotation_deg(red_l, l_gb_rl, pieces, red_l.gaps[0])
	var res_rl = Rules.apply_settled_rotation(red_l, rot_rl, pieces, links)
	print("Cleared red_lower: %s, released: %s" % [res_rl.cleared, res_rl.released])

	var green_ml = Rules.get_piece_by_id(&"green_mid_left", pieces)
	var l_cm_gm = find_link.call(&"cyan_mid_top", &"green_mid_left")
	var rot_gm = Rules.alignment_rotation_deg(green_ml, l_cm_gm, pieces, green_ml.gaps[0])
	var res_gm = Rules.apply_settled_rotation(green_ml, rot_gm, pieces, links)
	print("Cleared green_mid_left: %s, released: %s" % [res_gm.cleared, res_gm.released])

	var cyan_mt = Rules.get_piece_by_id(&"cyan_mid_top", pieces)
	var l_om_cm = find_link.call(&"orange_mid_right", &"cyan_mid_top")
	var rot_cm = Rules.alignment_rotation_deg(cyan_mt, l_om_cm, pieces, cyan_mt.gaps[0])
	var res_cm = Rules.apply_settled_rotation(cyan_mt, rot_cm, pieces, links)
	print("Cleared cyan_mid_top: %s, released: %s" % [res_cm.cleared, res_cm.released])

	var ora_mr = Rules.get_piece_by_id(&"orange_mid_right", pieces)
	var l_pm_om = find_link.call(&"purple_mid_right", &"orange_mid_right")
	var rot_om = Rules.alignment_rotation_deg(ora_mr, l_pm_om, pieces, ora_mr.gaps[0])
	var res_om = Rules.apply_settled_rotation(ora_mr, rot_om, pieces, links)
	print("Cleared orange_mid_right: %s, released: %s" % [res_om.cleared, res_om.released])

	# Check cascade releases for purple_mid_right
	var pmr = Rules.get_piece_by_id(&"purple_mid_right", pieces)
	if pmr != null and not Rules._is_gone(pmr):
		if Rules.is_piece_releasable(pmr, pieces, links):
			pmr.state = RingPiece2DScript.State.RELEASED
			print("Released piece: purple_mid_right")

	# Now solve orange_lower_mid!
	var ora_lm = Rules.get_piece_by_id(&"orange_lower_mid", pieces)
	var l_pb_ol = find_link.call(&"purple_bot_right", &"orange_lower_mid")
	var rot_ol = Rules.alignment_rotation_deg(ora_lm, l_pb_ol, pieces, ora_lm.gaps[0])
	var res_ol = Rules.apply_settled_rotation(ora_lm, rot_ol, pieces, links, 1)
	print("Cleared orange_lower_mid: %s, released: %s" % [res_ol.cleared, res_ol.released])

	# Check cascade releases for remaining anchors / roots
	for r_id in [&"red_top_right", &"green_bot_left", &"purple_bot_right"]:
		var r = Rules.get_piece_by_id(r_id, pieces)
		if r != null and not Rules._is_gone(r):
			if Rules.is_piece_releasable(r, pieces, links):
				r.state = RingPiece2DScript.State.RELEASED
				print("Released piece: %s" % [r_id])

	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 13 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 13 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 13 did not report won")
		quit(1)
