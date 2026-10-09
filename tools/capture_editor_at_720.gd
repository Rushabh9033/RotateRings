extends SceneTree

# Capture the editor at the actual mobile viewport size (720x1280) the
# user plays at. The user's screenshot #7 showed the editor without a
# visible right panel, so we need to verify what the user actually sees.
#
# Run: godot --display-driver windows --rendering-driver opengl3 --script tools/capture_editor_at_720.gd

const LevelEditorScene = preload("res://scenes/level_editor/LevelEditor.tscn")

func _initialize() -> void:
	# The user's actual viewport is 720x1280 (mobile portrait). The editor
	# is a Control that needs to lay out in that space.
	var sv := SubViewport.new()
	sv.size = Vector2i(720, 1280)
	sv.transparent_bg = false
	sv.own_world_3d = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)

	var ed: Control = LevelEditorScene.instantiate()
	ed.name = "LevelEditor"
	sv.add_child(ed)
	ed.size = Vector2(720, 1280)
	# Override the stretch so Controls don't auto-scale.
	ProjectSettings.set_setting("display/window/stretch/mode", "disabled")
	await process_frame
	await process_frame
	ed.reset_size()
	ed.size = Vector2(720, 1280)
	await process_frame
	await process_frame
	await process_frame

	# Place 4 pieces (Level 3 shape) and select one.
	ed._placed_pieces = [
		{"id": "r1", "color": "cyan",   "color_hex": "#32ADDA", "x": 360.0, "y": 540.0, "radius": 75, "thickness": 16, "gap_deg": 270, "closed": false},
		{"id": "r2", "color": "orange", "color_hex": "#EA7829", "x": 250.0, "y": 720.0, "radius": 58, "thickness": 16, "gap_deg": 180, "closed": false},
		{"id": "r3", "color": "purple", "color_hex": "#7B61FF", "x": 470.0, "y": 720.0, "radius": 58, "thickness": 16, "gap_deg": 0,   "closed": false},
		{"id": "r4", "color": "red",    "color_hex": "#C8202F", "x": 360.0, "y": 900.0, "radius": 75, "thickness": 16, "gap_deg": 90,  "closed": false},
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

	# Debug: print actual node rects
	print("[debug] sv.size=", sv.size, " ed.size=", ed.size)
	for child in ed.get_children():
		var ctl := child as Control
		if ctl:
			print("[debug] ", child.name, " type=", ctl.get_class(), " pos=", ctl.position, " size=", ctl.size, " visible=", ctl.visible)
		else:
			print("[debug] ", child.name, " (Node2D) pos=", child.position)

	var img: Image = sv.get_texture().get_image()
	if img == null:
		print("FAIL: SubViewport texture null")
		quit(2); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	img.save_png("res://_godot_test_out/editor_at_720.png")
	print("Saved _godot_test_out/editor_at_720.png")
	quit(0)
