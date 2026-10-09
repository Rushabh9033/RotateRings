extends SceneTree
func _init() -> void:
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready(): await screen.ready
	screen.load_level_by_id(3)
	for i in range(60): await process_frame
	var pc = screen.puzzle_controller
	for t in pc._active_drop_tweens:
		if is_instance_valid(t): t.kill()
	pc._active_drop_tweens.clear()
	for ch in pc.get_children():
		if ch is Tween: ch.kill()
	pc.scale = Vector2.ONE
	pc.position = Vector2.ZERO
	for child in pc.pieces_container.get_children():
		if child is Node2D and child.def != null:
			child.position = child.def.position
			child.modulate.a = 1.0
			child.visible = true
			if child.get("_state_tween") != null:
				var st = child.get("_state_tween")
				if is_instance_valid(st): st.kill()
	for i in range(8): await process_frame
	var img = root.get_viewport().get_texture().get_image()
	if img == null: print("FAIL"); quit(1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/level3_root.png")
	print("Saved _godot_test_out/level3_root.png size=", img.get_size())
	quit(0)
