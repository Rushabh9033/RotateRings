extends SceneTree

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const SolutionStepScript = preload("res://data/solution_step.gd")

func _init() -> void:
	print("--- TESTING LEVEL 5 CANDIDATE FIX ---")
	var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(250, 340), 76.0, 24.0, Color("#EA7829"), 315.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Orange
	var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(440, 370), 76.0, 24.0, Color("#3EA7C0"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Cyan
	var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(320, 520), 76.0, 24.0, Color("#8228D9"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Purple
	var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(140, 660), 76.0, 24.0, Color("#C8202F"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Red
	var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(360, 710), 76.0, 24.0, Color("#62C73E"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # LightGreen
	var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(280, 890), 76.0, 24.0, Color("#4361CF"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkBlue
	var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(550, 600), 76.0, 24.0, Color("#2CA45C"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkGreen

	var pieces_defs = [r0, r1, r2, r3, r4, r5, r6]
	var links_defs = [
		LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_2", Color("#C8202F")), # Red holds Purple
		LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#8228D9")), # Purple holds Cyan
		LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_4", Color("#8228D9")), # Purple holds LightGreen
		LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_0", Color("#3EA7C0")), # Cyan holds Orange
		LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_4", Color("#2CA45C")), # DarkGreen holds LightGreen
		LinkDefinitionScript.new(&"link_5", &"ring_4", &"ring_5", Color("#62C73E"))  # LightGreen holds DarkBlue
	]

	var steps = [
		SolutionStepScript.new(&"ring_0", 9.0, true),
		SolutionStepScript.new(&"ring_5", 294.0, true),
		SolutionStepScript.new(&"ring_1", 128.7, true),
		SolutionStepScript.new(&"ring_4", 330.0, true), # detaches ring_6, ring_6 cascades!
		SolutionStepScript.new(&"ring_4", 258.1, true), # detaches ring_4 from ring_2
		SolutionStepScript.new(&"ring_2", 142.1, true)  # detaches ring_2 from ring_3
	]

	# Build nodes
	var piece_map := {}
	var pieces_array := []
	for p_def in pieces_defs:
		var p_node = RingPiece2DScript.new()
		p_node.setup(p_def)
		p_node.position = p_def.position
		piece_map[p_def.id] = p_node
		pieces_array.append(p_node)

	var active_links := []
	for link_def in links_defs:
		var link = LinkDefinitionScript.new(link_def.id, link_def.from_piece_id, link_def.to_piece_id, link_def.joint_color)
		var from_p = piece_map.get(link.from_piece_id)
		var to_p = piece_map.get(link.to_piece_id)
		var diff_pos: Vector2 = to_p.position - from_p.position
		link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
		link.stem_dist = diff_pos.length()
		link.is_detached = false
		active_links.append(link)

	# Check spawn cuff in gap
	for link in active_links:
		var from_p = piece_map[link.from_piece_id]
		var to_p = piece_map[link.to_piece_id]
		var world_angle_rad: float = deg_to_rad(from_p.rotation_degrees + link.collar_angle_deg)
		var dir := Vector2.from_angle(world_angle_rad)
		var pos_cuff: Vector2 = from_p.position + dir * (link.stem_dist - to_p.radius)
		var cuff_rel: Vector2 = pos_cuff - to_p.position
		var angle_on_child_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
		if to_p.is_angle_in_any_gap(angle_on_child_deg):
			print("❌ Cuff in gap: ", link.id)
			quit(1)

	print("✅ Zero cuffs in gap at spawn!")

	# Simulate steps
	var active_pieces = pieces_array.duplicate()
	_cascade(active_pieces, active_links)

	for step in steps:
		var p = null
		for item in active_pieces:
			if item.piece_id == step.piece_id:
				p = item
				break
		if not p:
			print("   Note: piece %s already cascaded" % step.piece_id)
			continue

		var target_rot: float = step.target_angle_deg
		var delta := wrapf(target_rot - p.rotation_degrees, -180.0, 180.0)
		var clamp_res = PuzzleRulesScript.clamp_rotation_step(p, delta, active_pieces, active_links)
		if bool(clamp_res["hit_stopper"]) and absf(float(clamp_res["allowed_delta"]) - delta) > 1.0:
			print("❌ Step on %s BLOCKED: wanted delta %.1f, got %.1f" % [p.piece_id, delta, float(clamp_res["allowed_delta"])])
			quit(1)

		p.rotation_degrees += float(clamp_res["allowed_delta"])
		p.current_angle_deg = fposmod(p.rotation_degrees, 360.0)

		# Detach
		for link in active_links:
			if link.to_piece_id == p.piece_id and not link.is_detached:
				var parent_p = piece_map.get(link.from_piece_id)
				var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
				var dir := Vector2.from_angle(world_angle_rad)
				var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - p.radius)
				var cuff_rel: Vector2 = pos_cuff - p.position
				var angle_on_child_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
				if p.is_angle_in_any_gap(angle_on_child_deg):
					link.is_detached = true
					print("   Detached link %s -> %s" % [link.from_piece_id, link.to_piece_id])

		_cascade(active_pieces, active_links)
		print("   Remaining pieces count:", active_pieces.size())

	if active_pieces.is_empty():
		print("✅ Level 5 COMPLETELY SOLVED TO 0 PIECES!")
		quit(0)
	else:
		print("❌ Level 5 remaining pieces:", active_pieces.size())
		quit(1)

func _cascade(active_pieces: Array, active_links: Array) -> void:
	var changed := true
	while changed:
		changed = false
		var to_remove = []
		for p in active_pieces:
			var remaining_in := 0
			for link in active_links:
				if link.to_piece_id == p.piece_id and not link.is_detached:
					remaining_in += 1
			var holds_active := false
			for link in active_links:
				if link.from_piece_id == p.piece_id and not link.is_detached:
					for other in active_pieces:
						if other.piece_id == link.to_piece_id and other != p:
							holds_active = true
							break
			if remaining_in == 0 and not holds_active:
				to_remove.append(p)
		if to_remove.size() > 0:
			changed = true
			for p in to_remove:
				print("   CASCADE RELEASE: ", p.piece_id)
				active_pieces.erase(p)
				for link in active_links:
					if link.from_piece_id == p.piece_id:
						link.is_detached = true
