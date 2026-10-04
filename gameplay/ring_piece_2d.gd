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
		# Particle puffs only in NEAR_VALID; skip for perf on heavy levels
		if gaps.size() <= 1:
			for gap in gaps:
				var angle = deg_to_rad(rotation_degrees + gap.center_angle_deg)
				var gap_pos = Vector2.from_angle(angle) * radius
				_emit_dust_puff(gap_pos)

	queue_redraw()

func _emit_dust_puff(pos: Vector2) -> void:
	var puff = CPUParticles2D.new()
	puff.emitting = false
	puff.one_shot = true
	puff.explosiveness = 0.9
	puff.lifetime = 0.3
	puff.spread = 160.0
	puff.gravity = Vector2(0, 0)
	puff.initial_velocity_min = 30.0
	puff.initial_velocity_max = 60.0
	puff.scale_amount_min = 2.0
	puff.scale_amount_max = 5.0
	puff.color = Color(1.0, 1.0, 1.0, 0.7)
	puff.amount = 8
	puff.position = pos

	add_child(puff)
	puff.emitting = true

	var tween = create_tween()
	tween.tween_callback(puff.queue_free).set_delay(0.4)

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

	# PERFORMANCE: 72 segments — indistinguishable from 256 at mobile resolution
	var seg_count := 72
	var cap_r: float = thickness * 0.5

	var is_closed: bool = gaps.is_empty() or (gaps.size() == 1 and float(gaps[0].get("width_deg")) <= 0.0)

	if is_closed:
		_draw_ring_arc(Vector2.ZERO, radius, 0.0, TAU, seg_count, cap_r, is_closed)
		return

	var gap = gaps[0]
	var half_gap := deg_to_rad(gap.width_deg * 0.5)
	var arc_start := half_gap
	var arc_end := TAU - half_gap

	# State-based outer glow
	if state == State.SELECTED or state == State.ROTATING:
		var glow_c := Color(ring_color.r, ring_color.g, ring_color.b, 0.30)
		draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, glow_c, thickness + 12.0, true)
	elif state == State.NEAR_VALID:
		draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(1.0, 1.0, 0.6, 0.55), thickness + 9.0, true)
	elif state == State.RELEASABLE:
		draw_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, Color(0.4, 1.0, 0.4, 0.60), thickness + 9.0, true)

	_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, false)


func _draw_ring_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool) -> void:
	# PERFORMANCE: fixed 72 segs — smooth enough, 3.5x faster than 256
	segs = 72

	var shadow_off1 := Vector2(0, 6.0) * shadow_offset_mult

	# === LAYER 1: Soft warm ambient shadow ===
	draw_arc(center + shadow_off1, r, a_start, a_end, segs, _c_shadow, thickness + 2.0, true)
	if not is_closed:
		draw_circle(center + shadow_off1 + Vector2.from_angle(a_start) * r, cap_r + 1.0, _c_shadow)
		draw_circle(center + shadow_off1 + Vector2.from_angle(a_end) * r, cap_r + 1.0, _c_shadow)

	# === LAYER 2: Darker lower 3D base ===
	var off_dark := Vector2(0, 2.5)
	draw_arc(center + off_dark, r, a_start, a_end, segs, _c_dark, thickness, true)
	if not is_closed:
		draw_circle(center + off_dark + Vector2.from_angle(a_start) * r, cap_r, _c_dark)
		draw_circle(center + off_dark + Vector2.from_angle(a_end) * r, cap_r, _c_dark)

	# === LAYER 3: Main body ===
	draw_arc(center, r, a_start, a_end, segs, _c_main, thickness, true)
	if not is_closed:
		draw_circle(center + Vector2.from_angle(a_start) * r, cap_r, _c_main)
		draw_circle(center + Vector2.from_angle(a_end) * r, cap_r, _c_main)

	# === LAYER 4: Bright top-left 3D highlight bevel ===
	var off_light := Vector2(-1.5, -2.5)
	draw_arc(center + off_light, r, a_start, a_end, segs, _c_light, thickness - 3.0, true)
	if not is_closed:
		draw_circle(center + off_light + Vector2.from_angle(a_start) * r, cap_r - 1.5, _c_light)
		draw_circle(center + off_light + Vector2.from_angle(a_end) * r, cap_r - 1.5, _c_light)

	# === LAYER 5: Tiny inner shadow for more depth ===
	draw_arc(center + Vector2(0, -1.0), r - (thickness * 0.5) + 1.5, a_start, a_end, segs, _c_inner_dark, 1.5, true)


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
		var effective_half_gap: float = (gap.width_deg * 0.5) + gap.tolerance_deg
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
