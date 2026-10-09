extends SceneTree

# Smoke test for M4: per-property locks on PieceDefinition.
#
# Verifies:
#   - to_dict / apply_dict round-trip of property_locks
#   - is_property_locked returns false by default and true after set
#   - toggle flips the value
#   - get_property_locks returns a copy (not a reference)

const PieceDefinitionScript = preload("res://data/piece_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_default()
	_test_set_get()
	_test_toggle()
	_test_round_trip()
	_test_get_returns_copy()
	if _failures.is_empty():
		print("TEST PASS: M4 (per-property locks on PieceDefinition) works")
		quit(0)
	else:
		_report()
		quit(1)

func _test_default() -> void:
	var p := PieceDefinitionScript.new()
	for prop in ["position", "size", "rotation", "gaps", "motion", "visual", "connectors"]:
		if p.is_property_locked(prop):
			_fail("default lock set for %s" % prop)

func _test_set_get() -> void:
	var p := PieceDefinitionScript.new()
	p.set_property_lock_value("size", true)
	if not p.is_property_locked("size"): _fail("set size=true didn't take")
	if p.is_property_locked("position"): _fail("position should still be unlocked")
	p.set_property_lock_value("size", false)
	if p.is_property_locked("size"): _fail("set size=false didn't take")

func _test_toggle() -> void:
	var p := PieceDefinitionScript.new()
	var v1: bool = p.toggle_property_lock("rotation")
	if v1 != true: _fail("toggle should return new value=true")
	if not p.is_property_locked("rotation"): _fail("toggle didn't set")
	var v2: bool = p.toggle_property_lock("rotation")
	if v2 != false: _fail("toggle should return new value=false on second")
	if p.is_property_locked("rotation"): _fail("toggle didn't unset")

func _test_round_trip() -> void:
	var p := PieceDefinitionScript.new()
	p.set_property_lock_value("position", true)
	p.set_property_lock_value("connectors", true)
	var d: Dictionary = p.to_dict()
	# Verify the dict contains the property_locks.
	if not d.has("property_locks"): _fail("to_dict didn't include property_locks")
	var pl: Dictionary = d["property_locks"]
	if not bool(pl.get("position", false)): _fail("position lock not in dict")
	if not bool(pl.get("connectors", false)): _fail("connectors lock not in dict")
	# Round-trip into a fresh piece.
	var p2 := PieceDefinitionScript.new()
	p2.apply_dict(d)
	if not p2.is_property_locked("position"): _fail("apply_dict lost position lock")
	if not p2.is_property_locked("connectors"): _fail("apply_dict lost connectors lock")
	if p2.is_property_locked("size"): _fail("apply_dict picked up a size lock it shouldn't have")

func _test_get_returns_copy() -> void:
	var p := PieceDefinitionScript.new()
	p.set_property_lock_value("size", true)
	var copy: Dictionary = p.get_property_locks()
	copy["size"] = false
	# Mutating the copy must not affect the piece.
	if not p.is_property_locked("size"): _fail("get_property_locks returned a reference, not a copy")

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)