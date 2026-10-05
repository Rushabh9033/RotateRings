extends Node
class_name ReleaseAnimator

const RingShardBurstScript = preload("res://gameplay/ring_shard_burst.gd")
const FloatingTextScript = preload("res://gameplay/floating_text.gd")
const DroppedRing2DScript = preload("res://gameplay/dropped_ring_2d.gd")

var audio_service: Node = null
var haptic_service: Node = null
var combo_count: int = 0

func setup(audio: Node, haptic: Node) -> void:
	audio_service = audio
	haptic_service = haptic
	combo_count = 0

func reset_combo() -> void:
	combo_count = 0

func animate_release(
	piece: Node2D,
	on_completed: Callable
) -> void:
	piece.state = 5 # RELEASING
	piece.is_interactive = false
	combo_count += 1
	
	if audio_service and audio_service.has_method("play_release"):
		audio_service.play_release()
	if haptic_service and haptic_service.has_method("trigger_release"):
		haptic_service.trigger_release()
		
	var parent = piece.get_parent()
	var pos: Vector2 = piece.global_position
	var rad: float = float(piece.get("radius")) if piece.get("radius") != null else 100.0
	var ring_color: Color = piece.get("ring_color") if piece.get("ring_color") != null else Color("#29B6F6")
	
	# 1. Spawn Realistic Ring Fragments (RigidBody2D Arcs)
	var shards_per_full_circle := 12
	
	var arcs: Array = RingGeometry.get_solid_arcs(piece.gaps)
	for arc in arcs:
		var start_angle: float = arc.start
		var end_angle: float = arc.end
		if end_angle < start_angle:
			end_angle += TAU
			
		var arc_len = end_angle - start_angle
		var shards_count = max(2, roundi((arc_len / TAU) * shards_per_full_circle))
		var arc_per_shard = arc_len / float(shards_count)
		
		for i in range(shards_count):
			var s_start = start_angle + (i * arc_per_shard)
			var s_end = s_start + arc_per_shard
			
			# Gap between fragments so they look shattered
			s_start += 0.05
			s_end -= 0.05
			
			if s_end <= s_start: continue
			
			var dropped_shard := DroppedRing2DScript.new()
			dropped_shard.setup(rad, piece.get("thickness") if piece.get("thickness") != null else 26.0, ring_color, piece.gaps, piece.rotation_degrees, s_start, s_end, true)
			dropped_shard.global_position = pos
			
			# H. Release impulse is more explosive than naturally weighted. Let's make it more natural/heavy
			dropped_shard.mass = 0.8
			dropped_shard.gravity_scale = 3.5
			parent.add_child(dropped_shard)
			
			# Calculate outward explosion (in global space)
			var center_angle_local = s_start + (s_end - s_start) * 0.5
			var center_angle_global = center_angle_local + deg_to_rad(piece.rotation_degrees)
			var exp_dir = Vector2.from_angle(center_angle_global)
			
			# Natural heavy release: smaller random outward impulse, less extreme upward
			var impulse = (exp_dir * randf_range(100.0, 250.0)) + Vector2(0, -100.0)
			dropped_shard.apply_central_impulse(impulse)
			dropped_shard.apply_torque_impulse(randf_range(-3000.0, 3000.0))
	
	# 2. Spawn Floating Combo Praise Text
	var praise_text := "Good!"
	var praise_color := Color("#4CAF50") # Green
	if combo_count == 2:
		praise_text = "Great!"
		praise_color = Color("#29B6F6") # Blue
	elif combo_count >= 3:
		praise_text = "Excellent!"
		praise_color = Color("#9C27B0") # Purple
		
	var float_lbl := FloatingTextScript.new()
	float_lbl.setup(pos + Vector2(0, -20), praise_text, praise_color)
	parent.add_child(float_lbl)
	
	# We immediately consider the piece released and free the old Kinematic visual
	piece.state = 6 # RELEASED
	if on_completed.is_valid():
		on_completed.call(piece)
	piece.queue_free()
