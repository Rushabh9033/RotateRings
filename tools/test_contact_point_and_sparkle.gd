extends SceneTree

func _init() -> void:
	print("--- TEST CONTACT POINT & SPARKLE WITH GAMEPLAY SCREEN ---")

	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready

	screen.load_level_by_id(2)
	for i in range(10):
		await process_frame

	var pc = screen.puzzle_controller
	var pieces = pc.active_pieces
	var active_links = pc.active_links
	var PuzzleRules = load("res://gameplay/puzzle_rules.gd")

	var orange_ring = PuzzleRules.get_piece_by_id(&"ring_0", pieces)
	var purple_ring = PuzzleRules.get_piece_by_id(&"ring_2", pieces)

	# Simulate rotating Orange clockwise by +65 degrees
	var step_res = PuzzleRules.clamp_rotation_step(orange_ring, 65.0, pieces, active_links)
	print("Clamp step result for +65 deg on Orange:")
	print("  allowed_delta:", step_res["allowed_delta"])
	print("  hit_stopper:", step_res["hit_stopper"])
	print("  contact_point:", step_res["contact_point"])
	print("  contact_color:", step_res["contact_color"])

	var contact_pt: Vector2 = step_res["contact_point"]

	# Rotate orange to its blocked position against purple
	orange_ring.rotation_degrees += step_res["allowed_delta"]
	orange_ring.current_angle_deg = fposmod(orange_ring.rotation_degrees, 360.0)
	orange_ring.queue_redraw()
	pc._redraw_connectors()

	# Trigger collision spark at the exact contact point
	pc._on_collision_occurred(contact_pt, step_res["contact_color"])

	# Advance 3 frames for sparkle draw
	for i in range(3):
		await process_frame

	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/verify_level2_contact_sparkle.png")
	print("Saved verify_level2_contact_sparkle.png successfully!")

	# Verify audio service
	var AudioService = load("res://app/audio_service.gd").new()
	root.add_child(AudioService)
	AudioService.play_connector_touch()
	print("SUCCESS: play_connector_touch executed without errors")

	quit(0)
