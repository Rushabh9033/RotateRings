extends Control
class_name EditorToolbar

# ==============================================================================
# EditorToolbar — top-of-screen strip that lights up the in-game editor.
# Mounts:
#   - Mode strip (M26): SELECT / PIECE / GAP / CONNECTOR / MEASURE / REFERENCE
#   - Snap toggles (M9)
#   - Grid + framing inputs (M23)
#   - Color picker + recent swatches + copy/paste (M18)
#   - Size-link button (M15)
#   - Reference overlay controls (M13)
#   - TEST LEVEL button (M22)
# All buttons are wired to either the LevelDocument or the overlay's public
# state. The toolbar is mode-aware — buttons enable/disable depending on
# what's selected.
# ==============================================================================

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")

signal test_level_pressed()
signal reference_overlay_changed(visible: bool)
signal fit_reference_requested()
signal fit_puzzle_requested()
signal reference_zoom_changed(zoom: float)
signal reference_pan_changed(pan: Vector2)
signal reference_opacity_changed(opacity: float)
signal size_link_requested(follower_id: String, master_id: String)

# Wired by the host (GameplayScreen). The toolbar reads the document for
# state and dispatches actions back into the overlay/document.
var document: Resource = null
var overlay: Control = null  # the PieceEditOverlay

# Mode (M26). 0=SELECT, 1=PIECE, 2=GAP, 3=CONNECTOR, 4=MEASURE, 5=REFERENCE.
var current_mode: int = 0

# UI nodes we keep references to.
var _mode_buttons: Array = []   # [Button, ...]
var _snap_toggles: Dictionary = {}  # property_name -> CheckBox
var _snap_spin: SpinBox = null
var _frame_scale_spin: SpinBox = null
var _frame_off_x_spin: SpinBox = null
var _frame_off_y_spin: SpinBox = null
var _ref_visibility_btn: Button = null
var _ref_opacity_slider: HSlider = null
var _ref_overlay_mode_btn: Button = null  # cycles 50 / difference / edges / normal
var _ref_lock_btn: Button = null
var _ref_zoom_slider: HSlider = null
var _ref_pan_x_spin: SpinBox = null
var _ref_pan_y_spin: SpinBox = null
var _fit_ref_btn: Button = null
var _fit_puzzle_btn: Button = null
var _color_picker: ColorPickerButton = null
var _color_hex_edit: LineEdit = null
var _color_recent: Array = []   # recent color Buttons
var _color_copy_btn: Button = null
var _color_paste_btn: Button = null
var _size_link_master_picker: OptionButton = null
var _size_link_follower_picker: OptionButton = null
var _size_link_btn: Button = null
var _test_level_btn: Button = null
var _test_level_status: Label = null

# Recent colors (M18).
var _recent_colors: Array = []  # [Color, ...]

# Reference overlay state (M13). Lives in the toolbar; the ReferenceViewer
# reads from these when it instantiates.
var reference_visible: bool = true
var reference_opacity: float = 0.5
var reference_overlay_mode: String = "normal"  # "normal" | "blend50" | "difference" | "edges"
var reference_locked: bool = false  # when true, ref follows puzzle frame
var reference_zoom: float = 1.0
var reference_pan: Vector2 = Vector2.ZERO

# ==============================================================================
# Lifecycle
# ==============================================================================

func _ready() -> void:
	# Layout: top strip, anchored to top of parent.
	anchor_right = 1.0
	anchor_bottom = 0.0
	custom_minimum_size = Vector2(0, 88)
	mouse_filter = Control.MOUSE_FILTER_PASS
	_rebuild_ui()
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)

func _on_document_changed() -> void:
	# Refresh size-link pickers (pieces may have been added/removed).
	_refresh_pickers()

func set_document(doc) -> void:
	if document == doc: return
	if document != null and document.document_changed.is_connected(_on_document_changed):
		document.document_changed.disconnect(_on_document_changed)
	document = doc
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)
	_refresh_pickers()
	if _frame_scale_spin != null and doc != null:
		_frame_scale_spin.value = doc.frame_scale
		_frame_off_x_spin.value = doc.frame_offset_x
		_frame_off_y_spin.value = doc.frame_offset_y

func set_overlay(o: Control) -> void:
	overlay = o
	if overlay != null and overlay.has_method("set_document"):
		overlay.set_document(document)
	# Sync the toolbar's mode buttons to the overlay's current mode.
	if overlay != null and overlay.get("measure_mode"):
		current_mode = 4
		_refresh_mode_buttons()

# ==============================================================================
# UI build
# ==============================================================================

func _rebuild_ui() -> void:
	for c in get_children():
		c.queue_free()
	_mode_buttons.clear()
	_snap_toggles.clear()
	_recent_colors = []
	_recent_colors.append(Color("#EA7829"))  # orange
	_recent_colors.append(Color("#32ADDA"))  # cyan
	_recent_colors.append(Color("#7B61FF"))  # purple
	_recent_colors.append(Color("#E63946"))  # red
	_recent_colors.append(Color("#3EC6B0"))  # green
	_recent_colors.append(Color("#1F5A82"))  # cuff_blue
	_recent_colors.append(Color("#F4C95D"))  # yellow
	_recent_colors.append(Color("#F2A6B5"))  # pink

	var panel := PanelContainer.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.modulate = Color(1, 1, 1, 0.94)
	add_child(panel)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	# ----- Row 1: mode strip + TEST LEVEL -----
	vbox.add_child(_build_mode_strip())

	# ----- Row 2: snap / grid / framing -----
	vbox.add_child(_build_snap_strip())

	# ----- Row 3: color picker -----
	vbox.add_child(_build_color_strip())

	# ----- Row 4: size link -----
	vbox.add_child(_build_size_link_strip())

	# ----- Row 5: reference overlay -----
	vbox.add_child(_build_reference_strip())

	# ----- Row 6: TEST LEVEL -----
	vbox.add_child(_build_test_level_strip())

# ----- Row 1: mode strip (M26) -----

func _build_mode_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	var modes: Array = [
		["SELECT", 0],
		["PIECE", 1],
		["GAP", 2],
		["CONNECTOR", 3],
		["MEASURE", 4],
		["REFERENCE", 5],
	]
	for m in modes:
		var btn := Button.new()
		btn.text = m[0]
		btn.toggle_mode = true
		btn.button_pressed = (int(m[1]) == current_mode)
		var captured_mode: int = int(m[1])
		btn.pressed.connect(func(): _on_mode_button(captured_mode))
		hbox.add_child(btn)
		_mode_buttons.append(btn)
	# TEST LEVEL button at the right.
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	return hbox

func _on_mode_button(mode: int) -> void:
	current_mode = mode
	_refresh_mode_buttons()
	# Apply the mode to the overlay.
	if overlay != null:
		# SELECT / PIECE / GAP / CONNECTOR: leave the overlay's drag
		# modes intact. MEASURE toggles overlay.measure_mode.
		if mode == 4:
			overlay.measure_mode = true
		else:
			overlay.measure_mode = false
		# REFERENCE: just emit the signal so the host can show/hide the
		# reference viewer.
		if mode == 5:
			emit_signal("reference_overlay_changed", true)
		else:
			emit_signal("reference_overlay_changed", false)

func _refresh_mode_buttons() -> void:
	for i in range(_mode_buttons.size()):
		_mode_buttons[i].button_pressed = (i == current_mode)

# ----- Row 2: snap / grid / framing (M9 + M23) -----

func _build_snap_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	# Snap toggles.
	for prop in ["snap_to_grid", "snap_to_guides", "snap_to_piece_centers", "snap_to_edges", "snap_to_connector_points"]:
		var cb := CheckBox.new()
		cb.text = prop.replace("snap_to_", "")
		cb.button_pressed = (document.get(prop) if document != null else false)
		cb.toggled.connect(func(pressed: bool, captured_prop: String = prop):
			if document != null:
				document.apply_edit(func():
					document.set(captured_prop, pressed)
				)
		)
		hbox.add_child(cb)
		_snap_toggles[prop] = cb
	# Grid size spin.
	hbox.add_child(_label("grid"))
	var gs := SpinBox.new()
	gs.min_value = 1.0
	gs.max_value = 200.0
	gs.step = 1.0
	gs.value = (document.grid_size if document != null else 20.0)
	gs.size_flags_horizontal = 0
	gs.custom_minimum_size = Vector2(80, 0)
	gs.value_changed.connect(func(v: float):
		if document != null:
			document.apply_edit(func():
				document.grid_size = v
			)
	)
	hbox.add_child(gs)
	_snap_spin = gs
	# Framing: scale / offset x / offset y.
	hbox.add_child(_vsplit())
	hbox.add_child(_label("scale"))
	var fs := SpinBox.new()
	fs.min_value = 0.1
	fs.max_value = 4.0
	fs.step = 0.05
	fs.value = (document.frame_scale if document != null else 1.0)
	fs.size_flags_horizontal = 0
	fs.custom_minimum_size = Vector2(80, 0)
	fs.value_changed.connect(func(v: float):
		if document != null:
			document.apply_edit(func():
				document.frame_scale = v
			)
	)
	hbox.add_child(fs)
	_frame_scale_spin = fs
	hbox.add_child(_label("off x"))
	var fx := SpinBox.new()
	fx.min_value = -1000.0
	fx.max_value = 1000.0
	fx.step = 1.0
	fx.value = (document.frame_offset_x if document != null else 0.0)
	fx.size_flags_horizontal = 0
	fx.custom_minimum_size = Vector2(80, 0)
	fx.value_changed.connect(func(v: float):
		if document != null:
			document.apply_edit(func():
				document.frame_offset_x = v
			)
	)
	hbox.add_child(fx)
	_frame_off_x_spin = fx
	hbox.add_child(_label("off y"))
	var fy := SpinBox.new()
	fy.min_value = -1000.0
	fy.max_value = 1000.0
	fy.step = 1.0
	fy.value = (document.frame_offset_y if document != null else 0.0)
	fy.size_flags_horizontal = 0
	fy.custom_minimum_size = Vector2(80, 0)
	fy.value_changed.connect(func(v: float):
		if document != null:
			document.apply_edit(func():
				document.frame_offset_y = v
			)
	)
	hbox.add_child(fy)
	_frame_off_y_spin = fy
	return hbox

func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	return l
func _vsplit() -> VSeparator:
	return VSeparator.new()

# ----- Row 3: color picker (M18) -----

func _build_color_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.add_child(_label("color"))
	var cp := ColorPickerButton.new()
	cp.color = Color("#EA7829")
	cp.color_changed.connect(func(c: Color):
		if _color_hex_edit != null:
			_color_hex_edit.text = _color_to_hex(c)
		_push_recent_color(c)
	)
	hbox.add_child(cp)
	_color_picker = cp
	var hex := LineEdit.new()
	hex.text = _color_to_hex(Color("#EA7829"))
	hex.placeholder_text = "#RRGGBB"
	hex.custom_minimum_size = Vector2(96, 0)
	hex.focus_exited.connect(func():
		var c: Color = _hex_to_color(hex.text)
		_color_picker.color = c
		_push_recent_color(c)
	)
	hbox.add_child(hex)
	_color_hex_edit = hex
	# Recent colors row.
	hbox.add_child(_vsplit())
	hbox.add_child(_label("recent"))
	_color_recent = []
	for cc in _recent_colors:
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(24, 24)
		sw.modulate = cc
		sw.tooltip_text = _color_to_hex(cc)
		var captured: Color = cc
		sw.pressed.connect(func():
			_color_picker.color = captured
			_color_hex_edit.text = _color_to_hex(captured)
		)
		hbox.add_child(sw)
		_color_recent.append(sw)
	# Copy / paste.
	var copy := Button.new()
	copy.text = "Copy"
	copy.pressed.connect(func():
		if overlay != null and overlay.has_method("_color_clipboard"):
			overlay._color_clipboard = _color_picker.color
	)
	hbox.add_child(copy)
	_color_copy_btn = copy
	var paste := Button.new()
	paste.text = "Paste"
	paste.pressed.connect(func():
		if overlay != null and overlay.has_method("_color_clipboard"):
			var c: Color = overlay._color_clipboard
			_color_picker.color = c
			_color_hex_edit.text = _color_to_hex(c)
	)
	hbox.add_child(paste)
	_color_paste_btn = paste
	return hbox

func _push_recent_color(c: Color) -> void:
	# Move to the front (de-dupe by hex).
	var hex: String = _color_to_hex(c)
	for i in range(_recent_colors.size()):
		if _color_to_hex(_recent_colors[i]) == hex:
			_recent_colors.remove_at(i)
			break
	_recent_colors.push_front(c)
	if _recent_colors.size() > 8:
		_recent_colors.resize(8)
	# Refresh swatches.
	for i in range(min(_recent_colors.size(), _color_recent.size())):
		_color_recent[i].modulate = _recent_colors[i]
		_color_recent[i].tooltip_text = _color_to_hex(_recent_colors[i])

# ----- Row 4: size link (M15) -----

func _build_size_link_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	hbox.add_child(_label("link size"))
	var master := OptionButton.new()
	master.tooltip_text = "Master piece (size source)"
	hbox.add_child(master)
	_size_link_master_picker = master
	hbox.add_child(_label("→"))
	var follower := OptionButton.new()
	follower.tooltip_text = "Follower piece (size target)"
	hbox.add_child(follower)
	_size_link_follower_picker = follower
	var link_btn := Button.new()
	link_btn.text = "Link"
	link_btn.pressed.connect(_on_size_link_pressed)
	hbox.add_child(link_btn)
	_size_link_btn = link_btn
	var unlink_btn := Button.new()
	unlink_btn.text = "Unlink"
	unlink_btn.pressed.connect(_on_size_unlink_pressed)
	hbox.add_child(unlink_btn)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer)
	_refresh_pickers()
	return hbox

func _on_size_link_pressed() -> void:
	if document == null: return
	var master_id: String = String(_size_link_master_picker.get_item_metadata(_size_link_master_picker.selected)) if _size_link_master_picker.selected >= 0 else ""
	var follower_id: String = String(_size_link_follower_picker.get_item_metadata(_size_link_follower_picker.selected)) if _size_link_follower_picker.selected >= 0 else ""
	if master_id.is_empty() or follower_id.is_empty(): return
	document.link_size_to_master(follower_id, master_id, "radius")
	emit_signal("size_link_requested", follower_id, master_id)

func _on_size_unlink_pressed() -> void:
	if document == null: return
	var follower_id: String = String(_size_link_follower_picker.get_item_metadata(_size_link_follower_picker.selected)) if _size_link_follower_picker.selected >= 0 else ""
	if follower_id.is_empty(): return
	document.unlink_size(follower_id)

func _refresh_pickers() -> void:
	if _size_link_master_picker == null or _size_link_follower_picker == null: return
	_size_link_master_picker.clear()
	_size_link_follower_picker.clear()
	if document == null: return
	for p in document.pieces:
		var pid: String = String(p.get("id", ""))
		_size_link_master_picker.add_item(pid)
		_size_link_master_picker.set_item_metadata(_size_link_master_picker.item_count - 1, pid)
		_size_link_follower_picker.add_item(pid)
		_size_link_follower_picker.set_item_metadata(_size_link_follower_picker.item_count - 1, pid)

# ----- Row 5: reference overlay (M13) -----

func _build_reference_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	# ON/OFF
	var vis := Button.new()
	vis.text = "Ref: ON" if reference_visible else "Ref: OFF"
	vis.toggle_mode = true
	vis.button_pressed = reference_visible
	vis.pressed.connect(func():
		reference_visible = not reference_visible
		vis.text = "Ref: ON" if reference_visible else "Ref: OFF"
		emit_signal("reference_overlay_changed", reference_visible)
	)
	hbox.add_child(vis)
	_ref_visibility_btn = vis
	# Opacity
	hbox.add_child(_label("opacity"))
	var op := HSlider.new()
	op.min_value = 0.0
	op.max_value = 1.0
	op.step = 0.05
	op.value = reference_opacity
	op.custom_minimum_size = Vector2(120, 0)
	op.value_changed.connect(func(v: float):
		reference_opacity = v
		emit_signal("reference_opacity_changed", v)
	)
	hbox.add_child(op)
	_ref_opacity_slider = op
	# Mode cycle (50 / difference / edges / normal)
	var mode_btn := Button.new()
	mode_btn.text = "mode: %s" % reference_overlay_mode
	mode_btn.pressed.connect(func():
		var modes: Array = ["normal", "blend50", "difference", "edges"]
		var cur: int = modes.find(reference_overlay_mode)
		cur = (cur + 1) % modes.size()
		reference_overlay_mode = modes[cur]
		mode_btn.text = "mode: %s" % reference_overlay_mode
	)
	hbox.add_child(mode_btn)
	_ref_overlay_mode_btn = mode_btn
	# Lock ref / lock game
	var lock := Button.new()
	lock.text = "🔒 ref" if reference_locked else "🔓 ref"
	lock.toggle_mode = true
	lock.button_pressed = reference_locked
	lock.pressed.connect(func():
		reference_locked = not reference_locked
		lock.text = "🔒 ref" if reference_locked else "🔓 ref"
	)
	hbox.add_child(lock)
	_ref_lock_btn = lock
	# Fit ref / Fit puzzle
	var fit_ref := Button.new()
	fit_ref.text = "Fit Ref"
	fit_ref.pressed.connect(func(): emit_signal("fit_reference_requested"))
	hbox.add_child(fit_ref)
	_fit_ref_btn = fit_ref
	var fit_puzzle := Button.new()
	fit_puzzle.text = "Fit Puzzle"
	fit_puzzle.pressed.connect(func(): emit_signal("fit_puzzle_requested"))
	hbox.add_child(fit_puzzle)
	_fit_puzzle_btn = fit_puzzle
	# Zoom + Pan
	hbox.add_child(_vsplit())
	hbox.add_child(_label("zoom"))
	var zoom := HSlider.new()
	zoom.min_value = 0.25
	zoom.max_value = 4.0
	zoom.step = 0.05
	zoom.value = reference_zoom
	zoom.custom_minimum_size = Vector2(120, 0)
	zoom.value_changed.connect(func(v: float):
		reference_zoom = v
		emit_signal("reference_zoom_changed", v)
	)
	hbox.add_child(zoom)
	_ref_zoom_slider = zoom
	hbox.add_child(_label("pan x"))
	var px := SpinBox.new()
	px.min_value = -1000.0
	px.max_value = 1000.0
	px.step = 1.0
	px.value = reference_pan.x
	px.size_flags_horizontal = 0
	px.custom_minimum_size = Vector2(80, 0)
	px.value_changed.connect(func(v: float):
		reference_pan.x = v
		emit_signal("reference_pan_changed", reference_pan)
	)
	hbox.add_child(px)
	_ref_pan_x_spin = px
	hbox.add_child(_label("pan y"))
	var py := SpinBox.new()
	py.min_value = -1000.0
	py.max_value = 1000.0
	py.step = 1.0
	py.value = reference_pan.y
	py.size_flags_horizontal = 0
	py.custom_minimum_size = Vector2(80, 0)
	py.value_changed.connect(func(v: float):
		reference_pan.y = v
		emit_signal("reference_pan_changed", reference_pan)
	)
	hbox.add_child(py)
	_ref_pan_y_spin = py
	return hbox

# ----- Row 6: TEST LEVEL (M22) -----

func _build_test_level_strip() -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	var btn := Button.new()
	btn.text = "TEST LEVEL"
	btn.tooltip_text = "Load the editor's current document into the runtime gameplay. Unsaved changes are preserved on return."
	btn.pressed.connect(func():
		emit_signal("test_level_pressed")
	)
	hbox.add_child(btn)
	_test_level_btn = btn
	var status := Label.new()
	status.text = "(editor active — Ctrl+S to save)"
	hbox.add_child(status)
	_test_level_status = status
	# Save button.
	var save_btn := Button.new()
	save_btn.text = "Save (Ctrl+S)"
	save_btn.pressed.connect(func():
		_save_document()
	)
	hbox.add_child(save_btn)
	return hbox

func _save_document() -> void:
	if document == null or document.level_id <= 0: return
	var path: String = "res://data/user_levels/%d.json" % document.level_id
	document.save_to_disk(path)
	if _test_level_status != null:
		_test_level_status.text = "Saved " + path

# ==============================================================================
# Color helpers
# ==============================================================================

func _color_to_hex(c: Color) -> String:
	return "#%02X%02X%02X" % [int(c.r * 255.0), int(c.g * 255.0), int(c.b * 255.0)]

func _hex_to_color(s: String) -> Color:
	s = s.strip_edges()
	if s.begins_with("#"): s = s.substr(1)
	if s.length() != 6: return Color.WHITE
	var r: int = ("0x" + s.substr(0, 2)).hex_to_int()
	var g: int = ("0x" + s.substr(2, 2)).hex_to_int()
	var b: int = ("0x" + s.substr(4, 2)).hex_to_int()
	return Color(r / 255.0, g / 255.0, b / 255.0, 1.0)