extends SceneTree

func _init() -> void:
	var LevelEditorScene = load("res://scenes/level_editor/LevelEditor.tscn")
	var SaveService = load("res://app/save_service.gd")
	var AudioService = load("res://app/audio_service.gd")
	var HapticService = load("res://app/haptic_service.gd")

	var save_svc = SaveService.new()
	var audio_svc = AudioService.new()
	var haptic_svc = HapticService.new()
	root.add_child(save_svc)
	root.add_child(audio_svc)
	root.add_child(haptic_svc)

	var ed: Control = LevelEditorScene.instantiate()
	root.add_child(ed)
	if not ed.is_node_ready(): await ed.ready
	ed.setup_editor(2)
	ed.size = Vector2(720, 1280)
	await process_frame
	await process_frame

	ed._placed_pieces.clear()
	ed._placed_links.clear()
	ed._placed_pieces = [
		{"id": "ring_orange", "color_name": "orange", "color_hex": "#EA7829", "x": 240.0, "y": 520.0, "radius": 70, "thickness": 14, "gap_deg": 270, "shape": "CIRCLE", "closed": false},
		{"id": "ring_cyan", "color_name": "cyan", "color_hex": "#32ADDA", "x": 447.0, "y": 544.0, "radius": 52, "thickness": 14, "gap_deg": 200, "shape": "CIRCLE", "closed": false},
		{"id": "ring_purple", "color_name": "purple", "color_hex": "#7B61FF", "x": 353.0, "y": 700.0, "radius": 60, "thickness": 14, "gap_deg": 90, "shape": "CIRCLE", "closed": false},
	]
	ed._placed_links = [
		{"from_id": "ring_orange", "to_id": "ring_cyan", "cuff_color_name": "orange", "cuff_color_hex": "#EA7829"},
		{"from_id": "ring_orange", "to_id": "ring_purple", "cuff_color_name": "orange", "cuff_color_hex": "#EA7829"},
	]
	ed._selected_piece_idx = 0
	ed._on_grid_toggled(true)
	ed._update_pixel_label()
	ed.queue_redraw()
	ed.puzzle_preview.queue_redraw()
	for i in range(20):
		await process_frame
	print("[capture] ed.size=", ed.size, " right_panel.size=", ed.right_panel.size, " right_panel.visible=", ed.right_panel.visible)
	print("[capture] radius_slider.value=", ed.radius_slider.value, " min=", ed.radius_slider.min_value, " max=", ed.radius_slider.max_value)
	print("[capture] scale_slider.value=", ed.scale_slider.value)
	var img = root.get_viewport().get_texture().get_image()
	if img == null:
		print("FAIL")
		quit(1)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/editor_in_level2.png")
	print("Saved _godot_test_out/editor_in_level2.png size=", img.get_size())
	quit(0)
