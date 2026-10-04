extends Node2D
class_name TutorialHand

var time_passed: float = 0.0
var is_active: bool = false
var start_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO

var hand_scale: float = 0.0
var swipe_progress: float = 0.0
var is_pressing: bool = false

func _ready() -> void:
	z_index = 200
	modulate.a = 0.0
	
	if not get_node_or_null("HandSprite"):
		var hand_sprite = Sprite2D.new()
		hand_sprite.name = "HandSprite"
		hand_sprite.z_index = 100
		add_child(hand_sprite)

func _process(delta: float) -> void:
	if not is_active:
		return
	
	# Sync sprite scale if the user adds a texture later
	var hand_sprite = get_node_or_null("HandSprite")
	if hand_sprite:
		hand_sprite.scale = Vector2(hand_scale, hand_scale)
		if is_pressing:
			hand_sprite.scale *= 0.9
			
	queue_redraw()

func play_swipe(from: Vector2, to: Vector2) -> void:
	start_pos = from
	end_pos = to
	is_active = true
	position = from
	
	var tween = create_tween().set_loops()
	
	# Fade in and scale up
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(self, "hand_scale", 1.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Press down (shrink slightly)
	tween.tween_property(self, "is_pressing", true, 0.0)
	tween.tween_property(self, "hand_scale", 0.85, 0.15)
	
	# Swipe
	tween.tween_property(self, "position", to, 0.8).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Release (scale back up)
	tween.tween_property(self, "is_pressing", false, 0.0)
	tween.tween_property(self, "hand_scale", 1.0, 0.15)
	
	# Fade out
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	# Reset position for loop
	tween.tween_property(self, "position", from, 0.0).set_delay(0.2)

func stop() -> void:
	is_active = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func _draw() -> void:
	# Fallback procedural drawing so the animation is visible until final art is added!
	var hand_sprite = get_node_or_null("HandSprite")
	if hand_sprite and hand_sprite.texture != null:
		return # Hide procedural drawing if real art is loaded
		
	draw_set_transform(Vector2.ZERO, deg_to_rad(-15.0), Vector2(hand_scale, hand_scale))
	
	var skin_color = Color.WHITE
	var outline_color = Color(0.2, 0.2, 0.25)
	var shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	
	var offset = Vector2(10, 20) if not is_pressing else Vector2(5, 10)
	
	# Shadow
	draw_circle(offset, 25.0, shadow_color)
	draw_circle(Vector2(-10, -25) + offset, 12.0, shadow_color)
	
	# Outline / Border
	var ow = 4.0
	draw_circle(Vector2.ZERO, 25.0 + ow, outline_color)
	# Index finger
	draw_circle(Vector2(-10, -25), 12.0 + ow, outline_color)
	draw_rect(Rect2(-22 - ow, -25, 24 + ow*2, 25), outline_color)
	
	# Fill
	draw_circle(Vector2.ZERO, 25.0, skin_color)
	# Palm detail
	draw_circle(Vector2(0, 5), 18.0, Color(0.9, 0.9, 0.95))
	
	# Index finger fill
	draw_circle(Vector2(-10, -25), 12.0, skin_color)
	draw_rect(Rect2(-22, -25, 24, 25), skin_color)
	
	# Pressed ripple effect
	if is_pressing:
		draw_circle(Vector2(-10, -25), 6.0, Color(0.5, 0.8, 1.0, 0.5))
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
