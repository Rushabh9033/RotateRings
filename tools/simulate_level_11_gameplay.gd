extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 11 SIMULATION START ===")
	var def = UserLevels.build(11)
	if def == null:
		print("FAIL: could not load level 11 definition")
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

	# 1. Zero initial tube collisions
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

	# 2. Check initial blocker collisions
	var cyan_bl = Rules.get_piece_by_id(&"cyan_bot_left", pieces)
	var green_br = Rules.get_piece_by_id(&"green_bot_right", pieces)
	var blue_mid = Rules.get_piece_by_id(&"blue_mid", pieces)

	if Rules._blockers_hit_ring(cyan_bl, blue_mid, 0.0):
		print("FAIL: cyan_bot_left blocker initially hits blue_mid!")
		quit(1)
		return
	if Rules._blockers_hit_ring(green_br, blue_mid, 0.0):
		print("FAIL: green_bot_right blocker initially hits blue_mid!")
		quit(1)
		return
	print("PASS: Zero initial blocker overlaps!")

	# 3. Verify blocker actually blocks rotation into blue_mid
	var rot_clamp_c = Rules.clamp_rotation_step(cyan_bl, -60.0, pieces, links)
	print("cyan_bot_left rotation -60 deg: allowed=%.1f deg, hit_stopper=%s" % [rot_clamp_c.allowed_delta, rot_clamp_c.hit_stopper])
	if absf(rot_clamp_c.allowed_delta) >= 55.0:
		print("WARNING: cyan blocker did not collide with blue_mid when rotating -60 deg")

	# 4. Check rotatability of all playable pieces
	for p in pieces:
		var rotatable = Rules.is_piece_rotatable(p, pieces, links)
		print("Piece %s: rotatable=%s, role=%d" % [p.piece_id, rotatable, Rules.piece_role(p)])

	# 5. Full playthrough simulation
	var red = Rules.get_piece_by_id(&"red_left", pieces)
	var green_r = Rules.get_piece_by_id(&"green_right", pieces)
	var orange_tl = Rules.get_piece_by_id(&"orange_top_left", pieces)
	var purple_tr = Rules.get_piece_by_id(&"purple_top_right", pieces)
	var orange_bc = Rules.get_piece_by_id(&"orange_bot_center", pieces)
	var cyan_tc = Rules.get_piece_by_id(&"cyan_top_center", pieces)

	var find_link = func(fid: StringName, tid: StringName):
		for l in links:
			if l.def.from_piece_id == fid and l.def.to_piece_id == tid:
				return l
		return null

	var l_blue_red = find_link.call(&"blue_mid", &"red_left")
	var l_ora_red = find_link.call(&"orange_top_left", &"red_left")
	var l_blue_grn = find_link.call(&"blue_mid", &"green_right")
	var l_pur_grn = find_link.call(&"purple_top_right", &"green_right")

	# Step A: Clear red_left from blue_mid
	var align_rot_blue_red = Rules.alignment_rotation_deg(red, l_blue_red, pieces, red.gaps[0])
	print("Step 1: Rotate red_left to %.1f deg to clear blue_mid link" % [align_rot_blue_red])
	var res1 = Rules.apply_settled_rotation(red, align_rot_blue_red, pieces, links)
	print("  Cleared: %s, Released: %s, state of l_blue_red: %d" % [str(res1.cleared), str(res1.released), l_blue_red.state])

	# Step B: Clear red_left from orange_top_left
	var align_rot_ora_red = Rules.alignment_rotation_deg(red, l_ora_red, pieces, red.gaps[0])
	print("Step 2: Rotate red_left to %.1f deg to clear orange_top_left link" % [align_rot_ora_red])
	var res2 = Rules.apply_settled_rotation(red, align_rot_ora_red, pieces, links)
	print("  Cleared: %s, Released: %s, state of l_ora_red: %d" % [str(res2.cleared), str(res2.released), l_ora_red.state])

	# Step C: Clear green_right from blue_mid
	var align_rot_blue_grn = Rules.alignment_rotation_deg(green_r, l_blue_grn, pieces, green_r.gaps[0])
	print("Step 3: Rotate green_right to %.1f deg to clear blue_mid link" % [align_rot_blue_grn])
	var res3 = Rules.apply_settled_rotation(green_r, align_rot_blue_grn, pieces, links)
	print("  Cleared: %s, Released: %s, state of l_blue_grn: %d" % [str(res3.cleared), str(res3.released), l_blue_grn.state])

	# Step D: Clear green_right from purple_top_right
	var align_rot_pur_grn = Rules.alignment_rotation_deg(green_r, l_pur_grn, pieces, green_r.gaps[0])
	print("Step 4: Rotate green_right to %.1f deg to clear purple_top_right link" % [align_rot_pur_grn])
	var res4 = Rules.apply_settled_rotation(green_r, align_rot_pur_grn, pieces, links)
	print("  Cleared: %s, Released: %s, state of l_pur_grn: %d" % [str(res4.cleared), str(res4.released), l_pur_grn.state])

	# When red and green release, blue_mid is also released via resolve_releases:
	print("Is blue_mid gone: %s (state=%d)" % [Rules._is_gone(blue_mid), blue_mid.state])

	# Step E: Clear cyan_bot_left and green_bot_right from orange_bot_center
	var l_ora_cyan_bl = find_link.call(&"orange_bot_center", &"cyan_bot_left")
	var align_rot_cbl = Rules.alignment_rotation_deg(cyan_bl, l_ora_cyan_bl, pieces, cyan_bl.gaps[0])
	print("Step 5: Rotate cyan_bot_left to %.1f deg" % [align_rot_cbl])
	var res5 = Rules.apply_settled_rotation(cyan_bl, align_rot_cbl, pieces, links)
	print("  Cleared: %s, Released: %s, state: %d" % [str(res5.cleared), str(res5.released), l_ora_cyan_bl.state])

	var l_ora_grn_br = find_link.call(&"orange_bot_center", &"green_bot_right")
	var align_rot_gbr = Rules.alignment_rotation_deg(green_br, l_ora_grn_br, pieces, green_br.gaps[0])
	print("Step 6: Rotate green_bot_right to %.1f deg" % [align_rot_gbr])
	var res6 = Rules.apply_settled_rotation(green_br, align_rot_gbr, pieces, links)
	print("  Cleared: %s, Released: %s, state: %d" % [str(res6.cleared), str(res6.released), l_ora_grn_br.state])

	# Step F: Clear orange_top_left and purple_top_right from cyan_top_center
	var l_cyan_ora_tl = find_link.call(&"cyan_top_center", &"orange_top_left")
	var align_rot_otl = Rules.alignment_rotation_deg(orange_tl, l_cyan_ora_tl, pieces, orange_tl.gaps[0])
	print("Step 7: Rotate orange_top_left to %.1f deg" % [align_rot_otl])
	var res7 = Rules.apply_settled_rotation(orange_tl, align_rot_otl, pieces, links)
	print("  Cleared: %s, Released: %s, state: %d" % [str(res7.cleared), str(res7.released), l_cyan_ora_tl.state])

	var l_cyan_pur_tr = find_link.call(&"cyan_top_center", &"purple_top_right")
	var align_rot_ptr = Rules.alignment_rotation_deg(purple_tr, l_cyan_pur_tr, pieces, purple_tr.gaps[0])
	print("Step 8: Rotate purple_top_right to %.1f deg" % [align_rot_ptr])
	var res8 = Rules.apply_settled_rotation(purple_tr, align_rot_ptr, pieces, links)
	print("  Cleared: %s, Released: %s, state: %d" % [str(res8.cleared), str(res8.released), l_cyan_pur_tr.state])

	# Check victory!
	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 11 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 11 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 11 did not report won")
		quit(1)
