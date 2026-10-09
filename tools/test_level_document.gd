extends SceneTree

# Smoke test for LevelDocument (M1).
#
# Verifies:
#   - from_level_definition round-trip
#   - save_to_disk + load_from_disk
#   - apply_edit pushes undo snapshots and sets dirty
#   - undo() / redo() restore exact state
#   - locks toggle
#   - guides add / remove
#   - snap_to_grid math
#   - size_links apply_size_link_for_field
#   - generate_unique_piece_id doesn't collide

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_round_trip()
	_test_save_load()
	_test_undo_redo()
	_test_locks()
	_test_guides()
	_test_snap()
	_test_size_link()
	_test_unique_id()
	if _failures.is_empty():
		print("TEST PASS: LevelDocument M1 baseline works")
		quit(0)
	else:
		_report()
		quit(1)

func _test_round_trip() -> void:
	var def = _make_test_level_def()
	var doc := LevelDocumentScript.from_level_definition(def)
	if doc.pieces.size() != def.pieces.size():
		_fail("from_level_definition dropped pieces: %d vs %d" % [doc.pieces.size(), def.pieces.size()])
	if doc.links.size() != def.links.size():
		_fail("from_level_definition dropped links: %d vs %d" % [doc.links.size(), def.links.size()])
	# Round-trip back to a LevelDefinition and confirm equality on key fields.
	var def2 = doc.to_level_definition()
	if def2.pieces.size() != def.pieces.size():
		_fail("to_level_definition dropped pieces")
	# Check that the radius field round-trips.
	var original_radius: float = float(def.pieces[0].radius)
	var rt_radius: float = float(def2.pieces[0].radius)
	if absf(original_radius - rt_radius) > 0.001:
		_fail("radius round-trip drift: %.3f vs %.3f" % [original_radius, rt_radius])

func _test_save_load() -> void:
	var doc := LevelDocumentScript.new()
	doc.level_id = 99
	doc.title = "M1 test"
	doc.frame_scale = 1.25
	doc.frame_offset_x = 10.0
	doc.frame_offset_y = -5.0
	var p := PieceDefinitionScript.new()
	p.id = "p1"
	p.position = Vector2(123, 456)
	p.radius = 70.0
	p.thickness = 18.0
	p.color = Color("#EA7829")
	p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
	doc.pieces.append(p.to_dict())
	var path := "user://level_document_test.json"
	if not doc.save_to_disk(path):
		_fail("save_to_disk returned false")
		return
	var doc2 := LevelDocumentScript.load_from_disk(path)
	if doc2 == null:
		_fail("load_from_disk returned null")
		return
	if doc2.level_id != 99: _fail("level_id lost on save/load")
	if absf(doc2.frame_scale - 1.25) > 0.001: _fail("frame_scale lost")
	if absf(doc2.frame_offset_x - 10.0) > 0.001: _fail("frame_offset_x lost")
	if doc2.pieces.size() != 1: _fail("pieces count lost")
	if absf(float(doc2.pieces[0]["x"]) - 123.0) > 0.001: _fail("piece x lost")
	if absf(float(doc2.pieces[0]["y"]) - 456.0) > 0.001: _fail("piece y lost")
	if absf(float(doc2.pieces[0]["radius"]) - 70.0) > 0.001: _fail("piece radius lost")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _test_undo_redo() -> void:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	doc.pieces.append({"id": "p1", "x": 100.0, "y": 100.0, "radius": 60.0})
	doc.pieces.append({"id": "p2", "x": 200.0, "y": 200.0, "radius": 60.0})
	if doc.can_undo(): _fail("can_undo should be false on a fresh doc")
	# Edit 1: move p1 to (300, 300).
	doc.apply_edit(func():
		doc.pieces[0]["x"] = 300.0
		doc.pieces[0]["y"] = 300.0
	)
	if not doc.can_undo(): _fail("can_undo false after edit")
	if absf(float(doc.pieces[0]["x"]) - 300.0) > 0.001: _fail("edit didn't apply")
	# Edit 2: change p2's radius.
	doc.apply_edit(func():
		doc.pieces[1]["radius"] = 90.0
	)
	if absf(float(doc.pieces[1]["radius"]) - 90.0) > 0.001: _fail("edit 2 didn't apply")
	# Undo once: should roll back p2 radius but keep p1 position.
	if not doc.undo(): _fail("undo() returned false")
	if absf(float(doc.pieces[1]["radius"]) - 60.0) > 0.001: _fail("undo didn't revert radius")
	if absf(float(doc.pieces[0]["x"]) - 300.0) > 0.001: _fail("undo rolled back too far")
	# Undo again: should roll back p1.
	if not doc.undo(): _fail("second undo() returned false")
	if absf(float(doc.pieces[0]["x"]) - 100.0) > 0.001: _fail("undo didn't revert position")
	if doc.can_undo(): _fail("can_undo true after exhausting stack")
	# Redo once: p1 position back.
	if not doc.redo(): _fail("redo() returned false")
	if absf(float(doc.pieces[0]["x"]) - 300.0) > 0.001: _fail("redo didn't restore position")
	# Apply a new edit: redo stack should clear.
	doc.apply_edit(func():
		doc.pieces[0]["x"] = 500.0
	)
	if doc.can_redo(): _fail("can_redo true after fresh edit (should be cleared)")

func _test_locks() -> void:
	var doc := LevelDocumentScript.new()
	doc.pieces.append({"id": "p1", "x": 100.0})
	if doc.is_property_locked("p1", "position"): _fail("default lock should be unlocked")
	doc.toggle_property_lock("p1", "position")
	if not doc.is_property_locked("p1", "position"): _fail("lock didn't take")
	doc.toggle_property_lock("p1", "position")
	if doc.is_property_locked("p1", "position"): _fail("toggle didn't release")
	doc.set_property_lock("p1", "size", true)
	if not doc.is_property_locked("p1", "size"): _fail("set_property_lock didn't take")
	var locks_dict: Dictionary = doc.get_locks("p1")
	if not locks_dict.get("size", false): _fail("get_locks returned wrong map")

func _test_guides() -> void:
	var doc := LevelDocumentScript.new()
	doc.add_guide("x", 100.0)
	doc.add_guide("y", 200.0)
	if doc.guides.size() != 2: _fail("add_guide didn't add")
	doc.remove_guide(0)
	if doc.guides.size() != 1: _fail("remove_guide didn't remove")
	if String(doc.guides[0]["axis"]) != "y": _fail("wrong guide survived")

func _test_snap() -> void:
	var doc := LevelDocumentScript.new()
	doc.grid_size = 10.0
	doc.snap_to_grid = true
	var snapped: Vector2 = doc.snap_coordinate(Vector2(103.0, 207.0))
	if absf(snapped.x - 100.0) > 0.001: _fail("snap_to_grid x wrong: %.2f" % snapped.x)
	if absf(snapped.y - 210.0) > 0.001: _fail("snap_to_grid y wrong: %.2f" % snapped.y)
	doc.snap_to_grid = false
	var unsnapped: Vector2 = doc.snap_coordinate(Vector2(103.0, 207.0))
	if absf(unsnapped.x - 103.0) > 0.001: _fail("snap should be opt-in")
	doc.add_guide("x", 200.0)
	doc.snap_to_guides = true
	var snapped_guide: Vector2 = doc.snap_coordinate(Vector2(197.0, 500.0))
	if absf(snapped_guide.x - 200.0) > 0.001: _fail("snap_to_guides not working")

func _test_size_link() -> void:
	var doc := LevelDocumentScript.new()
	doc.pieces.append({"id": "master", "radius": 70.0})
	doc.pieces.append({"id": "follower", "radius": 30.0})
	doc.link_size_to_master("follower", "master", "radius")
	doc.apply_size_link_for_field("master", "radius", 100.0)
	var follower: Dictionary = doc.find_piece("follower")
	if absf(float(follower["radius"]) - 100.0) > 0.001: _fail("size link didn't update follower")
	doc.unlink_size("follower")
	# Unlinked: changing the master must NOT change the follower.
	doc.apply_size_link_for_field("master", "radius", 50.0)
	follower = doc.find_piece("follower")
	if absf(float(follower["radius"]) - 100.0) > 0.001: _fail("unlinked follower was still updated (got %f)" % float(follower["radius"]))

func _test_unique_id() -> void:
	var doc := LevelDocumentScript.new()
	doc.pieces.append({"id": "piece_1"})
	doc.pieces.append({"id": "piece_2"})
	var new_id: String = doc.generate_unique_piece_id("piece")
	if new_id != "piece_3": _fail("unique id didn't skip existing: %s" % new_id)
	var link_id: String = doc.generate_unique_link_id("link")
	if link_id != "link_1": _fail("unique link id didn't start fresh: %s" % link_id)

# ----- helpers -----

func _make_test_level_def():
	var def = preload("res://data/level_definition.gd").new()
	def.level_id = 1
	def.title = "test"
	var p := PieceDefinitionScript.new()
	p.id = "p1"
	p.position = Vector2(100, 100)
	p.radius = 60.0
	p.thickness = 22.0
	p.color = Color("#EA7829")
	p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
	def.pieces.append(p)
	return def

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)