extends Node
class_name ReleaseAnimator

const RingShardBurstScript = preload("res://gameplay/ring_shard_burst.gd")
const FloatingTextScript = preload("res://gameplay/floating_text.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

var audio_service: Node = null
var haptic_service: Node = null
var combo_count: int = 0
var _pending_praise: bool = false
var _pending_praise_pos: Vector2 = Vector2.ZERO
var _pending_praise_direct: bool = false
var _cascade_count: int = 0
var _viewport_rect: Rect2 = Rect2()

func _ready() -> void:
	_viewport_rect = get_viewport().get_visible_rect()

func _register_release_for_praise(pos: Vector2, is_direct: bool) -> void:
	if is_direct:
		_cascade_count = 0
	else:
		_cascade_count += 1
		
	_pending_praise_pos = pos
	if is_direct:
		_pending_praise_direct = true
		
	if not _pending_praise:
		_pending_praise = true
		call_deferred("_spawn_aggregated_praise")

func _spawn_aggregated_praise() -> void:
	if not _pending_praise: return
	_pending_praise = false
	
	var praise_text := ""
	var praise_color := Color.WHITE
	
	if _pending_praise_direct:
		praise_text = "Good!"
		praise_color = Color("#4CAF50")
		if combo_count == 2:
			praise_text = "Great!"
			praise_color = Color("#29B6F6")
		elif combo_count >= 3:
			praise_text = "Excellent!"
			praise_color = Color("#9C27B0")
	elif _cascade_count > 0:
		praise_text = "Combo x%d" % (_cascade_count + 1)
		praise_color = Color("#FF9800")
		
	if praise_text != "":
		var float_lbl := FloatingTextScript.new()
		var spawn_pos = _pending_praise_pos + Vector2(0, -20)
		# Clamp to screen bounds
		spawn_pos.x = clampf(spawn_pos.x, 80.0, _viewport_rect.size.x - 80.0)
		spawn_pos.y = clampf(spawn_pos.y, 80.0, _viewport_rect.size.y - 80.0)
		float_lbl.setup(spawn_pos, praise_text, praise_color)
		
		# Find a parent
		var parent = get_parent()
		if is_instance_valid(parent):
			parent.add_child(float_lbl)
			
	_pending_praise_direct = false


func setup(audio: Node, haptic: Node) -> void:
	audio_service = audio
	haptic_service = haptic
	combo_count = 0

func reset_combo() -> void:
	combo_count = 0

func animate_release(
	piece: Node2D,
	on_completed: Callable,
	is_direct: bool = false
) -> void:
	piece.state = RingPiece2DScript.State.RELEASING
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
	var thick: float = piece.get("thickness") if piece.get("thickness") != null else 26.0

	var burst := RingShardBurstScript.new()
	parent.add_child(burst)
	burst.setup(pos, rad, 0.0, TAU, ring_color, thick)
	
	# 2. Handle Praise / Combo
	_register_release_for_praise(pos, is_direct)
	
	# We immediately consider the piece released and free the old Kinematic visual
	piece.state = RingPiece2DScript.State.RELEASED
	if on_completed.is_valid():
		on_completed.call(piece)
	piece.queue_free()
