extends Control
class_name EditorToolbar

# ==============================================================================
# EditorToolbar — right-side dock (M26 toolbar + all editor controls).
#
# Layout: a 380px wide vertical dock on the right edge of the screen with
# collapsible sections and large readable controls. Collapsible via the
# collapse/expand button at the top of the dock so the puzzle area gets
# full width when not editing.
#
# Sections (top-to-bottom):
#   1. Mode strip       (M26): SELECT / PIECE / GAP / CONNECTOR / MEASURE / REFERENCE
#   2. Snap             (M9): 5 toggles + grid size
#   3. Framing          (M23): scale + offset x/y
#   4. Color            (M18): picker + hex + recent + copy/paste
#   5. Size link        (M15): master / follower pickers + link/unlink
#   6. Reference overlay (M13): ON/OFF + opacity + mode + lock + fit + zoom + pan
#   7. TEST LEVEL       (M22): TEST LEVEL + Save + status
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

var document: Resource = null
var overlay: Control = null

# Mode (M26). 0=SELECT, 1=PIECE, 2=GAP, 3=CONNECTOR, 4=MEASURE, 5=REFERENCE.
var current_mode: int = 0

# Dock UI state.
var _collapsed: bool = false

func _set_collapsed(v: bool) -> void:
	_collapsed = v
	_apply_collapsed()
const DOCK_EXPANDED_WIDTH: float = 380.0
const DOCK_COLLAPSED_WIDTH: float = 44.0

# UI nodes we keep references to.
var _dock_root: PanelContainer = null
var _mode_buttons: Array = []
var _snap_toggles: Dictionary = {}
var _snap_spin: SpinBox = null
var _frame_scale_spin: SpinBox = null
var _frame_off_x_spin: SpinBox = null
var _frame_off_y_spin: SpinBox = null
var _ref_visibility_btn: Button = null
var _ref_opacity_slider: HSlider = null
var _ref_opacity_label: Label = null
var _ref_overlay_mode_btn: Button = null
var _ref_lock_btn: Button = null
var _ref_zoom_slider: HSlider = null
var _ref_zoom_label: Label = null
var _ref_pan_x_spin: SpinBox = null
var _ref_pan_y_spin: SpinBox = null
var _fit_ref_btn: Button = null
var _fit_puzzle_btn: Button = null
var _color_picker: ColorPickerButton = null
var _color_hex_edit: LineEdit = null
var _color_recent: Array = []
var _color_copy_btn: Button = null
var _color_paste_btn: Button = null
var _size_link_master_picker: OptionButton = null
var _size_link_follower_picker: OptionButton = null
var _size_link_btn: Button = null
var _size_unlink_btn: Button = null
var _test_level_btn: Button = null
var _save_btn: Button = null
var _test_level_status: Label = null
var _collapse_btn: Button = null
var _body: Control = null
var _section_collapsed: Dictionary = {}

# Recent colors.
var _recent_colors: Array = []

# Reference overlay state.
var reference_visible: bool = true
var reference_opacity: float = 0.5
var reference_overlay_mode: String = "normal"
var reference_locked: bool = false
var reference_zoom: float = 1.0
var reference_pan: Vector2 = Vector2.ZERO

# ==============================================================================
# Lifecycle
# ==============================================================================

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_PASS
	# Right-side dock: anchor_right=1, anchor_top=0, anchor_bottom=1.
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0
	# 380px wide dock on the right.
	offset_left = -DOCK_EXPANDED_WIDTH
	offset_right = 0.0
	offset_top = 0.0
	offset_bottom = 0.0
	_rebuild_ui()
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)

func _on_document_changed() -> void:
	_refresh_pickers()
	if _frame_scale_spin != null and document != null:
		_frame_scale_spin.value = document.frame_scale
		_frame_off_x_spin.value = document.frame_offset_x
		_frame_off_y_spin.value = document.frame_offset_y

func set_document(doc) -> void:
	if document == doc: return
	if document != null and document.document_changed.is_connected(_on_document_changed):
		document.document_changed.disconnect(_on_document_changed)
	document = doc
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)
	_rebuild_ui()
	_refresh_pickers()
	if _frame_scale_spin != null and doc != null:
		_frame_scale_spin.value = doc.frame_scale
		_frame_off_x_spin.value = doc.frame_offset_x
		_frame_off_y_spin.value = doc.frame_offset_y

func set_overlay(o: Control) -> void:
	overlay = o
	if overlay != null and overlay.has_method("set_document"):
		overlay.set_document(document)
	if overlay != null and overlay.get("measure_mode"):
		current_mode = 4
		_refresh_mode_buttons()

func _apply_collapsed() -> void:
	if _dock_root == null: return
	if _collapsed:
		offset_left = -DOCK_COLLAPSED_WIDTH
		_body.visible = false
		_collapse_btn.text = ">"
	else:
		offset_left = -DOCK_EXPANDED_WIDTH
		_body.visible = true
		_collapse_btn.text = "<"

# ==============================================================================
# UI build
# ==============================================================================

func _rebuild_ui() -> void:
	for c in get_children():
		c.queue_free()
	_mode_buttons.clear()
	_snap_toggles.clear()
	_recent_colors = []
	_recent_colors.append(Color("#EA7829"))
	_recent_colors.append(Color("#32ADDA"))
	_recent_colors.append(Color("#7B61FF"))
	_recent_colors.append(Color("#E63946"))
	_recent_colors.append(Color("#3EC6B0"))
	_recent_colors.append(Color("#1F5A82"))
	_recent_colors.append(Color("#F4C95D"))
	_recent_colors.append(Color("#F2A6B5"))

	# Outer HBox: [body | collapse button]. Body holds the section list;
	# collapse button sits on the left edge of the dock so the user can
	# expand it back even when collapsed.
	var outer := HBoxContainer.new()
	outer.anchor_right = 1.0
	outer.anchor_bottom = 1.0
	outer.add_theme_constant_override("separation", 0)
	outer.mouse_filter = Control.MOUSE_FILTER_PASS
	add_child(outer)

	_body = Control.new()
	_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.mouse_filter = Control.MOUSE_FILTER_PASS
	outer.add_child(_body)

	_dock_root = PanelContainer.new()
	_dock_root.anchor_right = 1.0
	_dock_root.anchor_bottom = 1.0
	_dock_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dock_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_dock_root.modulate = Color(1, 1, 1, 0.96)
	_body.add_child(_dock_root)

	# Collapse button on the very left of the dock.
	_collapse_btn = Button.new()
	_collapse_btn.text = "<"
	_collapse_btn.custom_minimum_size = Vector2(28, 32)
	_collapse_btn.pressed.connect(func(): _set_collapsed(not _collapsed))
	outer.add_child(_collapse_btn)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_dock_root.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 8)
	scroll.add_child(vbox)

	# Section title helper.
	vbox.add_child(_build_section_title("Editor Toolbar"))

	vbox.add_child(_build_mode_strip())
	vbox.add_child(_build_section_title("Snap & Grid"))
	vbox.add_child(_build_snap_strip())
	vbox.add_child(_build_section_title("Framing"))
	vbox.add_child(_build_framing_strip())
	vbox.add_child(_build_section_title("Color"))
	vbox.add_child(_build_color_strip())
	vbox.add_child(_build_section_title("Size Link"))
	vbox.add_child(_build_size_link_strip())
	vbox.add_child(_build_section_title("Reference Overlay"))
	vbox.add_child(_build_reference_strip())
	vbox.add_child(_build_section_title("TEST LEVEL"))
	vbox.add_child(_build_test_level_strip())

	# Apply the current collapsed state.
	_apply_collapsed()

func _build_section_title(title: String) -> Label:
	var l := Label.new()
	l.text = title.to_upper()
	l.add_theme_font_size_override("font_size", 12)
	l.add_theme_color_override("font_color", Color(0.95, 0.7, 0.3, 1))
	return l

# ----- Row 1: mode strip (M26) -----

func _build_mode_strip() -> Control:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
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
		btn.custom_minimum_size = Vector2(0, 36)
		btn.button_pressed = (int(m[1]) == current_mode)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var captured_mode: int = int(m[1])
		btn.pressed.connect(func(): _on_mode_button(captured_mode))
		grid.add_child(btn)
		_mode_buttons.append(btn)
	return grid

func _on_mode_button(mode: int) -> void:
	current_mode = mode
	_refresh_mode_buttons()
	if overlay != null:
		if mode == 4:
			overlay.measure_mode = true
		else:
			overlay.measure_mode = false
		if mode == 5:
			emit_signal("reference_overlay_changed", true)
		else:
			emit_signal("reference_overlay_changed", false)

func _refresh_mode_buttons() -> void:
	for i in range(_mode_buttons.size()):
		_mode_buttons[i].button_pressed = (i == current_mode)

# ----- Row 2: snap / grid (M9) -----

func _build_snap_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	for prop in ["snap_to_grid", "snap_to_guides", "snap_to_piece_centers", "snap_to_edges", "snap_to_connector_points"]:
		var cb := CheckBox.new()
		cb.text = prop.replace("snap_to_", "snap to ").replace("_", " ")
		cb.button_pressed = (document.get(prop) if document != null else false)
		cb.add_theme_font_size_override("font_size", 14)
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.toggled.connect(func(pressed: bool, captured_prop: String = prop):
			if document != null:
				document.apply_edit(func():
					document.set(captured_prop, pressed)
				)
		)
		v.add_child(cb)
		_snap_toggles[prop] = cb
	# Grid size.
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	var lbl := Label.new()
	lbl.text = "grid"
	lbl.custom_minimum_size = Vector2(60, 0)
	hbox.add_child(lbl)
	var gs := SpinBox.new()
	gs.min_value = 1.0
	gs.max_value = 200.0
	gs.step = 1.0
	gs.value = (document.grid_size if document != null else 20.0)
	gs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gs.value_changed.connect(func(v: float):
		if document != null:
			document.apply_edit(func():
				document.grid_size = v
			)
	)
	hbox.add_child(gs)
	_snap_spin = gs
	v.add_child(hbox)
	return v

# ----- Row 3: framing (M23) -----

func _build_framing_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	v.add_child(_labeled_spin("scale", "frame_scale", _frame_scale_spin, 0.1, 4.0, 0.05, _on_frame_scale_changed))
	v.add_child(_labeled_spin("off x", "frame_offset_x", _frame_off_x_spin, -1000.0, 1000.0, 1.0, _on_frame_off_x_changed))
	v.add_child(_labeled_spin("off y", "frame_offset_y", _frame_off_y_spin, -1000.0, 1000.0, 1.0, _on_frame_off_y_changed))
	return v

func _labeled_spin(label: String, _doc_field: String, _existing: SpinBox, min_v: float, max_v: float, step: float, on_change: Callable) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(60, 0)
	hbox.add_child(l)
	var sb := SpinBox.new()
	sb.min_value = min_v
	sb.max_value = max_v
	sb.step = step
	if document != null:
		sb.value = float(document.get(label_to_field(label)))
	sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb.value_changed.connect(on_change)
	hbox.add_child(sb)
	match label:
		"scale": _frame_scale_spin = sb
		"off x": _frame_off_x_spin = sb
		"off y": _frame_off_y_spin = sb
	return hbox

func label_to_field(label: String) -> String:
	match label:
		"scale": return "frame_scale"
		"off x": return "frame_offset_x"
		"off y": return "frame_offset_y"
	return label

func _on_frame_scale_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_scale = v)
func _on_frame_off_x_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_offset_x = v)
func _on_frame_off_y_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_offset_y = v)

# ----- Row 4: color picker (M18) -----

func _build_color_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	# Picker + hex on one row.
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 6)
	var cp := ColorPickerButton.new()
	cp.color = Color("#EA7829")
	cp.custom_minimum_size = Vector2(48, 32)
	cp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cp.color_changed.connect(func(c: Color):
		if _color_hex_edit != null:
			_color_hex_edit.text = _color_to_hex(c)
		_push_recent_color(c)
	)
	row1.add_child(cp)
	_color_picker = cp
	var hex := LineEdit.new()
	hex.text = _color_to_hex(Color("#EA7829"))
	hex.placeholder_text = "#RRGGBB"
	hex.custom_minimum_size = Vector2(0, 32)
	hex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hex.add_theme_font_size_override("font_size", 14)
	hex.focus_exited.connect(func():
		var c: Color = _hex_to_color(hex.text)
		_color_picker.color = c
		_push_recent_color(c)
	)
	row1.add_child(hex)
	_color_hex_edit = hex
	v.add_child(row1)
	# Recent swatches grid (4x2).
	var grid := GridContainer.new()
	grid.columns = 8
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_color_recent = []
	for cc in _recent_colors:
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(32, 32)
		sw.modulate = cc
		sw.tooltip_text = _color_to_hex(cc)
		var captured: Color = cc
		sw.pressed.connect(func():
			_color_picker.color = captured
			_color_hex_edit.text = _color_to_hex(captured)
		)
		grid.add_child(sw)
		_color_recent.append(sw)
	v.add_child(grid)
	# Copy / paste row.
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 6)
	var copy := Button.new()
	copy.text = "Copy"
	copy.custom_minimum_size = Vector2(0, 32)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.pressed.connect(func():
		if overlay != null and overlay.has_method("_color_clipboard"):
			overlay._color_clipboard = _color_picker.color
	)
	row2.add_child(copy)
	_color_copy_btn = copy
	var paste := Button.new()
	paste.text = "Paste"
	paste.custom_minimum_size = Vector2(0, 32)
	paste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paste.pressed.connect(func():
		if overlay != null and overlay.has_method("_color_clipboard"):
			var c: Color = overlay._color_clipboard
			_color_picker.color = c
			_color_hex_edit.text = _color_to_hex(c)
	)
	row2.add_child(paste)
	_color_paste_btn = paste
	v.add_child(row2)
	return v

func _push_recent_color(c: Color) -> void:
	var hex: String = _color_to_hex(c)
	for i in range(_recent_colors.size()):
		if _color_to_hex(_recent_colors[i]) == hex:
			_recent_colors.remove_at(i)
			break
	_recent_colors.push_front(c)
	if _recent_colors.size() > 8:
		_recent_colors.resize(8)
	for i in range(min(_recent_colors.size(), _color_recent.size())):
		_color_recent[i].modulate = _recent_colors[i]
		_color_recent[i].tooltip_text = _color_to_hex(_recent_colors[i])

# ----- Row 4: size link (M15) -----

func _build_size_link_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	# Master picker.
	var lbl1 := Label.new()
	lbl1.text = "master"
	v.add_child(lbl1)
	var master := OptionButton.new()
	master.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master.tooltip_text = "Master piece (size source)"
	v.add_child(master)
	_size_link_master_picker = master
	# Follower picker.
	var lbl2 := Label.new()
	lbl2.text = "follower"
	v.add_child(lbl2)
	var follower := OptionButton.new()
	follower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	follower.tooltip_text = "Follower piece (size target)"
	v.add_child(follower)
	_size_link_follower_picker = follower
	# Buttons.
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	var link_btn := Button.new()
	link_btn.text = "Link"
	link_btn.custom_minimum_size = Vector2(0, 32)
	link_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link_btn.pressed.connect(_on_size_link_pressed)
	hbox.add_child(link_btn)
	_size_link_btn = link_btn
	var unlink_btn := Button.new()
	unlink_btn.text = "Unlink"
	unlink_btn.custom_minimum_size = Vector2(0, 32)
	unlink_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	unlink_btn.pressed.connect(_on_size_unlink_pressed)
	hbox.add_child(unlink_btn)
	_size_unlink_btn = unlink_btn
	v.add_child(hbox)
	_refresh_pickers()
	return v

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
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	# ON/OFF
	var vis := Button.new()
	vis.text = "Reference: ON" if reference_visible else "Reference: OFF"
	vis.toggle_mode = true
	vis.button_pressed = reference_visible
	vis.custom_minimum_size = Vector2(0, 32)
	vis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vis.pressed.connect(func():
		reference_visible = not reference_visible
		vis.text = "Reference: ON" if reference_visible else "Reference: OFF"
		emit_signal("reference_overlay_changed", reference_visible)
	)
	v.add_child(vis)
	_ref_visibility_btn = vis
	# Opacity
	v.add_child(_labeled_slider("opacity", "0 to 1", reference_opacity, func(v): reference_opacity = v; emit_signal("reference_opacity_changed", v), 0.0, 1.0, 0.05))
	# Mode cycle
	var mode_btn := Button.new()
	mode_btn.text = "mode: %s" % reference_overlay_mode
	mode_btn.custom_minimum_size = Vector2(0, 32)
	mode_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_btn.pressed.connect(func():
		var modes: Array = ["normal", "blend50", "difference", "edges"]
		var cur: int = modes.find(reference_overlay_mode)
		cur = (cur + 1) % modes.size()
		reference_overlay_mode = modes[cur]
		mode_btn.text = "mode: %s" % reference_overlay_mode
	)
	v.add_child(mode_btn)
	_ref_overlay_mode_btn = mode_btn
	# Lock
	var lock := Button.new()
	lock.text = "lock ref" if reference_locked else "unlock ref"
	lock.toggle_mode = true
	lock.button_pressed = reference_locked
	lock.custom_minimum_size = Vector2(0, 32)
	lock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lock.pressed.connect(func():
		reference_locked = not reference_locked
		lock.text = "lock ref" if reference_locked else "unlock ref"
	)
	v.add_child(lock)
	_ref_lock_btn = lock
	# Fit row
	var fit_row := HBoxContainer.new()
	fit_row.add_theme_constant_override("separation", 6)
	var fit_ref := Button.new()
	fit_ref.text = "Fit Ref"
	fit_ref.custom_minimum_size = Vector2(0, 32)
	fit_ref.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fit_ref.pressed.connect(func(): emit_signal("fit_reference_requested"))
	fit_row.add_child(fit_ref)
	_fit_ref_btn = fit_ref
	var fit_puzzle := Button.new()
	fit_puzzle.text = "Fit Puzzle"
	fit_puzzle.custom_minimum_size = Vector2(0, 32)
	fit_puzzle.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fit_puzzle.pressed.connect(func(): emit_signal("fit_puzzle_requested"))
	fit_row.add_child(fit_puzzle)
	_fit_puzzle_btn = fit_puzzle
	v.add_child(fit_row)
	# Zoom + Pan
	v.add_child(_labeled_slider("zoom", "0.25 to 4", reference_zoom, func(v): reference_zoom = v; emit_signal("reference_zoom_changed", v), 0.25, 4.0, 0.05))
	# Pan x / y
	var pan_row1 := HBoxContainer.new()
	pan_row1.add_theme_constant_override("separation", 6)
	var pxl := Label.new()
	pxl.text = "pan x"
	pxl.custom_minimum_size = Vector2(60, 0)
	pan_row1.add_child(pxl)
	var px := SpinBox.new()
	px.min_value = -1000.0
	px.max_value = 1000.0
	px.step = 1.0
	px.value = reference_pan.x
	px.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	px.value_changed.connect(func(v: float):
		reference_pan.x = v
		emit_signal("reference_pan_changed", reference_pan)
	)
	pan_row1.add_child(px)
	_ref_pan_x_spin = px
	v.add_child(pan_row1)
	var pan_row2 := HBoxContainer.new()
	pan_row2.add_theme_constant_override("separation", 6)
	var pyl := Label.new()
	pyl.text = "pan y"
	pyl.custom_minimum_size = Vector2(60, 0)
	pan_row2.add_child(pyl)
	var py := SpinBox.new()
	py.min_value = -1000.0
	py.max_value = 1000.0
	py.step = 1.0
	py.value = reference_pan.y
	py.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	py.value_changed.connect(func(v: float):
		reference_pan.y = v
		emit_signal("reference_pan_changed", reference_pan)
	)
	pan_row2.add_child(py)
	_ref_pan_y_spin = py
	v.add_child(pan_row2)
	return v

func _labeled_slider(label: String, range_label: String, init: float, on_change: Callable, min_v: float, max_v: float, step: float) -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 0)
	var lbl_row := HBoxContainer.new()
	var lbl := Label.new()
	lbl.text = label
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl_row.add_child(lbl)
	var val_lbl := Label.new()
	val_lbl.text = str(init)
	val_lbl.custom_minimum_size = Vector2(50, 0)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_row.add_child(val_lbl)
	v.add_child(lbl_row)
	var sl := HSlider.new()
	sl.min_value = min_v
	sl.max_value = max_v
	sl.step = step
	sl.value = init
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.custom_minimum_size = Vector2(0, 28)
	sl.value_changed.connect(func(v: float):
		val_lbl.text = str(v)
		on_change.call(v)
	)
	v.add_child(sl)
	# Store references for the two that the test reads.
	match label:
		"opacity": _ref_opacity_slider = sl; _ref_opacity_label = val_lbl
		"zoom":    _ref_zoom_slider = sl;    _ref_zoom_label = val_lbl
	return v

# ----- Row 6: TEST LEVEL (M22) -----

func _build_test_level_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 6)
	var test_btn := Button.new()
	test_btn.text = "TEST LEVEL"
	test_btn.custom_minimum_size = Vector2(0, 40)
	test_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test_btn.tooltip_text = "Load the editor's current document into the runtime gameplay. Unsaved changes are preserved on return."
	test_btn.pressed.connect(func(): emit_signal("test_level_pressed"))
	v.add_child(test_btn)
	_test_level_btn = test_btn
	var save_btn := Button.new()
	save_btn.text = "Save (Ctrl+S)"
	save_btn.custom_minimum_size = Vector2(0, 32)
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.pressed.connect(func(): _save_document())
	v.add_child(save_btn)
	_save_btn = save_btn
	var status := Label.new()
	status.text = "(editor active)"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(status)
	_test_level_status = status
	return v

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