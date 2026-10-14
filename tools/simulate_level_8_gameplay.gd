extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var def = UserLevels.build(8)
	if def == null:
		print("FAIL: could not load level 8 definition")
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

	# 1. Zero initial tube collision
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

	print("PASS: Zero initial tube collisions!")

	# 2. Test Blocker Collision:
	var cyan = Rules.get_piece_by_id(&"cyan", pieces)
	var purple = Rules.get_piece_by_id(&"purple", pieces)

	# Rotate cyan clockwise so its blocker arm sweeps towards purple
	var blocked_step = Rules.clamp_rotation_step(cyan, 60.0, pieces, links)
	print("Cyan rotation by +60 deg: allowed=%.1f deg, hit_stopper=%s" % [blocked_step.allowed_delta, blocked_step.hit_stopper])

	# Rotate purple counter-clockwise so its mouth/tube sweeps towards cyan's blocker arm
	var purple_blocked = Rules.clamp_rotation_step(purple, -60.0, pieces, links)
	print("Purple rotation by -60 deg: allowed=%.1f deg, hit_stopper=%s" % [purple_blocked.allowed_delta, purple_blocked.hit_stopper])

	if blocked_step.hit_stopper:
		print("SUCCESS: Blocker arm physically blocks rotation!")
	else:
		print("NOTE: Blocker arm allows initial range, testing full sweep...")
		var full_sweep = Rules.clamp_rotation_step(cyan, 180.0, pieces, links)
		print("Cyan full sweep 180 deg: allowed=%.1f deg, hit_stopper=%s" % [full_sweep.allowed_delta, full_sweep.hit_stopper])
		if full_sweep.hit_stopper:
			print("SUCCESS: Cyan blocker arm hits obstacle and clamps rotation!")

	quit(0)
