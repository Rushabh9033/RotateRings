extends Control
class_name Inspector

# ==============================================================================
# Inspector — right-side panel showing every editable property of the current
# selection (piece or link) with live numeric input, color picker, and
# collapsible section headers.
#
# Sections 5 + 13 of the precision-editor mandate. Built as a code-driven
# Control so it can be mounted under any host (in-game overlay or standalone
# editor) without scene-tree plumbing. All mutations route through
# LevelDocument.apply_edit() so undo/redo is automatic.
# ==============================================================================

const LevelDocumentScript = preload("res://data/level_document.gd")
const PIECE_SECTIONS := ["Identity", "Position", "Size", "Rotation", "Gaps", "Motion", "Visual", "Z-order", "Locks"]
const LINK_SECTIONS := ["Identity", "Endpoints", "Cuff", "Stem", "Visual", "Tolerance", "Detach", "Locks"]

# Reference to the document we're editing. Set by the host via set_document().
var document: Resource = null

# Currently selected piece id (or link id). Exactly one of _selected_piece_id
# or _selected_link_id is set at a time.
var _selected_piece_id: String = ""
var _selected_link_id: String = ""

# When true, refresh() is silent (no re-render of inputs to avoid mid-edit
# cursor jumps). When the document changes, we set this and re-render.
var _suppress: bool = false

# Section collapsed state. Section name -> bool (true = collapsed).
var _section_collapsed: Dictionary = {}

# Pending color picker (color picker is implemented as a ColorPickerButton
# inside the Visual section).
var _color_picker: ColorPickerButton = null

signal piece_property_changed(piece_id: String, field: String, value: Variant)
signal link_property_changed(link_id: String, field: String, value: Variant)

# ==============================================================================
# Lifecycle
# ==============================================================================

func _ready() -> void:
	# Layout: fills its parent. Children are laid out via _layout().
	anchor_right = 1.0
	anchor_bottom = 1.0
	mouse_filter = Control.MOUSE_FILTER_PASS
	_rebuild_ui()

func _on_document_changed() -> void:
	# Re-render only if the current selection is affected. Cheap to always
	# rebuild for now.
	_rebuild_ui()

func set_document(doc) -> void:
	if document == doc: return
	if document != null and document.document_changed.is_connected(_on_document_changed):
		document.document_changed.disconnect(_on_document_changed)
	document = doc
	if document != null and not document.document_changed.is_connected(_on_document_changed):
		document.document_changed.connect(_on_document_changed)
	_rebuild_ui()

# Public selection API used by the host (overlay / editor screen).
func select_piece(piece_id: String) -> void:
	_selected_piece_id = piece_id
	_selected_link_id = ""
	_rebuild_ui()

func select_link(link_id: String) -> void:
	_selected_piece_id = ""
	_selected_link_id = link_id
	_rebuild_ui()

func clear_selection() -> void:
	_selected_piece_id = ""
	_selected_link_id = ""
	_rebuild_ui()

# ==============================================================================
# UI build
# ==============================================================================

func _rebuild_ui() -> void:
	# Tear down existing children.
	for c in get_children():
		c.queue_free()
	if document == null: return

	var panel := PanelContainer.new()
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	add_child(panel)
	# Default panel styling is set by the host's theme; we just provide the
	# container.

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	if not _selected_piece_id.is_empty():
		var piece_dict: Dictionary = document.find_piece(_selected_piece_id)
		if not piece_dict.is_empty():
			_build_piece_inspector(vbox, _selected_piece_id, piece_dict)
		else:
			var lbl := Label.new()
			lbl.text = "(no piece selected)"
			vbox.add_child(lbl)
	elif not _selected_link_id.is_empty():
		var link_dict: Dictionary = document.find_link(_selected_link_id)
		if not link_dict.is_empty():
			_build_link_inspector(vbox, _selected_link_id, link_dict)
		else:
			var lbl := Label.new()
			lbl.text = "(no link selected)"
			vbox.add_child(lbl)
	else:
		_build_document_inspector(vbox)

# ---- piece ----

func _build_piece_inspector(vbox: VBoxContainer, piece_id: String, p: Dictionary) -> void:
	# Header (id + shape).
	var header := HBoxContainer.new()
	vbox.add_child(header)
	var id_lbl := Label.new()
	id_lbl.text = "Piece: %s" % piece_id
	id_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(id_lbl)
	var shape_lbl := Label.new()
	shape_lbl.text = "  " + _shape_name(p)
	header.add_child(shape_lbl)

	# Sections.
	_add_section_header(vbox, "Identity")
	_add_text_field(vbox, "id", piece_id, "id", "piece", true)  # readonly
	_add_text_field(vbox, "title", String(p.get("title", "")), "title", "piece", false)
	_add_text_field(vbox, "piece_type", _piece_type_name(p), "piece_type", "piece", true)
	_add_text_field(vbox, "role", _piece_role_name(p), "role", "piece", true)

	_add_section_header(vbox, "Position")
	_add_num_field(vbox, "x", float(p.get("x", 0.0)), "x", "piece")
	_add_num_field(vbox, "y", float(p.get("y", 0.0)), "y", "piece")

	_add_section_header(vbox, "Size")
	_add_num_field(vbox, "radius", float(p.get("radius", 60.0)), "radius", "piece")
	_add_num_field(vbox, "radius_y", float(p.get("radius_y", 60.0)), "radius_y", "piece")
	_add_num_field(vbox, "thickness", float(p.get("thickness", 22.0)), "thickness", "piece")
	_add_num_field(vbox, "corner_radius", float(p.get("corner_radius", 8.0)), "corner_radius", "piece")
	_add_num_field(vbox, "length", float(p.get("length", 100.0)), "length", "piece")
	_add_num_field(vbox, "length_b", float(p.get("length_b", 60.0)), "length_b", "piece")
	_add_num_field(vbox, "width", float(p.get("width", 24.0)), "width", "piece")
	_add_num_field(vbox, "height", float(p.get("height", 60.0)), "height", "piece")

	_add_section_header(vbox, "Rotation")
	_add_num_field(vbox, "start_angle_deg", float(p.get("start_angle_deg", 0.0)), "start_angle_deg", "piece")

	_add_section_header(vbox, "Gaps")
	# Gap editing uses a small "Gaps" sub-list. We show count + button to add.
	var gaps_v: Array = p.get("gaps", [])
	var gaps_lbl := Label.new()
	gaps_lbl.text = "  %d gap(s)" % gaps_v.size()
	vbox.add_child(gaps_lbl)
	for i in range(gaps_v.size()):
		var g: Dictionary = gaps_v[i]
		_add_gap_row(vbox, piece_id, i, g)

	_add_section_header(vbox, "Motion")
	# motion_model is an int (0=ROTATE, 1=SLIDE_AXIS_BIDIRECTIONAL, ...).
	# Use a num field; the user can edit the integer directly.
	_add_num_field(vbox, "motion_model", float(int(p.get("motion_model", 0))), "motion_model", "piece")
	_add_num_field(vbox, "slide_min", float(p.get("slide_min", 0.0)), "slide_min", "piece")
	_add_num_field(vbox, "slide_max", float(p.get("slide_max", 0.0)), "slide_max", "piece")
	_add_num_field(vbox, "target_exit_angle_deg", float(p.get("target_exit_angle_deg", 0.0)), "target_exit_angle_deg", "piece")

	_add_section_header(vbox, "Visual")
	_add_color_field(vbox, "color", _color_from_piece(p), piece_id, "color")

	_add_section_header(vbox, "Z-order")
	_add_num_field(vbox, "z_index", int(p.get("z_index", 1)), "z_index", "piece")

	_add_section_header(vbox, "Locks")
	_build_locks_section(vbox, piece_id, "piece")

# ---- link ----

func _build_link_inspector(vbox: VBoxContainer, link_id: String, l: Dictionary) -> void:
	var header := HBoxContainer.new()
	vbox.add_child(header)
	var id_lbl := Label.new()
	id_lbl.text = "Link: %s" % link_id
	id_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(id_lbl)

	_add_section_header(vbox, "Identity")
	_add_text_field(vbox, "id", link_id, "id", "link", true)
	_add_text_field(vbox, "from_id", String(l.get("from_id", "")), "from_id", "link", true)
	_add_text_field(vbox, "to_id", String(l.get("to_id", "")), "to_id", "link", true)

	_add_section_header(vbox, "Endpoints")
	_add_num_field(vbox, "collar_angle_deg", float(l.get("collar_angle_deg", 0.0)), "collar_angle_deg", "link")
	_add_text_field(vbox, "cuff_center_local", _vec2_str(l.get("cuff_center_local", {"x": 0.0, "y": 0.0})), "cuff_center_local", "link", false)
	_add_num_field(vbox, "cuff_orientation_deg", float(l.get("cuff_orientation_deg", 0.0)), "cuff_orientation_deg", "link")
	_add_num_field(vbox, "cuff_width", float(l.get("cuff_width", 32.0)), "cuff_width", "link")
	_add_num_field(vbox, "cuff_depth", float(l.get("cuff_depth", 18.0)), "cuff_depth", "link")
	_add_num_field(vbox, "cuff_round_radius", float(l.get("cuff_round_radius", 5.0)), "cuff_round_radius", "link")

	_add_section_header(vbox, "Stem")
	_add_num_field(vbox, "stem_length", float(l.get("stem_length", 200.0)), "stem_length", "link")
	_add_num_field(vbox, "stem_width", float(l.get("stem_width", 6.0)), "stem_width", "link")
	_add_num_field(vbox, "stem_distance_from_piece", float(l.get("stem_distance_from_piece", 0.0)), "stem_distance_from_piece", "link")

	_add_section_header(vbox, "Visual")
	_add_color_field(vbox, "joint_color", _color_from_link(l), link_id, "joint_color")

	_add_section_header(vbox, "Tolerance")
	_add_num_field(vbox, "clearance_tolerance_deg", float(l.get("clearance_tolerance_deg", 16.0)), "clearance_tolerance_deg", "link")

	_add_section_header(vbox, "Detach")
	var det_lbl := Label.new()
	det_lbl.text = "  is_detached: " + str(bool(l.get("is_detached", false)))
	vbox.add_child(det_lbl)

	_add_section_header(vbox, "Locks")
	_build_locks_section(vbox, link_id, "link")

# ---- document (no selection) ----

func _build_document_inspector(vbox: VBoxContainer) -> void:
	var header := Label.new()
	header.text = "LevelDocument (no selection)"
	vbox.add_child(header)
	# Show count summary + framing controls.
	var summary := Label.new()
	summary.text = "  pieces: %d\n  links: %d\n  guides: %d\n  dirty: %s" % [
		document.pieces.size(), document.links.size(), document.guides.size(),
		str(document.is_dirty),
	]
	vbox.add_child(summary)

	_add_section_header(vbox, "Framing")
	_add_num_field(vbox, "frame_scale", document.frame_scale, "frame_scale", "doc")
	_add_num_field(vbox, "frame_offset_x", document.frame_offset_x, "frame_offset_x", "doc")
	_add_num_field(vbox, "frame_offset_y", document.frame_offset_y, "frame_offset_y", "doc")
	_add_text_field(vbox, "frame_anchor", String(document.frame_anchor), "frame_anchor", "doc", false)

	_add_section_header(vbox, "Snap")
	_add_checkbox(vbox, "snap_to_grid", document.snap_to_grid, "snap_to_grid", "doc")
	_add_checkbox(vbox, "snap_to_piece_centers", document.snap_to_piece_centers, "snap_to_piece_centers", "doc")
	_add_checkbox(vbox, "snap_to_edges", document.snap_to_edges, "snap_to_edges", "doc")
	_add_checkbox(vbox, "snap_to_guides", document.snap_to_guides, "snap_to_guides", "doc")
	_add_checkbox(vbox, "snap_to_connector_points", document.snap_to_connector_points, "snap_to_connector_points", "doc")
	_add_num_field(vbox, "grid_size", document.grid_size, "grid_size", "doc")

	_add_section_header(vbox, "Nudge")
	_add_num_field(vbox, "nudge_step", document.nudge_step, "nudge_step", "doc")
	_add_num_field(vbox, "nudge_shift_multiplier", document.nudge_shift_multiplier, "nudge_shift_multiplier", "doc")
	_add_num_field(vbox, "nudge_alt_multiplier", document.nudge_alt_multiplier, "nudge_alt_multiplier", "doc")

# ==============================================================================
# Section + field builders
# ==============================================================================

func _add_section_header(vbox: VBoxContainer, name: String) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var lbl := Button.new()
	lbl.text = "▼ " + name if not _section_collapsed.get(name, false) else "▶ " + name
	lbl.toggle_mode = true
	lbl.button_pressed = not _section_collapsed.get(name, false)
	lbl.pressed.connect(func(): _toggle_section(name))
	hbox.add_child(lbl)
	var sep := HSeparator.new()
	sep.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(sep)

func _toggle_section(name: String) -> void:
	_section_collapsed[name] = not _section_collapsed.get(name, false)
	_rebuild_ui()

# Numeric field with label on the left and an editable line-edit on the right.
# On focus_exited, commits the value through document.apply_edit().
func _add_num_field(vbox: VBoxContainer, label: String, value: float, field: String, target: String) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var lbl := Label.new()
	lbl.text = "  " + label
	lbl.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(lbl)
	var edit := LineEdit.new()
	edit.text = _fmt_num(value)
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.placeholder_text = "0"
	var captured_field := field
	var captured_target := target
	var captured_value := value
	edit.focus_exited.connect(func():
		var new_val: float = float(edit.text)
		_commit_field(captured_target, captured_field, new_val, captured_value)
	)
	hbox.add_child(edit)

# String field (text).
func _add_text_field(vbox: VBoxContainer, label: String, value: String, field: String, target: String, read_only: bool) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var lbl := Label.new()
	lbl.text = "  " + label
	lbl.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(lbl)
	var edit := LineEdit.new()
	edit.text = value
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	edit.editable = not read_only
	if read_only:
		edit.modulate = Color(0.7, 0.7, 0.7, 1.0)
	if not read_only:
		var captured_field := field
		var captured_target := target
		edit.focus_exited.connect(func():
			_commit_field(captured_target, captured_field, edit.text, value)
		)
	hbox.add_child(edit)

func _add_checkbox(vbox: VBoxContainer, label: String, value: bool, field: String, target: String) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var cb := CheckBox.new()
	cb.text = label
	cb.button_pressed = value
	var captured_field := field
	var captured_target := target
	cb.toggled.connect(func(pressed: bool):
		_commit_field(captured_target, captured_field, pressed, value)
	)
	hbox.add_child(cb)

# Color field: a small swatch button + hex line-edit + copy/paste.
func _add_color_field(vbox: VBoxContainer, label: String, color: Color, target_id: String, field: String) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var lbl := Label.new()
	lbl.text = "  " + label
	lbl.custom_minimum_size = Vector2(160, 0)
	hbox.add_child(lbl)
	var swatch := ColorRect.new()
	swatch.color = color
	swatch.custom_minimum_size = Vector2(24, 24)
	swatch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(swatch)
	var hex := LineEdit.new()
	hex.text = _color_to_hex(color)
	hex.custom_minimum_size = Vector2(96, 0)
	hex.placeholder_text = "#RRGGBB"
	var captured_field := field
	var captured_target := target_id
	hex.focus_exited.connect(func():
		var c: Color = _hex_to_color(hex.text)
		swatch.color = c
		_commit_field(captured_target, captured_field, c, null)
	)
	hbox.add_child(hex)
	var copy_btn := Button.new()
	copy_btn.text = "Copy"
	copy_btn.pressed.connect(func(): _copy_color(color))
	hbox.add_child(copy_btn)
	var paste_btn := Button.new()
	paste_btn.text = "Paste"
	paste_btn.pressed.connect(func():
		var c: Color = _paste_color()
		swatch.color = c
		hex.text = _color_to_hex(c)
		_commit_field(captured_target, captured_field, c, null)
	)
	hbox.add_child(paste_btn)

# Locks sub-section: one checkbox per lockable property.
func _build_locks_section(vbox: VBoxContainer, target_id: String, kind: String) -> void:
	var properties: Array[String] = ["position", "size", "rotation", "gaps", "motion", "visual", "connectors"]
	for prop in properties:
		var hbox := HBoxContainer.new()
		vbox.add_child(hbox)
		var lbl := Label.new()
		lbl.text = "  lock " + prop
		lbl.custom_minimum_size = Vector2(160, 0)
		hbox.add_child(lbl)
		var cb := CheckBox.new()
		var cur: bool = document.is_property_locked(target_id, prop)
		cb.button_pressed = cur
		var captured_target := target_id
		var captured_prop: String = prop
		cb.toggled.connect(func(pressed: bool):
			document.set_property_lock(captured_target, captured_prop, pressed)
		)
		hbox.add_child(cb)

# ==============================================================================
# Field commit
# ==============================================================================

# target = "piece" | "link" | "doc"
# field = property name
# value = new value (already typed)
# prev_value = the value when the editor opened; not currently used
func _commit_field(target: String, field: String, value: Variant, prev_value: Variant) -> void:
	if _suppress: return
	if document == null: return
	if target == "piece":
		if _selected_piece_id.is_empty(): return
		var piece_id := _selected_piece_id
		document.apply_edit(func():
			var p: Dictionary = document.find_piece(piece_id)
			if p.is_empty(): return
			p[field] = value
			# Re-emit change for downstream listeners.
			piece_property_changed.emit(piece_id, field, value)
		)
	elif target == "link":
		if _selected_link_id.is_empty(): return
		var link_id := _selected_link_id
		document.apply_edit(func():
			var l: Dictionary = document.find_link(link_id)
			if l.is_empty(): return
			l[field] = value
			link_property_changed.emit(link_id, field, value)
		)
	elif target == "doc":
		document.apply_edit(func():
			document.set(field, value)
		)
	# Size-master link propagation (Section 15).
	if target == "piece" and (field == "radius" or field == "thickness" or field == "length" or field == "width" or field == "radius_y" or field == "height"):
		document.apply_size_link_for_field(_selected_piece_id, field, float(value))

# ==============================================================================
# Helpers
# ==============================================================================

func _add_gap_row(vbox: VBoxContainer, piece_id: String, gap_index: int, gap: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	vbox.add_child(hbox)
	var lbl := Label.new()
	lbl.text = "    gap #%d" % gap_index
	lbl.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(lbl)
	var c_edit := LineEdit.new()
	c_edit.text = _fmt_num(float(gap.get("center_angle_deg", 0.0)))
	c_edit.custom_minimum_size = Vector2(60, 0)
	c_edit.placeholder_text = "center"
	var captured_piece := piece_id
	var captured_index := gap_index
	c_edit.focus_exited.connect(func():
		_set_gap_field(captured_piece, captured_index, "center_angle_deg", float(c_edit.text))
	)
	hbox.add_child(c_edit)
	var w_edit := LineEdit.new()
	w_edit.text = _fmt_num(float(gap.get("width_deg", 60.0)))
	w_edit.custom_minimum_size = Vector2(60, 0)
	w_edit.placeholder_text = "width"
	w_edit.focus_exited.connect(func():
		_set_gap_field(captured_piece, captured_index, "width_deg", float(w_edit.text))
	)
	hbox.add_child(w_edit)
	var t_edit := LineEdit.new()
	t_edit.text = _fmt_num(float(gap.get("tolerance_deg", 16.0)))
	t_edit.custom_minimum_size = Vector2(60, 0)
	t_edit.placeholder_text = "tol"
	t_edit.focus_exited.connect(func():
		_set_gap_field(captured_piece, captured_index, "tolerance_deg", float(t_edit.text))
	)
	hbox.add_child(t_edit)
	var del := Button.new()
	del.text = "x"
	del.pressed.connect(func():
		document.apply_edit(func():
			var p: Dictionary = document.find_piece(captured_piece)
			if not p.is_empty() and "gaps" in p:
				var gv: Array = p["gaps"]
				if captured_index >= 0 and captured_index < gv.size():
					gv.remove_at(captured_index)
					p["gaps"] = gv
		)
	)
	hbox.add_child(del)

func _set_gap_field(piece_id: String, gap_index: int, field: String, value: float) -> void:
	document.apply_edit(func():
		var p: Dictionary = document.find_piece(piece_id)
		if not p.is_empty() and "gaps" in p:
			var gv: Array = p["gaps"]
			if gap_index >= 0 and gap_index < gv.size():
				var g: Dictionary = gv[gap_index]
				g[field] = value
				gv[gap_index] = g
				p["gaps"] = gv
	)

func _fmt_num(v: float) -> String:
	return str(snappedf(v, 0.001))

func _shape_name(p: Dictionary) -> String:
	var s: int = int(p.get("shape_type", 0))
	match s:
		0: return "CIRCLE"
		1: return "ROUNDED_SQUARE"
		2: return "ROUNDED_TRIANGLE"
		3: return "OVAL"
		4: return "STRAIGHT"
		5: return "L_SHAPE"
		6: return "PATH"
		_: return "UNKNOWN(%d)" % s

func _piece_type_name(p: Dictionary) -> String:
	var s: int = int(p.get("piece_type", 0))
	match s:
		0: return "CLOSED_CIRCLE"
		1: return "OPEN_CIRCLE"
		2: return "DUAL_GAP_CIRCLE"
		_: return "UNKNOWN(%d)" % s

func _piece_role_name(p: Dictionary) -> String:
	var s: int = int(p.get("role", 0))
	match s:
		0: return "NORMAL"
		1: return "ROOT_ANCHOR"
		2: return "HUB"
		3: return "EXIT"
		4: return "SPECIAL"
		_: return "UNKNOWN(%d)" % s

func _color_from_piece(p: Dictionary) -> Color:
	if p.has("color_hex") and p["color_hex"] is String:
		var c: Color = _hex_to_color(p["color_hex"])
		return c
	if "color" in p and p["color"] is Color:
		return p["color"]
	return Color.WHITE

func _color_from_link(l: Dictionary) -> Color:
	if l.has("joint_color_hex") and l["joint_color_hex"] is String:
		var c: Color = _hex_to_color(l["joint_color_hex"])
		return c
	if "joint_color" in l and l["joint_color"] is Color:
		return l["joint_color"]
	return Color.WHITE

func _vec2_str(d: Variant) -> String:
	if d is Dictionary and d.has("x") and d.has("y"):
		return "%g, %g" % [float(d["x"]), float(d["y"])]
	if d is Vector2:
		return "%g, %g" % [(d as Vector2).x, (d as Vector2).y]
	return "0, 0"

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

# Clipboard for color copy/paste (Section 5).
var _color_clipboard: Color = Color.WHITE

func _copy_color(c: Color) -> void:
	_color_clipboard = c

func _paste_color() -> Color:
	return _color_clipboard