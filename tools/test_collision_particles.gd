extends SceneTree

const LevelDatabaseScript = preload("res://data/level_database.gd")
const PuzzleControllerScript = preload("res://gameplay/puzzle_controller.gd")
const CollisionSparkBurstScript = preload("res://gameplay/collision_spark_burst.gd")

func _init() -> void:
	print("--- TESTING COLLISION PARTICLES ---")
	var root_node = Node2D.new()
	root.add_child(root_node)

	var pc = PuzzleControllerScript.new()
	root_node.add_child(pc)
	pc._ready()
	var lvl4 = LevelDatabaseScript.get_level(4)
	pc.load_level(lvl4)

	# Trigger collision spark manually:
	pc._on_collision_occurred(Vector2(360, 600), Color.RED)

	var found_sparks := false
	for child in pc.get_children():
		if child is CollisionSparkBurstScript:
			found_sparks = true
			print("✅ Found CollisionSparkBurst node in tree! Pos:", child.global_position, " Sparks count:", child.sparks.size())
			# Simulate process tick
			child._process(0.1)
			assert(child.sparks.size() > 0)
			break

	if found_sparks:
		print("✅ Collision spark burst test PASSED!")
		quit(0)
	else:
		print("❌ CollisionSparkBurst NOT found!")
		quit(1)
