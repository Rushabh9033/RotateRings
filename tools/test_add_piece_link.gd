extends SceneTree

# Smoke test for M5/M6: add_piece + add_link + multi-connector.
#
# Verifies:
#   - add_piece returns a unique id and the new piece has the full
#     schema field set (so the editor can mutate anything).
#   - add_link snaps collar_angle_deg to the world vector angle.
#   - add_link respects the 'connectors' property lock.
#   - Multi-connector: one piece can have N outgoing links.

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_add_piece_basic()
	_test_add_piece_field_set()
	_test_add_link_basic()
	_test_add_link_snap_to_vector()
	_test_add_link_locked()
	_test_multi_connector()
	_test_undo_add()
	if _failures.is_empty():
		print("TEST PASS: M5+M6 (add_piece + add_link + multi-connector) works")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	# Closed root anchor.
	var p1 := PieceDefinitionScript.new()
	p1.id = "p1"
	p1.position = Vector2(100, 100)
	p1.radius = 60.0
	p1.thickness = 22.0
	p1.color = Color("#EA7829")
	p1.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p1.gaps = []  # closed = root
	doc.pieces.append(p1.to_dict())
	return doc

func _test_add_piece_basic() -> void:
	var doc := _make_doc()
	var new_id: String = doc.add_piece(Vector2(200, 200))
	if new_id.is_empty(): _fail("add_piece returned empty")
	if doc.pieces.size() != 2: _fail("add_piece didn't insert: %d" % doc.pieces.size())
	if String(doc.pieces[1]["id"]) != new_id: _fail("id mismatch")

func _test_add_piece_field_set() -> void:
	var doc := _make_doc()
	var new_id: String = doc.add_piece()
	var p: Dictionary = doc.find_piece(new_id)
	# All the editable fields must be present so the Inspector has them.
	for field in ["x", "y", "radius", "radius_y", "thickness", "color", "color_hex",
		"shape_type", "piece_type", "role", "z_index", "gaps", "start_angle_deg",
		"length", "width", "corner_radius", "property_locks"]:
		if not p.has(field): _fail("new piece missing field: %s" % field)

func _test_add_link_basic() -> void:
	var doc := _make_doc()
	var nid: String = doc.add_piece(Vector2(200, 200))
	var link_id: String = doc.add_link("p1", nid)
	if link_id.is_empty(): _fail("add_link returned empty")
	if doc.links.size() != 1: _fail("add_link didn't insert")
	var l: Dictionary = doc.find_link(link_id)
	if String(l["from_id"]) != "p1": _fail("link from_id wrong")
	if String(l["to_id"]) != nid: _fail("link to_id wrong")

func _test_add_link_snap_to_vector() -> void:
	var doc := _make_doc()
	# Force p1's start_angle to 0 so the test is independent of the default.
	doc.pieces[0]["start_angle_deg"] = 0.0
	# p1 at (100,100), child at (200,100) → vector is +X, so collar should
	# be 0 relative to p1's start_angle_deg.
	var nid: String = doc.add_piece(Vector2(200, 100))
	var link_id: String = doc.add_link("p1", nid)
	var l: Dictionary = doc.find_link(link_id)
	var collar: float = float(l["collar_angle_deg"])
	if absf(collar) > 0.5: _fail("collar_angle_deg didn't snap to world X: %f" % collar)

func _test_add_link_locked() -> void:
	var doc := _make_doc()
	doc.set_property_lock("p1", "connectors", true)
	var nid: String = doc.add_piece(Vector2(200, 200))
	var link_id: String = doc.add_link("p1", nid)
	if not link_id.is_empty(): _fail("add_link should have refused (connectors locked)")
	if doc.links.size() != 0: _fail("add_link leaked a link despite lock")

func _test_multi_connector() -> void:
	var doc := _make_doc()
	var n1: String = doc.add_piece(Vector2(200, 200))
	var n2: String = doc.add_piece(Vector2(300, 200))
	var n3: String = doc.add_piece(Vector2(400, 200))
	# p1 now has 3 outgoing links to n1, n2, n3.
	doc.add_link("p1", n1)
	doc.add_link("p1", n2)
	doc.add_link("p1", n3)
	if doc.links.size() != 3: _fail("multi-connector link count wrong: %d" % doc.links.size())
	# Confirm p1 is from on all three.
	for l in doc.links:
		if String(l["from_id"]) != "p1": _fail("multi-connector: link from_id wrong: %s" % String(l["from_id"]))

func _test_undo_add() -> void:
	var doc := _make_doc()
	doc.add_piece(Vector2(200, 200))
	if doc.pieces.size() != 2: _fail("add_piece didn't insert")
	doc.undo()
	if doc.pieces.size() != 1: _fail("undo didn't remove added piece: %d" % doc.pieces.size())

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)