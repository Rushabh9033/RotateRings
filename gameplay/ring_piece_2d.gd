extends Node2D
class_name RingPiece2D

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
@export var ring_color: Color = Color("#29B6F6")
@export var current_angle_deg: float = 90.0
@export var target_exit_angle_deg: float = 0.0

var gaps: Array = []
var attached_collars: Array = []
var state: State = State.IDLE:
	set(value):
		if state != value:
			var old_state = state
			state = value
			_on_state_changed(old_state, value)
var is_interactive: bool = true

# For 3D animation
var shadow_offset_mult: float = 1.0

# --- PERFORMANCE: precomputed colors (avoids Color math every draw call) ---
var _c_shadow := Color(0.20, 0.14, 0.10, 0.12)
var _c_dark := Color.WHITE
var _c_main := Color.WHITE
var _c_light := Color.WHITE
var _c_inner_dark := Color.WHITE

func _precompute_colors() -> void:
	_c_shadow = Color(0.20, 0.14, 0.10, 0.12)
	_c_dark = ring_color.darkened(0.22)
	_c_main = ring_color.lightened(0.02)
	_c_light = ring_color.lightened(0.25)
	_c_light.a = 0.85
	_c_inner_dark = ring_color.darkened(0.1)
	_c_inner_dark.a = 0.5

func _on_state_changed(old: State, new: State) -> void:
	if new == State.RELEASED: return

	var tween = create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)

	if new == State.SELECTED or new == State.ROTATING:
		# Lift up
		tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.18)
		tween.parallel().tween_property(self, "shadow_offset_mult", 2.0, 0.18)
		z_index = 10
	elif new == State.IDLE or new == State.NEAR_VALID or new == State.RELEASABLE:
		# Drop down
		tween.tween_property(self, "scale", Vector2.ONE, 0.25)
		tween.parallel().tween_property(self, "shadow_offset_mult", 1.0, 0.25)
		z_index = 0

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

func setup(def) -> void:
	piece_id = def.id
	radius = def.radius
	thickness = def.thickness
	ring_color = def.color
	current_angle_deg = def.start_angle_deg
	target_exit_angle_deg = def.target_exit_angle_deg if def.get("target_exit_angle_deg") != null else 0.0
	rotation_degrees = current_angle_deg
	gaps = def.gaps.duplicate()
	_precompute_colors()
	queue_redraw()

func _draw() -> void:
	if state == State.RELEASED:
		return

	var seg_count := 72
	var cap_r: float = thickness * 0.5
	var is_closed: bool = gaps.is_empty() or (gaps.size() == 1 and float(gaps[0].get("width_deg")) <= 0.0)

	if is_closed:
		_draw_ring_arc(Vector2.ZERO, radius, 0.0, TAU, seg_count, cap_r, is_closed, def.shape_type)
		return

	var arcs: Array = RingGeometry.get_solid_arcs(gaps)

	for arc in arcs:
		var arc_start: float = arc.start
		var arc_end: float = arc.end
		
		# Ensure arc_end is greater than arc_start for Godot's draw_arc
		if arc_end < arc_start:
			arc_end += TAU

		# State-based outer glow
		if state == State.SELECTED or state == State.ROTATING:
			var glow_c := Color(ring_color.r, ring_color.g, ring_color.b, 0.30)
			_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, glow_c, thickness + 12.0, def.shape_type)
		elif state == State.NEAR_VALID:
			_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, def.shape_type)
		elif state == State.RELEASABLE:
			_draw_poly_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, def.shape_type)

		_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, false, def.shape_type)


func _draw_ring_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool, shape_type: int) -> void:
	# PERFORMANCE: fixed 72 segs for shapes
	segs = 72
	
	var shadow_off1 := Vector2(0, 6.0) * shadow_offset_mult
	var off_dark := Vector2(0, 2.5)
	
	_draw_poly_arc(center + shadow_off1, r, a_start, a_end, segs, _c_shadow, thickness + 2.0, shape_type)
	if not is_closed:
		var p_start = center + shadow_off1 + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + shadow_off1 + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r + 1.0, _c_shadow)
		draw_circle(p_end, cap_r + 1.0, _c_shadow)
		
	_draw_poly_arc(center + off_dark, r, a_start, a_end, segs, _c_dark, thickness, shape_type)
	if not is_closed:
		var p_start = center + off_dark + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + off_dark + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r, _c_dark)
		draw_circle(p_end, cap_r, _c_dark)
		
	_draw_poly_arc(center, r, a_start, a_end, segs, _c_main, thickness, shape_type)
	if not is_closed:
		var p_start = center + Vector2.from_angle(a_start) * PieceGeometry.get_boundary_distance(shape_type, r, a_start)
		var p_end = center + Vector2.from_angle(a_end) * PieceGeometry.get_boundary_distance(shape_type, r, a_end)
		draw_circle(p_start, cap_r, _c_main)
		draw_circle(p_end, cap_r, _c_main)
		
	var off_hl := Vector2(-1.5, -2.5)
	var hl_w = thickness * 0.4
	_draw_poly_arc(center + off_hl, r, a_start, a_end, segs, _c_light, hl_w, shape_type)

func _draw_poly_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, color: Color, line_width: float, shape_type: int) -> void:
	var pts = PackedVector2Array()
	var step = (a_end - a_start) / float(segs)
	for i in range(segs + 1):
		var theta = a_start + step * i
		var dist = PieceGeometry.get_boundary_distance(shape_type, r, theta)
		pts.append(center + Vector2(cos(theta), sin(theta)) * dist)
	
	if pts.size() >= 2:
		draw_polyline(pts, color, line_width, true)
