class_name ConnectorRuntime

extends RefCounted

# ENGAGED: cuff still holds the child tube.
# CLEARING: opening accepted the cuff; it is retracting out of the tube.
# DETACHED: cuff is outside the tube. Permanent. It no longer grips, so it does not lock rotation, the solver, or hints.
# The drawn cuff and stem are still solid: they must not pass through another cuff or another ring.
enum State {
	ENGAGED,
	CLEARING,
	DETACHED,
}

# Matches the cuff drawn in PuzzleController (sleeve span / radial depth).
# Tuned so the cuff is larger than ring thickness and the gap comfortably accommodates
# the sleeve width with margin. Tweak these together with GAP_WIDTH_DEG in json_to_gd.py
# and thickness in PieceDefinition to keep all visuals balanced.
const TANGENTIAL_WIDTH := 32.0      # sleeve width along the ring arc
const RADIAL_DEPTH := 18.0          # sleeve radial height (thicker than ring tube)
const STEM_RADIUS := 6.0
const SAFETY_MARGIN := 3.0
const CLEARANCE_MARGIN := 3.0
# Extra space required between solid bodies (ring tubes, cuffs, stems).
const BODY_MARGIN := 3.0

var def
var state: State = State.ENGAGED
var retract_progress: float = 0.0
var current_stem_dist: float = 0.0

func _init(link_def) -> void:
	def = link_def
	current_stem_dist = def.stem_dist
	state = State.ENGAGED
	retract_progress = 0.0

static func retraction_distance(tube_thickness: float) -> float:
	return tube_thickness * 0.5 + RADIAL_DEPTH * 0.5 + CLEARANCE_MARGIN
