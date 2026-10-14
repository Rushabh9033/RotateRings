extends SceneTree

const GameplayScreenScene = preload("res://scenes/gameplay/GameplayScreen.tscn")
const SaveServiceScript = preload("res://app/save_service.gd")
const AudioServiceScript = preload("res://app/audio_service.gd")

func _init() -> void:
	print("=== RUNTIME HAMMER TOOL & ANIMATION TEST START ===")
	call_deferred("_run_test")

func _run_test() -> void:
	var save_service = SaveServiceScript.new()
	save_service.name = "SaveService"
	root.add_child(save_service)
	save_service.save_data["hammers_remaining"] = 3

	var audio_service = AudioServiceScript.new()
	audio_service.name = "AudioService"
	root.add_child(audio_service)

	var screen = GameplayScreenScene.instantiate()
	root.add_child(screen)
	screen.setup(save_service, audio_service, null)

	# Load Level 18
	var loaded = screen.load_level_by_id(18)
	assert(loaded, "Failed to load Level 18")

	# Wait a couple frames for setup
	await process_frame
	await process_frame

	var pc = screen.puzzle_controller
	var initial_piece_count = pc.active_pieces.size()
	print("Level 18 loaded with %d pieces" % initial_piece_count)
	assert(initial_piece_count > 0, "Level 18 has no active pieces")

	var initial_hammers = save_service.get_hammers_remaining()
	print("Initial hammers: %d" % initial_hammers)
	assert(initial_hammers == 3, "Expected 3 initial hammers")

	# 1. Test starting targeting mode
	print("Testing hammer button press...")
	screen._on_hammer_pressed()
	assert(screen.hammer_animator != null, "Hammer animator not initialized")
	assert(screen.hammer_animator.is_targeting, "Hammer animator should be in targeting mode")
	print("Hammer animator targeting mode: ACTIVE (OK)")

	# 2. Test cancellation
	screen.hammer_animator.cancel_targeting()
	assert(not screen.hammer_animator.is_targeting, "Hammer animator should have cancelled targeting")
	print("Hammer animator cancellation: OK")

	# 3. Re-start targeting and smash a ring
	screen._on_hammer_pressed()
	assert(screen.hammer_animator.is_targeting, "Hammer animator should be in targeting mode again")

	var target_piece = pc.active_pieces[0]
	var target_id = target_piece.piece_id
	print("Smashing target piece: %s (pos: %s)" % [target_id, str(target_piece.global_position)])

	screen.hammer_animator.execute_smash(target_piece)
	assert(screen.hammer_animator.is_striking, "Hammer animator should be striking")

	# Let strike animation, impact callback, and drop tweens run
	for i in range(40):
		await process_frame
		await create_timer(0.02).timeout

	print("Smash animation and drop completed!")
	var after_piece_count = pc.active_pieces.size()
	var destroyed_count = initial_piece_count - after_piece_count
	print("Pieces remaining: %d (Destroyed: %d rings)" % [after_piece_count, destroyed_count])
	assert(destroyed_count >= 1 and destroyed_count <= 3, "Expected 1 to 3 pieces destroyed by hammer strike, got %d" % destroyed_count)

	var remaining_hammers = save_service.get_hammers_remaining()
	print("Remaining hammers: %d" % remaining_hammers)
	assert(remaining_hammers == 2, "Expected 2 hammers remaining after smash")

	print("=== ALL HAMMER TOOL RUNTIME TESTS PASSED SUCCESSFULLY! ===")
	quit(0)
