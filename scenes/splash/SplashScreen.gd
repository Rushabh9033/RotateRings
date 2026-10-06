extends Control
class_name SplashScreen

const RING := Color("7B61FF")
const RADIUS := 102.0
const THICK := 30.0
const GAP := 0.82
const SNAP_SPIN := 0.52

var audio_service: Node = null
var haptic_service: Node = null

var _mask: ColorRect
var _world: Node2D
var _title: Label
var _shader: ShaderMaterial
var _tween: Tween
var _elapsed := 0.0
var _phase := "arrive"
var _skipped := false
var _boot_ready := false
var _frag_u: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _spin := 0.0
var _squash := 1.0
var _dust := 0.0
var _title_lift := 0.0
var _base_angles: Array[float] = []
var _span := 0.0

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 40
	_span = (TAU - GAP) / 4.0
	for i in 4:
		_base_angles.append(GAP * 0.5 + _span * 0.5 + float(i) * ((TAU - GAP) / 4.0))
	_build()

func begin(audio: Node, haptic: Node) -> void:
	audio_service = audio
	haptic_service = haptic
	_boot_ready = true
	_play()

func _build() -> void:
	_mask = ColorRect.new()
	_mask.set_anchors_preset(Control.PRESET_FULL_RECT)
	_mask.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_mask.color = Color("F6EBDD")
	var shader := load("res://scenes/splash/splash_portal.gdshader") as Shader
	_shader = ShaderMaterial.new()
	_shader.shader = shader
	_mask.material = _shader
	add_child(_mask)

	_world = _WorldDraw.new()
	_world.z_index = 2
	add_child(_world)
	_world._host = self

	_title = Label.new()
	_title.text = "Rotate Rings"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_font_override("font", preload("res://app/ui_theme.gd").rounded_font())
	_title.add_theme_font_size_override("font_size", 46)
	_title.add_theme_color_override("font_color", Color("4A3428"))
	_title.modulate.a = 0.0
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title.z_index = 3
	add_child(_title)
	_layout_title()

func _view_size() -> Vector2:
	var s := size
	if s.x < 2.0 or s.y < 2.0:
		s = get_viewport_rect().size
	return s

func _layout_title() -> void:
	var s := _view_size()
	_title.position = Vector2(40.0, s.y * 0.5 + 168.0 + _title_lift)
	_title.size = Vector2(maxf(s.x - 80.0, 200.0), 64.0)

func _process(delta: float) -> void:
	_elapsed += delta
	if _phase == "hold" and not _boot_ready:
		_spin = SNAP_SPIN + sin(_elapsed * 1.6) * 0.03
	_dust = move_toward(_dust, 0.0, delta * 1.6)
	_push_shader()
	_layout_title()
	if _world:
		_world.position = _view_size() * 0.5
		_world.queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if _elapsed < 0.5 or _phase == "portal" or _phase == "done":
		return
	var pressed: bool = (event is InputEventMouseButton and (event as InputEventMouseButton).pressed) or (event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed)
	if pressed:
		accept_event()
		_skip_to_portal()

func _play() -> void:
	_phase = "arrive"
	_whoosh()
	_tween = create_tween()
	_tween.tween_interval(0.12)
	_tween.set_parallel(true)
	for i in 4:
		var index := i
		_tween.tween_method(_set_frag.bind(index), 0.0, 1.0, 0.5).set_delay(0.04 * float(index)).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.set_parallel(false)
	_tween.chain().tween_callback(_contact)
	_tween.tween_interval(0.08)
	_tween.tween_method(_set_spin, 0.0, SNAP_SPIN, 0.26).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(_tick)
	_tween.tween_callback(_snap)

func _skip_to_portal() -> void:
	if _skipped or _phase == "snap" or _phase == "portal" or _phase == "done":
		return
	_skipped = true
	if _tween and _tween.is_valid():
		_tween.kill()
	for i in 4:
		_frag_u[i] = 1.0
	_spin = SNAP_SPIN
	_phase = "snap"
	_contact()
	_snap()

func _set_frag(u: float, index: int) -> void:
	_frag_u[index] = u

func _set_spin(value: float) -> void:
	_spin = value
	_phase = "turn"

func _whoosh() -> void:
	if audio_service and audio_service.has_method("play_piece_select"):
		audio_service.play_piece_select()

func _contact() -> void:
	_phase = "assembled"
	if audio_service and audio_service.has_method("play_connector_touch"):
		audio_service.play_connector_touch()

func _tick() -> void:
	if audio_service and audio_service.has_method("play_rotation_tick"):
		audio_service.play_rotation_tick(1.15)

func _snap() -> void:
	_phase = "snap"
	_dust = 1.0
	if audio_service and audio_service.has_method("play_release"):
		audio_service.play_release()
	if haptic_service and haptic_service.has_method("trigger_release"):
		haptic_service.trigger_release()
	var snap := create_tween()
	snap.tween_method(_set_squash, 1.0, 1.05, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	snap.tween_method(_set_squash, 1.05, 1.0, 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	snap.parallel().tween_property(_title, "modulate:a", 1.0, 0.16)
	snap.parallel().tween_method(_set_title_lift, 10.0, 0.0, 0.16).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	snap.tween_interval(0.1)
	snap.tween_callback(_begin_portal)

func _set_squash(value: float) -> void:
	_squash = value

func _set_title_lift(value: float) -> void:
	_title_lift = value

func _begin_portal() -> void:
	if not _boot_ready:
		_phase = "hold"
		return
	_phase = "portal"
	_dust = 0.0
	_shader.set_shader_parameter("portal", 1.0)
	var grow := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var end_r := maxf(size.x, size.y) * 1.15
	grow.tween_method(_set_portal_scale, 1.0, end_r / RADIUS, 0.42)
	grow.parallel().tween_property(_title, "modulate:a", 0.0, 0.1)
	grow.tween_callback(_finish)

func _set_portal_scale(value: float) -> void:
	_squash = value

func _finish() -> void:
	_phase = "done"
	queue_free()

func _push_shader() -> void:
	if _shader == null:
		return
	var s := _view_size()
	var center := s * 0.5
	_shader.set_shader_parameter("viewport_px", s)
	_shader.set_shader_parameter("center_px", center)
	var portaling := _phase == "portal"
	_shader.set_shader_parameter("portal", 1.0 if portaling else 0.0)
	var scale := _squash if portaling else 1.0
	var inner := (RADIUS - THICK * 0.5) * scale
	var outer := (RADIUS + THICK * 0.5) * scale
	_shader.set_shader_parameter("inner_px", inner if portaling else 0.0)
	_shader.set_shader_parameter("outer_px", outer if portaling else 0.0)
	_shader.set_shader_parameter("gap_center", _spin)
	var slot := (TAU - GAP) / 4.0
	var gap_width := TAU - (_span + 3.0 * slot)
	_shader.set_shader_parameter("gap_half", gap_width * 0.5)
	var cream := Color("F6EBDD")
	if _phase == "snap" or portaling:
		cream = cream.lerp(Color("FFF8F1"), 0.65)
	_shader.set_shader_parameter("cream", cream)

class _WorldDraw extends Node2D:
	var _host = null

	func _draw() -> void:
		var host = _host
		if host == null or str(host._phase) == "done":
			return
		draw_set_transform(Vector2.ZERO, host._spin, Vector2(host._squash, host._squash))
		for i in 4:
			var u: float = host._frag_u[i]
			var ang: float = host._base_angles[i]
			var travel := lerpf(500.0, 0.0, u)
			var center := Vector2.from_angle(ang) * travel
			center.y += sin(u * PI) * 28.0 * (1.0 - u)
			var wobble := -0.42 if i % 2 == 0 else 0.36
			var extra := lerpf(wobble, 0.0, u)
			var start: float = ang - float(host._span) * 0.5 + extra
			var end: float = ang + float(host._span) * 0.5 + extra
			var inv := 1.0 / maxf(float(host._squash), 0.001)
			_arc(center + Vector2(0, 12) * inv, host.RADIUS, start, end, Color(0.42, 0.24, 0.14, 0.16), host.THICK + 4.0)
			_arc(center + Vector2(0, 6) * inv, host.RADIUS, start, end, host.RING.darkened(0.28), host.THICK)
			_arc(center, host.RADIUS, start, end, host.RING, host.THICK)
			var hi := Color(1, 1, 1, 0.5)
			_arc(center + Vector2(-2, -3) * inv, host.RADIUS, start + 0.08, start + minf(0.7, float(host._span) * 0.45), hi, host.THICK * 0.28)
		if host._dust > 0.01:
			var gap_at: Vector2 = Vector2.from_angle(0.0) * float(host.RADIUS)
			for n in 4:
				var spec: Vector2 = gap_at + Vector2.from_angle(float(n) * 1.4) * (10.0 + float(n) * 4.0)
				draw_circle(spec, 2.4, Color(1, 0.86, 0.45, host._dust * 0.8))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	func _arc(center: Vector2, radius: float, start: float, end: float, color: Color, width: float) -> void:
		draw_arc(center, radius, start, end, 36, color, width, true)
		draw_circle(center + Vector2.from_angle(start) * radius, width * 0.48, color)
		draw_circle(center + Vector2.from_angle(end) * radius, width * 0.48, color)
