extends SceneTree

const LevelDatabase = preload("res://data/level_database.gd")
const SaveServiceScript = preload("res://app/save_service.gd")

func _init() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)

func _run() -> void:
	var ok := true
	ok = _definitions() and ok
	ok = _progression() and ok
	ok = _save_resolution() and ok
	ok = _level_select_rebuild() and ok
	ok = _router_rejects_invalid() and ok
	if ok:
		print("LEVEL_CONTRACT_OK")
		quit(0)
	else:
		print("LEVEL_CONTRACT_FAILED")
		quit(1)

func _definitions() -> bool:
	var level_one = LevelDatabase.get_level(1)
	var level_twelve = LevelDatabase.get_level(12)
	var level_thirteen = LevelDatabase.get_level(13)
	var missing = LevelDatabase.get_level(999)
	if level_one == null or int(level_one.level_id) != 1:
		print("FAIL get_level(1)")
		return false
	if level_twelve == null or int(level_twelve.level_id) != 12:
		print("FAIL get_level(12)")
		return false
	if level_thirteen == null or int(level_thirteen.level_id) != 13:
		print("FAIL get_level(13) lost its own id")
		return false
	if int(level_thirteen.level_id) == 1 or level_thirteen.pieces.size() == level_one.pieces.size():
		print("FAIL level 13 collapsed into level 1")
		return false
	if missing != null:
		print("FAIL get_level(999) was not null")
		return false
	if not LevelDatabase.is_level_playable(13) or LevelDatabase.get_next_playable_level(12) != 13:
		print("FAIL level 12 does not continue to 13")
		return false
	if LevelDatabase.get_next_playable_level(50) != 0:
		print("FAIL level 50 should end the campaign")
		return false
	if LevelDatabase.get_next_playable_level(11) != 12:
		print("FAIL next playable after 11")
		return false
	if LevelDatabase.get_playable_level_count() != 50 or LevelDatabase.get_defined_level_count() != 50:
		print("FAIL playable/defined counts")
		return false
	if LevelDatabase.get_total_levels() != LevelDatabase.get_playable_level_count():
		print("FAIL get_total_levels drifted from playable count")
		return false
	print("PASS definitions")
	return true

func _progression() -> bool:
	if LevelDatabase.get_previous_playable_level(1) != 0:
		print("FAIL previous of 1")
		return false
	if not LevelDatabase.is_level_defined(13) or not LevelDatabase.is_level_defined(50):
		print("FAIL defined quarantine range")
		return false
	if LevelDatabase.is_level_defined(0) or LevelDatabase.is_level_defined(51):
		print("FAIL defined bounds")
		return false
	print("PASS progression helpers")
	return true

func _save_resolution() -> bool:
	var save = SaveServiceScript.new()
	save.save_data["highest_unlocked_level"] = 50
	if save.resolve_unlocked_level(50) != 50:
		print("FAIL save 50 was rewritten")
		return false
	if save.resolve_unlocked_level(50) == 1:
		print("FAIL save 50 resolved to level 1")
		return false
	if save.resolve_unlocked_level(7) != 7:
		print("FAIL playable save was rewritten")
		return false
	if save.resolve_unlocked_level(999) != 50:
		print("FAIL invalid save id")
		return false
	save.save_data["highest_unlocked_level"] = 50
	if save.get_continue_level() != 50:
		print("FAIL continue did not keep level 50")
		return false
	if not save.is_level_unlocked(13):
		print("FAIL level 13 stayed locked")
		return false
	print("PASS save resolution")
	return true

func _level_select_rebuild() -> bool:
	var screen = load("res://scenes/level_select/LevelSelectScreen.tscn").instantiate()
	root.add_child(screen)
	var save = SaveServiceScript.new()
	screen.setup(save, null)
	screen.build_grid()
	var first := _button_count(screen)
	screen.build_grid()
	var second := _button_count(screen)
	if first != 50 or second != 50:
		print("FAIL level select counts ", first, " then ", second)
		return false
	print("PASS level select")
	return true

func _button_count(screen: Control) -> int:
	var map: Node = screen.get_node("SafeArea/VBox/Scroll/MapContainer")
	var count := 0
	for child in map.get_children():
		if child is Button:
			count += 1
			var label := str(child.text)
			if label.is_valid_int() and not LevelDatabase.is_level_playable(int(label)):
				print("FAIL button for non-playable level ", label)
				return -1
	return count

func _router_rejects_invalid() -> bool:
	var router = load("res://app/scene_router.gd").new()
	root.add_child(router)
	var home := Control.new()
	var gameplay := Control.new()
	root.add_child(home)
	root.add_child(gameplay)
	var levels = load("res://scenes/level_select/LevelSelectScreen.tscn").instantiate()
	root.add_child(levels)
	levels.setup(SaveServiceScript.new(), null)
	router.home_screen = home
	router.level_select_screen = levels
	router.gameplay_screen = gameplay
	router.show_gameplay(999)
	if router.current_screen != router.Screen.LEVEL_SELECT or gameplay.visible:
		print("FAIL router accepted 999")
		return false
	router.show_gameplay(0)
	if router.current_screen != router.Screen.LEVEL_SELECT or gameplay.visible:
		print("FAIL router accepted level 0")
		return false
	if _button_count(levels) != 50:
		print("FAIL router rebuild left stale nodes")
		return false
	print("PASS router rejection")
	return true
