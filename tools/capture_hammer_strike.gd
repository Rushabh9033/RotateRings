extends SceneTree

const GameplayScreenScene = preload("res://scenes/gameplay/GameplayScreen.tscn")
const SaveServiceScript = preload("res://app/save_service.gd")
const AudioServiceScript = preload("res://app/audio_service.gd")

func _init() -> void:
	var vp = SubViewport.new()
	vp.size = Vector2i(720, 1280)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(vp)

	var save_service = SaveServiceScript.new()
	save_service.name = "SaveService"
	vp.add_child(save_service)
	save_service.save_data["hammers_remaining"] = 3

	var audio_service = AudioServiceScript.new()
	audio_service.name = "AudioService"
	vp.add_child(audio_service)

	var screen = GameplayScreenScene.instantiate()
	vp.add_child(screen)
	screen.setup(save_service, audio_service, null)

	if not screen.is_node_ready():
		await screen.ready
	screen.load_level_by_id(18)

	for i in range(30):
		await process_frame

	var pc = screen.puzzle_controller
	var target_piece = pc.active_pieces[0]

	# Start targeting
	screen._on_hammer_pressed()

	# Trigger smash on target piece
	screen.hammer_animator.execute_smash(target_piece)

	# Advance to impact frame (windup ~0.16s + slam ~0.10s = ~0.26s -> ~16 frames at 60fps)
	for i in range(16):
		await process_frame

	var img_strike = vp.get_texture().get_image()
	if img_strike != null:
		img_strike.save_png("screenshots/hammer_strike_impact.png")
		print("Saved screenshots/hammer_strike_impact.png")

	# Advance to ring shatter and gravity drop frame
	for i in range(15):
		await process_frame

	var img_drop = vp.get_texture().get_image()
	if img_drop != null:
		img_drop.save_png("screenshots/hammer_rings_drop.png")
		print("Saved screenshots/hammer_rings_drop.png")

	print("HAMMER ANIMATION CAPTURE COMPLETE.")
	quit(0)
