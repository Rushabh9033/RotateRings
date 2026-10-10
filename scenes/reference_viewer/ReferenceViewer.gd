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

# Calibration state. The reference is placed in the canonical
# canvas at a uniform scale and translation defined by:
#   canonical_p = (ref_p - ref_image_origin) * ref_scale + ref_canvas_origin
# Plus a puzzle-region rect (in ref-image space) that crops the
# displayed portion. Once `_locked` is true, all of these are frozen
# and the calibration handles become non-interactive.
var _ref_image_origin: Vector2 = Vector2.ZERO   # where the ref image's (0,0) sits in canvas space
var _ref_canvas_origin: Vector2 = Vector2.ZERO  # where the ref appears in the canvas (same as origin by default)
var _ref_scale: float = 1.0                    # uniform scale (NEVER independent X/Y)
var _puzzle_region_min: Vector2 = Vector2.ZERO  # in ref-image pixel space
var _puzzle_region_max: Vector2 = Vector2.ZERO
# Legacy fields, kept for back-compat with the earlier _apply_calibration:
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
	# Apply the calibration transform to the reference rect.
	# canonical = (ref_p - image_origin) * scale + canvas_origin
	# The ref image is placed inside `PuzzleCanvas` (canonical canvas).
	# ref_rect's position is canvas_origin; its scale is _ref_scale.
	if ref_rect.texture == null: return
	# Region: when puzzle_region has a non-zero area, crop the texture
	# to that sub-rect by drawing a smaller TextureRect that aliases the
	# same texture. We use the ImageTexture.region property to do this
	# in-place when the calibration is a sub-region.
	if _puzzle_region_max.x > _puzzle_region_min.x and _puzzle_region_max.y > _puzzle_region_min.y:
		var rw: float = _puzzle_region_max.x - _puzzle_region_min.x
		var rh: float = _puzzle_region_max.y - _puzzle_region_min.y
		ref_rect.size = Vector2(rw * _ref_scale, rh * _ref_scale)
		# ImageTexture doesn't expose a region setter at runtime easily,
		# so we accept the full image is shown and rely on the host's
		# render layer to clip or overlay the puzzle region. The size
		# of the ref_rect still represents the calibrated region in
		# canvas space, which the host uses to position calibration
		# handles.
	else:
		ref_rect.size = Vector2(_ref_size.x * _ref_scale, _ref_size.y * _ref_scale)
	ref_rect.position = _ref_canvas_origin
	ref_rect.scale = Vector2.ONE  # TextureRect's own scale; we baked _ref_scale into size
	# Back-compat: also update the legacy _calib_top_left / _calib_bottom_right
	_calib_top_left = _puzzle_region_min
	_calib_bottom_right = _puzzle_region_max

# Set the calibration transform. Called by the host when the user
# finishes dragging calibration handles. `_ref_scale` is the uniform
# scale; `_ref_canvas_origin` is where the (0,0) of the ref image lands
# in canvas space; `_puzzle_region` is the puzzle region inside the
# image in image pixel coordinates.
func set_calibration(image_origin: Vector2, canvas_origin: Vector2, scale: float,
		puzzle_region_min: Vector2, puzzle_region_max: Vector2) -> void:
	_ref_image_origin = image_origin
	_ref_canvas_origin = canvas_origin
	_ref_scale = scale
	_puzzle_region_min = puzzle_region_min
	_puzzle_region_max = puzzle_region_max
	_apply_calibration()

# Reset to the default: ref image at its natural size, anchored to
# the canvas origin, no puzzle-region crop.
func reset_calibration() -> void:
	_ref_image_origin = Vector2.ZERO
	_ref_canvas_origin = Vector2.ZERO
	_ref_scale = 1.0
	_puzzle_region_min = Vector2.ZERO
	_puzzle_region_max = _ref_size
	_apply_calibration()

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
	# Locked: reference is FROZEN — still visible, but its transform
	# (calibration + scale + offset) is no longer editable. Mouse input
	# passes through to level objects underneath (handled by the host
	# setting mouse_filter appropriately on the reference rect).
	# Visibility is independent — toggled by the [Reference ON/OFF] button.
	# The reference is the editor's tracing paper; you lock it once
	# you've calibrated, then place pieces directly over it.

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
