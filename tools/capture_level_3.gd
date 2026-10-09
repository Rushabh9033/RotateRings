extends SceneTree

# Headless capture of Level N. Pass level id as arg.
# Run:  godot --display-driver windows --rendering-driver opengl3 --script tools/capture_level_3.gd -- 3
# Out:  _godot_test_out/level3_actual.png

const GameplayScreenScene = preload("res://scenes/gameplay/GameplayScreen.tscn")
const UiTheme = preload("res://app/ui_theme.gd")
const SaveService = preload("res://app/save_service.gd")
const AudioService = preload("res://app/audio_service.gd")
const HapticService = preload("res://app/haptic_service.gd")

func _initialize() -> void:
	var level_id := 3
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		level_id = int(args[0])

	var sv := SubViewport.new()
	sv.size = Vector2i(720, 1280)
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
	await process_frame
	await process_frame
	gp.reset_size()
	gp.size = Vector2(720, 1280)
	await process_frame
	await process_frame

	var ok: bool = gp.load_level_by_id(level_id)
	print("[capture] load_level_by_id(", level_id, ") -> ", ok)
	if not ok:
		quit(1); return

	for i in range(150):
		await process_frame

	var pc = gp.puzzle_controller
	print("[capture] puzzle_controller.scale=", pc.scale, " position=", pc.position)

	var img: Image = sv.get_texture().get_image()
	if img == null:
		print("[capture] FAIL: SubViewport texture null")
		quit(2); return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://_godot_test_out"))
	var err := img.save_png("res://_godot_test_out/level%d_actual.png" % level_id)
	print("[capture] saved _godot_test_out/level%d_actual.png err=%d" % [level_id, err])

	# Also unframed variant
	pc.scale = Vector2.ONE
	pc.position = Vector2.ZERO
	for i in range(8):
		await process_frame
	var img2: Image = sv.get_texture().get_image()
	if img2 != null:
		img2.save_png("res://_godot_test_out/level%d_actual_unframed.png" % level_id)

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

	quit(0)
