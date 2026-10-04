extends SceneTree

func _init() -> void:
	print("\n==============================================")
	print("       TEST JIGGLE CONNECTORS VIBRATION       ")
	print("==============================================")

	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready

	# Load Level 3
	screen.load_level_by_id(3)
	for i in range(5):
		await process_frame

	var pc = screen.puzzle_controller
	var blue_piece: Node2D = null
	for p in pc.active_pieces:
		if p.piece_id == &"ring_0":
			blue_piece = p
			break

	if not blue_piece:
		print("❌ Could not find blue piece (ring_0) in Level 3!")
		quit(1)
		return

	print("Found Blue Piece (ring_0) at initial rotation: ", blue_piece.rotation_degrees)

	var stats := {
		"count": 0,
		"diff": false,
		"last_rot": blue_piece.rotation_degrees
	}

	blue_piece.rotation_changed.connect(func(_p, angle):
		stats["count"] += 1
		if absf(angle - stats["last_rot"]) > 0.1:
			stats["diff"] = true
	)

	# Trigger jiggle on locked blue piece
	pc.drag_controller.jiggle_locked_piece(blue_piece)

	# Wait a few frames and capture peak vibration image
	for i in range(10):
		await process_frame
	var img = root.get_viewport().get_texture().get_image()
	img.save_png("C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/jiggle_frame_peak.png")
	print("Saved jiggle_frame_peak.png (rot=", blue_piece.rotation_degrees, ")")

	# Wait for the 0.21s tween to fully complete in real time
	await create_timer(0.35).timeout

	print("Total rotation_changed events emitted during jiggle: ", stats["count"])
	print("Observed rotation angle difference during vibration: ", stats["diff"])

	if stats["count"] > 10 and stats["diff"]:
		print("✅ SUCCESS: rotation_changed emitted continuously during jiggle, vibrating connectors with the ring!")
	else:
		print("❌ FAILED: rotation_changed was not emitted during jiggle!")
		quit(1)
		return

	# Verify final rest angle returned to original
	if absf(blue_piece.rotation_degrees - 270.0) < 0.01:
		print("✅ SUCCESS: Blue piece returned cleanly to 270.0° resting position.")
	else:
		print("❌ FAILED: Final rotation not restored! got: ", blue_piece.rotation_degrees)
		quit(1)
		return

	print("==============================================")
	print("TEST COMPLETE: ALL CHECKS PASSED!")
	print("==============================================\n")
	quit(0)
