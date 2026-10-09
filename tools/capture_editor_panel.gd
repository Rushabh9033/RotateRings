extends SceneTree

# Capture the right panel of the editor with the new sliders visible.
# Renders the LevelEditor inside a SubViewport at exactly 1280x800 with
# stretch disabled, so the panel lays out where the .tscn anchors expect.

const LevelEditorScene = preload("res://scenes/level_editor/LevelEditor.tscn")

func _initialize() -> void:
	var sv := SubViewport.new()
	var target := Vector2i(1280, 800)
	sv.size = target
	sv.transparent_bg = false
	sv.own_world_3d = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)

	# Override the project's stretch transform so Controls size 1:1.
	# Setting content_scale_size on the root window forces a 1:1 stretch.
	ProjectSettings.set_setting("display/window/stretch/mode", "disabled")
	# We need to apply this; in a SceneTree run it's read at boot. So set
	# before adding children if possible. (The project setting is read-only
	# at runtime; this is best-effort.)

	var ed: Control = LevelEditorScene.instantiate()
	ed.name = "LevelEditor"
	sv.add_child(ed)
	ed.size = Vector2(target)

	# Force layout
	await process_frame
	await process_frame
	ed.reset_size()
	ed.size = Vector2(target)
	await process_frame
	await process_frame

	# Place 4 pieces (Level 3-like) and select one.
	ed._placed_pieces = [
		{"id": "r1", "color": "cyan",   "color_hex": "#32ADDA", "x": 360.0, "y": 280.0, "radius": 75, "thickness": 16, "gap_deg": 270, "closed": false},
		{"id": "r2", "color": "orange", "color_hex": "#EA7829", "x": 280.0, "y": 450.0, "radius": 58, "thickness": 16, "gap_deg": 180, "closed": false},
		{"id": "r3", "color": "purple", "color_hex": "#7B61FF", "x": 440.0, "y": 450.0, "radius": 58, "thickness": 16, "gap_deg": 0,   "closed": false},
		{"id": "r4", "color": "red",    "color_hex": "#C8202F", "x": 360.0, "y": 620.0, "radius": 75, "thickness": 16, "gap_deg": 90,  "closed": false},
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
	for i in range(15):
		await process_frame

	print("[debug] sv.size=", sv.size, " ed.size=", ed.size)
	for child in ed.get_children():
		print("[debug] ", child.name, " pos=", child.position, " size=", child.size if child is Control else "Node2D")

	var img: Image = sv.get_texture().get_image()
	if img == null:
		print("FAIL: SubViewport texture null")
		quit(2); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/editor_panel.png")
	print("Saved _godot_test_out/editor_panel.png")
	quit(0)
