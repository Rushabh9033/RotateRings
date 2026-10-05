extends RigidBody2D
class_name DroppedRing2D

var radius: float = 80.0
var thickness: float = 26.0
var ring_color: Color = Color("#29B6F6")
var gaps: Array = []
var custom_arc_start: float = 0.0
var custom_arc_end: float = 0.0
var use_custom_arc: bool = false

func setup(p_radius: float, p_thickness: float, p_color: Color, p_gaps: Array, p_initial_rotation: float, arc_start: float = 0.0, arc_end: float = 0.0, p_use_custom: bool = false) -> void:
	radius = p_radius
	thickness = p_thickness
	ring_color = p_color
	gaps = p_gaps.duplicate()
	rotation_degrees = p_initial_rotation
	use_custom_arc = p_use_custom
	custom_arc_start = arc_start
	custom_arc_end = arc_end
	queue_redraw()
	
	_build_collision()

func _build_collision() -> void:
	var arcs_to_build: Array = []
	if use_custom_arc:
		arcs_to_build.append({ "start": custom_arc_start, "end": custom_arc_end })
	else:
		var is_closed: bool = gaps.is_empty() or (gaps.size() == 1 and float(gaps[0].get("width_deg")) <= 0.0)
		if is_closed:
			arcs_to_build.append({ "start": 0.0, "end": TAU })
		else:
			arcs_to_build = RingGeometry.get_solid_arcs(gaps)
			
	for arc in arcs_to_build:
		var a_start = arc.start
		var a_end = arc.end
		if a_end < a_start: a_end += TAU
		
		# Generate polygon points for this arc
		var pts := PackedVector2Array()
		var segs: int = max(4, roundi((a_end - a_start) / (PI / 8.0)))
		var r_outer = radius + (thickness * 0.5)
		var r_inner = radius - (thickness * 0.5)
		
		# Outer arc
		for i in range(segs + 1):
			var a = lerpf(a_start, a_end, float(i) / float(segs))
			pts.append(Vector2.from_angle(a) * r_outer)
			
		# Inner arc (reverse)
		for i in range(segs, -1, -1):
			var a = lerpf(a_start, a_end, float(i) / float(segs))
			pts.append(Vector2.from_angle(a) * r_inner)
			
		var col = CollisionPolygon2D.new()
		col.polygon = pts
		add_child(col)

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Keep the visual drawing rotated properly matching physical rotation
	queue_redraw()

func _draw() -> void:
	var seg_count := 48
	var cap_r: float = thickness * 0.5
	
	if use_custom_arc:
		_draw_ring_arc(Vector2.ZERO, radius, custom_arc_start, custom_arc_end, seg_count, cap_r, false)
		return
		
	var is_closed: bool = gaps.is_empty() or (gaps.size() == 1 and float(gaps[0].get("width_deg")) <= 0.0)

	if is_closed:
		_draw_ring_arc(Vector2.ZERO, radius, 0.0, TAU, seg_count, cap_r, is_closed)
		return

	var arcs: Array = RingGeometry.get_solid_arcs(gaps)
	for arc in arcs:
		var arc_start: float = arc.start
		var arc_end: float = arc.end
		if arc_end < arc_start:
			arc_end += TAU
		_draw_ring_arc(Vector2.ZERO, radius, arc_start, arc_end, seg_count, cap_r, false)

func _draw_ring_arc(center: Vector2, r: float, a_start: float, a_end: float, segs: int, cap_r: float, is_closed: bool) -> void:
	segs = 64
	
	# === LAYER 1: Soft warm ambient shadow ===
	var shadow_c1 := Color(0.20, 0.14, 0.10, 0.12)
	var shadow_off1 := Vector2(0, 6.0)
	draw_arc(center + shadow_off1, r, a_start, a_end, segs, shadow_c1, thickness + 2.0, true)
	if not is_closed:
		draw_circle(center + shadow_off1 + Vector2.from_angle(a_start) * r, cap_r + 1.0, shadow_c1)
		draw_circle(center + shadow_off1 + Vector2.from_angle(a_end) * r, cap_r + 1.0, shadow_c1)
		
	# === LAYER 2: Darker lower 3D base ===
	var c_dark = ring_color.darkened(0.22)
	var off_dark := Vector2(0, 2.5)
	draw_arc(center + off_dark, r, a_start, a_end, segs, c_dark, thickness, true)
	if not is_closed:
		draw_circle(center + off_dark + Vector2.from_angle(a_start) * r, cap_r, c_dark)
		draw_circle(center + off_dark + Vector2.from_angle(a_end) * r, cap_r, c_dark)

	# === LAYER 3: Main body ===
	var c_main = ring_color.lightened(0.02)
	draw_arc(center, r, a_start, a_end, segs, c_main, thickness, true)
	if not is_closed:
		draw_circle(center + Vector2.from_angle(a_start) * r, cap_r, c_main)
		draw_circle(center + Vector2.from_angle(a_end) * r, cap_r, c_main)

	# === LAYER 4: Bright top-left 3D highlight bevel ===
	var c_light = ring_color.lightened(0.25)
	c_light.a = 0.85
	var off_light := Vector2(-1.5, -2.5)
	draw_arc(center + off_light, r, a_start, a_end, segs, c_light, thickness - 3.0, true)
	if not is_closed:
		draw_circle(center + off_light + Vector2.from_angle(a_start) * r, cap_r - 1.5, c_light)
		draw_circle(center + off_light + Vector2.from_angle(a_end) * r, cap_r - 1.5, c_light)
		
	# === LAYER 5: Tiny inner shadow for more depth ===
	var c_inner_dark = ring_color.darkened(0.1)
	c_inner_dark.a = 0.5
	draw_arc(center + Vector2(0, -1.0), r - (thickness * 0.5) + 1.5, a_start, a_end, segs, c_inner_dark, 1.5, true)
