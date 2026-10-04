extends Node
class_name SaveService

const SAVE_PATH := "user://loopshift_save.json"

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

func save_data_to_disk() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var json_str := JSON.stringify(save_data, "\t")
		file.store_string(json_str)
		file.close()

func is_level_unlocked(lvl_num: int) -> bool:
	return lvl_num <= int(save_data.get("highest_unlocked_level", 1))

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
	
	# Unlock next level
	var current_highest: int = int(save_data.get("highest_unlocked_level", 1))
	if lvl_num >= current_highest:
		save_data["highest_unlocked_level"] = lvl_num + 1
		
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
