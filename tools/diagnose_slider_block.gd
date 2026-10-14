extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var def = UserLevels.build(15)
	var pieces: Array = []
	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)

	var links: Array = []
	for l_def in def.links:
		var l = ConnectorRuntimeScript.new(l_def)
		links.append(l)

	print("Finding EXACT blocker for each slider:")
	for s_id in [&"blue_slider", &"orange_slider"]:
		var s = Rules.get_piece_by_id(s_id, pieces)
		var axis = s.def.motion_axis.normalized()
		var base_pos = s.position
		print("\n=== %s ===" % [s_id])
		for step in [50.0, 55.0, 60.0, 65.0, 70.0, 75.0]:
			s.position = base_pos + axis * step
			# Check against every other piece and link
			for other in pieces:
				if other == s or Rules._is_gone(other): continue
				if Rules._tubes_overlap(s, other, 0.0):
					print("Step %f hits piece %s" % [step, other.piece_id])
			for link in links:
				if not Rules._link_drawn(link, pieces): continue
				if link.def.to_piece_id == s.piece_id: continue
				if Rules._cuff_hits_ring(link, s, pieces, 0.0):
					print("Step %f hits cuff of link %s (from %s to %s)" % [step, link.def.id, link.def.from_piece_id, link.def.to_piece_id])
				if Rules._stem_hits_ring(link, s, pieces, 0.0):
					print("Step %f hits stem of link %s (from %s to %s)" % [step, link.def.id, link.def.from_piece_id, link.def.to_piece_id])
	quit(0)
