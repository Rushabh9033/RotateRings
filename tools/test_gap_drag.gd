extends SceneTree

# Smoke test for M12: gap drag handles — center + edges.
# We drive the public begin / apply / commit methods directly.

const PieceEditOverlayScript = preload("res://gameplay/piece_edit_overlay.gd")
const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_gap_center_drag()
	_test_gap_left_edge_widens()
	_test_gap_right_edge_widens()
	_test_gap_lock_ignored()
	if _failures.is_empty():
		print("TEST PASS: M12 (gap drag handles) works")
		quit(0)
	else:
		_report()
		quit(1)

func _make_overlay() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	var p := PieceDefinitionScript.new()
	p.id = "p1"
	p.position = Vector2(360, 640)
	p.radius = 100.0
	p.thickness = 22.0
	p.color = Color("#EA7829")
	p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
	p.start_angle_deg = 0.0
	p.gaps = [GapDefinitionScript.new(180.0, 60.0, 16.0)]
	doc.pieces.append(p.to_dict())
	# Build an overlay and feed it a document.
	var ov = PieceEditOverlayScript.new()
	ov.set_document(doc)
	# Manually populate _pieces with one entry, since we can't go through the
	# gameplay scene.
	ov._pieces.append({
		"id": "p1",
		"piece": null,
		"def": p,
		"center": Vector2(360, 640),
		"radius": 100.0,
		"locked": false,
	})
	return ov

func _test_gap_center_drag() -> void:
	var ov = _make_overlay()
	# Center of the gap is at 180 deg → 12 o'clock in screen-Y = (360, 540).
	# Drag from there to +30 deg CCW → new center 210.
	var start: Vector2 = Vector2(360, 640 - 100)  # gap center on the boundary
	var end: Vector2 = Vector2(360 - 50, 640 - 86.6)  # rotated +30 deg, length 100
	ov._begin_gap_drag(0, 0, int(PieceEditOverlayScript.GapDragKind.CENTER), start)
	ov._apply_gap_drag(end)
	ov._commit_gap_drag()
	var g: Resource = ov._pieces[0]["def"].gaps[0]
	var new_center: float = float(g.center_angle_deg)
	# Allow ±2 deg tolerance for boundary sampling error.
	if absf(wrapf(new_center - 210.0, -180.0, 180.0)) > 2.0:
		_fail("gap center drag: got %f expected ~210" % new_center)

func _test_gap_left_edge_widens() -> void:
	var ov = _make_overlay()
	# Left edge is at 150 deg (center 180 - width 30). Drag it 30 deg away
	# from the center (further left) → width = 60 + 60 = 120, center = 180.
	var start: Vector2 = Vector2(360 + 100 * cos(deg_to_rad(150)), 640 + 100 * sin(deg_to_rad(150)))
	# New left position 30 deg further left = 120 deg.
	var end: Vector2 = Vector2(360 + 100 * cos(deg_to_rad(120)), 640 + 100 * sin(deg_to_rad(120)))
	ov._begin_gap_drag(0, 0, int(PieceEditOverlayScript.GapDragKind.LEFT_EDGE), start)
	ov._apply_gap_drag(end)
	ov._commit_gap_drag()
	var g: Resource = ov._pieces[0]["def"].gaps[0]
	var new_width: float = float(g.width_deg)
	if absf(new_width - 120.0) > 5.0:
		_fail("gap left edge widen: got width %f expected ~120" % new_width)

func _test_gap_right_edge_widens() -> void:
	var ov = _make_overlay()
	# Right edge at 210. Drag 30 deg further right = 240.
	var start: Vector2 = Vector2(360 + 100 * cos(deg_to_rad(210)), 640 + 100 * sin(deg_to_rad(210)))
	var end: Vector2 = Vector2(360 + 100 * cos(deg_to_rad(240)), 640 + 100 * sin(deg_to_rad(240)))
	ov._begin_gap_drag(0, 0, int(PieceEditOverlayScript.GapDragKind.RIGHT_EDGE), start)
	ov._apply_gap_drag(end)
	ov._commit_gap_drag()
	var g: Resource = ov._pieces[0]["def"].gaps[0]
	var new_width: float = float(g.width_deg)
	if absf(new_width - 120.0) > 5.0:
		_fail("gap right edge widen: got width %f expected ~120" % new_width)

func _test_gap_lock_ignored() -> void:
	var ov = _make_overlay()
	ov._pieces[0]["def"].set_property_lock_value("gaps", true)
	# Hit-test should return -1 because gaps are locked.
	var hit: Array = ov._hit_test_gap_handle(Vector2(360, 540))
	if int(hit[0]) >= 0: _fail("locked gap still hit-tested: %s" % str(hit))

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)