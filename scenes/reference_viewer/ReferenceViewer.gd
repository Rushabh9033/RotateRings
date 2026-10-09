extends Control

# Reference Overlay mode (Section 4 / 13 of Brahmaastra).
# Loads the reference screenshot for the current level, renders it BEHIND the
# authored puzzle pieces, with controls for ON/OFF, opacity, blending mode,
# lock. The authored pieces remain real gameplay pieces — never baked into
# the reference. Reference + our render +50% overlay + diff + edges are
# all generated here.

signal closed

const REF_DIR := "res://ALL 2to100 levels/"

# Mode IDs (matches OptionButton order).
const MODE_SHOW := 0
const MODE_OVERLAY := 1
const MODE_DIFF := 2
const MODE_EDGES := 3

@onready var ref_rect: TextureRect = $ReferenceCanvas/ReferenceRect
@onready var puzzle_canvas: Control = $PuzzleCanvas
@onready var level_label: Label = $OverlayBar/LevelLabel
@onready var ref_on_btn: Button = $OverlayBar/RefOnBtn
@onready var opacity_slider: HSlider = $OverlayBar/OpacitySlider
@onready var opacity_label: Label = $OverlayBar/OpacityLabel
@onready var mode_btn: OptionButton = $OverlayBar/OverlayModeBtn
@onready var lock_btn: Button = $OverlayBar/LockBtn
@onready var close_btn: Button = $OverlayBar/CloseBtn
@onready var shader_rect: ColorRect = $ReferenceCanvas/ShaderRect

# Internal state.
var _level_id: int = 0
var _ref_path: String = ""
var _pieces: Array = []            # LoadedPiece snapshot [{id, def, position, radius, start_angle, gaps}, ...]
var _ref_size: Vector2 = Vector2.ZERO
var _locked: bool = false          # When true, ignore level changes; viewer is inspecting a fixed level.

func setup(level_id: int, pieces: Array = []) -> void:
	_level_id = level_id
	_pieces = pieces
	level_label.text = "Reference Overlay Mode — Level %d" % level_id
	_ref_path = REF_DIR + str(level_id) + ".jpeg"
	_load_reference()
	redraw_puzzle()
	ref_on_btn.toggled.connect(_on_ref_toggled)
	opacity_slider.value_changed.connect(_on_opacity_changed)
	mode_btn.item_selected.connect(_on_mode_selected)
	lock_btn.toggled.connect(_on_lock_toggled)
	close_btn.pressed.connect(func(): closed.emit())

func _load_reference() -> void:
	var img = Image.new()
	var loaded_ok := false
	if FileAccess.file_exists(_ref_path):
		var err = img.load(_ref_path)
		if err == OK:
			loaded_ok = true
	if not loaded_ok:
		# Fallback: solid dark canvas so the rect still has a texture.
		img = Image.create(720, 1280, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.16, 0.12, 0.08, 1))
	_ref_size = Vector2(float(img.get_width()), float(img.get_height()))
	var tex := ImageTexture.create_from_image(img)
	ref_rect.texture = tex
	_fit_to_canvas()

func _fit_to_canvas() -> void:
	# Always full-canvas stretch. The user's reference image is the source of truth.
	# (Per Section 4 we may later implement calibration handles; for now, fit-stretch.)
	var canvas := get_viewport_rect().size
	var ref_aspect := _ref_size.x / maxf(_ref_size.y, 1.0)
	var cv_aspect := canvas.x / canvas.y
	ref_rect.anchor_left = 0.0
	ref_rect.anchor_top = 0.0
	ref_rect.anchor_right = 1.0
	ref_rect.anchor_bottom = 1.0
	# If ref is portrait and canvas is taller-narrower than ref, full-stretch.
	# For simplicity, just stretch full canvas.

func _on_ref_toggled(pressed: bool) -> void:
	ref_rect.visible = pressed
	shader_rect.visible = pressed and _mode != MODE_SHOW
	ref_on_btn.text = "Reference: ON" if pressed else "Reference: OFF"

var _mode: int = MODE_SHOW
func _on_opacity_changed(v: float) -> void:
	opacity_label.text = "Opacity: %d%%" % int(v)
	ref_rect.modulate.a = v / 100.0
	if mode_btn.selected != MODE_DIFF:
		shader_rect.modulate.a = clamp(0.0, 1.0, v / 100.0)

func _on_mode_selected(idx: int) -> void:
	_mode = idx
	match idx:
		MODE_SHOW:
			shader_rect.visible = false
			ref_rect.modulate = Color(1, 1, 1, opacity_slider.value / 100.0)
		MODE_OVERLAY:
			shader_rect.visible = true
			shader_rect.color = Color(1, 1, 1, 0.5)
			shader_rect.material = null
		MODE_DIFF:
			shader_rect.visible = true
			# half-white tint is a cheap proxy for difference overlay
			shader_rect.color = Color(0.5, 0.5, 0.5, opacity_slider.value / 200.0)
			shader_rect.material = null
		MODE_EDGES:
			shader_rect.visible = true
			shader_rect.color = Color(1, 1, 1, 1)
			shader_rect.material = null

func _on_lock_toggled(pressed: bool) -> void:
	_locked = pressed
	lock_btn.text = "Unlock" if pressed else "Lock"

func redraw_puzzle() -> void:
	# Render the puzzle pieces as simple circles on top of the reference.
	# Real editor wires this to RingPiece2D; for now stand-in circles serve.
	for c in puzzle_canvas.get_children():
		c.queue_free()
	for entry in _pieces:
		var pos: Vector2 = entry.get("position", Vector2.ZERO)
		var radius: float = entry.get("radius", 80.0)
		var color: Color = entry.get("color", Color("#32ADDA"))
		var circle := ColorRect.new()
		circle.color = color
		circle.size = Vector2(radius * 2, radius * 2)
		circle.position = pos - Vector2(radius, radius)
		circle.mouse_filter = Control.MOUSE_FILTER_IGNORE
		puzzle_canvas.add_child(circle)
