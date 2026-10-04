extends SceneTree

func _init() -> void:
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready

	screen.load_level_by_id(5)
	for i in range(12):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/verify_level_5.png")
	print("Saved verify_level_5.png")
	quit(0)
