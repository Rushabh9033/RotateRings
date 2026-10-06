extends RefCounted
class_name LevelDatabase

const CampaignBoard = preload("res://data/campaign_board.gd")

# Portrait board is 720 x 1280. Every id in this list has its own solved layout.
const PLAYABLE_LEVEL_IDS: Array[int] = [
	1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
	11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
	21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
	31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
	41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
	51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
	61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
	71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
	81, 82, 83, 84, 85, 86, 87, 88, 89, 90,
	91, 92, 93, 94, 95, 96, 97, 98, 99, 100,
]
const HIGHEST_DEFINED_LEVEL := 100

static func is_level_playable(level_id: int) -> bool:
	return PLAYABLE_LEVEL_IDS.has(level_id)

static func is_level_defined(level_id: int) -> bool:
	return level_id >= 1 and level_id <= HIGHEST_DEFINED_LEVEL

static func get_playable_level_ids() -> Array[int]:
	return PLAYABLE_LEVEL_IDS.duplicate()

static func get_playable_level_count() -> int:
	return PLAYABLE_LEVEL_IDS.size()

static func get_defined_level_count() -> int:
	return HIGHEST_DEFINED_LEVEL

static func get_max_playable_level() -> int:
	return PLAYABLE_LEVEL_IDS[PLAYABLE_LEVEL_IDS.size() - 1]

static func get_next_playable_level(level_id: int) -> int:
	var index := PLAYABLE_LEVEL_IDS.find(level_id)
	if index < 0 or index + 1 >= PLAYABLE_LEVEL_IDS.size():
		return 0
	return PLAYABLE_LEVEL_IDS[index + 1]

static func get_previous_playable_level(level_id: int) -> int:
	var index := PLAYABLE_LEVEL_IDS.find(level_id)
	if index <= 0:
		return 0
	return PLAYABLE_LEVEL_IDS[index - 1]

static func get_total_levels() -> int:
	return get_playable_level_count()

static func get_level(level_id: int):
	if not is_level_defined(level_id):
		push_warning("LevelDatabase: level %d is not defined. Refusing to substitute Level 1." % level_id)
		return null
	return CampaignBoard.build(level_id)
