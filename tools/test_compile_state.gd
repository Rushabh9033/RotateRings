extends SceneTree

func _init():
	var StateClass = load("res://gameplay/puzzle_state.gd")
	if StateClass != null:
		var inst = StateClass.new()
		print("PuzzleState compiled & instantiated successfully! inst=", inst)
	else:
		print("ERROR: PuzzleState script failed to load!")
	quit()
