extends SceneTree

# Smoke test for M3: EditorClipboard + duplicate / paste / match-size.

const LevelDocumentScript = preload("res://data/level_document.gd")
const EditorClipboardScript = preload("res://data/editor_clipboard.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_duplicate()
	_test_paste()
	_test_delete()
	_test_size_clipboard()
	_test_match_size_same_shape()
	_test_match_size_different_shape()
	_test_match_size_locked()
	_test_undo_duplicate()
	if _failures.is_empty():
		print("TEST PASS: M3 (EditorClipboard + Duplicate + Match Size) works")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	var p1 := PieceDefinitionScript.new()
	p1.id = "p1"
	p1.position = Vector2(100, 100)
	p1.radius = 60.0
	p1.thickness = 22.0
	p1.color = Color("#EA7829")
	p1.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p1.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
	doc.pieces.append(p1.to_dict())
	var p2 := PieceDefinitionScript.new()
	p2.id = "p2"
	p2.position = Vector2(200, 200)
	p2.radius = 30.0  # different from p1
	p2.thickness = 16.0
	p2.color = Color("#32ADDA")
	p2.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p2.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
	doc.pieces.append(p2.to_dict())
	return doc

func _test_duplicate() -> void:
	var doc := _make_doc()
	var new_id: String = doc.duplicate_piece("p1", Vector2(40, 40))
	if new_id.is_empty(): _fail("duplicate_piece returned empty")
	if doc.pieces.size() != 3: _fail("duplicate didn't insert: pieces=%d" % doc.pieces.size())
	# New piece is at p1's (100,100) + (40,40) = (140,140).
	var dup: Dictionary = doc.find_piece(new_id)
	if absf(float(dup["x"]) - 140.0) > 0.001: _fail("dup x wrong: %f" % float(dup["x"]))
	if absf(float(dup["y"]) - 140.0) > 0.001: _fail("dup y wrong: %f" % float(dup["y"]))
	# Duplicate kept the size.
	if absf(float(dup["radius"]) - 60.0) > 0.001: _fail("dup didn't keep radius: %f" % float(dup["radius"]))
	if absf(float(dup["thickness"]) - 22.0) > 0.001: _fail("dup didn't keep thickness")
	# ID is unique.
	if String(dup["id"]) == "p1": _fail("dup id collided with source")

func _test_paste() -> void:
	var doc := _make_doc()
	var cb := EditorClipboardScript.new()
	cb.copy_object(doc.find_piece("p1"), "piece")
	var new_id: String = doc.paste_piece(cb.object, Vector2(10, 10))
	if new_id.is_empty(): _fail("paste_piece returned empty")
	if doc.pieces.size() != 3: _fail("paste didn't insert")
	# New id differs from p1.
	if new_id == "p1": _fail("paste id collided with source")

func _test_delete() -> void:
	var doc := _make_doc()
	# Add a link from p1 to p2 first.
	doc.links.append({"id": "l1", "from_id": "p1", "to_id": "p2"})
	if not doc.delete_piece("p1"): _fail("delete_piece returned false")
	if doc.pieces.size() != 1: _fail("delete_piece didn't remove piece: %d" % doc.pieces.size())
	if doc.links.size() != 0: _fail("delete_piece didn't cascade-delete link: %d" % doc.links.size())
	# Delete missing piece returns false.
	if doc.delete_piece("doesnt_exist"): _fail("delete_piece of missing piece returned true")

func _test_size_clipboard() -> void:
	var cb := EditorClipboardScript.new()
	var doc := _make_doc()
	cb.copy_size_from_piece(doc.find_piece("p1"))
	if not cb.has_size(): _fail("size clipboard empty after copy")
	if absf(float(cb.size["radius"]) - 60.0) > 0.001: _fail("size clipboard radius wrong")
	if absf(float(cb.size["thickness"]) - 22.0) > 0.001: _fail("size clipboard thickness wrong")

func _test_match_size_same_shape() -> void:
	var doc := _make_doc()
	# p2 is 30 radius, 16 thickness. Match p1's size (60, 22) onto p2.
	var n: int = doc.match_size_from_piece("p1", ["p2"])
	if n < 1: _fail("match_size returned 0")
	var p2: Dictionary = doc.find_piece("p2")
	if absf(float(p2["radius"]) - 60.0) > 0.001: _fail("match_size didn't change radius: %f" % float(p2["radius"]))
	if absf(float(p2["thickness"]) - 22.0) > 0.001: _fail("match_size didn't change thickness")

func _test_match_size_different_shape() -> void:
	var doc := LevelDocumentScript.new()
	var p1 := PieceDefinitionScript.new()
	p1.id = "circle1"
	p1.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p1.radius = 60.0
	p1.thickness = 22.0
	doc.pieces.append(p1.to_dict())
	var p2 := PieceDefinitionScript.new()
	p2.id = "oval1"
	p2.shape_type = PieceDefinitionScript.ShapeType.OVAL
	p2.radius = 30.0
	p2.radius_y = 20.0
	p2.thickness = 16.0
	doc.pieces.append(p2.to_dict())
	# Match CIRCLE size to OVAL — only common fields (radius, thickness) should copy.
	doc.match_size_from_piece("circle1", ["oval1"])
	var oval1: Dictionary = doc.find_piece("oval1")
	if absf(float(oval1["radius"]) - 60.0) > 0.001: _fail("radius didn't copy across shapes")
	if absf(float(oval1["radius_y"]) - 20.0) > 0.001: _fail("radius_y shouldn't be touched")
	if absf(float(oval1["thickness"]) - 22.0) > 0.001: _fail("thickness didn't copy across shapes")

func _test_match_size_locked() -> void:
	var doc := _make_doc()
	doc.set_property_lock("p2", "size", true)
	doc.match_size_from_piece("p1", ["p2"])
	var p2: Dictionary = doc.find_piece("p2")
	# Size lock should prevent the change.
	if absf(float(p2["radius"]) - 30.0) > 0.001: _fail("locked size still got matched: %f" % float(p2["radius"]))
	# Undo the lock so the next assertion doesn't pollute.
	doc.set_property_lock("p2", "size", false)

func _test_undo_duplicate() -> void:
	var doc := _make_doc()
	doc.duplicate_piece("p1", Vector2(40, 40))
	if doc.pieces.size() != 3: _fail("duplicate didn't insert")
	doc.undo()
	if doc.pieces.size() != 2: _fail("undo didn't revert duplicate: %d" % doc.pieces.size())

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)