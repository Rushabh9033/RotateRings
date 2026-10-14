extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 17 SIMULATION START ===")
	var def = UserLevels.build(17)
	if def == null:
		print("FAIL: could not load level 17")
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
			if Rules._blockers_hit_ring(p1, p2, 0.0) or Rules._blockers_hit_ring(p2, p1, 0.0):
				print("FAIL: initial blocker collision between %s and %s" % [p1.piece_id, p2.piece_id])
				quit(1)
				return

	print("PASS: Zero initial tube & blocker collisions!")

	# 2. Check blockers on green_bot_left and purple_bot_right:
	var gbl = Rules.get_piece_by_id(&"green_bot_left", pieces)
	var pbr = Rules.get_piece_by_id(&"purple_bot_right", pieces)

	# Rotate gbl clockwise towards 90 deg -> MUST hit cuff!
	var clamped_cw = Rules.clamp_rotation_step(gbl, 120.0, pieces, links)
	print("gbl rotate CW (+120 deg): allowed=%f, hit_stopper=%s" % [clamped_cw.allowed_delta, clamped_cw.hit_stopper])
	assert(clamped_cw.hit_stopper, "gbl CW rotation MUST hit the blocker against cuff!")

	# Rotate gbl counter-clockwise -> should rotate freely without hitting blocker!
	var clamped_ccw = Rules.clamp_rotation_step(gbl, -180.0, pieces, links)
	print("gbl rotate CCW (-180 deg): allowed=%f, hit_stopper=%s" % [clamped_ccw.allowed_delta, clamped_ccw.hit_stopper])

	# Rotate pbr counter-clockwise (-120 deg) -> MUST hit cuff!
	var clamped_pbr_ccw = Rules.clamp_rotation_step(pbr, -120.0, pieces, links)
	print("pbr rotate CCW (-120 deg): allowed=%f, hit_stopper=%s" % [clamped_pbr_ccw.allowed_delta, clamped_pbr_ccw.hit_stopper])
	assert(clamped_pbr_ccw.hit_stopper, "pbr CCW rotation MUST hit the blocker against cuff!")

	# Rotate pbr clockwise (+180 deg) -> should rotate freely!
	var clamped_pbr_cw = Rules.clamp_rotation_step(pbr, 180.0, pieces, links)
	print("pbr rotate CW (+180 deg): allowed=%f, hit_stopper=%s" % [clamped_pbr_cw.allowed_delta, clamped_pbr_cw.hit_stopper])

	print("PASS: Blockers properly obstruct and allow intended rotation paths!")
	quit(0)
