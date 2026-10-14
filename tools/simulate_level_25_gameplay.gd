extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 25 SIMULATION START ===")
	var def = UserLevels.build(25)
	if def == null:
		print("FAIL: could not load level 25 definition")
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
			var delta = wrapf(rot - p.rotation_degrees, -180.0, 180.0)
			var cl = Rules.clamp_rotation_step(p, delta, pieces, links)
			print(child_id, ' delta: ', delta, ' clamp: ', cl)
			var res = Rules.apply_settled_rotation(p, rot, pieces, links, 1)
			if not res.applied:
				res = Rules.apply_settled_rotation(p, rot, pieces, links, -1)
			print("Rotated %s to %f: applied=%s cleared=%s, released=%s" % [child_id, rot, res.applied, res.cleared, res.released])
			l.current_stem_dist = 0.0

	var slide_and_release = func(slider_id: StringName):
		var s = Rules.get_piece_by_id(slider_id, pieces)
		if s != null and s.state != RingPiece2DScript.State.RELEASED:
			var axis: Vector2 = s.def.motion_axis.normalized()
			s.position += axis * float(s.def.slide_max)
			s.state = RingPiece2DScript.State.RELEASED
			Rules.on_piece_released(s, links)
			print("Slid and released %s!" % [slider_id])

	var try_release_ring = func(ring_id: StringName):
		var r = Rules.get_piece_by_id(ring_id, pieces)
		if r != null and r.state != RingPiece2DScript.State.RELEASED:
			if Rules.is_piece_releasable(r, pieces, links):
				r.state = RingPiece2DScript.State.RELEASED
				Rules.on_piece_released(r, links)
				print("Released %s!" % [ring_id])

	# Gameplay execution sequence:
	# 1. Slide free sliders
	slide_and_release.call(&"purple_s1")
	slide_and_release.call(&"blue_s1")
	slide_and_release.call(&"purple_s2")
	slide_and_release.call(&"green_s1")
	slide_and_release.call(&"green_s2")

	# 2. Clear children:
	# purple_r1 held by orange_r1
	clear_child.call(&"purple_r1")
	try_release_ring.call(&"purple_r1")

	# orange_r1 held by cyan_r1
	clear_child.call(&"orange_r1")
	try_release_ring.call(&"orange_r1")
	try_release_ring.call(&"cyan_r1")

	# orange_r2 held by cyan_r2
	clear_child.call(&"orange_r2")
	try_release_ring.call(&"orange_r2")
	try_release_ring.call(&"cyan_r2")

	# orange_r4 held by cyan_r4
	clear_child.call(&"orange_r4")
	try_release_ring.call(&"orange_r4")
	try_release_ring.call(&"cyan_r4")

	# red_r1 held by orange_r3
	clear_child.call(&"red_r1")
	try_release_ring.call(&"red_r1")

	# orange_r3 held by red_r2
	clear_child.call(&"orange_r3")
	try_release_ring.call(&"orange_r3")

	# red_r2 held by cyan_r3
	clear_child.call(&"red_r2")
	try_release_ring.call(&"red_r2")
	try_release_ring.call(&"cyan_r3")

	# blue_r1 held by green_r1
	clear_child.call(&"blue_r1")
	try_release_ring.call(&"blue_r1")

	# green_r2 held by blue_r2
	clear_child.call(&"green_r2")
	try_release_ring.call(&"green_r2")

	# blue_r2 held by green_r1
	clear_child.call(&"blue_r2")
	try_release_ring.call(&"blue_r2")
	try_release_ring.call(&"green_r1")

	var all_released := true
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			print("NOT RELEASED: %s (state=%d, role=%d)" % [p.piece_id, p.state, p.def.role])
			all_released = false

	print("IS LEVEL 25 WON: %s" % str(all_released))
	if all_released:
		print("SUCCESS: LEVEL 25 SIMULATION PASSED!")
		quit(0)
	else:
		print("FAIL: Some pieces were not released!")
		quit(1)
