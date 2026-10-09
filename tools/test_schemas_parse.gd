extends SceneTree

func _init() -> void:
	var ok := true
	for path in [
		"res://data/piece_definition.gd",
		"res://data/gap_definition.gd",
		"res://data/link_definition.gd",
		"res://data/level_definition.gd",
	]:
		var res = load(path)
		if res == null:
			printerr("FAIL: cannot load ", path)
			ok = false
		else:
			printerr("OK: ", path)
	if not ok:
		quit(1)
	else:
		quit(0)
