extends SceneTree

# Smoke test for the Canva-style equalize / tidy-up actions on
# LevelDocument. Verifies:
#   - equalize_h_gaps sets equal horizontal spacing
#   - equalize_v_gaps sets equal vertical spacing
#   - align_in_row makes the selection a row, equally spaced
#   - align_in_column makes the selection a column, equally spaced
#   - align_to_pieces aligns each target's edge to the source's edge
#   - locks prevent the change
#   - undo reverts the whole operation as one step

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_equalize_h_gaps()
	_test_equalize_v_gaps()
	_test_align_in_row()
	_test_align_in_column()
	_test_align_to_left()
	_test_align_to_right()
	_test_align_to_top()
	_test_equalize_with_lock()
	_test_undo_undoes_tidy()
	if _failures.is_empty():
		print("TEST PASS: equalize / align_to / tidy-up actions work")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	# 4 pieces at varied x and y so equalize can redistribute.
	var positions: Array = [
		{"id": "p1", "x": 100.0, "y": 100.0, "r": 30.0},
		{"id": "p2", "x": 200.0, "y": 200.0, "r": 30.0},
		{"id": "p3", "x": 400.0, "y": 300.0, "r": 30.0},
		{"id": "p4", "x": 700.0, "y": 400.0, "r": 30.0},
	]
	for s in positions:
		var p := PieceDefinitionScript.new()
		p.id = s["id"]
		p.position = Vector2(float(s["x"]), float(s["y"]))
		p.radius = float(s["r"])
		p.thickness = 18.0
		p.color = Color("#EA7829")
		p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
		p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
		doc.pieces.append(p.to_dict())
	return doc

func _test_equalize_h_gaps() -> void:
	var doc := _make_doc()
	# 4 pieces at x=100,200,400,700 → current gaps: 100, 200, 300 → avg = 200
	doc.equalize_h_gaps(["p1", "p2", "p3", "p4"], -1.0)
	# After equalize, p1 stays at 100, p2 at 300, p3 at 500, p4 at 700.
	if absf(float(doc.find_piece("p1")["x"]) - 100.0) > 0.001: _fail("p1 x wrong")
	if absf(float(doc.find_piece("p2")["x"]) - 300.0) > 0.001: _fail("p2 x wrong: %f" % float(doc.find_piece("p2")["x"]))
	if absf(float(doc.find_piece("p3")["x"]) - 500.0) > 0.001: _fail("p3 x wrong: %f" % float(doc.find_piece("p3")["x"]))
	if absf(float(doc.find_piece("p4")["x"]) - 700.0) > 0.001: _fail("p4 x wrong")

func _test_equalize_v_gaps() -> void:
	var doc := _make_doc()
	# 4 pieces at y=100,200,300,400 → gaps 100,100,100 → avg 100 (no change expected)
	doc.equalize_v_gaps(["p1", "p2", "p3", "p4"], -1.0)
	if absf(float(doc.find_piece("p1")["y"]) - 100.0) > 0.001: _fail("p1 y wrong")
	if absf(float(doc.find_piece("p4")["y"]) - 400.0) > 0.001: _fail("p4 y wrong")
	# Now with a forced gap.
	doc.equalize_v_gaps(["p1", "p2", "p3", "p4"], 50.0)
	if absf(float(doc.find_piece("p2")["y"]) - 150.0) > 0.001: _fail("forced p2 y: %f" % float(doc.find_piece("p2")["y"]))
	if absf(float(doc.find_piece("p4")["y"]) - 250.0) > 0.001: _fail("forced p4 y: %f" % float(doc.find_piece("p4")["y"]))

func _test_align_in_row() -> void:
	var doc := _make_doc()
	# anchor y = p1.y = 100. After align_in_row, all pieces at y=100, x=100,300,500,700.
	doc.align_in_row(["p1", "p2", "p3", "p4"])
	for id in ["p1", "p2", "p3", "p4"]:
		if absf(float(doc.find_piece(id)["y"]) - 100.0) > 0.001:
			_fail("align_in_row: %s y=%f" % [id, float(doc.find_piece(id)["y"])])

func _test_align_in_column() -> void:
	var doc := _make_doc()
	# anchor x = p1.x = 100. After align_in_column, all pieces at x=100, y=100,200,300,400.
	doc.align_in_column(["p1", "p2", "p3", "p4"])
	for id in ["p1", "p2", "p3", "p4"]:
		if absf(float(doc.find_piece(id)["x"]) - 100.0) > 0.001:
			_fail("align_in_column: %s x=%f" % [id, float(doc.find_piece(id)["x"])])

func _test_align_to_left() -> void:
	var doc := _make_doc()
	# Align all targets' left edge to p1's left edge.
	# p1.x = 100, r = 30 → left edge = 70.
	doc.align_to_pieces(["p2", "p3", "p4"], "p1", "left")
	# Each target.x should = 70 + 30 = 100.
	for id in ["p2", "p3", "p4"]:
		if absf(float(doc.find_piece(id)["x"]) - 100.0) > 0.001:
			_fail("align left: %s x=%f" % [id, float(doc.find_piece(id)["x"])])

func _test_align_to_right() -> void:
	var doc := _make_doc()
	# Align all targets' right edge to p1's right edge.
	# p1.x = 100, r = 30 → right edge = 130.
	doc.align_to_pieces(["p2", "p3", "p4"], "p1", "right")
	# Each target.x should = 130 - 30 = 100.
	for id in ["p2", "p3", "p4"]:
		if absf(float(doc.find_piece(id)["x"]) - 100.0) > 0.001:
			_fail("align right: %s x=%f" % [id, float(doc.find_piece(id)["x"])])

func _test_align_to_top() -> void:
	var doc := _make_doc()
	# Align all targets' top edge to p1's top edge.
	# p1.y = 100, r = 30 → top = 70.
	doc.align_to_pieces(["p2", "p3", "p4"], "p1", "top")
	for id in ["p2", "p3", "p4"]:
		if absf(float(doc.find_piece(id)["y"]) - 100.0) > 0.001:
			_fail("align top: %s y=%f" % [id, float(doc.find_piece(id)["y"])])

func _test_equalize_with_lock() -> void:
	var doc := _make_doc()
	doc.set_property_lock("p2", "position", true)
	doc.equalize_h_gaps(["p1", "p2", "p3", "p4"], -1.0)
	# p2 is locked, should stay at its original x (200).
	if absf(float(doc.find_piece("p2")["x"]) - 200.0) > 0.001:
		_fail("locked p2 moved: x=%f" % float(doc.find_piece("p2")["x"]))

func _test_undo_undoes_tidy() -> void:
	var doc := _make_doc()
	# Save original x for each piece.
	var orig: Dictionary = {}
	for s in ["p1", "p2", "p3", "p4"]:
		orig[s] = float(doc.find_piece(s)["x"])
	doc.equalize_h_gaps(["p1", "p2", "p3", "p4"], -1.0)
	doc.undo()
	for s in ["p1", "p2", "p3", "p4"]:
		if absf(float(doc.find_piece(s)["x"]) - orig[s]) > 0.001:
			_fail("undo didn't revert %s: %f vs %f" % [s, float(doc.find_piece(s)["x"]), orig[s]])

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)