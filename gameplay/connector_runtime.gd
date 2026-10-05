class_name ConnectorRuntime

extends RefCounted

# ENGAGED: cuff still holds the child tube.
# CLEARING: opening accepted the cuff; it is retracting out of the tube.
# DETACHED: cuff is outside the tube. Permanent. Does not block rotation, collision, solver, or hints.
enum State {
	ENGAGED,
	CLEARING,
	DETACHED,
}

# Matches the cuff drawn in PuzzleController (sleeve span / radial depth).
const TANGENTIAL_WIDTH := 38.0
const RADIAL_DEPTH := 32.0
const SAFETY_MARGIN := 2.0
const CLEARANCE_MARGIN := 2.0

var def: LinkDefinition
var state: State = State.ENGAGED
var retract_progress: float = 0.0
var current_stem_dist: float = 0.0

func _init(link_def: LinkDefinition) -> void:
	def = link_def
	current_stem_dist = def.stem_dist
	state = State.ENGAGED
	retract_progress = 0.0

static func retraction_distance(tube_thickness: float) -> float:
	return tube_thickness * 0.5 + RADIAL_DEPTH * 0.5 + CLEARANCE_MARGIN
