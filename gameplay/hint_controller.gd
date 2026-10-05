extends Node
class_name HintController

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const TutorialHandScript = preload("res://gameplay/tutorial_hand.gd")

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

func trigger_hint():
	if not current_level_def: return null
	
	if audio_service and audio_service.has_method("play_hint"):
		audio_service.play_hint()
		
	if current_hand and is_instance_valid(current_hand):
		current_hand.stop()
		
	for step in current_level_def.canonical_steps:
		var piece = PuzzleRulesScript.get_piece_by_id(step.piece_id, active_pieces)
		if piece and piece.state != 6 and piece.state != 5: # not RELEASED/RELEASING
			var target_deg = step.target_angle_deg
			var start_deg = piece.rotation_degrees
			
			# Check if rotating to this target angle actually clears any active connector
			var newly_cleared = PuzzleRulesScript.evaluate_clearance_hypothetical(piece, target_deg, active_pieces, active_links)
			
			if newly_cleared.size() == 0:
				# If rotating there doesn't clear anything new, this step is already completed!
				# (Either the connector is already detached, or this step is obsolete)
				continue
				
			var r = piece.radius
			var center = piece.global_position
			var from_pos = center + grab_offset.rotated(deg_to_rad(start_deg))
			var to_pos = center + grab_offset.rotated(deg_to_rad(target_deg))
			
			current_hand = TutorialHandScript.new()
			piece.get_parent().add_child(current_hand)
			current_hand.play_swipe(from_pos, to_pos)
			
			return piece
			
	return null
