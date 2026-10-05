extends SceneTree
func _init():
    var scene = preload("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
    root.add_child(scene)
    scene.call_deferred("load_level_by_id", 1)
    await create_timer(1.0).timeout
    var pc = scene.get_node("PuzzleArea/PuzzleController")
    print("PC scale: ", pc.scale)
    print("PC pos: ", pc.position)
    print("PC bounds: ", pc.get_puzzle_bounds())
    print("Ring0 global_pos: ", pc.get_node("Pieces/ring_0").global_position)
    quit()

