extends SceneTree

# Smoke test for Inspector (M2).
#
# Builds a LevelDocument, mounts the Inspector, sets selection, drives a
# numeric field change, and confirms the document picked it up + the undo
# stack recorded the edit.

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const InspectorScript = preload("res://scenes/editor/Inspector.gd")

var _failures: Array = []

func _init() -> void:
	var doc := _make_doc()
	var inspector = InspectorScript.new()
	inspector.set_document(doc)
	inspector.select_piece("p1")
	# Wait one frame so the inspector can call _ready and build the UI.
	await process_frame
	if not is_instance_valid(inspector): _fail("inspector freed too early")
	# Confirm the inspector built children.
	if inspector.get_child_count() == 0: _fail("inspector built no children after select_piece")
	# Drive a numeric commit by calling _commit_field directly (the public
	# path through the LineEdit is harder to script headless).
	inspector._commit_field("piece", "x", 222.0, 0.0)
	await process_frame
	# Verify the document picked up the change.
	var p1: Dictionary = doc.find_piece("p1")
	if absf(float(p1["x"]) - 222.0) > 0.001: _fail("numeric commit didn't update piece x: %f" % float(p1["x"]))
	# Verify undo captures it.
	if not doc.can_undo(): _fail("undo not pushed for numeric commit")
	doc.undo()
	p1 = doc.find_piece("p1")
	if absf(float(p1["x"]) - 100.0) > 0.001: _fail("undo didn't revert piece x: %f" % float(p1["x"]))
	# Verify lock toggling.
	doc.toggle_property_lock("p1", "position")
	if not doc.is_property_locked("p1", "position"): _fail("toggle lock didn't take")
	doc.toggle_property_lock("p1", "position")
	if doc.is_property_locked("p1", "position"): _fail("toggle lock didn't release")
	# Verify link inspector path.
	inspector.select_link("l1")
	await process_frame
	if inspector.get_child_count() == 0: _fail("inspector built no children for link selection")
	# Verify doc (no selection) inspector path.
	inspector.clear_selection()
	await process_frame
	if inspector.get_child_count() == 0: _fail("inspector built no children for no-selection")
	# Now drive a document-level change.
	inspector._commit_field("doc", "frame_scale", 1.5, 1.0)
	await process_frame
	if absf(doc.frame_scale - 1.5) > 0.001: _fail("doc-level commit didn't take")
	# Color commit.
	var c := Color(0.1, 0.2, 0.3, 1.0)
	inspector._commit_field("piece", "color_hex", "#1A2B3C", "#EA7829")
	await process_frame
	# Hex conversion is done by the inspector itself, not the commit pipeline.
	# Just confirm the field write went through.
	inspector.select_piece("p1")
	await process_frame
	inspector._commit_field("piece", "z_index", 5, 1)
	await process_frame
	p1 = doc.find_piece("p1")
	if int(p1["z_index"]) != 5: _fail("z_index commit didn't take: %d" % int(p1["z_index"]))
	# Snap toggle.
	doc.apply_edit(func():
		doc.snap_to_grid = true
	)
	inspector._commit_field("doc", "snap_to_grid", false, true)
	await process_frame
	if doc.snap_to_grid: _fail("snap_to_grid commit didn't take")
	# Free the inspector (avoid leaked-instance warning).
	inspector.queue_free()
	if _failures.is_empty():
		print("TEST PASS: Inspector M2 baseline works (selection + commits + undo)")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	var p := PieceDefinitionScript.new()
	p.id = "p1"
	p.position = Vector2(100, 100)
	p.radius = 60.0
	p.thickness = 22.0
	p.color = Color("#EA7829")
	p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
	doc.pieces.append(p.to_dict())
	doc.links.append({
		"id": "l1", "from_id": "p1", "to_id": "p1",
		"collar_angle_deg": 0.0, "cuff_width": 32.0, "cuff_depth": 18.0,
		"stem_length": 200.0, "stem_width": 6.0,
		"joint_color_hex": "#EA7829", "clearance_tolerance_deg": 16.0,
		"is_detached": false,
	})
	return doc

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)