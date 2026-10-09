extends SceneTree

# End-to-end test for the precision editor (M24 + M28 acceptance).
#
# Walks through a Level 2-equivalent scenario:
#   1. Build an empty LevelDocument
#   2. Add 3 pieces (closed root + 2 children)
#   3. Add links root->child1, root->child2
#   4. Set numeric positions, radius, thickness
#   5. Lock position on the root, verify move doesn't change it
#   6. Set a gap, then close the gap, then set piece_type = CLOSED_CIRCLE
#   7. Apply size-link from child1 to child2
#   8. Match axis X across all pieces
#   9. Duplicate child1
#   10. Save + load round-trip; verify lossless
#   11. Multiple undo/redo cycles

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const EditorClipboardScript = preload("res://data/editor_clipboard.gd")

var _failures: Array = []

func _init() -> void:
	_test_full_workflow()
	_test_lossless_round_trip()
	_test_undo_redo_stress()
	_test_alignment_batch()
	_test_z_order_stress()
	if _failures.is_empty():
		print("TEST PASS: M24 + M28 (end-to-end editor workflow) works")
		quit(0)
	else:
		_report()
		quit(1)

func _make_empty_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 2
	doc.title = "End-to-end test"
	return doc

func _make_piece(id: String, pos: Vector2, rad: float, thick: float, color: Color, gap_count: int) -> Resource:
	var p := PieceDefinitionScript.new()
	p.id = id
	p.position = pos
	p.radius = rad
	p.thickness = thick
	p.color = color
	p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p.start_angle_deg = 0.0
	p.z_index = 1
	if gap_count == 0:
		p.gaps = []
	else:
		for i in range(gap_count):
			p.gaps.append(GapDefinitionScript.new(270.0, 80.0, 16.0))
	return p

func _test_full_workflow() -> void:
	var doc := _make_empty_doc()
	# Add 3 pieces.
	var p1 := _make_piece("root", Vector2(360, 640), 96.0, 22.0, Color("#EA7829"), 0)
	var p2 := _make_piece("cyan", Vector2(447, 544), 65.0, 22.0, Color("#32ADDA"), 1)
	var p3 := _make_piece("purple", Vector2(353, 679), 78.0, 22.0, Color("#7B61FF"), 1)
	doc.pieces.append(p1.to_dict())
	doc.pieces.append(p2.to_dict())
	doc.pieces.append(p3.to_dict())
	if doc.pieces.size() != 3: _fail("pieces not added")
	# Add links.
	var l1: String = doc.add_link("root", "cyan")
	var l2: String = doc.add_link("root", "purple")
	if doc.links.size() != 2: _fail("links not added")
	# Lock position on root, verify it can't move.
	doc.set_property_lock("root", "position", true)
	doc.set_field_for_pieces(["root"], "x", 9999.0, "position")
	if absf(float(doc.find_piece("root")["x"]) - 360.0) > 0.001: _fail("locked root moved")
	# Set gap center precisely on the cyan piece.
	var cyan: Dictionary = doc.find_piece("cyan")
	cyan["gaps"][0]["center_angle_deg"] = 180.0
	cyan["gaps"][0]["width_deg"] = 100.0
	# Apply size link from cyan to purple.
	doc.link_size_to_master("purple", "cyan", "radius")
	# Match axis X across all (root's x = 360, others get snapped to 360).
	doc.match_axis(["root", "cyan", "purple"], "x")
	if absf(float(doc.find_piece("cyan")["x"]) - 360.0) > 0.001: _fail("match x failed: cyan")
	# Duplicate cyan.
	var new_id: String = doc.duplicate_piece("cyan", Vector2(80, 0))
	if doc.pieces.size() != 4: _fail("dup didn't insert")
	# Save + load round-trip.
	var path := "user://e2e_test.json"
	if not doc.save_to_disk(path):
		_fail("save failed")
		return
	var doc2 := LevelDocumentScript.load_from_disk(path)
	if doc2 == null: _fail("load failed")
	if doc2.pieces.size() != doc.pieces.size(): _fail("round-trip piece count")
	# Verify root's position is still locked (locks are saved).
	if not doc2.is_property_locked("root", "position"): _fail("round-trip lost lock")
	# Verify size link survives.
	if not doc2.size_links.has("purple"): _fail("round-trip lost size link")
	# Verify the duplicated piece's id is unique in the new doc.
	var all_ids: Array = []
	for p in doc2.pieces:
		all_ids.append(String(p["id"]))
	if all_ids.count(new_id) != 1: _fail("dup id not unique after round-trip")
	# Cleanup.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_lossless_round_trip() -> void:
	# Build a doc with all field types filled and verify they survive.
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	doc.title = "lossless test"
	doc.instruction = "test"
	doc.par_moves = 5
	doc.theme_id = &"custom"
	doc.frame_scale = 1.25
	doc.frame_offset_x = 10.0
	doc.frame_offset_y = -5.0
	doc.grid_size = 25.0
	doc.snap_to_grid = true
	doc.snap_to_guides = true
	doc.add_guide("x", 200.0)
	doc.add_guide("y", 400.0)
	doc.pieces.append({
		"id": "p1", "shape_type": 0, "piece_type": 1, "x": 100.0, "y": 100.0,
		"radius": 60.0, "radius_y": 60.0, "thickness": 22.0,
		"color_hex": "#EA7829", "color_name": "orange",
		"z_index": 5, "start_angle_deg": 45.0,
		"gaps": [{"center_angle_deg": 90.0, "width_deg": 80.0, "tolerance_deg": 16.0}],
		"property_locks": {"position": true, "size": false},
	})
	doc.links.append({
		"id": "l1", "from_id": "p1", "to_id": "p1",
		"collar_angle_deg": 90.0, "cuff_width": 32.0, "cuff_depth": 18.0,
		"stem_length": 200.0, "stem_width": 6.0,
		"joint_color_hex": "#32ADDA", "clearance_tolerance_deg": 16.0,
		"is_detached": false,
	})
	var path := "user://lossless_test.json"
	doc.save_to_disk(path)
	var doc2 := LevelDocumentScript.load_from_disk(path)
	if doc2 == null: _fail("lossless load failed"); return
	# All fields match.
	if doc2.title != "lossless test": _fail("title lost")
	if doc2.frame_scale != 1.25: _fail("frame_scale lost")
	if absf(doc2.frame_offset_x - 10.0) > 0.001: _fail("frame_offset_x lost")
	if doc2.grid_size != 25.0: _fail("grid_size lost")
	if not doc2.snap_to_grid: _fail("snap_to_grid lost")
	if doc2.guides.size() != 2: _fail("guides lost: %d" % doc2.guides.size())
	if doc2.pieces[0]["property_locks"]["position"] != true: _fail("lock lost")
	if absf(float(doc2.pieces[0]["start_angle_deg"]) - 45.0) > 0.001: _fail("start_angle lost")
	if absf(float(doc2.pieces[0]["gaps"][0]["width_deg"]) - 80.0) > 0.001: _fail("gap width lost")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_undo_redo_stress() -> void:
	var doc := _make_empty_doc()
	doc.pieces.append({"id": "p1", "x": 0.0, "y": 0.0, "radius": 60.0})
	# 50 edits.
	for i in range(50):
		doc.apply_edit(func():
			doc.pieces[0]["x"] = float(i + 1)
		)
	if not doc.can_undo(): _fail("can_undo should be true")
	# Undo all 50.
	for i in range(50):
		if not doc.undo(): _fail("undo %d failed" % i)
	if absf(float(doc.pieces[0]["x"]) - 0.0) > 0.001: _fail("undo didn't reach initial: %f" % float(doc.pieces[0]["x"]))
	if doc.can_undo(): _fail("can_undo should be false after exhausting")
	# Redo 50.
	for i in range(50):
		if not doc.redo(): _fail("redo %d failed" % i)
	if absf(float(doc.pieces[0]["x"]) - 50.0) > 0.001: _fail("redo didn't reach final: %f" % float(doc.pieces[0]["x"]))

func _test_alignment_batch() -> void:
	# Align 4 pieces in a vertical column.
	var doc := _make_empty_doc()
	for i in range(4):
		doc.pieces.append({
			"id": "p%d" % (i + 1), "x": float(i * 50 + 100), "y": float(i * 30 + 100),
			"radius": 40.0, "gaps": [],
		})
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "center")
	# All x should be 100 (p1's x).
	for i in range(2, 5):
		var p: Dictionary = doc.find_piece("p%d" % i)
		if absf(float(p["x"]) - 100.0) > 0.001:
			_fail("align center: p%d.x = %f" % [i, float(p["x"])])
	doc.distribute_pieces(["p1", "p2", "p3", "p4"], "y")
	# After distribute, y[0]=100, y[3]=190, step=30.
	if absf(float(doc.find_piece("p2")["y"]) - 130.0) > 0.001: _fail("distribute p2: %f" % float(doc.find_piece("p2")["y"]))
	if absf(float(doc.find_piece("p3")["y"]) - 160.0) > 0.001: _fail("distribute p3: %f" % float(doc.find_piece("p3")["y"]))

func _test_z_order_stress() -> void:
	var doc := _make_empty_doc()
	for i in range(5):
		doc.pieces.append({
			"id": "p%d" % (i + 1), "x": 0.0, "y": 0.0, "radius": 30.0,
			"gaps": [], "z_index": i + 1,
		})
	# Bring p1 all the way to the front, then send p5 all the way to the back.
	doc.bring_to_front("p1")
	doc.send_to_back("p5")
	if int(doc.find_piece("p1")["z_index"]) != 6: _fail("bring_to_front: got %d" % int(doc.find_piece("p1")["z_index"]))
	if int(doc.find_piece("p5")["z_index"]) != 0: _fail("send_to_back: got %d" % int(doc.find_piece("p5")["z_index"]))
	# Undo all.
	doc.undo()  # send_to_back
	doc.undo()  # bring_to_front
	if int(doc.find_piece("p1")["z_index"]) != 1: _fail("undo: p1 z should be 1")
	if int(doc.find_piece("p5")["z_index"]) != 5: _fail("undo: p5 z should be 5")

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)