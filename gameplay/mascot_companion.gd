extends Node2D
class_name MascotCompanion

enum State {
	IDLE,
	WATCHING,
	REACT_GOOD,
	REACT_BAD,
	CATCHING,
	CELEBRATING
}

var current_state: State = State.IDLE
var look_target: Vector2 = Vector2.ZERO
var body_color: Color = Color("#FFB74D") # Warm orange/gold
var time_passed: float = 0.0

var blink_timer: float = 0.0
var is_blinking: bool = false

# Procedural animation parameters
var body_offset_y: float = 0.0
var squash_stretch: Vector2 = Vector2.ONE
var hand_l_pos: Vector2 = Vector2(-25, 10)
var hand_r_pos: Vector2 = Vector2(25, 10)


func _update_animation_state(delta: float) -> void:
	var target_squash := Vector2.ONE
	var target_body_y := 0.0
	var target_hand_l := Vector2(-25, 10)
	var target_hand_r := Vector2(25, 10)

	match current_state:
		State.IDLE:
			# Gentle bobbing
			target_body_y = sin(time_passed * 3.0) * 4.0
			target_hand_l = Vector2(-25, 10 + sin(time_passed * 3.0 + 1.0) * 3.0)
			target_hand_r = Vector2(25, 10 + sin(time_passed * 3.0 + 2.0) * 3.0)
		
		State.WATCHING:
			# Lean slightly towards target
			var to_target = to_local(look_target).normalized()
			target_body_y = sin(time_passed * 4.0) * 2.0 + (to_target.y * 5.0)
			target_hand_l = Vector2(-25, 5) + to_target * 5.0
			target_hand_r = Vector2(25, 5) + to_target * 5.0
			
		State.REACT_GOOD:
			# Happy jumping
			var bounce = abs(sin(time_passed * 12.0))
			target_body_y = -bounce * 25.0
			target_squash = Vector2(1.0 - bounce * 0.1, 1.0 + bounce * 0.2)
			target_hand_l = Vector2(-30, -15 - bounce * 20.0)
			target_hand_r = Vector2(30, -15 - bounce * 20.0)
			
		State.REACT_BAD:
			# Shrink back, hands up
			target_body_y = 10.0
			target_squash = Vector2(1.1, 0.9)
			target_hand_l = Vector2(-20, -5)
			target_hand_r = Vector2(20, -5)

		State.CATCHING:
			# Reaching up to catch
			target_body_y = -15.0
			target_squash = Vector2(0.9, 1.1)
			target_hand_l = Vector2(-20, -35)
			target_hand_r = Vector2(20, -35)

		State.CELEBRATING:
			# Spin or big pose
			target_body_y = sin(time_passed * 10.0) * 15.0 - 20.0
			target_hand_l = Vector2(-35, -20)
			target_hand_r = Vector2(35, -20)

	# Smooth lerp
	body_offset_y = lerpf(body_offset_y, target_body_y, delta * 10.0)
	squash_stretch = squash_stretch.lerp(target_squash, delta * 12.0)
	hand_l_pos = hand_l_pos.lerp(target_hand_l, delta * 15.0)
	hand_r_pos = hand_r_pos.lerp(target_hand_r, delta * 15.0)

func set_state(new_state: State) -> void:
	if current_state == new_state: return
	current_state = new_state
	
	# Add a little squash/stretch juice on state transition
	squash_stretch = Vector2(1.3, 0.7) if new_state == State.REACT_GOOD else Vector2(0.8, 1.2)
	time_passed = 0.0

func _ready() -> void:
	# Create proper sprite slots for future professional art
	var body_sprite = Sprite2D.new()
	body_sprite.name = "BodySprite"
	add_child(body_sprite)
	
	var left_hand_sprite = Sprite2D.new()
	left_hand_sprite.name = "LeftHandSprite"
	add_child(left_hand_sprite)
	
	var right_hand_sprite = Sprite2D.new()
	right_hand_sprite.name = "RightHandSprite"
	add_child(right_hand_sprite)

func _process(delta: float) -> void:
	time_passed += delta
	_update_animation_state(delta)
	
	# Apply animation to sprites instead of draw calls
	var body = get_node_or_null("BodySprite")
	if body:
		body.position = Vector2(0, body_offset_y)
		body.scale = squash_stretch
		
	var lh = get_node_or_null("LeftHandSprite")
	if lh:
		lh.position = hand_l_pos
		
	var rh = get_node_or_null("RightHandSprite")
	if rh:
		rh.position = hand_r_pos

func _draw() -> void:
	# Intentionally left blank.
	# The procedural mascot has been removed.
	# Final professionally illustrated mascot artwork will be placed in the Sprite2D nodes.
	pass
