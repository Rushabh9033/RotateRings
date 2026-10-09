extends SceneTree

# Capture the editor with grid on + 4 pieces placed.
# Run: godot --display-driver windows --rendering-driver opengl3 --script tools/capture_editor_demo.gd

const LevelEditorScene = preload("res://scenes/level_editor/LevelEditor.tscn")

func _initialize() -> void:
	var sv := SubViewport.new()
	sv.size = Vector2i(1280, 800)
	sv.transparent_bg = false
	sv.own_world_3d = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)

	var ed: Control = LevelEditorScene.instantiate()
	ed.name = "LevelEditor"
	sv.add_child(ed)
	ed.size = Vector2(1280, 800)
	# Override canvas size for this capture so we can see whole thing.
	await process_frame
	await process_frame

	# Place a level layout similar to Level 3 for a recognizable demo.
	ed._placed_pieces = [
		{"id": "r1", "color": "cyan",   "color_hex": "#32ADDA", "x": 360.0, "y": 240.0, "radius": 75, "thickness": 16, "gap_deg": 270, "closed": false},
		{"id": "r2", "color": "orange", "color_hex": "#EA7829", "x": 270.0, "y": 400.0, "radius": 58, "thickness": 16, "gap_deg": 180, "closed": false},
		{"id": "r3", "color": "purple", "color_hex": "#7B61FF", "x": 450.0, "y": 400.0, "radius": 58, "thickness": 16, "gap_deg": 0,   "closed": false},
		{"id": "r4", "color": "red",    "color_hex": "#C8202F", "x": 360.0, "y": 560.0, "radius": 75, "thickness": 16, "gap_deg": 90,  "closed": false},
	]
	ed._placed_links = [
		{"from_id": "r1", "to_id": "r2", "cuff_color_hex": "#32ADDA"},
		{"from_id": "r1", "to_id": "r3", "cuff_color_hex": "#32ADDA"},
		{"from_id": "r2", "to_id": "r4", "cuff_color_hex": "#C8202F"},
	]
	ed._selected_piece_idx = 0
	ed._on_grid_toggled(true)
	ed._update_pixel_label()
	ed.queue_redraw()
	for i in range(10):
		await process_frame

	# Center the layout
	ed._center_x_pressed()
	ed._center_y_pressed()
	ed.queue_redraw()
	for i in range(10):
		await process_frame

	var img: Image = sv.get_texture().get_image()
	if img == null:
		print("FAIL: SubViewport texture null")
		quit(2); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/editor_demo.png")
	print("Saved _godot_test_out/editor_demo.png")
	quit(0)
