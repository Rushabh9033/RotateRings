extends SceneTree

func _init() -> void:
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready
	screen.load_level_by_id(1)
	# Let the drop animation + intro settle.
	for i in range(60):
		await process_frame
	var img = root.get_viewport().get_texture().get_image()
	var out = "C:/Users/RUSHABH/.minimax/v2/assets/2026/10/08/level1_render.png"
	img.save_png(out)
	print("Saved ", out)
	quit(0)
