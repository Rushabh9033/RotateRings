extends Node2D
class_name RingShardBurst

var shards: Array = []
var elapsed: float = 0.0
var total_lifetime: float = 1.15

func setup(center_pos: Vector2, radius: float, _start_angle: float, _end_angle: float, ring_color: Color, thickness: float = 24.0) -> void:
	global_position = center_pos
	z_index = 80
	var count := randi_range(46, 64)
	for i in count:
		var angle := randf() * TAU
		var radial := randf_range(radius * 0.15, radius + thickness * 0.35)
		var spawn := Vector2.from_angle(angle) * radial
		var outward := Vector2.from_angle(angle + randf_range(-0.6, 0.6))
		var speed := randf_range(90.0, 280.0)
		var poly := _unique_chunk(i, thickness)
		var tumble := randf_range(4.0, 14.0) * (1.0 if randf() > 0.5 else -1.0)
		shards.append({
			"pos": spawn,
			"vel": outward * speed + Vector2(randf_range(-80.0, 80.0), randf_range(-220.0, -20.0)),
			"rot": randf() * TAU,
			"rot_speed": randf_range(-11.0, 11.0),
			"poly": poly,
			"depth": randf_range(4.0, 11.0),
			"color_light": ring_color.lightened(randf_range(0.08, 0.32)),
			"color_main": ring_color.lightened(randf_range(-0.08, 0.08)),
			"color_dark": ring_color.darkened(randf_range(0.25, 0.5)),
			"color_side": ring_color.darkened(randf_range(0.4, 0.62)),
			"tumble": tumble,
			"phase": randf() * TAU,
			"life": randf_range(0.72, 1.0),
		})
	queue_redraw()

func _unique_chunk(index: int, thickness: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var kind := (index * 3 + randi() % 4) % 6
	var scale_k := randf_range(0.55, 1.15)
	match kind:
		0:
			var length := thickness * randf_range(0.7, 1.6) * scale_k
			var width := thickness * randf_range(0.18, 0.42)
			pts = PackedVector2Array([
				Vector2(-length, -width * randf_range(0.4, 1.0)),
				Vector2(length * randf_range(0.6, 1.1), -width * 0.35),
				Vector2(length * 0.8, width * randf_range(0.5, 1.2)),
				Vector2(-length * 0.7, width),
			])
		1:
			var s := thickness * randf_range(0.35, 0.8) * scale_k
			pts = PackedVector2Array([
				Vector2(0, -s * randf_range(0.8, 1.4)),
				Vector2(s * randf_range(0.7, 1.3), s * 0.6),
				Vector2(-s * randf_range(0.5, 1.2), s * randf_range(0.4, 1.0)),
			])
		2:
			var n := randi_range(6, 9)
			for j in n:
				var ang := TAU * float(j) / float(n) + randf_range(-0.45, 0.45)
				var rad := thickness * randf_range(0.22, 0.85) * scale_k
				pts.append(Vector2.from_angle(ang) * rad)
		3:
			var a := thickness * randf_range(0.4, 0.9)
			pts = PackedVector2Array([
				Vector2(-a, -a * 0.2),
				Vector2(a * 0.2, -a * randf_range(0.6, 1.1)),
				Vector2(a, a * 0.15),
				Vector2(a * 0.3, a * 0.8),
				Vector2(-a * 0.6, a * 0.4),
			])
		4:
			var w := thickness * randf_range(0.3, 0.7)
			var h := thickness * randf_range(0.5, 1.3)
			pts = PackedVector2Array([
				Vector2(-w, -h * 0.3),
				Vector2(w * 0.4, -h),
				Vector2(w, -h * 0.2),
				Vector2(w * 0.7, h * 0.6),
				Vector2(-w * 0.2, h),
				Vector2(-w, h * 0.1),
			])
		_:
			var bends := randi_range(4, 7)
			for j in bends:
				var ang := TAU * float(j) / float(bends)
				var rad := thickness * (0.25 + absf(sin(ang * 2.0)) * 0.55) * scale_k
				rad *= randf_range(0.75, 1.25)
				pts.append(Vector2.from_angle(ang) * rad)
	return pts

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= total_lifetime:
		queue_free()
		return
	var gravity := Vector2(0, 980.0)
	for s in shards:
		s.vel += gravity * delta
		s.vel.x *= 0.992
		s.pos += s.vel * delta
		s.rot += s.rot_speed * delta
	queue_redraw()

func _draw() -> void:
	for s in shards:
		var life: float = clampf(1.0 - elapsed / (total_lifetime * float(s.life)), 0.0, 1.0)
		if life <= 0.02:
			continue
		var flip := absf(sin(elapsed * float(s.tumble) + float(s.phase)))
		var squash := lerpf(0.35, 1.0, flip)
		draw_set_transform(s.pos, s.rot, Vector2(1.0, squash))
		var depth := float(s.depth) * lerpf(0.4, 1.0, flip)
		var side := PackedVector2Array()
		var top: PackedVector2Array = s.poly
		for p in top:
			side.append(p + Vector2(depth * 0.35, depth))
		var side_color: Color = s.color_side
		side_color.a = life
		draw_colored_polygon(side, side_color)
		var main: Color = s.color_main
		main.a = life
		draw_colored_polygon(top, main)
		var light := PackedVector2Array()
		for p in top:
			light.append(p * 0.55 + Vector2(-1.5, -2.0))
		var light_color: Color = s.color_light
		light_color.a = life * 0.9
		draw_colored_polygon(light, light_color)
		if top.size() > 0:
			var glint: Color = Color(1, 1, 1, 0.75 * life * flip)
			draw_circle(top[0] * 0.25 + Vector2(-1, -2), 1.6 + flip, glint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
