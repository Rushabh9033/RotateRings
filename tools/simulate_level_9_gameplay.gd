extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var def = UserLevels.build(9)
	if def == null:
		print("FAIL: could not load level 9 definition")
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

	# 2. Check blocker arm on red
	var red = Rules.get_piece_by_id(&"red", pieces)
	var light_green = Rules.get_piece_by_id(&"light_green", pieces)

	if red != null and light_green != null:
		# Check if blocker hits initially
		var init_block = Rules._blockers_hit_ring(red, light_green, 0.0)
		print("Initial blocker overlap red -> light_green: %s" % [init_block])
		if init_block:
			print("FAIL: blocker initially overlaps light_green!")
			quit(1)
			return

		# Rotate light_green clockwise towards red's blocker
		var lg_rot = Rules.clamp_rotation_step(light_green, 60.0, pieces, links)
		print("Light green rotation +60 deg: allowed=%.1f deg, hit_stopper=%s" % [lg_rot.allowed_delta, lg_rot.hit_stopper])

	# 3. Check rotatability of all playable pieces
	for p in pieces:
		var rotatable = Rules.is_piece_rotatable(p, pieces, links)
		print("Piece %s: rotatable=%s, role=%d" % [p.piece_id, rotatable, Rules.piece_role(p)])

	print("ALL LEVEL 9 CHECKS PASSED!")
	quit(0)
