extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 24 SIMULATION START ===")
	var def = UserLevels.build(24)
	if def == null:
		print("FAIL: could not load level 24 definition")
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
			var res = Rules.apply_settled_rotation(p, rot, pieces, links)
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

	# Step 1: Slide out initial free sliders
	slide_and_release.call(&"orange_slider_bar")
	slide_and_release.call(&"orange_slider_vert")

	# Step 2: Row 1 & 2 clear
	clear_child.call(&"blue_r1")
	var b1 = Rules.get_piece_by_id(&"blue_r1", pieces)
	if b1 != null and Rules.is_piece_releasable(b1, pieces, links):
		b1.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(b1, links)
		print("Released blue_r1!")

	clear_child.call(&"green_r1")
	var g1 = Rules.get_piece_by_id(&"green_r1", pieces)
	if g1 != null and Rules.is_piece_releasable(g1, pieces, links):
		g1.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(g1, links)
		print("Released green_r1!")

	clear_child.call(&"purple_r2")
	clear_child.call(&"orange_r2")

	var r1 = Rules.get_piece_by_id(&"red_r1", pieces)
	if r1 != null and Rules.is_piece_releasable(r1, pieces, links):
		r1.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(r1, links)
		print("Released red_r1!")

	var p2 = Rules.get_piece_by_id(&"purple_r2", pieces)
	if p2 != null and Rules.is_piece_releasable(p2, pieces, links):
		p2.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(p2, links)
		print("Released purple_r2!")

	var o2 = Rules.get_piece_by_id(&"orange_r2", pieces)
	if o2 != null and Rules.is_piece_releasable(o2, pieces, links):
		o2.state = RingPiece2DScript.State.RELEASED
		Rules.on_piece_released(o2, links)
		print("Released orange_r2!")

	slide_and_release.call(&"green_slider_tl")
	slide_and_release.call(&"red_slider_mid")

	# Step 3: Loop through remaining pieces (Row 3, Row 4, Row 5)
	var order = [
		&"cyan_r3", &"blue_r3", &"green_r3", &"orange_r3",
		&"purple_r4", &"blue_r4",
		&"green_slider_bot", &"cyan_slider_bot",
		&"orange_slider_u"
	]

	for pass_idx in range(10):
		for r_id in order:
			var p = Rules.get_piece_by_id(r_id, pieces)
			if p != null and p.state != RingPiece2DScript.State.RELEASED:
				if p.def.motion_model == 1:
					slide_and_release.call(r_id)
				else:
					clear_child.call(r_id)
					if Rules.is_piece_releasable(p, pieces, links):
						p.state = RingPiece2DScript.State.RELEASED
						Rules.on_piece_released(p, links)
						print("Released %s on pass %d!" % [r_id, pass_idx])

		# Hubs
		for hub_id in [&"cyan_r2", &"green_r4", &"red_r4", &"cyan_r5"]:
			var hub = Rules.get_piece_by_id(hub_id, pieces)
			if hub != null and hub.state != RingPiece2DScript.State.RELEASED:
				if Rules.is_piece_releasable(hub, pieces, links):
					hub.state = RingPiece2DScript.State.RELEASED
					Rules.on_piece_released(hub, links)
					print("RELEASED HUB %s on pass %d!" % [hub_id, pass_idx])

	var unreleased: Array = []
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			unreleased.append(p.piece_id)

	if unreleased.is_empty():
		print("SUCCESS: ALL PIECES IN LEVEL 24 RELEASED! IS LEVEL 24 WON: true")
		quit(0)
	else:
		print("PARTIAL: unreleased pieces: %s" % [str(unreleased)])
		quit(1)
