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
	screen.size = Vector2(720, 1280)
	vp.add_child(screen)
	screen.setup(save_service, audio_service, null)

	if not screen.is_node_ready():
		await screen.ready
	screen.load_level_by_id(4)

	var pc = screen.puzzle_controller
	for tw in pc._active_drop_tweens:
		if is_instance_valid(tw):
			tw.custom_step(3.0)
	for p in pc.active_pieces:
		if is_instance_valid(p) and p.def:
			p.position = p.def.position
			p.modulate.a = 1.0

	screen._frame_puzzle()

	for i in range(10):
		await process_frame

	var target_piece = pc.active_pieces[0] # ring_orange

	# 1. Start targeting mode
	screen._on_hammer_pressed()

	for i in range(25):
		await process_frame

	var img_targeting = vp.get_texture().get_image()
	if img_targeting != null:
		img_targeting.save_png("screenshots/hammer_targeting_smoke.png")
		print("Saved screenshots/hammer_targeting_smoke.png")

	# 2. Trigger smash
	screen.hammer_animator.execute_smash(target_piece)

	# Advance 32 frames to reach power slam impact
	for i in range(32):
		await process_frame

	var img_strike = vp.get_texture().get_image()
	if img_strike != null:
		img_strike.save_png("screenshots/hammer_strike_impact.png")
		print("Saved screenshots/hammer_strike_impact.png")

	# Advance another 16 frames into rock explosion
	for i in range(16):
		await process_frame

	var img_rocks = vp.get_texture().get_image()
	if img_rocks != null:
		img_rocks.save_png("screenshots/hammer_colored_rocks.png")
		print("Saved screenshots/hammer_colored_rocks.png")

	print("HAMMER ANIMATION & ROCKS CAPTURE COMPLETE.")
	quit(0)
