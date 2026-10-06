extends RefCounted
class_name PuzzleState

## Pure logical puzzle state model (independent of SceneTree / Node2D)
## Contains zero visual objects (no Node, Node2D, Tween, SceneTree, RingPiece2D).

var pieces: Dictionary = {}
var connectors: Dictionary = {}
var locks: Dictionary = {}

var move_count: int = 0
var released_piece_count: int = 0
var status: StringName = &"IN_PROGRESS"

func _init(p_pieces: Dictionary = {}, p_connectors: Dictionary = {}, p_locks: Dictionary = {}) -> void:
	pieces = p_pieces.duplicate(true)
	connectors = p_connectors.duplicate(true)
	locks = p_locks.duplicate(true)
	move_count = 0
	released_piece_count = 0
	status = &"IN_PROGRESS"

func clone() -> PuzzleState:
	var c := PuzzleState.new()
	c.move_count = move_count
	c.released_piece_count = released_piece_count
	c.status = status
	c.pieces = pieces.duplicate(true)
	c.connectors = connectors.duplicate(true)
	c.locks = locks.duplicate(true)
	return c

func get_hash() -> String:
	# Deterministic canonical hash string for solver state checking
	var parts: Array[String] = []
	var p_keys := pieces.keys()
	p_keys.sort()
	
	for pid in p_keys:
		var p: Dictionary = pieces[pid]
		var st: int = int(p.get("state", 0))
		if st == 6 or bool(p.get("released", false)):
			parts.append("%s:REL" % str(pid))
		else:
			var rot := fposmod(float(p.get("rotation_deg", p.get("rotation_degrees", 0.0))), 360.0)
			# Quantize to 0.1 degree steps to prevent floating point jitter
			var q_rot := int(round(rot * 10.0))
			parts.append("%s:%d:%d" % [str(pid), st, q_rot])
			
	var c_keys := connectors.keys()
	c_keys.sort()
	for cid in c_keys:
		var conn: Dictionary = connectors[cid]
		var c_st: int = int(conn.get("state", 0))
		parts.append("%s:%d" % [str(cid), c_st])
		
	var l_keys := locks.keys()
	l_keys.sort()
	for lid in l_keys:
		var lock: Dictionary = locks[lid]
		parts.append("%s:%d:%s" % [str(lid), int(lock.get("counter", 0)), str(lock.get("is_broken", false))])
		
	return ",".join(parts)

static func is_equal(a: PuzzleState, b: PuzzleState) -> bool:
	if a == null or b == null:
		return a == b
	return a.get_hash() == b.get_hash()
