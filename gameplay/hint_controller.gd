extends Node
class_name HintController

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const TutorialHandScript = preload("res://gameplay/tutorial_hand.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

var current_level_def = null
var active_pieces: Array = []
var audio_service: Node = null
var current_hand: Node2D = null

func setup(audio: Node) -> void:
	audio_service = audio

var active_links: Array = []

func set_level(def, pieces: Array, links: Array) -> void:
	current_level_def = def
	active_pieces = pieces
	active_links = links
	
	if current_hand and is_instance_valid(current_hand):
		current_hand.stop()
		current_hand = null

func trigger_hint() -> Node2D:
	if not active_pieces: return null
	
	# Current runtime state -> pure logical state -> solver
	var BFSSolverScript = preload("res://tools/bfs_solver.gd")
	var solved: Dictionary = BFSSolverScript.solve_bfs(active_pieces, active_links)
	
	var path: Array = solved.get("path", [])
	if path.is_empty():
		return null
	
	var step = path[0]
	var piece = PuzzleRulesScript.get_piece_by_id(step.piece_id, active_pieces)
	
	if piece and piece.state != RingPiece2DScript.State.RELEASED and piece.state != RingPiece2DScript.State.RELEASING:
		var target_deg = step.target_orientation
		var start_deg = piece.rotation_degrees
		var dir = step.get("direction", 0)
		
		var delta := wrapf(float(target_deg) - float(start_deg), -180.0, 180.0)
		if dir != 0:
			if dir > 0 and delta < 0: delta += 360.0
			elif dir < 0 and delta > 0: delta -= 360.0
		
		# Only play audio and mark used if we successfully show a hint
		if audio_service and audio_service.has_method("play_hint"):
			audio_service.play_hint()
		
		if current_hand and is_instance_valid(current_hand):
			current_hand.stop()
		
		var center: Vector2 = piece.global_position
		var scale: Vector2 = piece.get_global_transform().get_scale()
		var sx := maxf(absf(scale.x), 0.001)
		var orbit: float = (piece.radius + piece.thickness * 0.5 + 30.0) * sx
		var from_ang := deg_to_rad(start_deg)
		var sweep := deg_to_rad(delta)
		current_hand = TutorialHandScript.new()
		piece.get_parent().add_child(current_hand)
		current_hand.play_orbit(center, orbit, from_ang, sweep)
		
		return piece
	return null

