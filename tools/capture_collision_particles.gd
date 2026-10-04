extends SceneTree

func _init() -> void:
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready

	screen.load_level_by_id(4)
	for i in range(10):
		await process_frame

	var pc = screen.puzzle_controller
	# Trigger collision spark at contact point between green and purple rings (Vector2(380, 680))
	pc._on_collision_occurred(Vector2(380, 680), Color("#2CA45C"))

	# Advance 3 frames so sparks expand
	for i in range(3):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/verify_collision_particles.png")
	print("Saved verify_collision_particles.png")
	quit(0)
