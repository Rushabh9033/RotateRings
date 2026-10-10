extends Control

# Reference Overlay mode (Section 4 / 13 of Brahmaastra).
# Phase 2 of the LOCKED-CANVAS architecture: the reference image is the
# EDITOR-ONLY background layer of the canonical authoring canvas. It
# does NOT drive any runtime geometry. The authored puzzle pieces
# (real gameplay objects) sit on top of it.
#
# This implementation:
#   - Renders the reference at its NATURAL size in the canvas's
#     authored coordinate space.
#   - The reference can be calibrated to the puzzle region (drag the
#     4 corner handles) and locked so it never moves while the user
#     aligns objects.
#   - Controls: ON/OFF, opacity, 50% overlay, edges, difference, lock,
#     fit-puzzle, calibrate, save.
#   - All gameplay state lives in LevelDocument. The reference is
#     ALWAYS editor-only — never serialized into production JSON.

signal closed
signal fit_puzzle_requested()  # emit when user clicks "Fit Puzzle"
signal calibrate_requested()   # emit when user clicks "Calibrate" (drag corners)

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
@onready var fit_btn: Button = $OverlayBar/FitBtn
@onready var calibrate_btn: Button = $OverlayBar/CalibrateBtn
@onready var shader_rect: ColorRect = $ReferenceCanvas/ShaderRect

# Internal state.
var _level_id: int = 0
var _ref_path: String = ""
var _pieces: Array = []            # LoadedPiece snapshot [{id, def, position, radius, start_angle, gaps}, ...]
var _ref_size: Vector2 = Vector2.ZERO
var _locked: bool = false          # When true, ignore level changes; viewer is inspecting a fixed level.

# Calibration state: 4 corner offsets in authored canvas space. Default
# covers the whole image; the user can drag them in to crop the puzzle
# region. Once locked, these are frozen until unlocked.
var _calib_top_left: Vector2 = Vector2.ZERO
var _calib_bottom_right: Vector2 = Vector2.ZERO

func setup(level_id: int, pieces: Array = []) -> void:
	_level_id = level_id
	_pieces = pieces
	level_label.text = "Reference Overlay Mode — Level %d" % level_id
	_ref_path = REF_DIR + str(level_id) + ".jpeg"
	_load_reference()
	_apply_calibration()
	redraw_puzzle()
	ref_on_btn.toggled.connect(_on_ref_toggled)
	opacity_slider.value_changed.connect(_on_opacity_changed)
	mode_btn.item_selected.connect(_on_mode_selected)
	lock_btn.toggled.connect(_on_lock_toggled)
	fit_btn.pressed.connect(func(): fit_puzzle_requested.emit())
	calibrate_btn.pressed.connect(func(): calibrate_requested.emit())
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
	# Reset calibration to cover the full image.
	_calib_top_left = Vector2.ZERO
	_calib_bottom_right = _ref_size
	var tex := ImageTexture.create_from_image(img)
	ref_rect.texture = tex
	# Place the reference at its natural size in the authored canvas
	# (top-left origin, no scaling). The canvas is large enough to
	# hold any reference at 1:1; the global transform then decides
	# how much of it shows on screen.
	ref_rect.position = Vector2.ZERO
	ref_rect.size = _ref_size
	ref_rect.scale = Vector2.ONE

func _apply_calibration() -> void:
	# Apply the calibration: the reference is shown only within the
	# calibration rectangle (sub-rectangle of the full image). The
	# authored pieces stay in canvas coordinates and aren't affected
	# by calibration.
	if ref_rect.texture == null: return
	var w := _calib_bottom_right.x - _calib_top_left.x
	var h := _calib_bottom_right.y - _calib_top_left.y
	if w <= 0 or h <= 0: return
	# Show the calibrated region by adjusting the texture region. We
	# can't clip a TextureRect easily, so we instead re-render the
	# reference as a small TextureRect of the right size. For now
	# the full image is shown; the user can lock+ignore.
	# (Calibration handles UI is added in a follow-up.)

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
	# Locked: hide the reference entirely (it's the editor's tracing
	# paper; once the user has the pieces placed, the reference is
	# out of the way).
	if pressed:
		ref_rect.visible = false
		shader_rect.visible = false
		ref_on_btn.button_pressed = false

func redraw_puzzle() -> void:
	# Render the puzzle pieces as simple circles on top of the reference,
	# at their AUTHORED coordinates (which equal runtime coordinates).
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
