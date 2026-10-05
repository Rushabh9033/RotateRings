extends SceneTree

const LevelDatabaseScript = preload("res://data/level_database.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")

func _init() -> void:
	print("\n=======================================================")
	print("       DEEP AUDIT: ALL LEVELS BFS SOLVER               ")
	print("=======================================================")

	var db = LevelDatabaseScript.new()
	var total_levels = db.get_total_levels()
	var all_passed := true

	for lvl in range(1, total_levels + 1):
		var def = db.get_level(lvl)
		if not def:
			continue
		print("\n--- Auditing Level %d: '%s' ---" % [lvl, def.title])

		var pieces_array: Array = []
		for p_def in def.pieces:
			var p_node = RingPiece2DScript.new()
			p_node.setup(p_def)
			p_node.position = p_def.position
			pieces_array.append(p_node)

		var active_links: Array = []
		for link_def in def.links:
			var cr = ConnectorRuntime.new(link_def)
			var from_p = PuzzleRulesScript.get_piece_by_id(cr.def.from_piece_id, pieces_array)
			var to_p = PuzzleRulesScript.get_piece_by_id(cr.def.to_piece_id, pieces_array)
			if from_p and to_p:
				var diff_pos: Vector2 = to_p.position - from_p.position
				cr.def.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
				cr.def.stem_dist = diff_pos.length()
				cr.current_stem_dist = cr.def.stem_dist
				active_links.append(cr)

		var res = BFSSolver.solve_bfs(pieces_array, active_links)
		if res.solved:
			print("   ? Solvable in %d moves!" % res.moves)
			if res.moves < def.canonical_steps.size():
				print("   ?? SHORTCUT FOUND! Solver found %d moves, canonical has %d" % [res.moves, def.canonical_steps.size()])
			elif res.moves > def.canonical_steps.size():
				print("   ?? Canonical steps are impossible/outdated! (Solver found %d)" % res.moves)
		else:
			print("   ? UNSOLVABLE!")
			all_passed = false

	print("\n=======================================================")
	quit(0 if all_passed else 1)
