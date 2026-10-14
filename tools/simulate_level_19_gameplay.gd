extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 19 SIMULATION START ===")
	var def = UserLevels.build(19)
	if def == null:
		print("FAIL: could not load level 19 definition")
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
			if p1.def.shape_type == 0 and p2.def.shape_type == 0 and not is_linked and Rules._tubes_overlap(p1, p2, 0.0):
				print("FAIL: initial tube collision between %s and %s" % [p1.piece_id, p2.piece_id])
				quit(1)
				return

	print("PASS: Zero initial tube collisions between pieces!")

	var clear_child = func(child_id: StringName):
		var p = Rules.get_piece_by_id(child_id, pieces)
		if p == null:
			return
		var incoming: Array = []
		for l in links:
			if l.def.to_piece_id == child_id and l.state == ConnectorRuntimeScript.State.ENGAGED:
				incoming.append(l)
		for l in incoming:
			var rot = Rules.alignment_rotation_deg(p, l, pieces, p.gaps[0])
			var delta := wrapf(rot - p.rotation_degrees, -180.0, 180.0)
			var res = Rules.apply_settled_rotation(p, rot, pieces, links)
			print("Rotated %s to %f: applied=%s cleared=%s, released=%s" % [child_id, rot, res.applied, res.cleared, res.released])
			l.current_stem_dist = 0.0

	# Step 1: Slide out all sliders
	for p in pieces:
		if p.def.motion_model == 1:
			var axis: Vector2 = p.def.motion_axis.normalized()
			p.position += axis * float(p.def.slide_max)
			p.state = RingPiece2DScript.State.RELEASED
			Rules.on_piece_released(p, links)
			print("Slid and released %s!" % [p.piece_id])

	# Step 2: Clear rings in topological order
	clear_child.call(&"green_top")
	clear_child.call(&"red_ml")
	clear_child.call(&"orange_c")
	clear_child.call(&"red_mr")
	clear_child.call(&"purple_mr")
	clear_child.call(&"blue_br")
	clear_child.call(&"teal_bm")
	clear_child.call(&"teal_bot")

	# Cascaded releases
	var rel = Rules.resolve_releases(pieces, links)
	print("Cascaded releases: %s" % [rel])

	# Release anchor hub
	var hub = Rules.get_piece_by_id(&"cyan_l", pieces)
	if hub != null and Rules.is_piece_releasable(hub, pieces, links):
		hub.state = RingPiece2DScript.State.RELEASED
		print("Released anchor hub cyan_l!")

	var all_released := true
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			print("Piece NOT released: %s (role=%d, shape=%d)" % [p.piece_id, p.def.role, p.def.shape_type])
			all_released = false

	print("IS LEVEL 19 WON: %s" % [all_released])
	if all_released:
		print("=== LEVEL 19 SIMULATION SUCCESSFUL ===")
		quit(0)
	else:
		print("=== LEVEL 19 SIMULATION FAILED ===")
		quit(1)
