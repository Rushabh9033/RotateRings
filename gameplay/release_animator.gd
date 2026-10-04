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
	
	var gap = piece.gaps[0] if not piece.gaps.is_empty() and piece.gaps[0].width_deg > 0.0 else null
	var half_gap: float = deg_to_rad(gap.width_deg * 0.5) if gap else 0.0
	var start_angle: float = deg_to_rad(piece.rotation_degrees) + half_gap
	var end_angle: float = deg_to_rad(piece.rotation_degrees) + TAU - half_gap
	
	# 1. Spawn Realistic Ring Fragments (RigidBody2D Arcs)
	var shards_count := 10
	var total_arc := TAU - (half_gap * 2.0)
	var arc_per_shard := total_arc / float(shards_count)
	
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
		
		dropped_shard.mass = 0.5
		dropped_shard.gravity_scale = 4.0
		parent.add_child(dropped_shard)
		
		# Calculate outward explosion
		var center_angle = rad_to_deg(s_start + (s_end - s_start) * 0.5)
		var exp_dir = Vector2.from_angle(deg_to_rad(center_angle))
		
		var impulse = (exp_dir * randf_range(200.0, 450.0)) + Vector2(0, -250.0)
		dropped_shard.apply_central_impulse(impulse)
		dropped_shard.apply_torque_impulse(randf_range(-6000.0, 6000.0))
	
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
