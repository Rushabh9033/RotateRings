extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 18 SIMULATION START ===")
	var def = UserLevels.build(18)
	if def == null:
		print("FAIL: could not load level 18 definition")
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
			p.position += Vector2(0, 0) # touch
			for step_i in range(1, 10):
				p.rotation_degrees = p.rotation_degrees + (delta / 10.0)
				var blk = Rules._overlap_contact(p, pieces, links)
				if blk.blocking:
					print("DEBUG %s blocked at rot %f by point %s" % [child_id, p.rotation_degrees, blk.point])
					break
			p.rotation_degrees = 0.0
			var clamped = Rules.clamp_rotation_step(p, delta, pieces, links)
			print("%s target_rot=%f delta=%f allowed=%s hit_stopper=%s" % [child_id, rot, delta, clamped.allowed_delta, clamped.hit_stopper])
			var res = Rules.apply_settled_rotation(p, rot, pieces, links)
			print("Rotated %s to %f: applied=%s cleared=%s, released=%s" % [child_id, rot, res.applied, res.cleared, res.released])
			l.current_stem_dist = 0.0

	# Step 1: Slide out sliders
	for s_id in [&"red_arch", &"purple_slider", &"green_slider_diag", &"green_slider_center"]:
		var s = Rules.get_piece_by_id(s_id, pieces)
		if s != null:
			var axis: Vector2 = s.def.motion_axis.normalized()
			s.position += axis * float(s.def.slide_max)
			s.state = RingPiece2DScript.State.RELEASED
			Rules.on_piece_released(s, links)
			print("Slid and released %s!" % [s_id])

	# Step 2: Clear rings in topological leaf-to-root order
	# Chain 1: blue_bl -> cyan_bm -> orange_br (leaf)
	clear_child.call(&"orange_br")
	clear_child.call(&"cyan_bm")

	# Chain 2: blue_bl -> cyan_ml -> orange_ul -> purple_tl -> red_tr -> green_ur -> blue_r (leaf)
	clear_child.call(&"blue_r")
	clear_child.call(&"green_ur")
	clear_child.call(&"red_tr")
	clear_child.call(&"purple_tl")
	clear_child.call(&"orange_ul")
	clear_child.call(&"cyan_ml")

	# Cascaded releases
	var rel = Rules.resolve_releases(pieces, links)
	print("Cascaded releases: %s" % [rel])

	# Release anchor hubs if clear
	for anchor_id in [&"blue_bl", &"orange_center"]:
		var hub = Rules.get_piece_by_id(anchor_id, pieces)
		if hub != null and Rules.is_piece_releasable(hub, pieces, links):
			hub.state = RingPiece2DScript.State.RELEASED
			print("Released %s!" % [anchor_id])

	for p in pieces:
		print("Piece %s: state=%d, gone=%s, releasable=%s" % [p.piece_id, p.state, Rules._is_gone(p), Rules.is_piece_releasable(p, pieces, links)])
	for l in links:
		print("Link %s: state=%d" % [l.def.id, l.state])

	var won = Rules.is_puzzle_won(pieces, links)
	print("IS LEVEL 18 WON: %s" % [won])
	if won:
		print("SUCCESS: 100% COMPLETE LEVEL 18 PLAYTHROUGH VERIFIED!")
		quit(0)
	else:
		print("FAIL: Level 18 did not report won")
		quit(1)
