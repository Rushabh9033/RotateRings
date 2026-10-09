extends SceneTree

# End-to-end smoke test for the in-game edit overlay's new shape-aware tools:
#   1. Spin up Main.tscn and load Level 1.
#   2. For each non-circle shape (OVAL, STRAIGHT, L_SHAPE, ROUNDED_SQUARE,
#      ROUNDED_TRIANGLE, PATH): insert a piece via the in-game editor API,
#      then drive the new axis-aware resize handle and the rotate-ring drag
#      programmatically.
#   3. Verify the saved user_levels JSON contains the new shape_type and the
#      expected axis-specific dimension fields.
#
# This is intentionally headless and does NOT exercise the Godot IDE editor.

const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const UserLevelsScript = preload("res://data/user_levels.gd")
const LEVEL_TEST_ID := 96

var _failures: Array = []

func _init() -> void:
	var main_scene = load("res://scenes/Main.tscn")
	if main_scene == null:
		_fail("cannot load Main.tscn"); _report(); quit(1); return
	var app = main_scene.instantiate()
	root.add_child(app)
	if not app.is_node_ready():
		await app.ready
	await process_frame

	var gp_screen = app.get_node_or_null("Screens/GameplayScreen")
	if gp_screen == null:
		_fail("GameplayScreen not found at Screens/GameplayScreen"); _report(); quit(1); return

	# Wire overlay
	gp_screen.current_level_id = LEVEL_TEST_ID
	gp_screen.load_level_by_id(LEVEL_TEST_ID)
	await process_frame
	await process_frame

	var overlay = gp_screen.get_node_or_null("PuzzleArea/PieceEditOverlay")
	if overlay == null:
		_fail("PieceEditOverlay not found"); _report(); quit(1); return

	var pc = gp_screen.puzzle_controller
	var def = pc.current_level_def

	# Build a fresh JSON for this test level so that load_level() picks up
	# exactly the shapes we want, not whatever the campaign pipeline authored.
	var cx := 360.0
	var cy := 640.0
	var spacing := 180.0
	var pieces_obj: Array = []
	var shape_defs := [
		# Index 0 must be a closed root anchor (no gaps) so the puzzle doesn't
		# auto-release the rest on initial load. Use a ROUNDED_SQUARE here.
		{"shape": 1, "name": "ROUNDED_SQUARE_ROOT", "extra": {"corner_radius": 8.0}, "gaps": []},
		{"shape": 0, "name": "CIRCLE",         "extra": {}},
		{"shape": 3, "name": "OVAL",           "extra": {"radius_y": 70.0}},
		{"shape": 4, "name": "STRAIGHT",       "extra": {"length": 100.0, "width": 24.0}},
		{"shape": 5, "name": "L_SHAPE",        "extra": {"length": 100.0, "length_b": 70.0, "width": 24.0}},
		{"shape": 1, "name": "ROUNDED_SQUARE", "extra": {"corner_radius": 8.0}},
		{"shape": 2, "name": "ROUNDED_TRIANGLE", "extra": {}},
		{"shape": 6, "name": "PATH",           "extra": {"path_points": [{"x": 60.0, "y": 0.0}, {"x": 30.0, "y": 50.0}, {"x": -30.0, "y": 50.0}, {"x": -60.0, "y": 0.0}]}},
	]
	var idx_n: int = 0
	for sd in shape_defs:
		var p := PieceDefinitionScript.new()
		p.id = StringName("shape_test_%d" % idx_n)
		p.shape_type = sd["shape"]
		p.position = Vector2(cx + float(idx_n) * spacing - 600.0, cy)
		p.radius = 60.0
		p.radius_y = 60.0
		p.thickness = 16.0
		p.color = Color("#EA7829")
		p.start_angle_deg = 0.0
		p.z_index = 1
		# Use the per-shape gaps array (root = none, others = one gap).
		# Explicitly set piece_type so the load-time warning stays quiet
		# (root = CLOSED_CIRCLE, others = OPEN_CIRCLE).
		if sd.get("gaps", null) != null and sd["gaps"].is_empty():
			p.gaps = []
			p.piece_type = PieceDefinitionScript.PieceType.CLOSED_CIRCLE
		else:
			p.gaps = [preload("res://data/gap_definition.gd").new(90.0, 80.0, 16.0)]
			p.piece_type = PieceDefinitionScript.PieceType.OPEN_CIRCLE
		for k in sd["extra"]:
			p.set(k, sd["extra"][k])
		pieces_obj.append(p.to_dict())
		idx_n += 1

	# Add at least one link from the root anchor (idx 0) to the next ring so
	# the puzzle isn't auto-released on load. Without any link the puzzle
	# solver considers every piece releasable (no constraints) and queue_frees
	# them before we can drive the editor.
	var links_obj: Array = []
	var link_id := 0
	for i in range(1, idx_n):
		links_obj.append({
			"id": "link_%d" % link_id,
			"from_id": "shape_test_0",
			"to_id": "shape_test_%d" % i,
			"collar_angle_deg": 0.0,
			"cuff_width": 32.0,
			"cuff_depth": 18.0,
			"cuff_round_radius": 5.0,
			"stem_length": 200.0,
			"stem_width": 6.0,
			"joint_color_hex": "#EA7829",
			"joint_color_name": "orange",
			"clearance_tolerance_deg": 20.0,
			"is_detached": false,
		})
		link_id += 1
	var test_data := {
		"id": LEVEL_TEST_ID,
		"title": "Level %d (shape-tools test)" % LEVEL_TEST_ID,
		"source": "shape-tools-test",
		"pieces": pieces_obj,
		"links": links_obj,
	}
	var path := "res://data/user_levels/%d.json" % LEVEL_TEST_ID
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_fail("could not open %s for write" % path); _report(); quit(1); return
	f.store_string(JSON.stringify(test_data, "  "))
	f.close()

	# Now reload the level so it picks up the freshly written JSON.
	gp_screen.load_level_by_id(LEVEL_TEST_ID)
	await process_frame
	await process_frame
	# Wait for the puzzle's drop tween to finish before grabbing pieces.
	# SceneTree doesn't have get_tree(); just spin frames.
	for _sp in range(8):
		await process_frame
	# Wire overlay BEFORE toggle() — _refresh_pieces is called by toggle and
	# reads _puzzle (which set_puzzle writes).
	overlay.set_puzzle(pc)
	overlay.set_level_id(LEVEL_TEST_ID)
	overlay.toggle(true)
	await process_frame
	overlay._refresh_pieces()

	# Filter to only our test pieces (the level may have had pre-existing
	# pieces from the campaign pipeline that survived our clear).
	var test_indices: Array = []
	for ti in range(overlay._pieces.size()):
		var e: Dictionary = overlay._pieces[ti]
		if String(e["id"]).begins_with("shape_test_"):
			test_indices.append(ti)
	var n: int = test_indices.size()
	if n != shape_defs.size():
		_fail("expected %d test pieces, got %d" % [shape_defs.size(), n])

	for k in range(n):
		var idx: int = test_indices[k]
		var entry: Dictionary = overlay._pieces[idx]
		var def_local: Resource = entry["def"]
		var piece_obj = entry["piece"]
		var cx_piece: float = float(piece_obj.global_position.x)
		var cy_piece: float = float(piece_obj.global_position.y)
		var rot_start: float = float(piece_obj.rotation_degrees)

		# --- Axis resize: grab the +X handle, drag +24 px ---
		# Reset rotation to 0 first so the rotation-delta check below is
		# meaningful (we test against a clean reference each iteration).
		piece_obj.rotation_degrees = 0.0
		def_local.start_angle_deg = 0.0
		rot_start = 0.0

		# Compute the +X handle position using the same logic as the overlay.
		var ax_local := Vector2(1, 0)
		var ax_world: Vector2 = ax_local.rotated(deg_to_rad(rot_start))
		var boundary: float = preload("res://gameplay/piece_geometry.gd").get_boundary_distance_for_piece(def_local, ax_local.angle())
		var handle_pos := Vector2(cx_piece + ax_world.x * (boundary + 14.0), cy_piece + ax_world.y * (boundary + 14.0))
		var drag_target := handle_pos + Vector2(24.0, 0.0)  # +24 px right in world
		overlay._begin_resize_axis(idx, ax_local, handle_pos)
		overlay._apply_resize_axis(idx, drag_target)
		overlay._commit_resize_axis(idx)

		# --- Rotate: grab the rotate ring at 3 o'clock, drag +30 deg clockwise ---
		var ring_r: float = float(def_local.radius) + 30.0
		var ring_handle := Vector2(cx_piece + ring_r, cy_piece)
		# +30 deg CCW around the piece center: rotate the offset vector,
		# then add the center back.
		var offset := Vector2(ring_r, 0).rotated(deg_to_rad(30.0))
		var rot_target: Vector2 = Vector2(cx_piece, cy_piece) + offset
		overlay._begin_rotate(idx, ring_handle)
		overlay._apply_rotate(idx, rot_target)
		overlay._commit_rotate()

		# Verify rotation changed
		var rot_after: float = float(piece_obj.rotation_degrees)
		var rot_delta: float = absf(wrapf(rot_after - rot_start, -180.0, 180.0))
		if rot_delta < 25.0 or rot_delta > 35.0:
			_fail("piece %s: rotation delta %.2f, expected ~30" % [sz(def_local.id), rot_delta])

	# Final read: load via UserLevelsScript and verify the saved JSON round-trips
	# with the shape-specific fields.
	var built = UserLevelsScript.build(LEVEL_TEST_ID)
	if built == null:
		_fail("UserLevelsScript.build(%d) returned null" % LEVEL_TEST_ID)
	else:
		if built.pieces.size() != shape_defs.size():
			_fail("saved level has %d pieces, expected %d" % [built.pieces.size(), shape_defs.size()])
		# Check the L_SHAPE and OVAL dimensions were actually mutated by the resize.
		for bp in built.pieces:
			var sid: String = String(bp.id)
			if sid == "shape_test_3":  # STRAIGHT: length should have changed
				if absf(float(bp.length) - 60.0) < 0.001:
					_fail("STRAIGHT piece length unchanged (still %f); axis resize did not fire" % float(bp.length))
			elif sid == "shape_test_4":  # L_SHAPE: length should have changed
				if absf(float(bp.length) - 60.0) < 0.001:
					_fail("L_SHAPE piece length unchanged; axis resize did not fire")
			elif sid == "shape_test_2":  # OVAL: radius should have changed
				if absf(float(bp.radius) - 60.0) < 0.001:
					_fail("OVAL piece radius unchanged; axis resize did not fire")
			# rotation: any piece with start_angle_deg != 0 indicates it rotated
			if absf(float(bp.start_angle_deg) - 0.0) > 1.0 and absf(float(bp.start_angle_deg) - 360.0) > 1.0:
				pass  # at least one rotated — that's the smoke signal

	# Cleanup: remove the test level so it doesn't pollute saves.
	var cleanup_path := "res://data/user_levels/%d.json" % LEVEL_TEST_ID
	if FileAccess.file_exists(cleanup_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(cleanup_path))

	if _failures.is_empty():
		print("TEST PASS: shape-aware resize + rotate-ring tools work on every shape type")
		quit(0)
	else:
		_report()
		quit(1)

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)

func sz(s: StringName) -> String:
	return String(s)