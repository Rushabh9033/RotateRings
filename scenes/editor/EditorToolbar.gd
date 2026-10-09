extends Control
class_name EditorToolbar

# ==============================================================================
# EditorToolbar — true slide-in side panel.
#
# Compact: 320px wide, sits on the right edge, hidden by default.
# The user clicks a small "> Editor" handle on the right edge to slide
# the panel in. Clicking the "×" close button (or pressing Escape)
# slides it back out. This keeps the puzzle area uncluttered while
# editing; the panel is there when you need it.
#
# Sections are tightly packed; each row is a single labeled control
# or a small two-button group. Section headers are tiny inline
# separators.
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
signal editor_panel_shown(shown: bool)

var document: Resource = null
var overlay: Control = null

var current_mode: int = 0

# Panel state.
const PANEL_WIDTH: float = 320.0
const HANDLE_WIDTH: float = 28.0
var _shown: bool = false
var _handle: Button = null
var _panel: PanelContainer = null
var _close_btn: Button = null

# Multi-piece selection.
var selected_pieces: Array = []

# UI node refs.
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
var _align_source_picker: OptionButton = null
var _align_edge_picker: OptionButton = null

var _recent_colors: Array = []

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
	# Slide-in panel: anchored to right edge of parent.
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 1.0
	# Build the handle + panel container. Inner content is built when
	# set_document is called (or lazily on first show).
	_handle = Button.new()
	_handle.text = "▶"
	_handle.tooltip_text = "Open editor panel"
	_handle.custom_minimum_size = Vector2(HANDLE_WIDTH, 80)
	_handle.pressed.connect(_toggle_panel)
	add_child(_handle)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(PANEL_WIDTH, 0)
	_panel.modulate = Color(1, 1, 1, 0.97)
	add_child(_panel)
	_apply_panel_state()
	_rebuild_panel()
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)

func _on_document_changed() -> void:
	_refresh_pickers()
	_refresh_align_pickers()
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
	if _panel != null:
		_rebuild_panel()
	_refresh_pickers()
	_refresh_align_pickers()

func set_overlay(o: Control) -> void:
	overlay = o
	if overlay != null and overlay.has_method("set_document"):
		overlay.set_document(document)
	if overlay != null and overlay.get("measure_mode"):
		current_mode = 4
		_refresh_mode_buttons()
	if overlay != null and overlay.has_signal("selection_changed"):
		if not overlay.selection_changed.is_connected(_on_overlay_selection_changed):
			overlay.selection_changed.connect(_on_overlay_selection_changed)
	if overlay != null and "_multi_select" in overlay:
		set_selected_pieces(overlay._multi_select)

func _on_overlay_selection_changed(ids: Array) -> void:
	set_selected_pieces(ids)

func set_selected_pieces(ids: Array) -> void:
	selected_pieces = ids.duplicate()
	_refresh_align_pickers()

func _apply_panel_state() -> void:
	# Handle is at the right edge, full height.
	if _handle != null:
		_handle.anchor_left = 1.0
		_handle.anchor_right = 1.0
		_handle.anchor_top = 0.0
		_handle.anchor_bottom = 1.0
		_handle.offset_left = -HANDLE_WIDTH
		_handle.offset_right = 0.0
		_handle.offset_top = 0.0
		_handle.offset_bottom = 0.0
	if _panel != null:
		# The panel sits at the right edge, full height. When hidden, it's
		# shifted off-screen to the right by PANEL_WIDTH. When shown, it
		# sits flush with the right edge minus HANDLE_WIDTH so the handle
		# is still visible just to the right.
		_panel.anchor_left = 1.0
		_panel.anchor_right = 1.0
		_panel.anchor_top = 0.0
		_panel.anchor_bottom = 1.0
		if _shown:
			_panel.offset_left = -PANEL_WIDTH - HANDLE_WIDTH
			_panel.offset_right = -HANDLE_WIDTH
		else:
			_panel.offset_left = PANEL_WIDTH
			_panel.offset_right = PANEL_WIDTH + PANEL_WIDTH
		_panel.offset_top = 0.0
		_panel.offset_bottom = 0.0
		_panel.visible = _shown

# ==============================================================================
# Build
# ==============================================================================

func _rebuild_panel() -> void:
	# The handle and panel container are created once in _ready. This
	# method only rebuilds the inner content.
	if _panel == null: return
	for c in _panel.get_children():
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
	_color_recent = []

	# Root vertical layout inside the panel.
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 0)
	_panel.add_child(root)

	# Header: title + close button.
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 4)
	var title := Label.new()
	title.text = "Editor"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(0.95, 0.7, 0.3, 1))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_close_btn = Button.new()
	_close_btn.text = "×"
	_close_btn.custom_minimum_size = Vector2(28, 24)
	_close_btn.pressed.connect(_hide_panel)
	header.add_child(_close_btn)
	root.add_child(header)

	# Scrollable body of the panel.
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.add_theme_constant_override("h_separation", 0)
	scroll.add_theme_constant_override("v_separation", 0)
	root.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	# Add the sections. Each is a single tight row.
	vbox.add_child(_make_section("Mode"))
	vbox.add_child(_build_mode_strip())
	vbox.add_child(_make_section("Snap & Grid"))
	vbox.add_child(_build_snap_strip())
	vbox.add_child(_make_section("Framing"))
	vbox.add_child(_build_framing_strip())
	vbox.add_child(_make_section("Color"))
	vbox.add_child(_build_color_strip())
	vbox.add_child(_make_section("Size Link"))
	vbox.add_child(_build_size_link_strip())
	vbox.add_child(_make_section("Align"))
	vbox.add_child(_build_align_strip())
	vbox.add_child(_make_section("Reference"))
	vbox.add_child(_build_reference_strip())
	vbox.add_child(_make_section("Test"))
	vbox.add_child(_build_test_level_strip())

func _make_section(title: String) -> Label:
	var l := Label.new()
	l.text = title
	l.add_theme_font_size_override("font_size", 10)
	l.add_theme_color_override("font_color", Color(0.85, 0.65, 0.45, 1))
	return l

# ==============================================================================
# Mode (M26)
# ==============================================================================

func _build_mode_strip() -> Control:
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 3)
	grid.add_theme_constant_override("v_separation", 3)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var modes: Array = [
		["SELECT", 0], ["PIECE", 1], ["GAP", 2],
		["CONNECTOR", 3], ["MEASURE", 4], ["REFERENCE", 5],
	]
	for m in modes:
		var btn := Button.new()
		btn.text = m[0]
		btn.toggle_mode = true
		btn.custom_minimum_size = Vector2(0, 26)
		btn.button_pressed = (int(m[1]) == current_mode)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.add_theme_font_size_override("font_size", 11)
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

# ==============================================================================
# Snap & grid (M9)
# ==============================================================================

func _build_snap_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	for prop in ["snap_to_grid", "snap_to_guides", "snap_to_piece_centers", "snap_to_edges", "snap_to_connector_points"]:
		var cb := CheckBox.new()
		cb.text = prop.replace("snap_to_", "").replace("_", " ")
		cb.button_pressed = (document.get(prop) if document != null else false)
		cb.add_theme_font_size_override("font_size", 11)
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.toggled.connect(func(pressed: bool, captured_prop: String = prop):
			if document != null:
				document.apply_edit(func():
					document.set(captured_prop, pressed)
				)
		)
		v.add_child(cb)
		_snap_toggles[prop] = cb
	# Grid size on one row.
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	var lbl := Label.new()
	lbl.text = "grid"
	lbl.custom_minimum_size = Vector2(40, 0)
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)
	var gs := SpinBox.new()
	gs.min_value = 1.0
	gs.max_value = 200.0
	gs.step = 1.0
	gs.value = (document.grid_size if document != null else 20.0)
	gs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gs.add_theme_font_size_override("font_size", 11)
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

# ==============================================================================
# Framing (M23)
# ==============================================================================

func _build_framing_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	v.add_child(_labeled_spin("scale", "frame_scale", 0.1, 4.0, 0.05, _on_frame_scale_changed))
	v.add_child(_labeled_spin("off x", "frame_offset_x", -1000.0, 1000.0, 1.0, _on_frame_off_x_changed))
	v.add_child(_labeled_spin("off y", "frame_offset_y", -1000.0, 1000.0, 1.0, _on_frame_off_y_changed))
	return v

func _labeled_spin(label: String, _doc_field: String, min_v: float, max_v: float, step: float, on_change: Callable) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(40, 0)
	l.add_theme_font_size_override("font_size", 11)
	hbox.add_child(l)
	var sb := SpinBox.new()
	sb.min_value = min_v
	sb.max_value = max_v
	sb.step = step
	if document != null:
		sb.value = float(document.get(_doc_field))
	sb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sb.add_theme_font_size_override("font_size", 11)
	sb.value_changed.connect(on_change)
	hbox.add_child(sb)
	match _doc_field:
		"frame_scale": _frame_scale_spin = sb
		"frame_offset_x": _frame_off_x_spin = sb
		"frame_offset_y": _frame_off_y_spin = sb
	return hbox

func _on_frame_scale_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_scale = v)
func _on_frame_off_x_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_offset_x = v)
func _on_frame_off_y_changed(v: float) -> void:
	if document != null:
		document.apply_edit(func(): document.frame_offset_y = v)

# ==============================================================================
# Color (M18)
# ==============================================================================

func _build_color_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	# Picker + hex on one row.
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 4)
	var cp := ColorPickerButton.new()
	cp.color = Color("#EA7829")
	cp.custom_minimum_size = Vector2(36, 26)
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
	hex.custom_minimum_size = Vector2(0, 26)
	hex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hex.add_theme_font_size_override("font_size", 11)
	hex.focus_exited.connect(func():
		var c: Color = _hex_to_color(hex.text)
		_color_picker.color = c
		_push_recent_color(c)
	)
	row1.add_child(hex)
	_color_hex_edit = hex
	v.add_child(row1)
	# Recent swatches: 8 in a single row.
	var grid := HBoxContainer.new()
	grid.add_theme_constant_override("separation", 2)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_color_recent = []
	for cc in _recent_colors:
		var sw := Button.new()
		sw.custom_minimum_size = Vector2(28, 22)
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
	row2.add_theme_constant_override("separation", 4)
	var copy := Button.new()
	copy.text = "Copy"
	copy.custom_minimum_size = Vector2(0, 24)
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_font_size_override("font_size", 11)
	copy.pressed.connect(func():
		if overlay != null and overlay.has_method("_color_clipboard"):
			overlay._color_clipboard = _color_picker.color
	)
	row2.add_child(copy)
	_color_copy_btn = copy
	var paste := Button.new()
	paste.text = "Paste"
	paste.custom_minimum_size = Vector2(0, 24)
	paste.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paste.add_theme_font_size_override("font_size", 11)
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

# ==============================================================================
# Size link (M15)
# ==============================================================================

func _build_size_link_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	v.add_child(_labeled_picker("master", "size_link_master"))
	var master := OptionButton.new()
	master.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	master.tooltip_text = "Master piece (size source)"
	master.add_theme_font_size_override("font_size", 11)
	v.add_child(master)
	_size_link_master_picker = master
	v.add_child(_labeled_picker("follower", "size_link_follower"))
	var follower := OptionButton.new()
	follower.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	follower.tooltip_text = "Follower piece (size target)"
	follower.add_theme_font_size_override("font_size", 11)
	v.add_child(follower)
	_size_link_follower_picker = follower
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	var link_btn := Button.new()
	link_btn.text = "Link"
	link_btn.custom_minimum_size = Vector2(0, 24)
	link_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	link_btn.add_theme_font_size_override("font_size", 11)
	link_btn.pressed.connect(_on_size_link_pressed)
	hbox.add_child(link_btn)
	_size_link_btn = link_btn
	var unlink_btn := Button.new()
	unlink_btn.text = "Unlink"
	unlink_btn.custom_minimum_size = Vector2(0, 24)
	unlink_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	unlink_btn.add_theme_font_size_override("font_size", 11)
	unlink_btn.pressed.connect(_on_size_unlink_pressed)
	hbox.add_child(unlink_btn)
	_size_unlink_btn = unlink_btn
	v.add_child(hbox)
	_refresh_pickers()
	return v

func _labeled_picker(label: String, _tag: String) -> Label:
	var l := Label.new()
	l.text = label
	l.add_theme_font_size_override("font_size", 10)
	return l

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

# ==============================================================================
# Align (Canva-style)
# ==============================================================================

func _build_align_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	# source picker
	var lbl_src := Label.new()
	lbl_src.text = "source"
	lbl_src.add_theme_font_size_override("font_size", 10)
	v.add_child(lbl_src)
	var src := OptionButton.new()
	src.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	src.tooltip_text = "Reference piece"
	src.add_theme_font_size_override("font_size", 11)
	v.add_child(src)
	_align_source_picker = src
	# align mode
	var lbl_mode := Label.new()
	lbl_mode.text = "edge"
	lbl_mode.add_theme_font_size_override("font_size", 10)
	v.add_child(lbl_mode)
	var edge_picker := OptionButton.new()
	edge_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edge_picker.add_item("left")
	edge_picker.set_item_metadata(0, "left")
	edge_picker.add_item("right")
	edge_picker.set_item_metadata(1, "right")
	edge_picker.add_item("center H")
	edge_picker.set_item_metadata(2, "center")
	edge_picker.add_item("top")
	edge_picker.set_item_metadata(3, "top")
	edge_picker.add_item("bottom")
	edge_picker.set_item_metadata(4, "bottom")
	edge_picker.add_item("middle V")
	edge_picker.set_item_metadata(5, "middle")
	edge_picker.add_theme_font_size_override("font_size", 11)
	v.add_child(edge_picker)
	_align_edge_picker = edge_picker
	# Apply
	var apply := Button.new()
	apply.text = "Apply Align"
	apply.custom_minimum_size = Vector2(0, 24)
	apply.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	apply.add_theme_font_size_override("font_size", 11)
	apply.pressed.connect(func():
		_apply_align_to_source(String(edge_picker.get_item_metadata(edge_picker.selected)) if edge_picker.selected >= 0 else "left")
	)
	v.add_child(apply)
	# Tidy row 1: Row / Column
	var tidy_lbl := Label.new()
	tidy_lbl.text = "tidy up"
	tidy_lbl.add_theme_font_size_override("font_size", 10)
	v.add_child(tidy_lbl)
	var tidy_row1 := HBoxContainer.new()
	tidy_row1.add_theme_constant_override("separation", 4)
	var b_row := _make_small_button("Row", func(): _tidy_align_in_row())
	tidy_row1.add_child(b_row)
	var b_col := _make_small_button("Column", func(): _tidy_align_in_column())
	tidy_row1.add_child(b_col)
	v.add_child(tidy_row1)
	# Tidy row 2: Equalize H / V
	var tidy_row2 := HBoxContainer.new()
	tidy_row2.add_theme_constant_override("separation", 4)
	var b_eh := _make_small_button("Eq. H", func(): _tidy_equalize_h())
	tidy_row2.add_child(b_eh)
	var b_ev := _make_small_button("Eq. V", func(): _tidy_equalize_v())
	tidy_row2.add_child(b_ev)
	v.add_child(tidy_row2)
	_refresh_align_pickers()
	return v

func _make_small_button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(0, 24)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 11)
	b.pressed.connect(callback)
	return b

func _tidy_align_in_row() -> void:
	if document != null: document.align_in_row(selected_pieces)
func _tidy_align_in_column() -> void:
	if document != null: document.align_in_column(selected_pieces)
func _tidy_equalize_h() -> void:
	if document != null: document.equalize_h_gaps(selected_pieces, -1.0)
func _tidy_equalize_v() -> void:
	if document != null: document.equalize_v_gaps(selected_pieces, -1.0)

func _apply_align_to_source(edge: String) -> void:
	if document == null: return
	if selected_pieces.size() < 2: return
	var src_idx: int = _align_source_picker.selected if _align_source_picker != null else -1
	if src_idx < 0: return
	var src_id: String = String(_align_source_picker.get_item_metadata(src_idx))
	var targets: Array = []
	for pid in selected_pieces:
		if String(pid) != src_id:
			targets.append(pid)
	if targets.is_empty(): return
	document.align_to_pieces(targets, src_id, edge)

func _refresh_align_pickers() -> void:
	if _align_source_picker == null: return
	_align_source_picker.clear()
	if document == null: return
	var src_list: Array = selected_pieces if not selected_pieces.is_empty() else []
	for p in document.pieces:
		var pid: String = String(p.get("id", ""))
		if not pid.is_empty() and not src_list.has(pid):
			src_list.append(pid)
	for pid in src_list:
		_align_source_picker.add_item(String(pid))
		_align_source_picker.set_item_metadata(_align_source_picker.item_count - 1, String(pid))

# ==============================================================================
# Reference (M13)
# ==============================================================================

func _build_reference_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 2)
	var vis := Button.new()
	vis.text = "Reference: ON" if reference_visible else "Reference: OFF"
	vis.toggle_mode = true
	vis.button_pressed = reference_visible
	vis.custom_minimum_size = Vector2(0, 24)
	vis.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vis.add_theme_font_size_override("font_size", 11)
	vis.pressed.connect(func():
		reference_visible = not reference_visible
		vis.text = "Reference: ON" if reference_visible else "Reference: OFF"
		emit_signal("reference_overlay_changed", reference_visible)
	)
	v.add_child(vis)
	_ref_visibility_btn = vis
	v.add_child(_labeled_slider_compact("opacity", reference_opacity, func(v): reference_opacity = v; emit_signal("reference_opacity_changed", v), 0.0, 1.0, 0.05))
	var mode_btn := Button.new()
	mode_btn.text = "mode: " + reference_overlay_mode
	mode_btn.custom_minimum_size = Vector2(0, 24)
	mode_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mode_btn.add_theme_font_size_override("font_size", 11)
	mode_btn.pressed.connect(func():
		var modes: Array = ["normal", "blend50", "difference", "edges"]
		var cur: int = modes.find(reference_overlay_mode)
		cur = (cur + 1) % modes.size()
		reference_overlay_mode = modes[cur]
		mode_btn.text = "mode: " + reference_overlay_mode
	)
	v.add_child(mode_btn)
	_ref_overlay_mode_btn = mode_btn
	var fit_row := HBoxContainer.new()
	fit_row.add_theme_constant_override("separation", 4)
	var fit_ref := _make_small_button("Fit Ref", func(): emit_signal("fit_reference_requested"))
	fit_row.add_child(fit_ref)
	_fit_ref_btn = fit_ref
	var fit_puzzle := _make_small_button("Fit Puzzle", func(): emit_signal("fit_puzzle_requested"))
	fit_row.add_child(fit_puzzle)
	_fit_puzzle_btn = fit_puzzle
	v.add_child(fit_row)
	v.add_child(_labeled_slider_compact("zoom", reference_zoom, func(v): reference_zoom = v; emit_signal("reference_zoom_changed", v), 0.25, 4.0, 0.05))
	# Pan x/y
	v.add_child(_labeled_spin("pan x", "pan_x", -1000.0, 1000.0, 1.0, _on_pan_x_changed))
	v.add_child(_labeled_spin("pan y", "pan_y", -1000.0, 1000.0, 1.0, _on_pan_y_changed))
	return v

func _on_pan_x_changed(v: float) -> void:
	reference_pan.x = v
	emit_signal("reference_pan_changed", reference_pan)
func _on_pan_y_changed(v: float) -> void:
	reference_pan.y = v
	emit_signal("reference_pan_changed", reference_pan)

func _labeled_slider_compact(label: String, init: float, on_change: Callable, min_v: float, max_v: float, step: float) -> Control:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	var l := Label.new()
	l.text = label
	l.custom_minimum_size = Vector2(50, 0)
	l.add_theme_font_size_override("font_size", 11)
	hbox.add_child(l)
	var sl := HSlider.new()
	sl.min_value = min_v
	sl.max_value = max_v
	sl.step = step
	sl.value = init
	sl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sl.custom_minimum_size = Vector2(0, 18)
	sl.value_changed.connect(on_change)
	hbox.add_child(sl)
	match label:
		"opacity": _ref_opacity_slider = sl
		"zoom": _ref_zoom_slider = sl
	return hbox

# ==============================================================================
# Test (M22)
# ==============================================================================

func _build_test_level_strip() -> Control:
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_theme_constant_override("separation", 4)
	var test_btn := Button.new()
	test_btn.text = "TEST LEVEL"
	test_btn.custom_minimum_size = Vector2(0, 28)
	test_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	test_btn.add_theme_font_size_override("font_size", 12)
	test_btn.pressed.connect(func(): emit_signal("test_level_pressed"))
	v.add_child(test_btn)
	_test_level_btn = test_btn
	var save_btn := Button.new()
	save_btn.text = "Save (Ctrl+S)"
	save_btn.custom_minimum_size = Vector2(0, 24)
	save_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	save_btn.add_theme_font_size_override("font_size", 11)
	save_btn.pressed.connect(func(): _save_document())
	v.add_child(save_btn)
	_save_btn = save_btn
	var status := Label.new()
	status.text = "(editor active)"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.add_theme_font_size_override("font_size", 10)
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
# Panel state
# ==============================================================================

func show_panel() -> void:
	_shown = true
	if _handle != null:
		_handle.text = "▶"
		_handle.tooltip_text = "Close editor panel"
	_apply_panel_state()
	emit_signal("editor_panel_shown", true)

func hide_panel() -> void:
	_shown = false
	if _handle != null:
		_handle.text = "▶"
		_handle.tooltip_text = "Open editor panel"
	_apply_panel_state()
	emit_signal("editor_panel_shown", false)

func _hide_panel() -> void:
	hide_panel()

func _toggle_panel() -> void:
	if _shown:
		hide_panel()
	else:
		show_panel()
		# Re-render the panel content so the inner content is fresh when
		# the user reopens.
		_rebuild_panel()

func is_panel_shown() -> bool:
	return _shown

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