extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 23 SIMULATION START ===")
	var def = UserLevels.build(23)
	if def == null:
		print("FAIL: could not load level 23 definition")
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
				print("FAIL: initial tube collision between %s and %s (shapes %d vs %d)" % [p1.piece_id, p2.piece_id, p1.def.shape_type, p2.def.shape_type])
				quit(1)
				return

	print("PASS: Zero initial tube collisions between pieces!")

	# Function to rotate child piece to align its gap with link incoming from parent
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
			var res = Rules.apply_settled_rotation(p, rot, pieces, links)
			print("Rotated %s to %f: applied=%s cleared=%s, released=%s" % [child_id, rot, res.applied, res.cleared, res.released])
			l.current_stem_dist = 0.0

	# Now let's try a solve sequence.
	# Any piece that is leaf / has incoming links can align gap to clear:
	# Let's see: green_tr, cyan_inner_tl, cyan_inner_top, purple_inner_tr, green_inner_mid, green_inner_mr, cyan_mid_bot, green_inner_ml, blue_inner_bl, purple_inner_br
	var rings_to_clear = [
		&"green_tr",
		&"cyan_inner_tl",
		&"cyan_inner_top",
		&"purple_inner_tr",
		&"green_inner_mid",
		&"green_inner_mr",
		&"cyan_mid_bot",
		&"green_inner_ml",
		&"blue_inner_bl",
		&"purple_inner_br",
		&"orange_outer_tr",
		&"red_outer_mid",
		&"orange_outer_tl",
		&"blue_outer_ml",
		&"red_outer_mr",
		&"orange_outer_br",
		&"red_bot",
		&"green_outer_bl",
		&"green_outer_tm"
	]

	# Iteratively attempt to clear and release releasable pieces
	for pass_idx in range(10):
		var progressed := false
		for r_id in rings_to_clear:
			var p = Rules.get_piece_by_id(r_id, pieces)
			if p != null and p.state != RingPiece2DScript.State.RELEASED:
				clear_child.call(r_id)
				if Rules.is_piece_releasable(p, pieces, links):
					p.state = RingPiece2DScript.State.RELEASED
					Rules.on_piece_released(p, links)
					print("RELEASED %s on pass %d!" % [r_id, pass_idx])
					progressed = true
		# Also check hubs
		for hub_id in [&"purple_hub_tl", &"blue_hub_mid"]:
			var hub = Rules.get_piece_by_id(hub_id, pieces)
			if hub != null and hub.state != RingPiece2DScript.State.RELEASED:
				if Rules.is_piece_releasable(hub, pieces, links):
					hub.state = RingPiece2DScript.State.RELEASED
					Rules.on_piece_released(hub, links)
					print("RELEASED HUB %s on pass %d!" % [hub_id, pass_idx])
					progressed = true

	var unreleased: Array = []
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			unreleased.append(p.piece_id)

	if unreleased.is_empty():
		print("SUCCESS: ALL PIECES IN LEVEL 23 RELEASED! IS LEVEL 23 WON: true")
		quit(0)
	else:
		print("PARTIAL: unreleased pieces: %s" % [str(unreleased)])
		quit(1)
