class_name ConnectorRuntime

extends RefCounted

enum State {
	ATTACHED,
	ALIGNING,
	CLEARING,
	DETACHED
}

var def: LinkDefinition
var state: State = State.ATTACHED
var retract_progress: float = 0.0
var current_stem_dist: float = 0.0

func _init(link_def: LinkDefinition) -> void:
	def = link_def
	current_stem_dist = def.stem_dist
	state = State.ATTACHED
	retract_progress = 0.0

