extends RefCounted
class_name Band2650

# Levels 26–50. Open rings are circles. One closed root.
# A serial lock-chain: only the loose tip can turn, and a clasped
# ring takes a second turn. Target length is 13 moves at level 26,
# then +1 move each level through 37 at level 50.
const C := 0
const S := 1
const T := 2
const O := 3

const _BENDS: Array[float] = [82.0, -74.0, 108.0, 66.0, -96.0, 124.0, 54.0, -118.0]
const _SHAPES: Array[int] = [S, T, O, C, O, S, T, C]

static func root_for(level_id: int) -> Dictionary:
	var moves := level_id - 13
	if level_id < 26 or level_id > 50:
		moves = 13
	return _snake(level_id, moves)


static func _snake(level_id: int, moves: int) -> Dictionary:
	var pattern := (level_id - 26) % _BENDS.size()
	var bend := _BENDS[pattern]
	var modules := int(moves / 3)
	var tail := moves - modules * 3
	var spin := -160.0 + float((level_id * 29) % 120)
	var open_r := 56.0 + float((level_id + pattern) % 3) * 2.0
	var root_r := 64.0 + float(level_id % 5) * 3.0
	var node := _leaf(_radius_at(open_r, 0, level_id))
	var heading := spin
	for i in tail:
		heading += _step_bend(bend, pattern, i)
		node = _link(_radius_at(open_r, i + 1, level_id), heading, node)
	for mod in modules:
		heading += _step_bend(bend, pattern, tail + mod)
		var spur := _leaf(_radius_at(open_r, tail + mod + 3, level_id))
		node = _clasp(_radius_at(open_r, tail + mod + 8, level_id), heading, spur, node)
	node["shape"] = _SHAPES[pattern]
	node["gaps"] = 0
	node["turn"] = 0.0
	node["r"] = root_r
	return node


static func _step_bend(bend: float, pattern: int, step: int) -> float:
	if pattern == 3:
		return bend if step % 2 == 0 else -bend * 0.85
	if pattern == 6:
		return bend + float(step % 3) * 12.0
	return bend


static func _radius_at(base: float, salt: int, level_id: int) -> float:
	var bump := float((salt * 2 + level_id) % 4)
	return maxf(56.0, base + bump)


static func _leaf(r: float) -> Dictionary:
	return _node(r, C, 1, 142.0, [], [])


static func _link(r: float, heading: float, child: Dictionary) -> Dictionary:
	return _node(r, C, 1, 148.0, [[heading, child]], [])


static func _clasp(r: float, heading: float, spur: Dictionary, cont: Dictionary) -> Dictionary:
	return _node(r, C, 2, 154.0, [[heading, spur], [heading + 90.0, cont]], [[0, 1]])


static func _node(r: float, shape: int, gaps: int, turn: float, kids: Array, extra: Array) -> Dictionary:
	return {
		"r": r,
		"shape": shape,
		"gaps": gaps,
		"turn": turn,
		"color": 0,
		"kids": kids,
		"bridge": false,
		"extra": extra, "locks": extra,
		"thick": 16.0,
	}




