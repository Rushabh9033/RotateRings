extends Node2D
class_name RingPiece2D
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")

const GapDefinitionScript = preload("res://data/gap_definition.gd")

enum State {
	IDLE,
	SELECTED,
	ROTATING,
	NEAR_VALID,
	RELEASABLE,
	RELEASING,
	RELEASED,
	LOCKED
}

signal rotation_changed(piece: Node2D, angle_deg: float)
signal drag_ended(piece: Node2D)
signal release_completed(piece: Node2D)

@export var piece_id: StringName = &"ring_0"
@export var radius: float = 80.0
@export var thickness: float = 26.0
var shape_type: int = 0
@export var ring_color: Color = Color("#29B6F6")
@export var current_angle_deg: float = 90.0
@export var target_exit_angle_deg: float = 0.0

var gaps: Array = []
var def = null
var role: int = 0
var attached_collars: Array = []
var state: State = State.IDLE:
	set(value):
		if state != value:
			var old_state = state
			state = value
			_on_state_changed(old_state, value)
var is_interactive: bool = true
var show_hold_rim: bool = false

# For 3D animation
var shadow_offset_mult: float = 1.0

# Active state-change tween (killed before reassignment to avoid overlapping tweens).
var _state_tween: Tween = null
# Original z_index from def — restored on IDLE so author-set layering survives state cycles.
var _default_z_index: int = 0

var _c_shadow_soft := Color(0.12, 0.08, 0.06, 0.08)
var _c_shadow_mid := Color(0.12, 0.08, 0.06, 0.16)
var _c_dark := Color.WHITE
var _c_main := Color.WHITE
var _c_light := Color.WHITE
var _c_specular := Color(1.0, 1.0, 1.0, 0.38)
var _c_inner_dark := Color.WHITE

func _precompute_colors() -> void:
	_c_shadow_soft = Color(0.12, 0.08, 0.06, 0.08)
	_c_shadow_mid = Color(0.12, 0.08, 0.06, 0.16)
	_c_dark = ring_color.darkened(0.28)
	_c_main = ring_color.lightened(0.02)
	_c_light = ring_color.lightened(0.36)
	_c_light.a = 0.65
	_c_specular = Color(1.0, 1.0, 1.0, 0.38)
	_c_inner_dark = ring_color.darkened(0.22)
	_c_inner_dark.a = 0.7

func _on_state_changed(old: State, new: State) -> void:
	# Cancel any in-flight state tween so rapid state cycles don't stack.
	if is_instance_valid(_state_tween):
		_state_tween.kill()
	_state_tween = null

	# Brief squash on release entry — recovers the visual lift-down before queue_free.
	if new == State.RELEASING:
		_state_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_state_tween.tween_property(self, "scale", Vector2(0.85, 0.85), 0.16)
		_state_tween.parallel().tween_property(self, "shadow_offset_mult", 0.5, 0.16)
		_state_tween.tween_property(self, "modulate:a", 0.0, 0.32)
		queue_redraw()
		return

	if new == State.RELEASED:
		# Handed out is terminal — keep _draw early-return behavior.
		queue_redraw()
		return

	_state_tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

	if new == State.SELECTED or new == State.ROTATING:
		# Lift up
		_state_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18)
		_state_tween.parallel().tween_property(self, "shadow_offset_mult", 2.0, 0.18)
		z_index = 10
	elif new == State.IDLE or new == State.NEAR_VALID or new == State.RELEASABLE:
		# Drop down — restore the author-set z_index, not 0.
		_state_tween.tween_property(self, "scale", Vector2.ONE, 0.25)
		_state_tween.parallel().tween_property(self, "shadow_offset_mult", 1.0, 0.25)
		z_index = _default_z_index

	# Quick magnetic snap effect when approaching valid — simplified for performance
	if new == State.NEAR_VALID and old == State.ROTATING:
		var snap_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		snap_tween.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08)
		snap_tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18)

	queue_redraw()

func _ready() -> void:
	rotation_degrees = current_angle_deg
	queue_redraw()

func _process(_delta: float) -> void:
	# PERFORMANCE: only redraw when shadow is mid-animation.
	# Rotation is a Node2D transform — Godot redraws it automatically.
	# State glow changes call queue_redraw() via _on_state_changed.
	if absf(shadow_offset_mult - 1.0) > 0.001:
		queue_redraw()

func set_hold_rim(enabled: bool) -> void:
	if show_hold_rim == enabled:
		return
	show_hold_rim = enabled
	queue_redraw()

func setup(p_def) -> void:
	def = p_def
	piece_id = p_def.id
	radius = p_def.radius
	thickness = p_def.thickness
	ring_color = p_def.color
	shape_type = int(p_def.shape_type)
	current_angle_deg = p_def.start_angle_deg
	target_exit_angle_deg = p_def.target_exit_angle_deg if p_def.get("target_exit_angle_deg") != null else 0.0
	rotation_degrees = current_angle_deg
	position = p_def.position
	gaps = p_def.gaps.duplicate(true) if (p_def.get("gaps") != null and p_def.gaps is Array) else []
	if p_def.get("role") != null:
		role = int(p_def.role)
	elif shape_type == PieceGeometry.ShapeType.L_SHAPE or (p_def.get("motion_model") != null and int(p_def.motion_model) in [1, 2]):
		role = 0
	else:
		role = 1 if gaps.is_empty() else 0

	# Acorn child sprite
	if p_def != null and "has_acorn" in p_def and bool(p_def.has_acorn):
		var acorn_sp = get_node_or_null("AcornSprite") as Sprite2D
		if acorn_sp == null:
			acorn_sp = Sprite2D.new()
			acorn_sp.name = "AcornSprite"
			var a_tex = load("res://art/acorn.png")
			acorn_sp.texture = a_tex
			# Acorn size ~36x36 px -> scale from 128x128 texture
			var s_val: float = 36.0 / 128.0
			acorn_sp.scale = Vector2(s_val, s_val)
			acorn_sp.z_index = 10
			add_child(acorn_sp)
	_default_z_index = int(p_def.z_index) if p_def.get("z_index") != null else 0
	z_index = _default_z_index
	_precompute_colors()
	queue_redraw()

func _draw() -> void:
	if state == State.RELEASED:
		return

	var seg_count := 72
	var cap_r: float = thickness * 0.5
	var is_closed: bool = gaps.is_empty() or (gaps.size() == 1 and float(gaps[0].get("width_deg")) <= 0.0)

	var arcs: Array = [ {"start": 0.0, "end": TAU} ] if is_closed else PieceGeometry.get_solid_arcs(gaps)
	var holding := show_hold_rim or state == State.SELECTED or state == State.ROTATING

	if shape_type == PieceGeometry.ShapeType.L_SHAPE:
		_draw_l_shape()
		return

	for arc in arcs:
		var arc_start: float = arc.start
		var arc_end: float = arc.end

		if arc_end < arc_start:
			arc_end += TAU

		if holding:
			_draw_hold_rim(arc_start, arc_end, seg_count, cap_r, is_closed)
		elif state == State.NEAR_VALID:
			_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, shape_type)
		elif state == State.RELEASABLE:
			_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, shape_type)

		_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, is_closed, shape_type)

	if def != null and "blockers" in def and def.blockers is Array and not def.blockers.is_empty():
		_draw_blockers(holding)


func _draw_hold_rim(a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool) -> void:
	var rim := ring_color.lightened(0.38)
	rim.a = 1.0
	_draw_poly_arc(Vector2.ZERO, radius, a_start, a_end, segs, rim, thickness + 14.0, shape_type)
	if is_closed:
		return
	var cap_color := rim
	var p_start := Vector2.from_angle(a_start) * _b(a_start)
	var p_end := Vector2.from_angle(a_end) * _b(a_end)
	draw_circle(p_start, cap_r + 7.0, cap_color)
	draw_circle(p_end, cap_r + 7.0, cap_color)

# Boundary distance at a given local angle, honoring authored shape-specific fields.
func _b(local_angle_rad: float) -> float:
	if def != null:
		return PieceGeometry.get_boundary_distance_for_piece(def, local_angle_rad)
	return PieceGeometry.get_boundary_distance(shape_type, radius, local_angle_rad)

func _draw_ring_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool, shape_type: int) -> void:
	segs = 72

	# 1. Soft smooth drop shadow
	var shadow_mult := shadow_offset_mult
	var shadow_off := Vector2(0, 5.0) * shadow_mult
	_draw_poly_arc(center + shadow_off, r, a_start, a_end, segs, _c_shadow_soft, thickness + 4.0, shape_type)
	if not is_closed:
		var p_start_s := center + shadow_off + Vector2.from_angle(a_start) * _b(a_start)
		var p_end_s := center + shadow_off + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start_s, cap_r + 2.0, _c_shadow_soft)
		draw_circle(p_end_s, cap_r + 2.0, _c_shadow_soft)

	# 2. Main rich vibrant tube
	_draw_poly_arc(center, r, a_start, a_end, segs, _c_main, thickness, shape_type)
	if not is_closed:
		var p_start := center + Vector2.from_angle(a_start) * _b(a_start)
		var p_end := center + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start, cap_r, _c_main)
		draw_circle(p_end, cap_r, _c_main)

	# 3. Soft subtle top light sheen (cylindrical softness, no sharp white specular)
	var off_hl := Vector2(-0.8, -1.2)
	var hl_w := thickness * 0.50
	_draw_poly_arc(center + off_hl, r, a_start, a_end, segs, _c_light, hl_w, shape_type)
	if not is_closed:
		var p_start_hl := center + off_hl * 0.6 + Vector2.from_angle(a_start) * _b(a_start)
		var p_end_hl := center + off_hl * 0.6 + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start_hl, cap_r * 0.55, _c_light)
		draw_circle(p_end_hl, cap_r * 0.55, _c_light)

func _draw_poly_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, color: Color, line_width: float, shape_type: int) -> void:
	# Build a closed filled band: outer edge (r + half_t) and inner edge (r - half_t)
	var half_t: float = line_width * 0.5
	var pts = PackedVector2Array()
	var step: float = (a_end - a_start) / float(segs)
	for i in range(segs + 1):
		var theta: float = a_start + step * i
		var dist: float = _b(theta) + half_t
		pts.append(center + Vector2(cos(theta), sin(theta)) * dist)
	for i in range(segs, -1, -1):
		var theta2: float = a_start + step * i
		var dist2: float = maxf(0.0, _b(theta2) - half_t)
		pts.append(center + Vector2(cos(theta2), sin(theta2)) * dist2)
	if pts.size() >= 3:
		draw_colored_polygon(pts, color)

func _get_l_points() -> PackedVector2Array:
	var pts := PackedVector2Array()
	if def != null and "path_points" in def and def.path_points.size() >= 2:
		for pp in def.path_points:
			if pp is Dictionary:
				pts.append(Vector2(float(pp.get("x", 0.0)), float(pp.get("y", 0.0))))
			elif pp is Vector2:
				pts.append(pp)
		if pts.size() >= 2:
			return pts
		pts.clear()
	pts.append(Vector2(-radius * 0.8, -radius * 0.6))
	pts.append(Vector2(-radius * 0.8, 0.0))
	pts.append(Vector2(radius * 0.8, 0.0))
	return pts

func _smooth_path(pts: PackedVector2Array, corner_r: float) -> PackedVector2Array:
	# Rounds each interior corner with a small arc of interpolated points
	if pts.size() < 3:
		return pts
	var out := PackedVector2Array()
	out.append(pts[0])
	for i in range(1, pts.size() - 1):
		var prev := pts[i - 1]
		var cur := pts[i]
		var nxt := pts[i + 1]
		var d0 := (cur - prev).length()
		var d1 := (nxt - cur).length()
		if d0 < 0.001 or d1 < 0.001:
			out.append(cur)
			continue
		var cr := minf(corner_r, minf(d0 * 0.45, d1 * 0.45))
		var dir_in := (cur - prev).normalized()
		var dir_out := (nxt - cur).normalized()
		var p_start := cur - dir_in * cr
		var p_end := cur + dir_out * cr
		out.append(p_start)
		var steps := 8
		for s in range(1, steps):
			var t := float(s) / float(steps)
			var bz := p_start.lerp(cur, t).lerp(cur.lerp(p_end, t), t)
			out.append(bz)
		out.append(p_end)
	out.append(pts[pts.size() - 1])
	return out

func _draw_l_shape() -> void:
	var pts := _get_l_points()
	var cap_r := thickness * 0.5
	var smooth_r := thickness * 1.2
	var pts_smooth := _smooth_path(pts, smooth_r)
	var holding := show_hold_rim or state == State.SELECTED or state == State.ROTATING

	if holding:
		var rim := ring_color.lightened(0.38)
		rim.a = 1.0
		_draw_polyline_caps(pts_smooth, rim, thickness + 14.0, cap_r + 7.0)
	elif state == State.NEAR_VALID:
		_draw_polyline_caps(pts_smooth, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, cap_r + 4.5)
	elif state == State.RELEASABLE:
		_draw_polyline_caps(pts_smooth, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, cap_r + 4.5)

	# 1. Soft drop shadow
	var shadow_mult := shadow_offset_mult
	var shadow_off := Vector2(0, 5.0) * shadow_mult
	var pts_shadow := _offset_points(pts_smooth, shadow_off)
	_draw_polyline_caps(pts_shadow, _c_shadow_soft, thickness + 4.0, cap_r + 2.0)

	# 2. Main smooth tube body
	_draw_polyline_caps(pts_smooth, _c_main, thickness, cap_r)

	# 3. Soft upper cylindrical light sheen (no harsh specular line)
	var off_hl := Vector2(-0.8, -1.2)
	var pts_hl := _offset_points(pts_smooth, off_hl)
	_draw_polyline_caps(pts_hl, _c_light, thickness * 0.50, cap_r * 0.55)

	# Sleeve is drawn permanently by PuzzleController on board layer


func _draw_blockers(holding: bool) -> void:
	if def == null or not ("blockers" in def) or not (def.blockers is Array):
		return
	var shadow_mult := shadow_offset_mult
	var s_off := Vector2(0, 5.0) * shadow_mult
	for b in def.blockers:
		if not (b is Dictionary): continue
		var ang_deg: float = float(b.get("angle_deg", 0.0))
		var len_px: float = float(b.get("length", 40.0))
		var w: float = float(b.get("width", thickness))
		var has_stopper: bool = bool(b.get("has_stopper", false))
		var stopper_size: float = float(b.get("stopper_size", 24.0))

		var is_inward: bool = bool(b.get("is_inward", false))
		var rad := deg_to_rad(ang_deg)
		var dir := Vector2.from_angle(rad)
		var p_start: Vector2
		var p_end: Vector2
		if is_inward:
			p_start = dir * (radius - thickness * 0.5 + 2.0)
			p_end = dir * (radius - thickness * 0.5 - len_px)
		else:
			p_start = dir * (radius + thickness * 0.5 - 2.0)
			p_end = dir * (radius + thickness * 0.5 + len_px)

		if holding:
			var rim := ring_color.lightened(0.38)
			rim.a = 1.0
			draw_line(p_start, p_end, rim, w + 14.0, true)
			draw_circle(p_end, (w + 14.0) * 0.5, rim)

		# 1. Soft shadow
		draw_line(p_start + s_off, p_end + s_off, _c_shadow_soft, w + 4.0, true)
		# 2. Dark base
		draw_line(p_start + Vector2(0, 2.0), p_end + Vector2(0, 2.0), _c_dark, w, true)
		# 3. Main tube
		draw_line(p_start, p_end, _c_main, w - 0.5, true)
		# 4. Highlight
		draw_line(p_start + Vector2(-1.0, -1.5), p_end + Vector2(-1.0, -1.5), _c_light, w * 0.45, true)

		if has_stopper:
			var tangent := Vector2(-dir.y, dir.x)
			var stop_start := p_end - tangent * (stopper_size * 0.5)
			var stop_end := p_end + tangent * (stopper_size * 0.5)
			draw_line(stop_start + s_off, stop_end + s_off, _c_shadow_soft, w + 4.0, true)
			draw_line(stop_start + Vector2(0, 2.0), stop_end + Vector2(0, 2.0), _c_dark, w, true)
			draw_line(stop_start, stop_end, _c_main, w - 0.5, true)
			draw_line(stop_start + Vector2(-1.0, -1.5), stop_end + Vector2(-1.0, -1.5), _c_light, w * 0.45, true)
		else:
			draw_circle(p_end, (w - 0.5) * 0.5, _c_main)
			draw_circle(p_end + Vector2(-1.0, -1.0), (w * 0.45) * 0.5, _c_light)

func _offset_points(pts: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(p + offset)
	return out

func _draw_polyline_caps(pts: PackedVector2Array, color: Color, width: float, cap_radius: float) -> void:
	if pts.size() < 2: return
	draw_polyline(pts, color, width, true)
	# Only draw round caps on the start and end of the polyline!
	draw_circle(pts[0], cap_radius, color)
	draw_circle(pts[pts.size() - 1], cap_radius, color)

func get_distance_to_ring(global_pt: Vector2) -> float:
	var local_pos := to_local(global_pt)
	if shape_type == PieceGeometry.ShapeType.L_SHAPE:
		var pts := _get_l_points()
		var min_d := INF
		for i in range(pts.size() - 1):
			var seg_d = Geometry2D.get_closest_point_to_segment(local_pos, pts[i], pts[i + 1]).distance_to(local_pos)
			if seg_d < min_d: min_d = seg_d
		return min_d
	var dist := local_pos.length()
	return absf(dist - radius)

func contains_point(global_pt: Vector2) -> bool:
	var local_pos := to_local(global_pt)
	if shape_type == PieceGeometry.ShapeType.L_SHAPE:
		return get_distance_to_ring(global_pt) <= thickness + 36.0
	var dist := local_pos.length()
	var max_outer := radius + thickness * 1.2 + 48.0
	var min_inner := maxf(0.0, radius - thickness * 1.2 - 48.0)
	return dist >= min_inner and dist <= max_outer

func get_gap_world_angle_deg(gap_index: int = 0) -> float:
	if gaps.is_empty(): return 0.0
	var gap = gaps[gap_index] if gap_index < gaps.size() else gaps[0]
	var local_center: float = gap.center_angle_deg
	return fposmod(rotation_degrees + local_center, 360.0)

func is_angle_in_any_gap(target_world_angle_deg: float) -> bool:
	if gaps.is_empty(): return false
	for gap in gaps:
		if gap.width_deg <= 0.0: return false
		var gap_world_center := fposmod(rotation_degrees + gap.center_angle_deg, 360.0)
		var diff := absf(wrapf(gap_world_center - target_world_angle_deg, -180.0, 180.0))
		var effective_half_gap: float = gap.width_deg * 0.5
		if diff <= effective_half_gap:
			return true
	return false

func is_angle_near_gap(target_world_angle_deg: float, near_tolerance_deg: float = 30.0) -> bool:
	if gaps.is_empty(): return false
	for gap in gaps:
		if gap.width_deg <= 0.0: return false
		var gap_world_center := fposmod(rotation_degrees + gap.center_angle_deg, 360.0)
		var diff := absf(wrapf(gap_world_center - target_world_angle_deg, -180.0, 180.0))
		if diff <= near_tolerance_deg:
			return true
	return false
