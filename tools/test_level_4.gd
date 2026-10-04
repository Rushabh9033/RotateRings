extends SceneTree

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")

func _init() -> void:
	print("\n==============================================")
	print("       TEST LEVEL 4 UPDATED DEFINITION        ")
	print("==============================================")

	# 1. Setup pieces with verified video angles:
	# r_center: Closed Purple O-ring at (360, 600)
	var r_center = PieceDefinitionScript.new(&"ring_center", Vector2(360, 600), 72.0, 24.0, Color("#8228D9"), 0.0, [])
	# r0 (Cyan TL): opening facing LEFT (180°)
	var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(230, 460), 76.0, 24.0, Color("#3EA7C0"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
	# r1 (Orange TR): opening facing RIGHT (0°)
	var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(490, 460), 76.0, 24.0, Color("#EA7829"), 0.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
	# r2 (Red BL): opening facing LEFT (180°)
	var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(230, 740), 76.0, 24.0, Color("#C8202F"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
	# r3 (Green BR): opening facing RIGHT (0°)
	var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(490, 740), 76.0, 24.0, Color("#2CA45C"), 0.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
	# r4 (Blue bottom): opening facing DOWN (90°)
	var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(360, 880), 76.0, 24.0, Color("#32ADDA"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
	# r5 (DarkGreen top): opening facing UP (270°)
	var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(360, 320), 76.0, 24.0, Color("#1F7D3A"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])

	var pieces_def = [r_center, r0, r1, r2, r3, r4, r5]
	var links_def = [
		LinkDefinitionScript.new(&"link_0", &"ring_center", &"ring_0", Color("#8228D9")),
		LinkDefinitionScript.new(&"link_1", &"ring_center", &"ring_1", Color("#8228D9")),
		LinkDefinitionScript.new(&"link_2", &"ring_center", &"ring_2", Color("#8228D9")),
		LinkDefinitionScript.new(&"link_3", &"ring_center", &"ring_3", Color("#8228D9")),
		LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_0", Color("#1F7D3A")),
		LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_1", Color("#1F7D3A")),
		LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_4", Color("#C8202F")),
		LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_4", Color("#2CA45C"))
	]

	var pieces := []
	var links := []
	var piece_map := {}

	for p_def in pieces_def:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		p.position = p_def.position
		pieces.append(p)
		piece_map[p_def.id] = p

	for l_def in links_def:
		var link = l_def.duplicate()
		var from_p = piece_map.get(link.from_piece_id)
		var to_p = piece_map.get(link.to_piece_id)
		if from_p and to_p:
			from_p.set_meta("had_children_initially", true)
			to_p.set_meta("had_parents_initially", true)
			var diff_pos: Vector2 = to_p.position - from_p.position
			link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
			link.stem_dist = diff_pos.length()
			link.is_detached = false
		links.append(link)

	var check_unlock = func(piece: Node2D):
		var detached_any := false
		var remaining_incoming: Array = []
		for link in links:
			if link.to_piece_id == piece.piece_id:
				if link.is_detached: continue
				var parent_p = piece_map[link.from_piece_id]
				if parent_p.state == 6 or parent_p.state == 5:
					link.is_detached = true
					detached_any = true
					continue
				var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
				var dir := Vector2.from_angle(world_rad)
				var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - piece.radius)
				var cuff_rel: Vector2 = pos_cuff - piece.position
				var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
				if piece.is_angle_in_any_gap(angle_deg):
					link.is_detached = true
					detached_any = true
					print("  -> DETACHED link %s (%s -> %s) at angle %.1f°" % [link.id, link.from_piece_id, link.to_piece_id, angle_deg])
				else:
					remaining_incoming.append(link)

		var holds_attached_child := false
		for link in links:
			if link.from_piece_id == piece.piece_id and not link.is_detached:
				var child_p = piece_map[link.to_piece_id]
				if child_p.state != 6 and child_p.state != 5:
					holds_attached_child = true
					break

		if remaining_incoming.is_empty() and not holds_attached_child:
			piece.state = RingPiece2DScript.State.RELEASED
			print("  ==> RELEASED piece %s!" % piece.piece_id)

		var changed := true
		while changed:
			changed = false
			for p in pieces:
				if p.state != 6 and p.state != 5 and PuzzleRulesScript.is_piece_releasable(p, pieces, links):
					p.state = RingPiece2DScript.State.RELEASED
					print("  ==> CASCADE RELEASED piece %s!" % p.piece_id)
					changed = true

	# Sequential steps:
	var steps := [
		{"id": &"ring_0", "rot": 310.0}, # Cyan to DarkGreen cuff
		{"id": &"ring_1", "rot": 230.0}, # Orange to DarkGreen cuff -> DarkGreen cascades!
		{"id": &"ring_0", "rot": 50.0},  # Cyan to Purple cuff -> Cyan releases!
		{"id": &"ring_1", "rot": 130.0}, # Orange to Purple cuff -> Orange releases!
		{"id": &"ring_4", "rot": 230.0}, # Blue to Red cuff
		{"id": &"ring_4", "rot": 310.0}, # Blue to Green cuff -> Blue releases!
		{"id": &"ring_2", "rot": 310.0}, # Red to Purple cuff -> Red releases!
		{"id": &"ring_3", "rot": 230.0}, # Green to Purple cuff -> Green releases!
	]

	for s in steps:
		var p = piece_map[s["id"]]
		print("\nStep: Rotate %s to %.1f°" % [s["id"], s["rot"]])
		if not PuzzleRulesScript.is_piece_rotatable(p, pieces, links):
			print("❌ ERROR: %s is NOT rotatable!" % s["id"])
			quit(1)
			return
		p.rotation_degrees = s["rot"]
		p.current_angle_deg = s["rot"]
		check_unlock.call(p)

	var remaining = pieces.filter(func(p): return p.state != 6 and p.state != 5)
	if remaining.is_empty():
		print("\n==============================================")
		print("SUCCESS: Level 4 was COMPLETELY SOLVED!")
		print("==============================================")
		quit(0)
	else:
		print("\n❌ FAILED: Still has pieces: %s" % [remaining.map(func(p): return p.piece_id)])
		quit(1)
