extends Node
class_name SaveService

const SAVE_PATH := "user://loopshift_save.json"
const LevelDatabaseScript = preload("res://data/level_database.gd")

var save_data: Dictionary = {
	"version": 1,
	"highest_unlocked_level": 1,
	"levels": {},
	"settings": {
		"sound": true,
		"haptics": true,
		"reduced_motion": false
	}
}

func _ready() -> void:
	load_data()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_data_to_disk()
		return
		
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_str := file.get_as_text()
		file.close()
		var json := JSON.new()
		var parse_err := json.parse(json_str)
		if parse_err == OK and json.data is Dictionary:
			var data: Dictionary = json.data
			save_data["version"] = data.get("version", 1)
			save_data["highest_unlocked_level"] = data.get("highest_unlocked_level", 1)
			save_data["levels"] = data.get("levels", {})
			save_data["settings"] = data.get("settings", {
				"sound": true,
				"haptics": true,
				"reduced_motion": false
			})
			_sanitize_progression()

func save_data_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_str := JSON.stringify(save_data, "\t")
		file.store_string(json_str)
		file.close()

func resolve_unlocked_level(stored: int) -> int:
	if LevelDatabaseScript.is_level_playable(stored):
		return stored
	var resolved: int = LevelDatabaseScript.get_max_playable_level()
	push_warning("Save highest_unlocked_level %d is not playable. Resolved to %d, not Level 1." % [stored, resolved])
	return resolved

func get_highest_unlocked_level() -> int:
	return resolve_unlocked_level(int(save_data.get("highest_unlocked_level", 1)))

func get_continue_level() -> int:
	return get_highest_unlocked_level()

func _sanitize_progression() -> void:
	var stored := int(save_data.get("highest_unlocked_level", 1))
	var resolved := resolve_unlocked_level(stored)
	if resolved == stored:
		return
	save_data["highest_unlocked_level"] = resolved
	save_data_to_disk()

func is_level_unlocked(lvl_num: int) -> bool:
	if not LevelDatabaseScript.is_level_playable(lvl_num):
		return false
	return lvl_num <= get_highest_unlocked_level()

func is_level_cleared(lvl_num: int) -> bool:
	var levels: Dictionary = save_data.get("levels", {})
	var lvl_key := str(lvl_num)
	return levels.has(lvl_key) and levels[lvl_key].get("cleared", false)

func is_level_perfect(lvl_num: int) -> bool:
	var levels: Dictionary = save_data.get("levels", {})
	var lvl_key := str(lvl_num)
	return levels.has(lvl_key) and levels[lvl_key].get("perfect", false)

func get_best_moves(lvl_num: int) -> int:
	var levels: Dictionary = save_data.get("levels", {})
	var lvl_key := str(lvl_num)
	if levels.has(lvl_key):
		return int(levels[lvl_key].get("best_moves", 999))
	return 999

func record_level_completion(lvl_num: int, moves: int, par_moves: int, used_hint: bool) -> Dictionary:
	var is_perfect := (moves <= par_moves) and not used_hint
	var levels: Dictionary = save_data.get("levels", {})
	var lvl_key := str(lvl_num)
	
	var existing: Dictionary = levels.get(lvl_key, {})
	var previous_best: int = existing.get("best_moves", 999)
	var best: int = mini(previous_best, moves)
	var prev_perfect: bool = existing.get("perfect", false)
	
	levels[lvl_key] = {
		"cleared": true,
		"perfect": is_perfect or prev_perfect,
		"best_moves": best
	}
	save_data["levels"] = levels
	
	# Unlock only the next production level. Experimental ids do not advance the map.
	if LevelDatabaseScript.is_level_playable(lvl_num):
		var current_highest := get_highest_unlocked_level()
		var nxt := LevelDatabaseScript.get_next_playable_level(lvl_num)
		if nxt > current_highest:
			save_data["highest_unlocked_level"] = nxt
		elif lvl_num > current_highest:
			save_data["highest_unlocked_level"] = lvl_num
	else:
		push_warning("Completion of non-playable level %d did not change progression." % lvl_num)
		
	save_data_to_disk()
	
	return {
		"is_perfect": is_perfect,
		"is_new_best": moves < previous_best,
		"best_moves": best
	}

func get_setting(key: String, default_val: Variant = true) -> Variant:
	var settings: Dictionary = save_data.get("settings", {})
	return settings.get(key, default_val)

func set_setting(key: String, val: Variant) -> void:
	var settings: Dictionary = save_data.get("settings", {})
	settings[key] = val
	save_data["settings"] = settings
	save_data_to_disk()

func reset_all_progress() -> void:
	save_data["highest_unlocked_level"] = 1
	save_data["levels"] = {}
	save_data_to_disk()
