extends SceneTree

func _init() -> void:
	print("Starting drop test...")
	var root = get_root()
	var gameplay = load("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
	root.add_child(gameplay)
	
	await create_timer(1.0).timeout
	print("Loading Level 1...")
	gameplay.load_level_by_id(1)
	
	await create_timer(1.0).timeout
	print("Forcing unlock of a ring...")
	var controller = gameplay.puzzle_controller
	var pieces = controller.active_pieces
	if pieces.size() > 0:
		controller.unlock_and_release_piece(pieces[0])
		
	await create_timer(1.0).timeout
	print("Checking if DroppedRing2D exists...")
	var dropped_count = 0
	for child in controller.pieces_container.get_children():
		if child is DroppedRing2D:
			dropped_count += 1
			print("Dropped ring at: ", child.global_position, " Rot: ", child.rotation_degrees)
	
	if dropped_count > 0:
		print("SUCCESS: DroppedRing2D spawned and physics ran.")
	else:
		print("FAILED: No DroppedRing2D found.")
		
	quit()
