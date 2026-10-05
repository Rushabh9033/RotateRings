extends SceneTree

const Harness = preload("res://tools/level_engine_harness.gd")

func _init() -> void:
	var ok := _report(2) and _report(3)
	if ok:
		print("SUCCESS: Levels 2 and 3 solved through the rule engine")
		quit(0)
		return
	print("FAILED: Level 2/3 rule-engine solve")
	quit(1)

func _report(level_id: int) -> bool:
	var result: Dictionary = Harness.solve_level(level_id)
	print("Level ", level_id, " solved=", result.solved, " moves=", result.moves)
	return bool(result.solved)
