extends SceneTree

const LevelDatabaseScript = preload("res://data/level_database.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")

func _init() -> void:
	print("\n=======================================================")
	print("       DEEP AUDIT: ALL LEVELS SPAWN & SOLVABILITY      ")
	print("=======================================================")

	var total_levels: int = LevelDatabaseScript.get_total_levels()
	var all_passed := true

	for lvl in range(1, total_levels + 1):
		var def = LevelDatabaseScript.get_level(lvl)
		if not def:
			print("❌ Level %d: FAILED to load definition" % lvl)
			all_passed = false
			continue

		print("\n--- Auditing Level %d: '%s' (Pieces: %d, Links: %d) ---" % [lvl, def.title, def.pieces.size(), def.links.size()])

		var piece_map := {}
		var pieces_array := []
		for p_def in def.pieces:
			var p_node = RingPiece2DScript.new()
			p_node.setup(p_def)
			p_node.position = p_def.position
			piece_map[p_def.id] = p_node
			pieces_array.append(p_node)

		var active_links := []
		for link_def in def.links:
			var link = LinkDefinitionScript.new(link_def.id, link_def.from_piece_id, link_def.to_piece_id, link_def.joint_color)
			var from_p = piece_map.get(link.from_piece_id)
			var to_p = piece_map.get(link.to_piece_id)
			if from_p and to_p:
				var diff_pos: Vector2 = to_p.position - from_p.position
				link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
				link.stem_dist = diff_pos.length()
				link.is_detached = false
				active_links.append(link)

		# 1. Cuff-in-gap check
		var cuff_in_gap_errors := []
		for link in active_links:
			var from_p = piece_map[link.from_piece_id]
			var to_p = piece_map[link.to_piece_id]

			var world_angle_rad: float = deg_to_rad(from_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_angle_rad)
			var pos_cuff: Vector2 = from_p.position + dir * (link.stem_dist - to_p.radius)
			var cuff_rel: Vector2 = pos_cuff - to_p.position
			var angle_on_child_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)

			if to_p.is_angle_in_any_gap(angle_on_child_deg):
				cuff_in_gap_errors.append("Link %s (%s -> %s): cuff at %.1f deg is INSIDE child gap at spawn!" % [
					link.id, link.from_piece_id, link.to_piece_id, angle_on_child_deg
				])

		if cuff_in_gap_errors.size() > 0:
			all_passed = false
			for err in cuff_in_gap_errors:
				print("   ❌ SPAWN BUG: ", err)
		else:
			print("   ✅ Spawn check: Zero cuffs inside gaps at start.")

		# 2. Solvability test using canonical steps or BFS solver
		var can_solve := test_canonical_solution(pieces_array, active_links, def.canonical_steps)
		if can_solve:
			print("   ✅ Solvability: Level %d solves completely to 0 pieces!" % lvl)
		else:
			print("   ❌ Solvability: Canonical steps failed to solve Level %d!" % lvl)
			all_passed = false

	print("\n=======================================================")
	if all_passed:
		print("ALL LEVELS AUDITED & SOLVABLE!")
	else:
		print("AUDIT FAILED ON SOME LEVELS!")
	print("=======================================================\n")
	quit(0 if all_passed else 1)

func test_canonical_solution(pieces: Array, links: Array, steps: Array) -> bool:
	var active_pieces = pieces.duplicate()
	var active_links = links.duplicate()

	# Initial cascade check
	_cascade_check(active_pieces, active_links)

	for step in steps:
		var p = null
		for piece in active_pieces:
			if piece.piece_id == step.piece_id:
				p = piece
				break
		if not p:
			# Piece might have cascaded
			continue

		# Try rotating to step.target_angle_deg
		var target_rot: float = step.target_angle_deg
		var delta := wrapf(target_rot - p.rotation_degrees, -180.0, 180.0)
		var clamp_res = PuzzleRulesScript.clamp_rotation_step(p, delta, active_pieces, active_links)

		if bool(clamp_res["hit_stopper"]) and absf(float(clamp_res["allowed_delta"]) - delta) > 1.0:
			print("      Step on %s blocked by stopper! Wanted delta %.1f, got %.1f" % [p.piece_id, delta, float(clamp_res["allowed_delta"])])
			return false

		p.rotation_degrees += float(clamp_res["allowed_delta"])
		p.current_angle_deg = fposmod(p.rotation_degrees, 360.0)

		# Detach cuffs aligning with gap
		for link in active_links:
			if link.to_piece_id == p.piece_id and not link.is_detached:
				var parent_p = null
				for item in active_pieces:
					if item.piece_id == link.from_piece_id:
						parent_p = item
						break
				if parent_p:
					var world_angle_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
					var dir := Vector2.from_angle(world_angle_rad)
					var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - p.radius)
					var cuff_rel: Vector2 = pos_cuff - p.position
					var angle_on_child_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
					if p.is_angle_in_any_gap(angle_on_child_deg):
						link.is_detached = true

		_cascade_check(active_pieces, active_links)

	return active_pieces.is_empty()

func _cascade_check(active_pieces: Array, active_links: Array) -> void:
	var changed := true
	while changed:
		changed = false
		var to_remove = []
		for p in active_pieces:
			# Check incoming links
			var remaining_in := 0
			for link in active_links:
				if link.to_piece_id == p.piece_id and not link.is_detached:
					remaining_in += 1

			# Check outgoing links holding active pieces
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
				active_pieces.erase(p)
				# Detach all outgoing links from p
				for link in active_links:
					if link.from_piece_id == p.piece_id:
						link.is_detached = true
