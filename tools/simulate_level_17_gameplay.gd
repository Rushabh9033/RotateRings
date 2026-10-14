extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 17 SIMULATION START ===")
	var def = UserLevels.build(17)
	if def == null:
		print("FAIL: could not load level 17 definition")
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

	print("PASS: Zero initial tube collisions between pieces!")

	var clear_child = func(child_id: StringName, dir: int = 0):
		var p = Rules.get_piece_by_id(child_id, pieces)
		if p == null:
			return
		var incoming: Array = []
		for l in links:
			if l.def.to_piece_id == child_id and l.state == ConnectorRuntimeScript.State.ENGAGED:
				incoming.append(l)
		for l in incoming:
			var rot = Rules.alignment_rotation_deg(p, l, pieces, p.gaps[0])
			var res = Rules.apply_settled_rotation(p, rot, pieces, links, dir)
			print("Rotated %s to %f: cleared=%s, released=%s" % [child_id, rot, res.cleared, res.released])
			l.current_stem_dist = 0.0

	# Step 1: Clear the leaves
	# Top branch:
	clear_child.call(&"green_top")
	clear_child.call(&"orange_r2")
	clear_child.call(&"red_r2")

	# Mid row:
	clear_child.call(&"cyan_mid")
	clear_child.call(&"purple_mid_left")
	clear_child.call(&"orange_mid_right")

	# Bottom left:
	clear_child.call(&"cyan_inner_left")
	# green_bot_left has a blocker preventing clockwise rotation; rotate counter-clockwise (-1):
	clear_child.call(&"green_bot_left", -1)

	# Bottom right:
	clear_child.call(&"red_inner_right")
	# purple_bot_right has a blocker preventing counter-clockwise rotation; rotate clockwise (+1):
	clear_child.call(&"purple_bot_right", 1)

	# Resolve releases
	var rel = Rules.resolve_releases(pieces, links)
	print("Cascaded releases: %s" % [rel])

	# Release anchor hubs if clear
	for anchor_id in [&"blue_center_hub", &"green_far_left", &"blue_far_right"]:
		var hub = Rules.get_piece_by_id(anchor_id, pieces)
		if hub != null and Rules.is_piece_releasable(hub, pieces, links):
			hub.state = RingPiece2DScript.State.RELEASED
			print("Released %s!" % [anchor_id])

	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 17 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 17 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 17 did not report won")
		quit(1)
