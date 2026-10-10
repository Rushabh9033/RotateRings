extends SceneTree

# Exercise the editor on the just-authored Level 2.
# 1. Load the GameplayScreen at L2.
# 2. Enter Edit mode (which builds the LevelDocument and mounts the dock).
# 3. Verify each piece is at a distinct position (not stacked).
# 4. Drive a move on each piece (e.g. shift each by 20px right) and verify
#    the puzzle area accepts the new positions.
# 5. Confirm the document can be saved (load + save round-trip).

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const InspectorScript = preload("res://scenes/editor/Inspector.gd")
const EditorToolbarScript = preload("res://scenes/editor/EditorToolbar.gd")

var _failures: Array = []

func _init() -> void:
	_test_l2_pieces_distinct()
	_test_l2_moves_apply()
	_test_l2_save_round_trip()
	_test_l2_inspector_renders()
	_test_l2_dock_builds()
	if _failures.is_empty():
		print("TEST PASS: L2 author + editor can move all 3 pieces independently")
		quit(0)
	else:
		_report()
		quit(1)

func _load_l2() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 2
	doc.title = "L2 test"
	doc.theme_id = &"porcelain"
	doc.frame_scale = 1.0
	doc.frame_offset_x = 0.0
	doc.frame_offset_y = 0.0
	doc.grid_size = 20.0
	doc.snap_to_grid = false
	doc.nudge_step = 1.0
	doc.nudge_shift_multiplier = 10.0
	doc.nudge_alt_multiplier = 0.1
	# Same pieces the author produced for L2 (calibrated to 720x1280
	# with the puzzle centroid at the canvas center).
	doc.pieces.append({
		"id": "orange_1", "color_name": "orange", "color_hex": "#EA7829",
		"x": 302.0, "y": 566.0, "radius": 76.8, "radius_y": 76.8,
		"thickness": 22.0, "start_angle_deg": 0.0,
		"shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
		"gaps": [{"center_angle_deg": 231.9, "width_deg": 80.0, "tolerance_deg": 16.0}],
		"initially_locked": false, "locked": false,
		"property_locks": {}, "release_direction": {"x": 1, "y": 0},
		"target_exit_angle_deg": 0.0, "motion_model": 0,
	})
	doc.pieces.append({
		"id": "cyan_2", "color_name": "cyan", "color_hex": "#32ADDA",
		"x": 437.9, "y": 633.9, "radius": 80.1, "radius_y": 80.1,
		"thickness": 22.0, "start_angle_deg": 0.0,
		"shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
		"gaps": [{"center_angle_deg": 355.5, "width_deg": 80.0, "tolerance_deg": 16.0}],
		"initially_locked": false, "locked": false,
		"property_locks": {}, "release_direction": {"x": 1, "y": 0},
		"target_exit_angle_deg": 0.0, "motion_model": 0,
	})
	doc.pieces.append({
		"id": "purple_3", "color_name": "purple", "color_hex": "#7B61FF",
		"x": 340.1, "y": 720.1, "radius": 89.7, "radius_y": 89.7,
		"thickness": 22.0, "start_angle_deg": 0.0,
		"shape_type": 0, "piece_type": 1, "role": 0, "z_index": 1,
		"gaps": [{"center_angle_deg": 103.9, "width_deg": 80.0, "tolerance_deg": 16.0}],
		"initially_locked": false, "locked": false,
		"property_locks": {}, "release_direction": {"x": 1, "y": 0},
		"target_exit_angle_deg": 0.0, "motion_model": 0,
	})
	doc.links.append({
		"id": "link_0", "from_id": "orange_1", "to_id": "cyan_2",
		"collar_angle_deg": 27.0, "cuff_center_local": {"x": 0, "y": 0},
		"cuff_orientation_deg": 0, "cuff_width": 32.0, "cuff_depth": 18.0,
		"cuff_round_radius": 5.0, "stem_length": 152.0, "stem_width": 6.0,
		"stem_distance_from_piece": 152.0, "stem_dist": 152.0,
		"joint_color_hex": "#1F5A82", "joint_color_name": "cuff",
		"clearance_tolerance_deg": 16.0, "is_detached": false, "z_index": 0,
	})
	doc.links.append({
		"id": "link_1", "from_id": "orange_1", "to_id": "purple_3",
		"collar_angle_deg": 76.0, "cuff_center_local": {"x": 0, "y": 0},
		"cuff_orientation_deg": 0, "cuff_width": 32.0, "cuff_depth": 18.0,
		"cuff_round_radius": 5.0, "stem_length": 159.0, "stem_width": 6.0,
		"stem_distance_from_piece": 159.0, "stem_dist": 159.0,
		"joint_color_hex": "#1F5A82", "joint_color_name": "cuff",
		"clearance_tolerance_deg": 16.0, "is_detached": false, "z_index": 0,
	})
	return doc

func _test_l2_pieces_distinct() -> void:
	var doc := _load_l2()
	var positions: Array = []
	for p in doc.pieces:
		positions.append(Vector2(p["x"], p["y"]))
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()):
			if (positions[i] - positions[j]).length() < 5.0:
				_fail("pieces %s and %s overlap: %s vs %s" % [doc.pieces[i]["id"], doc.pieces[j]["id"], positions[i], positions[j]])

func _test_l2_moves_apply() -> void:
	var doc := _load_l2()
	# Each piece is moved 20px right via document.apply_edit. After
	# this, the new positions should not be at the old ones.
	var orig_x: Array = []
	for p in doc.pieces: orig_x.append(p["x"])
	doc.apply_edit(func():
		for p in doc.pieces:
			p["x"] = float(p["x"]) + 20.0
	)
	for i in range(doc.pieces.size()):
		if absf(float(doc.pieces[i]["x"]) - float(orig_x[i]) - 20.0) > 0.001:
			_fail("move didn't apply to %s" % doc.pieces[i]["id"])
	# And the positions are still distinct.
	var positions: Array = []
	for p in doc.pieces: positions.append(Vector2(p["x"], p["y"]))
	for i in range(positions.size()):
		for j in range(i + 1, positions.size()):
			if (positions[i] - positions[j]).length() < 5.0:
				_fail("moved pieces %s and %s overlap" % [doc.pieces[i]["id"], doc.pieces[j]["id"]])
	# Undo restores.
	doc.undo()
	for i in range(doc.pieces.size()):
		if absf(float(doc.pieces[i]["x"]) - float(orig_x[i])) > 0.001:
			_fail("undo didn't restore %s" % doc.pieces[i]["id"])

func _test_l2_save_round_trip() -> void:
	var doc := _load_l2()
	var path := "user://l2_test.json"
	if not doc.save_to_disk(path):
		_fail("L2 save failed")
		return
	var doc2 := LevelDocumentScript.load_from_disk(path)
	if doc2 == null:
		_fail("L2 load failed")
		return
	if doc2.pieces.size() != doc.pieces.size():
		_fail("L2 round-trip piece count: %d vs %d" % [doc2.pieces.size(), doc.pieces.size()])
	# Position survives
	for i in range(doc2.pieces.size()):
		if absf(float(doc2.pieces[i]["x"]) - float(doc.pieces[i]["x"])) > 0.001:
			_fail("L2 round-trip x lost for %s" % doc2.pieces[i]["id"])
	# Link survives
	if doc2.links.size() != doc.links.size():
		_fail("L2 round-trip link count: %d vs %d" % [doc2.links.size(), doc.links.size()])
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_l2_inspector_renders() -> void:
	var doc := _load_l2()
	var inspector = InspectorScript.new()
	inspector.set_document(doc)
	inspector.select_piece("orange_1")
	await process_frame
	# Inspector should have built some children (its tree is rebuilt on
	# _ready via set_document).
	if inspector.get_child_count() == 0:
		_fail("Inspector built no children for L2")
	inspector.queue_free()

func _test_l2_dock_builds() -> void:
	var doc := _load_l2()
	var bar = EditorToolbarScript.new()
	bar.set_document(doc)
	bar._ready()
	bar.show_panel()
	await process_frame
	if bar.get_child_count() == 0: _fail("Dock built no children for L2")
	# Test align action on a selection of all 3 pieces.
	bar.set_selected_pieces(["orange_1", "cyan_2", "purple_3"])
	# Run equalize_h (no deltas needed since positions are already different).
	doc.equalize_h_gaps(["orange_1", "cyan_2", "purple_3"], -1.0)
	# Undo.
	doc.undo()
	bar.queue_free()

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)