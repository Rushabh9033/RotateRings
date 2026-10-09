extends SceneTree

# End-to-end smoke test for the in-built edit overlay:
#   1. Spin up Main.tscn (full app)
#   2. Show GameplayScreen
#   3. Trigger _on_edit_pressed() to switch into edit mode
#   4. Call _commit_move() on the first piece programmatically
#   5. Verify data/user_levels/<level>.json was written and parses back

const UserLevelsScript = preload("res://data/user_levels.gd")

func _init() -> void:
	var main_scene = load("res://scenes/Main.tscn")
	if main_scene == null:
		print("FAIL: cannot load Main.tscn")
		quit(1); return
	var app = main_scene.instantiate()
	root.add_child(app)
	if not app.is_node_ready():
		await app.ready
	await process_frame

	# Find gameplay screen via scene_router or directly.
	var gp = app.get_node_or_null("Screens/GameplayScreen")
	if gp == null:
		print("FAIL: GameplayScreen not found at Screens/GameplayScreen")
		quit(1); return
	# Add signals so we know.
	if not gp.has_signal("back_to_levels_requested") and gp.has_signal("level_select_requested"):
		pass

	# Load Level 1 directly (we don't want to navigate through splash + home).
	# Set the level id and call load_level_by_id.
	gp.current_level_id = 1
	gp.load_level_by_id(1)
	await process_frame
	await process_frame

	# Find overlay.
	var overlay = gp.get_node_or_null("PuzzleArea/PieceEditOverlay")
	if overlay == null:
		print("FAIL: PieceEditOverlay not found")
		quit(1); return

	# Toggle edit mode on.
	overlay.debug_print = true
	overlay.toggle(true)
	await process_frame

	# Confirm we have at least one piece to drag.
	if overlay._pieces.size() < 1:
		print("FAIL: overlay has no pieces. pieces=", overlay._pieces.size())
		quit(1); return
	print("Overlay pieces: ", overlay._pieces.size())

	# Set the test target to a unique level (so we don't overwrite real saves).
	gp.current_level_id = 97
	# Re-call set_puzzle / refresh pieces because level_id changed.
	overlay.set_puzzle(gp.puzzle_controller)
	overlay._refresh_pieces()
	print("After re-refresh (level 97): ", overlay._pieces.size(), " pieces")

	# Synthesize a drag commit: pretend user dragged piece 0 to (200, 300).
	var first = overlay._pieces[0]
	first["center"] = Vector2(200, 300)
	# New signature (idx, drop_pos): drop_pos = the local mouse position at release.
	overlay._commit_move(0, first["center"] + Vector2(40, 40))

	# Verify JSON file at 97.json exists and parses back correctly.
	var path := "res://data/user_levels/97.json"
	if not FileAccess.file_exists(path):
		print("FAIL: 97.json not written")
		quit(1); return
	var def = UserLevelsScript.build(97)
	if def == null:
		print("FAIL: UserLevelsScript.build(97) returned null")
		quit(1); return
	print("OK: 97.json saved and round-trip-readable; pieces=", def.pieces.size(),
		  " links=", def.links.size())
	if def.pieces.size() < 1:
		print("FAIL: persisted 97.json has 0 pieces")
		quit(1); return

	# Clean up the test file.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("TEST PASS: edit-overlay saves level data correctly.")
	quit(0)
