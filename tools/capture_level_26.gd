extends SceneTree

func _init() -> void:
	var vp = SubViewport.new()
	vp.size = Vector2i(720, 1280)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)
	
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	vp.add_child(screen)
	
	if not screen.is_node_ready():
		await screen.ready
	screen.load_level_by_id(26)
	
	var pc = screen.puzzle_controller
	for i in range(120):
		await process_frame
	
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
			child.rotation_degrees = child.def.start_angle_deg
			child.modulate.a = 1.0
			child.visible = true
			if child.get("_state_tween") != null:
				var st = child.get("_state_tween")
				if is_instance_valid(st): st.kill()
	
	pc._connectors_dirty = true
	if is_instance_valid(pc.stems_layer): pc.stems_layer.queue_redraw()
	if is_instance_valid(pc.cuffs_layer): pc.cuffs_layer.queue_redraw()
	
	for i in range(10):
		await process_frame
	
	var img = vp.get_texture().get_image()
	if img == null:
		print("FAIL: viewport texture null")
		quit(1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/level26_root.png")
	print("Saved _godot_test_out/level26_root.png size=", img.get_size())
	quit(0)
