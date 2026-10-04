extends Node2D
class_name RingShardBurst

# 3D clay pebble shatter shards matching the reference game
var shards: Array = []
var elapsed: float = 0.0
var total_lifetime: float = 0.95

func setup(center_pos: Vector2, radius: float, start_angle: float, end_angle: float, ring_color: Color) -> void:
	global_position = center_pos
	z_index = 80
	var count := 75
	var angle_span := end_angle - start_angle
	if angle_span <= 0: angle_span += TAU

	for i in count:
		var frac := float(i) / float(count)
		var angle := start_angle + frac * angle_span
		# Spawn on the ring arc with slight radial jitter
		var spawn_offset := Vector2.from_angle(angle) * (radius + randf_range(-4.0, 4.0))
		var outward_dir := Vector2.from_angle(angle + randf_range(-0.35, 0.35))
		var speed := randf_range(110.0, 240.0)

		# Clay rock/pebble 3D chunk
		var sz := randf_range(16.0, 26.0)
		var c_light := ring_color.lightened(randf_range(0.12, 0.25))
		var c_main := ring_color.lightened(randf_range(-0.02, 0.10))
		var c_dark := ring_color.darkened(randf_range(0.20, 0.35))
		
		# Generate an irregular polygonal pebble shape
		var pts = PackedVector2Array()
		var p_count = randi_range(5, 7)
		for j in p_count:
			var ang = (j / float(p_count)) * TAU + randf_range(-0.25, 0.25)
			var rad_dist = sz * randf_range(0.38, 0.65)
			pts.append(Vector2.from_angle(ang) * rad_dist)

		var shard = {
			"pos": spawn_offset,
			"vel": outward_dir * speed + Vector2(randf_range(-40.0, 40.0), randf_range(-120.0, 30.0)),
			"rot": randf_range(0, TAU),
			"rot_speed": randf_range(-6.0, 6.0),
			"poly": pts,
			"color_light": c_light,
			"color_main": c_main,
			"color_dark": c_dark,
			"scale": 1.0
		}
		shards.append(shard)
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= total_lifetime:
		queue_free()
		return

	# Stronger gravity for realistic heavy falling chunks
	var gravity := Vector2(0, 1100.0)

	for s in shards:
		s.vel += gravity * delta
		# Air resistance
		s.vel.x *= 0.99
		s.vel.y *= 0.995
		s.pos += s.vel * delta
		s.rot += s.rot_speed * delta

	queue_redraw()

func _draw() -> void:
	for s in shards:
		if s.scale <= 0.02: continue
		draw_set_transform(s.pos, s.rot, Vector2.ONE * s.scale)

		var base_poly = s.poly
		
		# Offset polygon down for drop shadow
		var shadow_poly = PackedVector2Array()
		for p in base_poly: shadow_poly.append(p + Vector2(0, 4.0))
		draw_colored_polygon(shadow_poly, Color(0.2, 0.14, 0.08, 0.22 * s.scale))

		# Offset polygon down slightly for dark 3D base
		var dark_poly = PackedVector2Array()
		for p in base_poly: dark_poly.append(p + Vector2(0, 2.5))
		draw_colored_polygon(dark_poly, s.color_dark)

		# Main polygonal body
		draw_colored_polygon(base_poly, s.color_main)

		# Top highlight facet (scaled down and shifted up)
		var light_poly = PackedVector2Array()
		for p in base_poly: light_poly.append((p * 0.6) + Vector2(0, -1.0))
		draw_colored_polygon(light_poly, s.color_light)

		# Specular glint (even smaller)
		var glint_poly = PackedVector2Array()
		for p in base_poly: glint_poly.append((p * 0.25) + Vector2(1.5, -1.5))
		draw_colored_polygon(glint_poly, Color(1, 1, 1, 0.65 * s.scale))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
