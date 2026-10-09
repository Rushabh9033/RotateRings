extends SceneTree

# Headless capture of Level 2 (with realistic HUD framing).
# Run:  godot --display-driver windows --rendering-driver opengl3 --script tools/capture_level_2.gd
# Out:  _godot_test_out/level2_actual.png  (720x1280)

const GameplayScreenScene = preload("res://scenes/gameplay/GameplayScreen.tscn")
const UiTheme = preload("res://app/ui_theme.gd")
const SaveService = preload("res://app/save_service.gd")
const AudioService = preload("res://app/audio_service.gd")
const HapticService = preload("res://app/haptic_service.gd")

func _initialize() -> void:
	var sv := SubViewport.new()
	# The project has window/stretch/aspect=expand with reference 720x1280.
	# Render at 2x the reference so the captured image is at the
	# 1:1 reference resolution after the stretch transform is applied.
	sv.size = Vector2i(1440, 2560)
	sv.transparent_bg = false
	sv.own_world_3d = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)

	var save_svc = SaveService.new(); save_svc.name = "SaveService"; sv.add_child(save_svc)
	var audio_svc = AudioService.new(); audio_svc.name = "AudioService"; sv.add_child(audio_svc)
	var haptic_svc = HapticService.new(); haptic_svc.name = "HapticService"; sv.add_child(haptic_svc)

	var gp: Control = GameplayScreenScene.instantiate()
	gp.name = "GameplayScreen"
	sv.add_child(gp)
	gp.setup(save_svc, audio_svc, haptic_svc)
	gp.size = Vector2(720, 1280)
	UiTheme.mount_backdrop(gp, true)

	# Force real layout so HUD nodes have measurable size.
	await process_frame
	await process_frame
	gp.reset_size()
	gp.size = Vector2(720, 1280)
	await process_frame
	await process_frame

	# Now load level.
	var ok: bool = gp.load_level_by_id(2)
	print("[capture] load_level_by_id(2) -> ", ok)
	if not ok:
		quit(1); return

	# Wait for drop tweens (0.8s + 0.08 stagger) + framing tween (0.4s) + 0.5s settle.
	for i in range(150):
		await process_frame

	# Kill the drop tweens explicitly so they don't keep overwriting
	# the piece positions. Then force the pieces to their authored
	# positions.
	var pc2 = gp.puzzle_controller
	for t in pc2._active_drop_tweens:
		if is_instance_valid(t):
			t.kill()
	pc2._active_drop_tweens.clear()
	# Cancel the framing tween so the puzzle_controller stays at (0,0,1,1)
	if pc2.has_method("kill"):
		for ch in pc2.get_children():
			if ch is Tween:
				ch.kill()
	for child in pc2.pieces_container.get_children():
		if child is Node2D and child.def != null:
			child.position = child.def.position
			child.modulate.a = 1.0
			child.visible = true
			if child.has_method("kill") and child.get("_state_tween") != null:
				var st = child.get("_state_tween")
				if is_instance_valid(st):
					st.kill()
	# Reset puzzle_controller transform so pieces appear at their
	# authored positions (not framed into a sub-area).
	pc2.scale = Vector2.ONE
	pc2.position = Vector2.ZERO
	# Also kill each piece's state tween
	for child in pc2.pieces_container.get_children():
		if child.get("_state_tween") != null:
			var st = child.get("_state_tween")
			if is_instance_valid(st):
				st.kill()

	var pc = gp.puzzle_controller
	print("[capture] (with framing) puzzle_controller.scale=", pc.scale, " position=", pc.position)

	# Save the framed output (what the user actually sees).
	var img: Image = sv.get_texture().get_image()
	if img == null:
		print("[capture] FAIL: SubViewport texture null")
		quit(2); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	var err := img.save_png("res://_godot_test_out/level2_actual.png")
	print("[capture] saved _godot_test_out/level2_actual.png err=", err)

	# Also save a no-framing variant (authored coords 1:1 to canvas)
	# for calibration: kill the framing transform.
	pc.scale = Vector2.ONE
	pc.position = Vector2.ZERO
	for i in range(8):
		await process_frame
	var img2: Image = sv.get_texture().get_image()
	if img2 != null:
		var err2 := img2.save_png("res://_godot_test_out/level2_actual_unframed.png")
		print("[capture] saved _godot_test_out/level2_actual_unframed.png err=", err2)

	# Dump piece runtime state
	for child in pc.pieces_container.get_children():
		if child is Node2D:
			print("[capture]   piece id=", child.piece_id,
				" pos=", child.position,
				" rot=", child.rotation_degrees,
				" radius=", child.radius,
				" thickness=", child.thickness,
				" gaps=", child.gaps.size())
	for link in pc.active_links:
		var l = link.def
		print("[capture]   link from=", l.from_piece_id,
			" to=", l.to_piece_id,
			" stem_dist=", l.stem_dist,
			" collar=", l.collar_angle_deg)

	# Print HUD bounds so we can see whether framing used a real safe area
	var top_hud = gp.get_node_or_null("SafeArea/TopHUD")
	var bottom_hud = gp.get_node_or_null("SafeArea/BottomHUD")
	if top_hud:
		print("[capture] top_hud.size=", top_hud.size, " pos=", top_hud.position)
	if bottom_hud:
		print("[capture] bottom_hud.size=", bottom_hud.size, " pos=", bottom_hud.position)

	quit(0)
