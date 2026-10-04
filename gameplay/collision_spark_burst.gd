extends Node2D
class_name CollisionSparkBurst

# Exact match of the original mobile game's golden star sparkle on connector touch
var elapsed: float = 0.0
var total_lifetime: float = 0.38

# Sparkle geometry
var star_ray_length: float = 26.0
var star_ray_thickness: float = 4.0
var diagonal_ray_length: float = 14.0
var aura_radius: float = 22.0

# 3-4 small glitter specks
var glitters: Array = []

func setup(contact_pos: Vector2, _impact_color: Color = Color.WHITE, _impact_dir: Vector2 = Vector2.ZERO) -> void:
	position = contact_pos
	z_index = 25 # Always above rings (z=2) and cuffs (z=4) in puzzle space

	# Generate 4 small glitter specks around the star center
	for i in 4:
		var ang := randf_range(0, TAU)
		var dist := randf_range(8.0, 18.0)
		glitters.append({
			"offset": Vector2.from_angle(ang) * dist,
			"size": randf_range(2.0, 3.2),
			"alpha": randf_range(0.75, 1.0)
		})
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += minf(delta, 0.033)
	if elapsed >= total_lifetime:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var t := clampf(elapsed / total_lifetime, 0.0, 1.0)
	
	# Scale animation: snappy pop from 0.6 to 1.25, then gentle twinkle and fade
	var scale_anim := 1.0
	if t < 0.15:
		scale_anim = lerpf(0.65, 1.25, t / 0.15)
	else:
		scale_anim = lerpf(1.25, 0.70, (t - 0.15) / 0.85)

	var alpha := 1.0 - ease(t, 2.0)

	# 1. Warm amber glow aura
	var aura_col := Color(1.0, 0.65, 0.08, alpha * 0.40)
	draw_circle(Vector2.ZERO, aura_radius * scale_anim, aura_col)
	var inner_aura := Color(1.0, 0.88, 0.25, alpha * 0.55)
	draw_circle(Vector2.ZERO, (aura_radius * 0.55) * scale_anim, inner_aura)

	# 2. Main 4-point golden star (Horizontal & Vertical rays)
	var ray_l := star_ray_length * scale_anim
	var ray_w := star_ray_thickness * scale_anim

	# Draw 4-point star polygon: Horizontal + Vertical
	var gold_outer := Color(1.0, 0.82, 0.08, alpha)
	var white_core := Color(1.0, 1.0, 1.0, alpha)

	# Star polygon: (N, E, S, W) with pinched center
	var star_pts := PackedVector2Array([
		Vector2(0, -ray_l),
		Vector2(ray_w * 0.4, -ray_w * 0.4),
		Vector2(ray_l, 0),
		Vector2(ray_w * 0.4, ray_w * 0.4),
		Vector2(0, ray_l),
		Vector2(-ray_w * 0.4, ray_w * 0.4),
		Vector2(-ray_l, 0),
		Vector2(-ray_w * 0.4, -ray_w * 0.4)
	])
	draw_colored_polygon(star_pts, gold_outer)

	# 3. Secondary 4-point diagonal diamond rays
	var diag_l := diagonal_ray_length * scale_anim
	var diag_w := ray_w * 0.3
	var diag_pts := PackedVector2Array([
		Vector2(0, -diag_w),
		Vector2(diag_l * 0.707, -diag_l * 0.707),
		Vector2(diag_w, 0),
		Vector2(diag_l * 0.707, diag_l * 0.707),
		Vector2(0, diag_w),
		Vector2(-diag_l * 0.707, diag_l * 0.707),
		Vector2(-diag_w, 0),
		Vector2(-diag_l * 0.707, -diag_l * 0.707)
	])
	draw_colored_polygon(diag_pts, Color(1.0, 0.90, 0.35, alpha * 0.85))

	# 4. Brilliant pure white hot star core
	var core_l := ray_l * 0.42
	var core_w := ray_w * 0.30
	var core_pts := PackedVector2Array([
		Vector2(0, -core_l),
		Vector2(core_w * 0.3, -core_w * 0.3),
		Vector2(core_l, 0),
		Vector2(core_w * 0.3, core_w * 0.3),
		Vector2(0, core_l),
		Vector2(-core_w * 0.3, core_w * 0.3),
		Vector2(-core_l, 0),
		Vector2(-core_w * 0.3, -core_w * 0.3)
	])
	draw_colored_polygon(core_pts, white_core)
	draw_circle(Vector2.ZERO, 2.5 * scale_anim, white_core)

	# 5. Little glitter specks
	for g in glitters:
		var g_col := Color(1.0, 0.96, 0.60, alpha * g["alpha"])
		draw_circle(g["offset"] * scale_anim, g["size"] * scale_anim, g_col)
