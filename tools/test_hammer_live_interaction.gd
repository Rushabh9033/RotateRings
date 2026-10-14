extends SceneTree

const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

var frame = 0
var gp = null
var save_svc = null

func _init():
	gp = preload("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
	root.add_child(gp)
	save_svc = preload("res://app/save_service.gd").new()
	var audio_svc = preload("res://app/audio_service.gd").new()
	var haptic_svc = preload("res://app/haptic_service.gd").new()
	root.add_child(save_svc)
	root.add_child(audio_svc)
	root.add_child(haptic_svc)
	gp.setup(save_svc, audio_svc, haptic_svc)

func _process(_delta: float) -> bool:
	frame += 1

	if frame == 2:
		gp.load_level_by_id(4)

	var pc = gp.puzzle_controller
	var ha = gp.hammer_animator

	if frame == 30:
		for p in pc.active_pieces:
			if is_instance_valid(p) and p.def:
				p.position = p.def.position
				p.modulate.a = 1.0
		pc.is_active = true
		print("[TEST] Step 1: Level 4 ready with %d pieces. Initial hammers: %d" % [pc.active_pieces.size(), save_svc.get_hammers_remaining()])

		# Click hammer button to start targeting
		gp._on_hammer_pressed()
		print("[TEST] Step 2: Hammer button pressed. Targeting: %s, Puzzle active: %s" % [ha.is_targeting, pc.is_active])
		assert(ha.is_targeting == true, "Hammer should be targeting")
		assert(pc.is_active == false, "Puzzle controller should be frozen during targeting")

	# Target ring_orange at its real global position
	if frame == 35:
		var target_piece = pc.active_pieces[0]
		var target_pos = target_piece.global_position
		print("[TEST] Step 3: Clicking on piece '%s' at %s" % [target_piece.piece_id, target_pos])

		var ev = InputEventMouseButton.new()
		ev.button_index = MOUSE_BUTTON_LEFT
		ev.pressed = true
		ev.position = target_pos
		ev.global_position = target_pos
		
		# Process click through hammer input handler
		ha._input(ev)

		print("[TEST] Step 4: After click -> Striking: %s, Targeting: %s" % [ha.is_striking, ha.is_targeting])
		assert(ha.is_striking == true, "Hammer should now be striking!")
		assert(ha.is_targeting == false, "Targeting should be complete")

	# Wait for smash animation and drop to complete
	if frame >= 40 and not ha.is_striking and pc.active_pieces.size() < 7:
		print("[TEST] Step 5: Animation completed. Pieces remaining: %d" % pc.active_pieces.size())
		assert(pc.active_pieces.size() < 7, "At least 1-3 rings should be destroyed")
		assert(save_svc.get_hammers_remaining() == 2, "1 hammer should be consumed")
		assert(pc.is_active == true, "Puzzle controller active state should be restored")
		print("=== ALL HAMMER INTERACTION TESTS PASSED 100%! ===")
		quit(0)
		return true

	return false
