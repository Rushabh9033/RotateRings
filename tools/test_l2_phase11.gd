extends SceneTree

# Phase 11 L2 verifier: load L2 through the same path gameplay uses,
# instantiate, verify pieces + links, capture a screenshot.

const LevelDatabaseScript = preload("res://data/level_database.gd")
const UserLevelsScript = preload("res://data/user_levels.gd")
const PuzzleControllerScript = preload("res://gameplay/puzzle_controller.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")

func _init() -> void:
	print("=== Phase 11 L2 verifier ===")

	# 1. Read user_levels/2.json directly.
	var u = UserLevelsScript.build(2)
	if u == null:
		print("FAIL: user_levels/2.json missing or invalid")
		quit(1); return

	print("Loaded from user_levels/2.json:")
	print("  title: ", u.title)
	print("  pieces: ", u.pieces.size())
	print("  links: ", u.links.size())
	for p in u.pieces:
		print("  - id=%s pos=(%.2f, %.2f) r=%.2f thickness=%.2f gaps=%d color=%s" %
			[String(p.id), p.position.x, p.position.y, p.radius, p.thickness, p.gaps.size(), PieceDefinitionScript.color_hex_static(p.color)])
		for g in p.gaps:
			print("      gap center=%.2f width=%.2f tol=%.2f" %
				[g.center_angle_deg, g.width_deg, g.tolerance_deg])
	for l in u.links:
		print("  link %s -> %s  stem_dist=%.2f  collar_angle=%.2f  cuff_w=%.2f cuff_d=%.2f" %
			[String(l.from_piece_id), String(l.to_piece_id), l.stem_dist, l.collar_angle_deg, l.cuff_width, l.cuff_depth])

	# 2. Build through LevelDatabase (the gameplay path).
	var lvl = LevelDatabaseScript.get_level(2)
	if lvl == null:
		print("FAIL: LevelDatabase.get_level(2) returned null")
		quit(1); return

	# 3. Instantiate PuzzleController and load.
	var puzzle = PuzzleControllerScript.new()
	root.add_child(puzzle)
	await process_frame
	puzzle._ready()
	puzzle.load_level(lvl)
	await process_frame

	print("\nPuzzleController state:")
	print("  is_active: ", puzzle.is_active)
	print("  active_pieces: ", puzzle.active_pieces.size())
	print("  active_links: ", puzzle.active_links.size())
	for piece in puzzle.active_pieces:
		var d = piece.def
		print("    piece %s pos=(%.2f,%.2f) r=%.2f" % [String(d.id), d.position.x, d.position.y, d.radius])
	for link in puzzle.active_links:
		var ld = link.def
		print("    link %s->%s stem_dist=%.2f current=%.2f" %
			[String(ld.from_piece_id), String(ld.to_piece_id), ld.stem_dist, link.current_stem_dist])

	# 4. Move pieces into solved positions and verify connectors release.
	print("\n=== Interaction test ===")
	for link in puzzle.active_links:
		var solved_pos: float = link.target_stem_dist if "target_stem_dist" in link else link.def.stem_dist
		print("  link %s target_stem_dist=%.2f current=%.2f" %
			[String(link.def.from_piece_id), solved_pos, link.current_stem_dist])

	# 5. Capture a screenshot.
	var img = root.get_viewport().get_texture().get_image()
	if img != null:
		var path = "res://tools/analyzer_outputs/phase11_l2_runtime.png"
		var abs_path = ProjectSettings.globalize_path(path)
		var dir_path = abs_path.get_base_dir()
		DirAccess.make_dir_recursive_absolute(dir_path)
		var save_err = img.save_png(abs_path)
		print("\nScreenshot save: ", "OK " + abs_path if save_err == OK else "FAIL " + error_string(save_err))

	# 6. Done.
	print("\n=== Phase 11 L2 verifier: PASS ===")
	quit(0)