extends Node2D
class_name HammerAnimator

const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const UiTheme = preload("res://app/ui_theme.gd")

signal targeting_cancelled
signal smash_completed

var puzzle_controller = null
var audio_service: Node = null
var gameplay_screen = null

var is_targeting: bool = false
var is_striking: bool = false
var hover_target: Node2D = null

var hammer_sprite: Sprite2D = null
var shockwave_drawer: Node2D = null
var smoke_overlay: Node2D = null
var prompt_banner: PanelContainer = null

var time_passed: float = 0.0
var pointer_pos: Vector2 = Vector2.ZERO

class DarkSmokeOverlay extends Node2D:
	var alpha: float = 0.0

	func _draw() -> void:
		if alpha <= 0.001:
			return
		var vp_size := get_viewport_rect().size
		# Fullscreen rich dark smoky studio atmosphere (ultra-clean, no banding)
		var base_smoke := Color(0.06, 0.05, 0.08, 0.94 * alpha)
		draw_rect(Rect2(Vector2.ZERO, vp_size), base_smoke, true)




class ColoredRockChunk extends Node2D:
	var velocity: Vector2 = Vector2.ZERO
	var angular_velocity: float = 0.0
	var gravity: Vector2 = Vector2(0, 1350.0)
	var lifetime: float = 0.72
	var age: float = 0.0
	var rock_color: Color = Color.WHITE
	var radius: float = 12.0
	var poly_pts: PackedVector2Array = PackedVector2Array()
	var highlight_pts: PackedVector2Array = PackedVector2Array()

	func setup(col: Color, sz: float) -> void:
		rock_color = col
		radius = sz
		# 5-7 vertex irregular polygonal rock
		var num_verts := randi_range(5, 7)
		var pts: Array[Vector2] = []
		for i in range(num_verts):
			var ang := (float(i) / float(num_verts)) * TAU + randf_range(-0.25, 0.25)
			var r := radius * randf_range(0.72, 1.28)
			pts.append(Vector2(cos(ang), sin(ang)) * r)
		poly_pts = PackedVector2Array(pts)

		# Top specular highlight facet
		var hi_pts: Array[Vector2] = []
		hi_pts.append(Vector2(-radius * 0.45, -radius * 0.55))
		hi_pts.append(Vector2(radius * 0.25, -radius * 0.65))
		hi_pts.append(Vector2(-0.05 * radius, -radius * 0.15))
		highlight_pts = PackedVector2Array(hi_pts)

	func _process(delta: float) -> void:
		velocity += gravity * delta
		position += velocity * delta
		rotation += angular_velocity * delta
		age += delta

		var progress := age / lifetime
		if progress >= 1.0:
			queue_free()
			return

		# Shrink and fade in the second half of life
		if progress > 0.40:
			var fade_t := (progress - 0.40) / 0.60
			modulate.a = 1.0 - fade_t
			var sc := 1.0 - (fade_t * 0.75)
			scale = Vector2(sc, sc)

	func _draw() -> void:
		if poly_pts.is_empty():
			return
		
		# 1. Soft drop shadow offset
		var shadow_col := Color(0.08, 0.06, 0.07, 0.32 * modulate.a)
		var shadow_poly := PackedVector2Array()
		for p in poly_pts:
			shadow_poly.append(p + Vector2(0.0, 3.5))
		draw_colored_polygon(shadow_poly, shadow_col)

		# 2. Dark stone contour / border
		var dark_border_col := rock_color.darkened(0.38)
		draw_colored_polygon(poly_pts, dark_border_col)

		# 3. Vibrant stone body (slightly inset)
		var body_poly := PackedVector2Array()
		for p in poly_pts:
			body_poly.append(p * 0.82)
		draw_colored_polygon(body_poly, rock_color.lightened(0.04))

		# 4. Top-left chiseled specular highlight
		var hi_col := rock_color.lightened(0.42)
		hi_col.a = 0.85 * modulate.a
		draw_colored_polygon(highlight_pts, hi_col)

class ShockwaveNode extends Node2D:
	var center: Vector2 = Vector2.ZERO
	var radius: float = 0.0
	var max_radius: float = 240.0
	var alpha: float = 1.0
	var ring_color: Color = Color(1.0, 0.88, 0.45)

	func _draw() -> void:
		if alpha <= 0.001 or radius <= 0.0:
			return
		var c := ring_color
		c.a = alpha * 0.75
		draw_arc(center, radius, 0, TAU, 48, c, 6.0 * alpha + 1.0, true)
		var c_inner := Color(1.0, 1.0, 1.0, alpha * 0.9)
		draw_arc(center, maxf(1.0, radius - 4.0), 0, TAU, 36, c_inner, 3.0 * alpha, true)

func _ready() -> void:
	z_index = 150

	smoke_overlay = DarkSmokeOverlay.new()
	smoke_overlay.z_as_relative = false
	smoke_overlay.z_index = 50
	add_child(smoke_overlay)

	_setup_prompt_banner()

	hammer_sprite = Sprite2D.new()
	hammer_sprite.texture = load("res://art/tools/hammer_tool.png")
	# Texture is 256x256, scale to ~96x96 px
	var target_size := 96.0
	var tex_w: float = hammer_sprite.texture.get_width() if hammer_sprite.texture else 256.0
	var s_val: float = target_size / tex_w
	hammer_sprite.scale = Vector2(s_val, s_val)
	# Center pivot near handle top for natural swing rotation
	hammer_sprite.offset = Vector2(-15.0, -25.0)
	hammer_sprite.visible = false
	add_child(hammer_sprite)

	shockwave_drawer = ShockwaveNode.new()
	add_child(shockwave_drawer)

func _setup_prompt_banner() -> void:
	prompt_banner = PanelContainer.new()
	prompt_banner.z_as_relative = false
	prompt_banner.z_index = 160
	prompt_banner.visible = false
	prompt_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pill_style := StyleBoxFlat.new()
	pill_style.bg_color = Color(0.11, 0.08, 0.15, 0.92)
	pill_style.border_color = Color(1.0, 0.82, 0.35, 0.80)
	pill_style.set_border_width_all(2)
	pill_style.corner_radius_top_left = 24
	pill_style.corner_radius_top_right = 24
	pill_style.corner_radius_bottom_right = 24
	pill_style.corner_radius_bottom_left = 24
	pill_style.shadow_color = Color(0.0, 0.0, 0.0, 0.40)
	pill_style.shadow_size = 8
	pill_style.shadow_offset = Vector2(0, 3)
	pill_style.content_margin_left = 18.0
	pill_style.content_margin_right = 22.0
	pill_style.content_margin_top = 8.0
	pill_style.content_margin_bottom = 8.0
	prompt_banner.add_theme_stylebox_override("panel", pill_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_banner.add_child(hbox)

	var icon := TextureRect.new()
	icon.texture = load("res://art/tools/hammer_tool.png")
	icon.custom_minimum_size = Vector2(36, 36)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(icon)

	var lbl := Label.new()
	lbl.text = "Tap any object to smash it"
	lbl.add_theme_font_override("font", UiTheme.rounded_font())
	lbl.add_theme_font_size_override("font_size", 18)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.98, 0.94))
	lbl.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	lbl.add_theme_constant_override("shadow_offset_x", 0)
	lbl.add_theme_constant_override("shadow_offset_y", 2)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(lbl)

	add_child(prompt_banner)


func setup(gp_screen, pc, audio: Node = null) -> void:
	gameplay_screen = gp_screen
	puzzle_controller = pc
	audio_service = audio

func start_targeting() -> void:
	is_targeting = true
	is_striking = false
	time_passed = 0.0
	hover_target = null
	pointer_pos = get_global_mouse_position()

	# 1. Atmospheric Dark Smoke Overlay
	if is_instance_valid(smoke_overlay):
		var sm_tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		sm_tw.tween_property(smoke_overlay, "alpha", 1.0, 0.18)
		var sm_ticker := create_tween().set_loops(12)
		sm_ticker.tween_callback(smoke_overlay.queue_redraw).set_delay(0.02)

	# 2. Popout Puzzle Controller and Shapes
	_set_puzzle_popout(true)

	# 3. Message Banner: Exact Hammer Icon + "Tap any object to smash it"
	_show_prompt_banner(true)

	# 4. Floating Hammer Sprite
	hammer_sprite.position = pointer_pos + Vector2(40.0, -60.0)
	hammer_sprite.rotation_degrees = -20.0
	hammer_sprite.modulate.a = 0.0
	hammer_sprite.visible = true

	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "modulate:a", 1.0, 0.18)
	tw.parallel().tween_property(hammer_sprite, "scale", Vector2(96.0 / 256.0, 96.0 / 256.0) * 1.15, 0.18)
	tw.tween_property(hammer_sprite, "scale", Vector2(96.0 / 256.0, 96.0 / 256.0), 0.12)

func cancel_targeting() -> void:
	if not is_targeting or is_striking:
		return
	is_targeting = false
	_clear_hover()

	# 1. Fade out smoke overlay
	if is_instance_valid(smoke_overlay):
		var sm_tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		sm_tw.tween_property(smoke_overlay, "alpha", 0.0, 0.18)
		var sm_ticker := create_tween().set_loops(9)
		sm_ticker.tween_callback(smoke_overlay.queue_redraw).set_delay(0.02)

	# 2. Restore puzzle popout
	_set_puzzle_popout(false)

	# 3. Dismiss Prompt Banner
	_show_prompt_banner(false)

	# 4. Hide Hammer Sprite
	if is_instance_valid(hammer_sprite):
		var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(hammer_sprite, "modulate:a", 0.0, 0.15)
		tw.tween_callback(func(): hammer_sprite.visible = false)
	targeting_cancelled.emit()

var _base_pc_scale: Vector2 = Vector2.ONE
var _has_saved_pc_scale: bool = false

func _set_puzzle_popout(popout: bool) -> void:
	if puzzle_controller == null:
		return

	var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if popout:
		_base_pc_scale = puzzle_controller.scale
		_has_saved_pc_scale = true
		puzzle_controller.z_as_relative = false
		puzzle_controller.z_index = 65
		tw.tween_property(puzzle_controller, "scale", _base_pc_scale * 1.035, 0.22)
		for p in puzzle_controller.active_pieces:
			if is_instance_valid(p):
				tw.parallel().tween_property(p, "modulate", Color(1.18, 1.18, 1.14, 1.0), 0.20)
	else:
		var target_s: Vector2 = _base_pc_scale if _has_saved_pc_scale else puzzle_controller.scale
		tw.tween_property(puzzle_controller, "scale", target_s, 0.18)
		for p in puzzle_controller.active_pieces:
			if is_instance_valid(p):
				tw.parallel().tween_property(p, "modulate", Color.WHITE, 0.18)
		tw.tween_callback(func():
			if is_instance_valid(puzzle_controller):
				puzzle_controller.z_index = 0
		)

func _show_prompt_banner(show_it: bool) -> void:
	if prompt_banner == null:
		return
	if show_it:
		var vp_size := get_viewport_rect().size
		prompt_banner.reset_size()
		prompt_banner.position = Vector2((vp_size.x - prompt_banner.size.x) * 0.5, 136.0)
		prompt_banner.pivot_offset = prompt_banner.size * 0.5
		prompt_banner.visible = true
		prompt_banner.modulate.a = 0.0
		prompt_banner.scale = Vector2(0.75, 0.75)

		var tw := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(prompt_banner, "modulate:a", 1.0, 0.22)
		tw.parallel().tween_property(prompt_banner, "scale", Vector2.ONE, 0.22)
	else:
		var tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tw.tween_property(prompt_banner, "modulate:a", 0.0, 0.16)
		tw.parallel().tween_property(prompt_banner, "scale", Vector2(0.75, 0.75), 0.16)
		tw.tween_callback(func(): prompt_banner.visible = false)

func _process(delta: float) -> void:
	if is_instance_valid(smoke_overlay) and smoke_overlay.alpha > 0.001:
		smoke_overlay.queue_redraw()

	if not is_targeting or is_striking:
		return
	time_passed += delta
	var target_pos := get_global_mouse_position()
	pointer_pos = pointer_pos.lerp(target_pos, delta * 20.0)

	# Gentle floating hover bobbing
	var bob := sin(time_passed * 6.5) * 8.0
	var float_rot := -20.0 + sin(time_passed * 5.0) * 4.0
	hammer_sprite.position = pointer_pos + Vector2(35.0, -55.0 + bob)
	hammer_sprite.rotation_degrees = float_rot

	# Subtle breathing bobbing on prompt banner
	if prompt_banner and prompt_banner.visible:
		var vp_size := get_viewport_rect().size
		var banner_bob := sin(time_passed * 4.2) * 3.5
		prompt_banner.position.y = 136.0 + banner_bob
		prompt_banner.position.x = (vp_size.x - prompt_banner.size.x) * 0.5

	# Check hover over piece
	_update_hover(target_pos)

func _update_hover(pos: Vector2) -> void:
	if puzzle_controller == null or puzzle_controller.active_pieces.is_empty():
		_clear_hover()
		return
	var hit = _find_hit_piece(pos)
	if hit != hover_target:
		_clear_hover()
		hover_target = hit
		if is_instance_valid(hover_target) and hover_target.has_method("set_hold_rim"):
			hover_target.set_hold_rim(true)

func _clear_hover() -> void:
	if is_instance_valid(hover_target) and hover_target.has_method("set_hold_rim"):
		hover_target.set_hold_rim(false)
	hover_target = null

func _input(event: InputEvent) -> void:
	if not is_targeting or is_striking:
		return

	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) or \
	   (event is InputEventScreenTouch and event.pressed):
		var click_pos: Vector2 = event.position if event is InputEventScreenTouch else event.global_position
		
		# Let taps on top HUD corner buttons or bottom HUD cards pass through to UI buttons
		var vp_rect := get_viewport_rect()
		if click_pos.y > vp_rect.size.y - 130.0:
			return
		if click_pos.y < 110.0 and (click_pos.x > vp_rect.size.x - 110.0 or click_pos.x < 110.0):
			return

		var hit = _find_hit_piece(click_pos)
		if hit != null:
			get_viewport().set_input_as_handled()
			execute_smash(hit)
		else:
			# Absorb tap to prevent ring dragging, keep hammer targeting active
			get_viewport().set_input_as_handled()

func handle_input(event: InputEvent) -> bool:
	if not is_targeting or is_striking:
		return false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit = _find_hit_piece(event.global_position)
		if hit != null:
			execute_smash(hit)
			return true
		else:
			return true
	elif event is InputEventScreenTouch and event.pressed:
		var hit = _find_hit_piece(event.position)
		if hit != null:
			execute_smash(hit)
			return true
		else:
			return true
	return false

func _find_hit_piece(global_pt: Vector2) -> Node2D:
	if puzzle_controller == null or puzzle_controller.active_pieces.is_empty():
		return null

	if puzzle_controller.drag_controller and puzzle_controller.drag_controller.has_method("resolve_hit"):
		var hit = puzzle_controller.drag_controller.resolve_hit(global_pt, puzzle_controller.active_pieces)
		if hit != null and is_instance_valid(hit):
			return hit

	var best_p: Node2D = null
	var min_dist: float = INF
	for p in puzzle_controller.active_pieces:
		if not is_instance_valid(p): continue
		if p.state == RingPiece2DScript.State.RELEASED or p.state == RingPiece2DScript.State.RELEASING: continue
		var p_scale: float = p.global_scale.x if "global_scale" in p else 1.0
		var r: float = float(p.radius) if "radius" in p else 64.0
		var d: float = (global_pt - p.global_position).length()
		var reach: float = r * p_scale + 54.0
		if d <= reach and d < min_dist:
			min_dist = d
			best_p = p
	return best_p

func execute_smash(target_piece: Node2D) -> void:
	is_striking = true
	is_targeting = false
	_clear_hover()

	# Dismiss prompt banner immediately upon tap
	_show_prompt_banner(false)

	# Random breakage logic:
	# 45% chance: Single ring (only target_piece)
	# 35% chance: 2 rings (target_piece + 1 closest/connected)
	# 20% chance: 3 rings (target_piece + 2 closest/connected)
	var roll := randf()
	var extra_victims_count: int = 0
	if roll < 0.45:
		extra_victims_count = 0
	elif roll < 0.80:
		extra_victims_count = 1
	else:
		extra_victims_count = 2

	var victims: Array[Node2D] = [target_piece]
	var victim_candidates: Array[Node2D] = []

	# Check connected pieces first
	for link in puzzle_controller.active_links:
		if link.state == ConnectorRuntimeScript.State.ENGAGED:
			var p_from = PuzzleRulesScript.get_piece_by_id(link.def.from_piece_id, puzzle_controller.active_pieces)
			var p_to = PuzzleRulesScript.get_piece_by_id(link.def.to_piece_id, puzzle_controller.active_pieces)
			if p_from == target_piece and p_to and not (p_to in victims) and not (p_to in victim_candidates):
				victim_candidates.append(p_to)
			elif p_to == target_piece and p_from and not (p_from in victims) and not (p_from in victim_candidates):
				victim_candidates.append(p_from)

	# Add nearby pieces by distance
	for p in puzzle_controller.active_pieces:
		if not is_instance_valid(p) or p in victims or p in victim_candidates:
			continue
		if p.state == RingPiece2DScript.State.RELEASED or p.state == RingPiece2DScript.State.RELEASING:
			continue
		var dist: float = (p.global_position - target_piece.global_position).length()
		if dist <= 240.0:
			victim_candidates.append(p)

	# Sort candidates by distance from target
	victim_candidates.sort_custom(func(a, b):
		return (a.global_position - target_piece.global_position).length() < (b.global_position - target_piece.global_position).length()
	)

	var to_add := mini(extra_victims_count, victim_candidates.size())
	for i in range(to_add):
		victims.append(victim_candidates[i])

	var hit_center: Vector2 = target_piece.global_position
	var base_scale := Vector2(96.0 / 256.0, 96.0 / 256.0)

	if audio_service and audio_service.has_method("play_hammer_swing"):
		audio_service.play_hammer_swing()

	# Unity-Level Animation Sequence
	var tw := create_tween()

	# Phase 1: Windup & Pullback (0.16s)
	var windup_pos := hit_center + Vector2(30.0, -95.0)
	tw.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "position", windup_pos, 0.16)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", -65.0, 0.16)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 1.35, 0.16)

	# Phase 2: Power Slam (0.10s)
	tw.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(hammer_sprite, "position", hit_center + Vector2(8.0, -18.0), 0.10)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", 24.0, 0.10)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 1.18, 0.10)

	# Phase 3: Impact Blast, Shockwave & Shatter Callback
	tw.tween_callback(func():
		_trigger_impact_fx(hit_center, victims)
		_set_puzzle_popout(false)
		if is_instance_valid(smoke_overlay):
			var sm_tw := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			sm_tw.tween_property(smoke_overlay, "alpha", 0.0, 0.28)
			var sm_ticker := create_tween().set_loops(14)
			sm_ticker.tween_callback(smoke_overlay.queue_redraw).set_delay(0.02)
	)

	# Phase 4: Rebound & Fade (0.24s)
	tw.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(hammer_sprite, "position", hit_center + Vector2(16.0, -42.0), 0.14)
	tw.parallel().tween_property(hammer_sprite, "rotation_degrees", -12.0, 0.14)
	tw.parallel().tween_property(hammer_sprite, "scale", base_scale * 0.95, 0.14)
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(hammer_sprite, "modulate:a", 0.0, 0.14)
	tw.tween_callback(func():
		hammer_sprite.visible = false
		is_striking = false
		smash_completed.emit()
	)

func _trigger_impact_fx(hit_center: Vector2, victims: Array[Node2D]) -> void:
	if audio_service and audio_service.has_method("play_hammer_impact"):
		audio_service.play_hammer_impact()

	# 1. Screen Shake
	if gameplay_screen and gameplay_screen.has_method("shake_screen"):
		gameplay_screen.shake_screen(9.0, 0.24)
	elif puzzle_controller:
		var orig_pos = puzzle_controller.position
		var stw := create_tween()
		for i in 6:
			var off := Vector2(randf_range(-7.0, 7.0), randf_range(-7.0, 7.0))
			stw.tween_property(puzzle_controller, "position", orig_pos + off, 0.03)
		stw.tween_property(puzzle_controller, "position", orig_pos, 0.04)

	# 2. Shockwave Expansion
	if is_instance_valid(shockwave_drawer):
		var sw = shockwave_drawer as ShockwaveNode
		sw.center = to_local(hit_center)
		sw.radius = 10.0
		sw.alpha = 1.0
		var sw_tw := create_tween()
		sw_tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		sw_tw.tween_property(sw, "radius", 230.0, 0.32)
		sw_tw.parallel().tween_property(sw, "alpha", 0.0, 0.32)
		sw_tw.tween_callback(func():
			sw.radius = 0.0
			sw.queue_redraw()
		)
		var ticker := create_tween().set_loops(16)
		ticker.tween_callback(sw.queue_redraw).set_delay(0.02)

	# 3. Particle Star Burst
	_spawn_spark_burst(hit_center)

	# 4. Shatter victims into Small Colored Rocks
	_shatter_and_drop_rings(victims, hit_center)

func _spawn_spark_burst(pos: Vector2) -> void:
	var burst := CPUParticles2D.new()
	burst.one_shot = true
	burst.explosiveness = 0.95
	burst.lifetime = 0.65
	burst.amount = 24
	burst.spread = 180.0
	burst.gravity = Vector2(0, 520.0)
	burst.initial_velocity_min = 180.0
	burst.initial_velocity_max = 420.0
	burst.angular_velocity_min = -360.0
	burst.angular_velocity_max = 360.0
	burst.scale_amount_min = 4.0
	burst.scale_amount_max = 8.5
	burst.color = Color(1.0, 0.88, 0.28)
	burst.z_index = 160
	add_child(burst)
	burst.global_position = pos
	burst.emitting = true
	get_tree().create_timer(0.9).timeout.connect(burst.queue_free)

func _shatter_and_drop_rings(victims: Array[Node2D], hit_center: Vector2) -> void:
	# 1. Immediately break links connected to all victim pieces
	for link in puzzle_controller.active_links:
		for v in victims:
			if link.def.from_piece_id == v.piece_id or link.def.to_piece_id == v.piece_id:
				link.state = ConnectorRuntimeScript.State.DETACHED
				link.current_stem_dist = 0.0

	puzzle_controller._connectors_dirty = true
	if is_instance_valid(puzzle_controller.stems_layer): puzzle_controller.stems_layer.queue_redraw()
	if is_instance_valid(puzzle_controller.cuffs_layer): puzzle_controller.cuffs_layer.queue_redraw()

	# 2. Shatter each victim ring into Small Colored Rocks matching its color!
	for v in victims:
		if not is_instance_valid(v): continue
		v.state = RingPiece2DScript.State.RELEASING

		# Kill any in-flight state tweens
		if v.get("_state_tween") != null and is_instance_valid(v._state_tween):
			v._state_tween.kill()

		var ring_col: Color = v.ring_color if "ring_color" in v else Color("#EA7829")
		var ring_r: float = float(v.radius) if "radius" in v else 64.0
		var ring_pos: Vector2 = v.global_position

		# Instantly hide the intact ring: replaced by shattering colored rocks!
		v.visible = false

		# Spawn 16-18 Physical Colored Rock Chunks
		var rock_count := randi_range(16, 20)
		for i in range(rock_count):
			var ang := (float(i) / float(rock_count)) * TAU + randf_range(-0.25, 0.25)
			var r_dist := ring_r * randf_range(0.75, 1.25)
			var spawn_pos := ring_pos + Vector2(cos(ang), sin(ang)) * r_dist

			var blast_dir := (spawn_pos - hit_center).normalized()
			if (spawn_pos - hit_center).length() < 4.0:
				blast_dir = Vector2(cos(ang), sin(ang))

			var rock := ColoredRockChunk.new()
			rock.setup(ring_col, randf_range(10.0, 16.0))
			rock.velocity = blast_dir * randf_range(200.0, 460.0) + Vector2(randf_range(-60.0, 60.0), randf_range(-240.0, -90.0))
			rock.angular_velocity = randf_range(-14.0, 14.0)
			rock.z_index = 155
			add_child(rock)
			rock.global_position = spawn_pos

		# Spawn 8-10 Micro-Gravel Pebbles for extra physical crunch
		for j in range(8):
			var g_ang := randf() * TAU
			var g_dist := ring_r * randf_range(0.65, 1.35)
			var g_spawn := ring_pos + Vector2(cos(g_ang), sin(g_ang)) * g_dist
			var g_blast := (g_spawn - hit_center).normalized()
			if (g_spawn - hit_center).length() < 4.0:
				g_blast = Vector2(cos(g_ang), sin(g_ang))

			var pebble := ColoredRockChunk.new()
			pebble.setup(ring_col.lightened(0.12), randf_range(4.5, 7.5))
			pebble.velocity = g_blast * randf_range(240.0, 520.0) + Vector2(randf_range(-70.0, 70.0), randf_range(-280.0, -110.0))
			pebble.angular_velocity = randf_range(-18.0, 18.0)
			pebble.z_index = 156
			add_child(pebble)
			pebble.global_position = g_spawn

		# Spawn colored ceramic shard particles for fine dust
		_spawn_ring_shards(ring_pos, ring_col)

		# Safely clean up piece from puzzle state at 0.35s delay while rocks are flying
		get_tree().create_timer(0.35).timeout.connect(func(dead_p = v):
			if is_instance_valid(dead_p):
				dead_p.state = RingPiece2DScript.State.RELEASED
				PuzzleRulesScript.on_piece_released(dead_p, puzzle_controller.active_links)
				puzzle_controller.active_pieces.erase(dead_p)
				dead_p.queue_free()
				_check_after_smash()
		)

func _spawn_ring_shards(pos: Vector2, ring_col: Color) -> void:
	var shards := CPUParticles2D.new()
	shards.one_shot = true
	shards.explosiveness = 0.92
	shards.lifetime = 0.55
	shards.amount = 18
	shards.spread = 180.0
	shards.gravity = Vector2(0, 680.0)
	shards.initial_velocity_min = 140.0
	shards.initial_velocity_max = 360.0
	shards.angular_velocity_min = -500.0
	shards.angular_velocity_max = 500.0
	shards.scale_amount_min = 5.0
	shards.scale_amount_max = 12.0
	shards.color = ring_col.lightened(0.15)
	shards.z_index = 145
	add_child(shards)
	shards.global_position = pos
	shards.emitting = true
	get_tree().create_timer(0.8).timeout.connect(shards.queue_free)

func _check_after_smash() -> void:
	if puzzle_controller == null: return
	puzzle_controller._connectors_dirty = true
	if is_instance_valid(puzzle_controller.stems_layer): puzzle_controller.stems_layer.queue_redraw()
	if is_instance_valid(puzzle_controller.cuffs_layer): puzzle_controller.cuffs_layer.queue_redraw()

	# Resolve any subsequent cascading releases
	var cascaded = PuzzleRulesScript.resolve_releases(puzzle_controller.active_pieces, puzzle_controller.active_links)
	if not cascaded.is_empty():
		for p in cascaded:
			if is_instance_valid(p):
				p.state = RingPiece2DScript.State.RELEASING
				var tw := create_tween()
				tw.tween_property(p, "position:y", p.position.y + 600.0, 0.45)
				tw.parallel().tween_property(p, "modulate:a", 0.0, 0.40)
				tw.tween_callback(func(dead_p = p):
					if is_instance_valid(dead_p):
						dead_p.state = RingPiece2DScript.State.RELEASED
						PuzzleRulesScript.on_piece_released(dead_p, puzzle_controller.active_links)
						puzzle_controller.active_pieces.erase(dead_p)
						dead_p.queue_free()
				)

	puzzle_controller.piece_count_updated.emit(puzzle_controller.active_pieces.size())

	# Check win condition
	if PuzzleRulesScript.is_puzzle_won(puzzle_controller.active_pieces, puzzle_controller.active_links):
		puzzle_controller._on_all_pieces_released()

