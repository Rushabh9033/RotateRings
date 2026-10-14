extends SceneTree

const UiTheme = preload("res://app/ui_theme.gd")
const SaveService = preload("res://app/save_service.gd")
const AudioService = preload("res://app/audio_service.gd")
const HapticService = preload("res://app/haptic_service.gd")

func _init() -> void:
	var sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2i(720, 1280)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub_viewport)

	var save_svc = SaveService.new()
	sub_viewport.add_child(save_svc)
	# Mock progression: 3 levels cleared, Level 4 is current (matches user reference)
	save_svc.save_data["highest_unlocked_level"] = 4
	save_svc.save_data["levels"] = {
		"1": {"cleared": true, "perfect": false, "stars": 2},
		"2": {"cleared": true, "perfect": true, "stars": 3},
		"3": {"cleared": true, "perfect": false, "stars": 2}
	}

	var audio_svc = AudioService.new()
	sub_viewport.add_child(audio_svc)
	var haptic_svc = HapticService.new()
	sub_viewport.add_child(haptic_svc)

	var dir = DirAccess.open("res://")
	if not dir.dir_exists("_godot_test_out"):
		dir.make_dir("_godot_test_out")

	var capture = func(node: Control, setup_callback: Callable, filename: String, wait_frames: int = 30):
		sub_viewport.add_child(node)
		if setup_callback.is_valid():
			setup_callback.call()
		for i in range(wait_frames):
			await process_frame
		var tex = sub_viewport.get_texture()
		var img = tex.get_image()
		if img != null:
			img.save_png("_godot_test_out/" + filename)
			print("Saved: ", filename, " (", img.get_size(), ")")
		sub_viewport.remove_child(node)
		node.queue_free()

	# 1. HomeScreen
	var home = load("res://scenes/home/HomeScreen.tscn").instantiate()
	await capture.call(home, func():
		home.setup(save_svc, audio_svc)
		home.modulate.a = 1.0
	, "screen_home.png", 35)

	# 2. LevelSelectScreen
	var ls = load("res://scenes/level_select/LevelSelectScreen.tscn").instantiate()
	await capture.call(ls, func():
		save_svc.save_data["highest_unlocked_level"] = 4
		save_svc.save_data["levels"] = {
			"1": {"cleared": true, "perfect": false, "stars": 2},
			"2": {"cleared": true, "perfect": true, "stars": 3},
			"3": {"cleared": true, "perfect": false, "stars": 2}
		}
		ls.setup(save_svc, audio_svc)
	, "screen_level_select.png", 50)

	# 3. GameplayScreen
	var gp = load("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
	await capture.call(gp, func():
		gp.setup(save_svc, audio_svc, haptic_svc)
		gp.load_level_by_id(4)
		var pc = gp.puzzle_controller
		if pc:
			for ch in pc.pieces_container.get_children():
				if ch is Node2D and ch.def != null:
					ch.position = ch.def.position
					ch.modulate.a = 1.0
	, "screen_gameplay.png", 35)

	# 4. SettingsModal
	var sm = load("res://scenes/components/SettingsModal.tscn").instantiate()
	await capture.call(sm, func():
		sm.setup(save_svc, audio_svc)
		sm.show_modal()
		sm.modulate.a = 1.0
	, "screen_settings.png", 25)

	# 5. PauseModal
	var pm = load("res://scenes/components/PauseModal.tscn").instantiate()
	await capture.call(pm, func():
		pm.setup(save_svc)
		pm.show_modal()
		pm.modulate.a = 1.0
	, "screen_pause.png", 25)

	# 6. VictoryModal
	var vm = load("res://scenes/components/VictoryModal.tscn").instantiate()
	await capture.call(vm, func():
		vm.show_victory(12, 15, true, 12, 3)
		vm.modulate.a = 1.0
	, "screen_victory.png", 35)

	print("ALL SCREENS CAPTURED SUCCESSFULLY.")
	quit(0)
