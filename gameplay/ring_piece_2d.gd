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

# --- PERFORMANCE: precomputed colors (avoids Color math every draw call) ---
var _c_shadow := Color(0.20, 0.14, 0.10, 0.12)
var _c_dark := Color.WHITE
var _c_main := Color.WHITE
var _c_light := Color.WHITE
var _c_inner_dark := Color.WHITE

func _precompute_colors() -> void:
	_c_shadow = Color(0.42, 0.26, 0.16, 0.2)
	_c_dark = ring_color.darkened(0.28)
	_c_main = ring_color.lightened(0.04)
	_c_light = ring_color.lightened(0.34)
	_c_light.a = 0.75
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
	gaps = p_def.gaps.duplicate()
	role = 1 if gaps.is_empty() else 0
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
	# PERFORMANCE: fixed 72 segs for shapes
	segs = 72

	# For a CLOSED piece (no gap) we fill the full contour with a soft drop shadow
	# and the main color, so things like the central cuff render as solid rounded
	# squares / circles — matching the Game Rush reference's chunky cuff.
	if is_closed:
		# Drop shadow as a slightly larger filled shape, offset down
		var shadow_pts := PackedVector2Array()
		for i in range(segs + 1):
			var theta: float = TAU * float(i) / float(segs)
			shadow_pts.append(center + Vector2(0, 3.0) + Vector2(cos(theta), sin(theta)) * _b(theta))
		draw_colored_polygon(shadow_pts, Color(0.16, 0.13, 0.11, 0.20))
		# Filled body
		var body_pts := PackedVector2Array()
		for i in range(segs + 1):
			var theta: float = TAU * float(i) / float(segs)
			body_pts.append(center + Vector2(cos(theta), sin(theta)) * _b(theta))
		draw_colored_polygon(body_pts, _c_main)
		# Top highlight: offset slightly up + lighter color
		var hl_pts := PackedVector2Array()
		for i in range(segs + 1):
			var theta: float = TAU * float(i) / float(segs)
			hl_pts.append(center + Vector2(0, -1.0) + Vector2(cos(theta), sin(theta)) * _b(theta * 0.85))
		draw_colored_polygon(hl_pts, _c_light)
		return

	var shadow_off1 := Vector2(0, 6.0) * shadow_offset_mult
	var off_dark := Vector2(0, 2.5)

	_draw_poly_arc(center + shadow_off1, r, a_start, a_end, segs, _c_shadow, thickness + 2.0, shape_type)
	if not is_closed:
		var p_start = center + shadow_off1 + Vector2.from_angle(a_start) * _b(a_start)
		var p_end = center + shadow_off1 + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start, cap_r + 1.0, _c_shadow)
		draw_circle(p_end, cap_r + 1.0, _c_shadow)

	_draw_poly_arc(center + off_dark, r, a_start, a_end, segs, _c_dark, thickness, shape_type)
	if not is_closed:
		var p_start = center + off_dark + Vector2.from_angle(a_start) * _b(a_start)
		var p_end = center + off_dark + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start, cap_r, _c_dark)
		draw_circle(p_end, cap_r, _c_dark)

	_draw_poly_arc(center, r, a_start, a_end, segs, _c_main, thickness, shape_type)
	if not is_closed:
		var p_start = center + Vector2.from_angle(a_start) * _b(a_start)
		var p_end = center + Vector2.from_angle(a_end) * _b(a_end)
		draw_circle(p_start, cap_r, _c_main)
		draw_circle(p_end, cap_r, _c_main)

	var off_hl := Vector2(-1.5, -2.5)
	var hl_w = thickness * 0.4
	_draw_poly_arc(center + off_hl, r, a_start, a_end, segs, _c_light, hl_w, shape_type)
	var hole_edge := ring_color.darkened(0.35)
	hole_edge.a = 0.55
	_draw_poly_arc(center, r - thickness * 0.28, a_start, a_end, segs, hole_edge, 3.0, shape_type)

func _draw_poly_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, color: Color, line_width: float, shape_type: int) -> void:
	# Build a closed filled band: outer edge (r + half_t) and inner edge (r - half_t)
	# as a single polygon. This gives the tube a 3D filled look, not a hollow stroke.
	var half_t: float = line_width * 0.5
	var pts = PackedVector2Array()
	var step: float = (a_end - a_start) / float(segs)
	# Outer edge from a_start to a_end
	for i in range(segs + 1):
		var theta: float = a_start + step * i
		var dist: float = _b(theta) + half_t
		pts.append(center + Vector2(cos(theta), sin(theta)) * dist)
	# Inner edge from a_end to a_start (reverse)
	for i in range(segs, -1, -1):
		var theta2: float = a_start + step * i
		var dist2: float = maxf(0.0, _b(theta2) - half_t)
		pts.append(center + Vector2(cos(theta2), sin(theta2)) * dist2)
	if pts.size() >= 3:
		draw_colored_polygon(pts, color)

func get_distance_to_ring(global_pt: Vector2) -> float:
	var local_pos := to_local(global_pt)
	var dist := local_pos.length()
	return absf(dist - radius)

func contains_point(global_pt: Vector2) -> bool:
	var local_pos := to_local(global_pt)
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
