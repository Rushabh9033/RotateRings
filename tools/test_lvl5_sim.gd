extends SceneTree

const Harness = preload("res://tools/level_engine_harness.gd")

func _init() -> void:
	var result: Dictionary = Harness.solve_level(5)
	print("Level 5 solved=", result.solved, " moves=", result.moves)
	quit(0 if result.solved else 1)
