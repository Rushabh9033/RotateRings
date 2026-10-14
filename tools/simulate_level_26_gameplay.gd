extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 26 SIMULATION START ===")
	var def = UserLevels.build(26)
	if def == null:
		print("FAIL: could not load level 26 definition")
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
				print("FAIL: initial tube collision between %s and %s (shapes %d vs %d)" % [p1.piece_id, p2.piece_id, p1.def.shape_type, p2.def.shape_type])
				quit(1)
				return

	print("PASS: Zero initial tube collisions between pieces!")

	var clear_child = func(child_id: StringName):
		var p = Rules.get_piece_by_id(child_id, pieces)
		if p == null or p.gaps.is_empty():
			return
		var incoming: Array = []
		for l in links:
			if l.def.to_piece_id == child_id and l.state == ConnectorRuntimeScript.State.ENGAGED:
				incoming.append(l)
		for l in incoming:
			var rot = Rules.alignment_rotation_deg(p, l, pieces, p.gaps[0])
			var res = Rules.apply_settled_rotation(p, rot, pieces, links, 1)
			if not res.applied:
				res = Rules.apply_settled_rotation(p, rot, pieces, links, -1)
			if not res.applied:
				var cl1 = Rules.clamp_rotation_step(p, rot - p.rotation_degrees, pieces, links)
				print(child_id, ' FAILED rot to ', rot, ' cl: ', cl1)
			print("Rotated %s to %f: applied=%s cleared=%s, released=%s" % [child_id, rot, res.applied, res.cleared, res.released])
			l.current_stem_dist = 0.0

	var try_release_ring = func(ring_id: StringName):
		var r = Rules.get_piece_by_id(ring_id, pieces)
		if r != null and r.state != RingPiece2DScript.State.RELEASED:
			if Rules.is_piece_releasable(r, pieces, links):
				r.state = RingPiece2DScript.State.RELEASED
				Rules.on_piece_released(r, links)
				print("Released %s!" % [ring_id])

	# Solve outer rings first
	var outer_seq = [
		&"green_top_left", &"blue_tl", &"purple_tr", &"red_tr",
		&"green_ml", &"orange_mr", &"orange_bl", &"purple_mr",
		&"cyan_bl", &"red_br"
	]
	for oid in outer_seq:
		clear_child.call(oid)
		try_release_ring.call(oid)

	# Second pass on any outer rings with multiple links
	for oid in outer_seq:
		clear_child.call(oid)
		try_release_ring.call(oid)

	# Solve inner 6 rings
	var inner_seq = [
		&"orange_in_top", &"purple_in_tr", &"red_in_br",
		&"blue_in_bot", &"green_in_bl", &"purple_in_tl"
	]
	for iid in inner_seq:
		clear_child.call(iid)
		try_release_ring.call(iid)

	# Check root anchor release
	var hub = Rules.get_piece_by_id(&"cyan_hub", pieces)
	if hub != null and Rules.is_piece_releasable(hub, pieces, links):
		hub.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(hub, links)
		print("Released cyan_hub (ROOT ANCHOR)!")

	var all_released := true
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			print("NOT RELEASED: %s (state=%d, role=%d)" % [p.piece_id, p.state, p.def.role])
			all_released = false

	print("IS LEVEL 26 WON: %s" % str(all_released))
	if all_released:
		print("SUCCESS: LEVEL 26 SIMULATION PASSED!")
		quit(0)
	else:
		print("FAIL: Some pieces were not released!")
		quit(1)
