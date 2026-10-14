extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 14 SIMULATION START ===")
	var def = UserLevels.build(14)
	if def == null:
		print("FAIL: could not load level 14 definition")
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

	# Helper to clear a piece's incoming links by rotating to each cuff
	var clear_child = func(child_id: StringName):
		var p = Rules.get_piece_by_id(child_id, pieces)
		if p == null:
			return
		# Find all incoming links to this child
		var incoming: Array = []
		for l in links:
			if l.def.to_piece_id == child_id and l.state == ConnectorRuntimeScript.State.ENGAGED:
				incoming.append(l)
		print("Piece %s has %d incoming links to clear" % [child_id, incoming.size()])
		
		# For each link, find alignment rotation and clear it
		for l in incoming:
			var rot = Rules.alignment_rotation_deg(p, l, pieces, p.gaps[0])
			var res = Rules.apply_settled_rotation(p, rot, pieces, links)
			print("Rotated %s to %f: cleared=%s, released=%s" % [child_id, rot, res.cleared, res.released])
			l.current_stem_dist = 0.0

	# Step 1: Clear purple_r1c0 (held by 4 links)
	clear_child.call(&"purple_r1c0")

	# Step 2: Clear red_r1c2 (held by 4 links)
	clear_child.call(&"red_r1c2")

	# Step 3: Clear cyan_r2c1 (held by 3 links)
	clear_child.call(&"cyan_r2c1")

	# Resolve cascading releases
	var rel1 = Rules.resolve_releases(pieces, links)
	print("Cascaded releases after leaves: %s" % [rel1])

	# Step 4: Clear intermediate rings whose children are now released
	for p_id in [&"blue_r2c0", &"green_r2c2", &"green_r0c1", &"green_r3c0", &"red_r3c2"]:
		clear_child.call(p_id)

	# Final release check
	var rel2 = Rules.resolve_releases(pieces, links)
	print("Final cascaded releases: %s" % [rel2])

	# Check root release
	for r_id in [&"orange_r0c0", &"purple_r0c2", &"cyan_r3c1", &"orange_r1c1"]:
		var r = Rules.get_piece_by_id(r_id, pieces)
		if r != null and not Rules._is_gone(r):
			if Rules.is_piece_releasable(r, pieces, links):
				r.state = RingPiece2DScript.State.RELEASED
				print("Released root ring: %s" % [r_id])

	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 14 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 14 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 14 did not report won")
		quit(1)
