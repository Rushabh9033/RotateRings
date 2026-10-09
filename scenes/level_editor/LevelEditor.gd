extends Control

# In-game Level Editor (level_editor_scene).
# Manual control: click PLACE on canvas to drop a piece; drag a piece to move;
# click GAP then drag the gap-handle on a selected piece to rotate; click
# LINK then click two pieces to make a chain link between them (cuff color
# = destination ring color).
# AI control: clicking "AutoFill" calls LevelDatabase.get_level(level_id) which
# itself prefers user-level JSON if present, then falls back to the campaign
# pipeline. The resulting pieces + links are placed into the editor's working
# set so you can drag them.
#
# Save: writes data/user_levels/<n>.json. Once that file exists,
# LevelDatabase.get_level(n) prefers it on the next game launch.

signal back_pressed

const PieceDefScript = preload("res://data/piece_definition.gd")
const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const LevelDatabase = preload("res://data/level_database.gd")

# Called by scene_router each time the editor is shown. Pre-selects the
# level in the spinner and auto-loads from JSON / campaign pipeline so the
# current game's visible level is in the editor when the user enters.
func setup_editor(level_id: int = 1) -> void:
	level_input.value = level_id
	_load_level_from_json(level_id)

enum Tool { PLACE, MOVE, GAP, LINK }
enum ActiveColor { ORANGE, CYAN, PURPLE, RED, GREEN }

const COLOR_HEX := {
	ActiveColor.ORANGE: Color("#EA7829"),
	ActiveColor.CYAN:   Color("#32ADDA"),
	ActiveColor.PURPLE: Color("#7B61FF"),
	ActiveColor.RED:    Color("#E63946"),
	ActiveColor.GREEN:  Color("#3EC6B0"),
}

@onready var puzzle_preview: Node2D = $PuzzlePreview
@onready var level_input: SpinBox = $TopBar/LevelInput
@onready var load_btn: Button = $TopBar/LoadBtn
@onready var autofill_btn: Button = $TopBar/AutoFillBtn
@onready var save_btn: Button = $TopBar/SaveBtn
@onready var mode_label: Label = $RightPanel/VBox/ModeLabel
@onready var place_btn: Button = $RightPanel/VBox/ToolButtons/PlaceBtn
@onready var move_btn: Button = $RightPanel/VBox/ToolButtons/MoveBtn
@onready var gap_btn: Button = $RightPanel/VBox/ToolButtons/GapBtn
@onready var link_btn: Button = $RightPanel/VBox/ToolButtons/LinkBtn
@onready var orange_btn: Button = $RightPanel/VBox/ColorSection/ColorBtns/OrangeBtn
@onready var cyan_btn: Button = $RightPanel/VBox/ColorSection/ColorBtns/CyanBtn
@onready var purple_btn: Button = $RightPanel/VBox/ColorSection/ColorBtns/PurpleBtn
@onready var red_btn: Button = $RightPanel/VBox/ColorSection/ColorBtns/RedBtn
@onready var green_btn: Button = $RightPanel/VBox/ColorSection/ColorBtns/GreenBtn
@onready var radius_slider: HSlider = $RightPanel/VBox/SizeSection/RadiusSlider
@onready var radius_label: Label = $RightPanel/VBox/SizeSection/RadiusLabel
@onready var scale_slider: HSlider = $RightPanel/VBox/SizeSection/ScaleSlider
@onready var scale_label: Label = $RightPanel/VBox/SizeSection/ScaleLabel
@onready var grid_btn: Button = $RightPanel/VBox/LayoutSection/GridRow/GridBtn
@onready var snap_btn: Button = $RightPanel/VBox/LayoutSection/GridRow/SnapBtn
@onready var grid_size_slider: HSlider = $RightPanel/VBox/LayoutSection/GridSizeSlider
@onready var center_x_btn: Button = $RightPanel/VBox/LayoutSection/CenterRow/CenterXBtn
@onready var center_y_btn: Button = $RightPanel/VBox/LayoutSection/CenterRow/CenterYBtn
@onready var pixel_label: Label = $RightPanel/VBox/LayoutSection/PixelLabel
@onready var delete_btn: Button = $RightPanel/VBox/DeleteBtn
@onready var panel_toggle_btn: Button = $PanelToggleBtn
@onready var closed_toggle_btn: CheckButton = $RightPanel/VBox/ClosedToggleBtn
@onready var right_panel: PanelContainer = $RightPanel
@onready var back_btn: Button = $TopBar/BackBtn
@onready var status_label: Label = $BottomStatus

var _tool: Tool = Tool.PLACE
var _active_color: ActiveColor = ActiveColor.ORANGE
var _placed_pieces: Array = []         # Array of dicts: {id, color, x, y, radius, thickness, gap_deg}
var _placed_links: Array = []          # Array of dicts: {from_id, to_id, cuff_color}
var _next_piece_id: int = 1
var _selected_piece_idx: int = -1
var _linking_first_idx: int = -1       # when in LINK mode, first piece clicked
var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _rotating_gap: bool = false

func _ready() -> void:
	# Always start with a clean working set. No auto-load from level 1 anymore —
	# the user clicks Load explicitly to pull a saved level, or AutoFill to
	# pull the current campaign structure. This prevents stray pieces from
	# accumulating across sessions.
	puzzle_preview.editor_ref = self
	_placed_pieces.clear()
	_placed_links.clear()
	_selected_piece_idx = -1
	_next_piece_id = 1
	_set_status("Editor ready. Click Load to pull a saved level from data/user_levels/, or AutoFill to copy the game's current Level N.")

	load_btn.pressed.connect(_load_button_pressed)
	autofill_btn.pressed.connect(_autofill_button_pressed)
	save_btn.pressed.connect(_save_button_pressed)
	back_btn.pressed.connect(func(): back_pressed.emit())
	place_btn.toggled.connect(_on_place_toggled)
	move_btn.toggled.connect(_on_move_toggled)
	gap_btn.toggled.connect(_on_gap_toggled)
	link_btn.toggled.connect(_on_link_toggled)
	for b in [orange_btn, cyan_btn, purple_btn, red_btn, green_btn]:
		b.toggled.connect(_on_color_btn.bind(b))
	radius_slider.value_changed.connect(_on_radius_changed)
	scale_slider.value_changed.connect(_on_scale_all_changed)
	grid_btn.toggled.connect(_on_grid_toggled)
	snap_btn.toggled.connect(_on_snap_toggled)
	grid_size_slider.value_changed.connect(_on_grid_size_changed)
	center_x_btn.pressed.connect(_center_x_pressed)
	center_y_btn.pressed.connect(_center_y_pressed)
	level_input.value_changed.connect(_on_level_changed)
	delete_btn.pressed.connect(_delete_selected)
	panel_toggle_btn.pressed.connect(_on_panel_toggle)
	right_panel.visible = true
	_update_pixel_label()

func _on_level_changed(v: float) -> void:
	# Loading on change would clobber work; let user click Load explicitly.
	_set_status("Level %d selected — click Load." % int(v))

# Toggle the right panel on/off. Useful on narrow viewports (mobile
# 720x1280) where the panel covers the puzzle canvas.
func _on_panel_toggle() -> void:
	right_panel.visible = not right_panel.visible
	panel_toggle_btn.text = "Panel" if right_panel.visible else "Show"

func _on_radius_changed(v: float) -> void:
	radius_label.text = "Radius: %d" % int(v)
	if _selected_piece_idx >= 0 and _selected_piece_idx < _placed_pieces.size():
		_placed_pieces[_selected_piece_idx]["radius"] = int(v)
		puzzle_preview.queue_redraw()

# Scale All: every placed piece's radius and thickness is multiplied by
# the slider value (1.0x = no change, 0.5x = half, 2.0x = double).
#
# Anchoring: we snapshot the values at the moment the user starts a drag
# (i.e. when the slider value differs from its last set value AND the
# last set value was 1.0 — meaning we're starting a fresh scale from
# the resting position). Within a single drag we apply the slider value
# directly relative to that snapshot, so 0.5x always means "half of where
# we started this drag."
#
# Releasing the slider: when value returns to 1.0 OR when the user makes
# any other change, we drop the snapshot so the next drag starts fresh.
var _scale_anchor_radii: Array = []
var _scale_anchor_thicknesses: Array = []
var _scale_anchor_value: float = 1.0
var _scale_drag_active: bool = false

func _on_scale_all_changed(v: float) -> void:
	scale_label.text = "Scale All: %.2fx" % v
	if _placed_pieces.is_empty():
		return
	# If the piece set changed, or the user has "broken" the drag (e.g. added/
	# removed a piece), reset the anchor.
	if _scale_anchor_radii.size() != _placed_pieces.size():
		_scale_drag_active = false
	if not _scale_drag_active:
		_scale_anchor_radii.clear()
		_scale_anchor_thicknesses.clear()
		for p in _placed_pieces:
			_scale_anchor_radii.append(float(p.get("radius", 60)))
			_scale_anchor_thicknesses.append(float(p.get("thickness", 18)))
		_scale_anchor_value = 1.0
		_scale_drag_active = true
	# Apply: new_value = snapshot * (v / 1.0) — so 1.0x restores snapshot.
	var factor: float = v
	for i in range(_placed_pieces.size()):
		_placed_pieces[i]["radius"] = maxf(8.0, _scale_anchor_radii[i] * factor)
		if _scale_anchor_thicknesses.size() > i:
			_placed_pieces[i]["thickness"] = maxf(4.0, _scale_anchor_thicknesses[i] * factor)
	puzzle_preview.queue_redraw()

# === Grid / Snap / Center / Pixel-precise editing ===

# When snap is on, any piece move (drag) rounds its x,y to a multiple of
# the current grid_size. The PuzzlePreview reads grid_enabled + snap_enabled
# + grid_size to render the grid and the snap guides.
var grid_enabled: bool = false
var snap_enabled: bool = true
var grid_size: float = 10.0

func _on_grid_toggled(on: bool) -> void:
	grid_enabled = on
	puzzle_preview.queue_redraw()

func _on_snap_toggled(on: bool) -> void:
	snap_enabled = on

func _on_grid_size_changed(v: float) -> void:
	grid_size = v
	puzzle_preview.queue_redraw()

func _center_x_pressed() -> void:
	if _placed_pieces.is_empty(): return
	# Find mean X across all pieces, then translate the whole set so the
	# mean lands on canvas X=360 (the visual center of a 720-wide canvas).
	var sum_x: float = 0.0
	for p in _placed_pieces:
		sum_x += float(p["x"])
	var mean_x: float = sum_x / _placed_pieces.size()
	var dx: float = 360.0 - mean_x
	for p in _placed_pieces:
		p["x"] = float(p["x"]) + dx
		if _snap_on_commit():
			p["x"] = _round_to_grid(p["x"])
	puzzle_preview.queue_redraw()
	_update_pixel_label()
	_set_status("Centered horizontally: dx=%.1f" % dx)

func _center_y_pressed() -> void:
	if _placed_pieces.is_empty(): return
	var sum_y: float = 0.0
	for p in _placed_pieces:
		sum_y += float(p["y"])
	var mean_y: float = sum_y / _placed_pieces.size()
	var dy: float = 640.0 - mean_y
	for p in _placed_pieces:
		p["y"] = float(p["y"]) + dy
		if _snap_on_commit():
			p["y"] = _round_to_grid(p["y"])
	puzzle_preview.queue_redraw()
	_update_pixel_label()
	_set_status("Centered vertically: dy=%.1f" % dy)

func _snap_on_commit() -> bool:
	return snap_enabled

func _round_to_grid(v: float) -> float:
	return round(v / grid_size) * grid_size

func _update_pixel_label() -> void:
	if _selected_piece_idx < 0 or _selected_piece_idx >= _placed_pieces.size():
		pixel_label.text = "Selected: —"
		return
	var p: Dictionary = _placed_pieces[_selected_piece_idx]
	var x: float = float(p["x"])
	var y: float = float(p["y"])
	var snapped_x: float = _round_to_grid(x) if snap_enabled else x
	var snapped_y: float = _round_to_grid(y) if snap_enabled else y
	var snap_marker: String = "*" if snap_enabled and (snapped_x != x or snapped_y != y) else ""
	pixel_label.text = "Selected %s: x=%.1f y=%.1f%s (grid=%.0f)" % [
		String(p.get("id", "?")),
		x, y, snap_marker, grid_size,
	]

func _set_status(msg: String) -> void:
	status_label.text = "Status: " + msg

func _on_place_toggled(_pressed: bool) -> void:
	_tool = Tool.PLACE; mode_label.text = "Tool: PLACE"
	_move_btn_off(); _gap_btn_off(); _link_btn_off()
	_selected_piece_idx = -1
	puzzle_preview.queue_redraw()

func _on_move_toggled(_pressed: bool) -> void:
	_tool = Tool.MOVE; mode_label.text = "Tool: MOVE"
	_place_btn_off(); _gap_btn_off(); _link_btn_off()
	_selected_piece_idx = -1
	puzzle_preview.queue_redraw()

func _on_gap_toggled(_pressed: bool) -> void:
	_tool = Tool.GAP; mode_label.text = "Tool: GAP"
	_place_btn_off(); _move_btn_off(); _link_btn_off()
	puzzle_preview.queue_redraw()

func _on_link_toggled(_pressed: bool) -> void:
	_tool = Tool.LINK; mode_label.text = "Tool: LINK"
	_place_btn_off(); _move_btn_off(); _gap_btn_off()
	_linking_first_idx = -1
	puzzle_preview.queue_redraw()

func _place_btn_off() -> void: place_btn.set_pressed_no_signal(false)
func _move_btn_off()  -> void: move_btn.set_pressed_no_signal(false)
func _gap_btn_off()   -> void: gap_btn.set_pressed_no_signal(false)
func _link_btn_off()  -> void: link_btn.set_pressed_no_signal(false)

func _on_color_btn(_pressed: bool, _t: bool, btn: Button) -> void:
	if not btn.button_pressed: return
	for k in [orange_btn, cyan_btn, purple_btn, red_btn, green_btn]:
		if k != btn: k.set_pressed_no_signal(false)
	_active_color = ActiveColor.ORANGE
	if btn == orange_btn: _active_color = ActiveColor.ORANGE
	elif btn == cyan_btn: _active_color = ActiveColor.CYAN
	elif btn == purple_btn: _active_color = ActiveColor.PURPLE
	elif btn == red_btn: _active_color = ActiveColor.RED
	elif btn == green_btn: _active_color = ActiveColor.GREEN

# ============= Input =============
func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton or event is InputEventMouseMotion): return
	# Translate pointer to puzzle-space (offset by PuzzlePreview position)
	var pos = puzzle_preview.get_local_mouse_position()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(pos)
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = false
		_rotating_gap = false

	if event is InputEventMouseMotion:
		if _tool == Tool.MOVE and _dragging and _selected_piece_idx >= 0 and _selected_piece_idx < _placed_pieces.size():
			var p = _placed_pieces[_selected_piece_idx]
			var new_x: float = pos.x - _drag_offset.x
			var new_y: float = pos.y - _drag_offset.y
			if snap_enabled:
				new_x = _round_to_grid(new_x)
				new_y = _round_to_grid(new_y)
			p["x"] = new_x
			p["y"] = new_y
			puzzle_preview.queue_redraw()
			_update_pixel_label()
		elif _tool == Tool.GAP and _rotating_gap and _selected_piece_idx >= 0 and _selected_piece_idx < _placed_pieces.size():
			# Compute angle from selected piece center to mouse and store as gap_deg.
			var p = _placed_pieces[_selected_piece_idx]
			var cx: float = float(p["x"]); var cy: float = float(p["y"])
			var dx: float = pos.x - cx; var dy: float = pos.y - cy
			var ang: float = rad_to_deg(atan2(dy, dx))
			if ang < 0: ang += 360.0
			p["gap_deg"] = ang
			puzzle_preview.queue_redraw()

func _handle_click(local_pos: Vector2) -> void:
	match _tool:
		Tool.PLACE:
			_place_piece(local_pos)
		Tool.MOVE:
			var idx = _hit_test_piece(local_pos)
			if idx >= 0:
				_selected_piece_idx = idx
				var p = _placed_pieces[idx]
				_drag_offset = local_pos - Vector2(p["x"], p["y"])
				_dragging = true
				radius_slider.value = p["radius"]
				radius_label.text = "Radius: %d" % int(p["radius"])
				puzzle_preview.queue_redraw()
			else:
				_selected_piece_idx = -1
				puzzle_preview.queue_redraw()
		Tool.GAP:
			var idx = _hit_test_piece(local_pos) if _hit_test_piece(local_pos) >= 0 else _hit_test_gap_handle(local_pos)
			if idx >= 0:
				_selected_piece_idx = idx
				_rotating_gap = true
				puzzle_preview.queue_redraw()
		Tool.LINK:
			var idx = _hit_test_piece(local_pos)
			if idx >= 0:
				if _linking_first_idx < 0:
					_linking_first_idx = idx
					_set_status("Pick destination ring for chain link.")
				elif _linking_first_idx != idx:
					_make_link(_linking_first_idx, idx)
					_linking_first_idx = -1
					puzzle_preview.queue_redraw()

func _hit_test_piece(local_pos: Vector2) -> int:
	for i in range(_placed_pieces.size() - 1, -1, -1):
		var p = _placed_pieces[i]
		var d = Vector2(local_pos.x - p["x"], local_pos.y - p["y"]).length()
		if d <= float(p["radius"]) + 8.0:
			return i
	return -1

func _hit_test_gap_handle(local_pos: Vector2) -> int:
	if _selected_piece_idx < 0: return -1
	# Allow grabbing the small handle 24 px from ring center along gap direction.
	var p = _placed_pieces[_selected_piece_idx]
	var a = deg_to_rad(p["gap_deg"])
	var hx = p["x"] + cos(a) * float(p["radius"]) * 1.0
	var hy = p["y"] + sin(a) * float(p["radius"]) * 1.0
	if Vector2(local_pos.x - hx, local_pos.y - hy).length() < 36.0:
		return _selected_piece_idx
	# Try all pieces.
	for i in range(_placed_pieces.size()):
		var q = _placed_pieces[i]
		var aa = deg_to_rad(q["gap_deg"])
		var hxx = q["x"] + cos(aa) * float(q["radius"]) * 1.0
		var hyy = q["y"] + sin(aa) * float(q["radius"]) * 1.0
		if Vector2(local_pos.x - hxx, local_pos.y - hyy).length() < 36.0:
			return i
	return -1

func _place_piece(local_pos: Vector2) -> void:
	var col_hex = COLOR_HEX[_active_color]
	var is_closed: bool = closed_toggle_btn.button_pressed if is_instance_valid(closed_toggle_btn) else false
	var p = {
		"id": "piece_%d" % _next_piece_id,
		"color_name": _color_name_from_enum(_active_color),
		"color_hex": _color_to_hex(col_hex),
		"x": local_pos.x, "y": local_pos.y,
		"radius": int(radius_slider.value),
		"thickness": 22,
		"gap_deg": 270.0,
		"shape": "CIRCLE",
		"closed": is_closed,
	}
	_next_piece_id += 1
	_placed_pieces.append(p)
	_selected_piece_idx = _placed_pieces.size() - 1
	puzzle_preview.queue_redraw()
	_set_status("Placed piece %d. Switch to MOVE to drag, or GAP to rotate gap." % _selected_piece_idx)

func _color_name_from_enum(c: ActiveColor) -> String:
	match c:
		ActiveColor.ORANGE: return "orange"
		ActiveColor.CYAN:   return "cyan"
		ActiveColor.PURPLE: return "purple"
		ActiveColor.RED:    return "red"
		ActiveColor.GREEN:  return "green"
	return "orange"

func _make_link(from_idx: int, to_idx: int) -> void:
	var dst = _placed_pieces[to_idx]
	_placed_links.append({
		"from_id": _placed_pieces[from_idx]["id"],
		"to_id": dst["id"],
		"cuff_color_name": dst["color_name"],
	})
	_set_status("Linked %s → %s." % [_placed_pieces[from_idx]["id"], dst["id"]])

func _delete_selected() -> void:
	if _selected_piece_idx < 0: return
	var rid = _placed_pieces[_selected_piece_idx]["id"]
	_placed_pieces.remove_at(_selected_piece_idx)
	# Remove any links touching the removed piece.
	var keep: Array = []
	for l in _placed_links:
		if l["from_id"] != rid and l["to_id"] != rid: keep.append(l)
	_placed_links = keep
	_selected_piece_idx = -1
	puzzle_preview.queue_redraw()

# ============= AutoFill / Save / Load =============
func _load_button_pressed() -> void:
	var n: int = int(level_input.value)
	# Prefer JSON if present.
	var data: Variant = _read_user_level_json(n)
	if data != null:
		_load_from_dict(data)
		_set_status("Loaded level %d from data/user_levels/%d.json" % [n, n])
	else:
		_set_status("No JSON for level %d — click AutoFill to pull from current pipeline, or place pieces manually." % n)

func _load_level_from_json(n: int) -> bool:
	# Like _load_button_pressed but without setting status. Used by _ready().
	var data: Variant = _read_user_level_json(n)
	if data == null: return false
	# Reset state then load.
	_placed_pieces.clear()
	_placed_links.clear()
	_selected_piece_idx = -1
	_next_piece_id = 1
	_load_from_dict(data)
	return true

func _autofill_button_pressed() -> void:
	var n: int = int(level_input.value)
	var def = LevelDatabase.get_level(n)
	if def == null:
		_set_status("Level %d has no definition in LevelDatabase." % n)
		return
	# Convert def into editor piece/link arrays.
	_placed_pieces.clear()
	_placed_links.clear()
	_next_piece_id = 1
	for piece_def in def.pieces:
		# Convert Color to hex. piece_def is Variant at this point.
		var pcolor: Color = piece_def.color
		var hex6 := _color_to_hex(pcolor)
		var pname := _guess_color_name(pcolor)
		var rad: float = float(piece_def.radius)
		var thick: float = float(piece_def.thickness)
		var start: float = float(piece_def.start_angle_deg)
		var gaps_arr = piece_def.gaps
		var gap_center: float = 0.0
		if gaps_arr.size() > 0:
			gap_center = float(gaps_arr[0].center_angle_deg)
		var gap_deg: float = start + gap_center
		var pos: Vector2 = piece_def.position
		var is_closed: bool = gaps_arr.size() == 0
		var shp_str: String = "CIRCLE"
		var shape_int: int = int(piece_def.shape_type)
		if shape_int == int(PieceDefinitionScript.ShapeType.ROUNDED_SQUARE):
			shp_str = "ROUNDED_SQUARE"
		elif shape_int == int(PieceDefinitionScript.ShapeType.ROUNDED_TRIANGLE):
			shp_str = "ROUNDED_TRIANGLE"
		elif shape_int == int(PieceDefinitionScript.ShapeType.OVAL):
			shp_str = "OVAL"
		elif shape_int == int(PieceDefinitionScript.ShapeType.STRAIGHT):
			shp_str = "STRAIGHT"
		elif shape_int == int(PieceDefinitionScript.ShapeType.L_SHAPE):
			shp_str = "L_SHAPE"
		var p_id_str: String = String(piece_def.id)
		_placed_pieces.append({
			"id": p_id_str,
			"color_name": pname,
			"color_hex": "#" + hex6.to_upper(),
			"x": pos.x, "y": pos.y,
			"radius": int(rad),
			"thickness": int(thick),
			"gap_deg": gap_deg,
			"shape": shp_str,
			"closed": is_closed,
		})
		_next_piece_id += 1
	for link_def in def.links:
		# cuff = link's joint_color
		var cuff_color: Color = link_def.joint_color
		var cuff_hex6 := _color_to_hex(cuff_color)
		var cuff_name := _guess_color_name(cuff_color)
		_placed_links.append({
			"from_id": String(link_def.from_piece_id),
			"to_id": String(link_def.to_piece_id),
			"cuff_color_name": cuff_name,
			"cuff_color_hex": "#" + cuff_hex6.to_upper(),
		})
	puzzle_preview.queue_redraw()
	_set_status("Auto-filled level %d from LevelDatabase (%d pieces, %d links)." % [n, _placed_pieces.size(), _placed_links.size()])

func _guess_color_name(c: Color) -> String:
	# Snap to nearest known palette color.
	var palette := {
		"orange": Color("#EA7829"),
		"cyan":   Color("#32ADDA"),
		"purple": Color("#7B61FF"),
		"red":    Color("#E63946"),
		"green":  Color("#3EC6B0"),
		"cuff_blue": Color("#1F5A82"),
		"blue":   Color("#32ADDA"),
	}
	var best_name: String = "orange"
	var best_d: float = 9999.0
	for n in palette:
		var p = palette[n]
		var d = abs(p.r - c.r) + abs(p.g - c.g) + abs(p.b - c.b)
		if d < best_d:
			best_d = d
			best_name = n
	return best_name

func _save_button_pressed() -> void:
	var n: int = int(level_input.value)
	var data := _serialize(n)
	var path := "res://data/user_levels/%d.json" % n
	var abs_path := ProjectSettings.globalize_path(path)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		_set_status("Save FAILED: %s" % error_string(FileAccess.get_open_error()))
		return
	f.store_string(JSON.stringify(data, "  "))
	f.close()
	_set_status("Saved %d pieces, %d links → %s" % [_placed_pieces.size(), _placed_links.size(), abs_path])

func _read_user_level_json(n: int) -> Variant:
	var path := "res://data/user_levels/%d.json" % n
	if not FileAccess.file_exists(path): return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return null
	var txt := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(txt)
	if parsed is Dictionary: return parsed
	return null

func _serialize(level_id: int) -> Dictionary:
	# Round-trip the FULL modern schema (matches data/piece_definition.gd +
	# data/link_definition.gd) so saving from the editor doesn't strip
	# fields the runtime needs (motion_model, slide_*, role, piece_type,
	# release_direction, target_exit_angle_deg, gaps as objects with
	# center_angle_deg/width_deg/tolerance_deg, link collar/stem/etc.).
	# The runtime overwrites runtime-recomputed fields (collar_angle_deg,
	# stem_dist, runtime_current_stem_dist) on load anyway, so writing
	# placeholders here is safe.
	var pieces_obj: Array = []
	for p in _placed_pieces:
		# Normalize the gap_deg into the modern gaps[] format.
		var width_deg: float = float(p.get("gap_width_deg", 70.0))
		var tol_deg: float = float(p.get("gap_tolerance_deg", 16.0))
		var closed: bool = bool(p.get("closed", false))
		var gaps_out: Array = []
		if not closed:
			gaps_out.append({
				"center_angle_deg": float(p.get("gap_deg", 270.0)),
				"width_deg": width_deg,
				"tolerance_deg": tol_deg,
			})
		pieces_obj.append({
			"id": p["id"],
			"color_name": p.get("color_name", "orange"),
			"color_hex": p.get("color_hex", "#EA7829"),
			"shape_type": 0,
			"shape_name": "CIRCLE",
			"motion_model": 0,
			"motion_axis": {"x": 1.0, "y": 0.0},
			"slide_min": -1000.0,
			"slide_max": 1000.0,
			"slide_path": [],
			"special_params": {},
			"role": 0,
			"piece_type": 1 if not closed else 0,
			"x": p["x"],
			"y": p["y"],
			"start_angle_deg": 0.0,
			"radius": p["radius"],
			"radius_y": p["radius"],
			"length": 0.0,
			"length_b": 0.0,
			"width": 0.0,
			"height": 0.0,
			"corner_radius": 0.0,
			"thickness": p["thickness"],
			"path_points": [],
			"z_index": 1,
			"initially_locked": false,
			"release_direction": {"x": 1.0, "y": 0.0},
			"target_exit_angle_deg": 0.0,
			"gaps": gaps_out,
			"closed": closed,
		})
	var links_obj: Array = []
	for l in _placed_links:
		links_obj.append({
			"id": "link_%d" % randi(),
			"from_id": l["from_id"],
			"to_id": l["to_id"],
			"collar_angle_deg": 0.0,
			"cuff_center_local": {"x": 0.0, "y": 0.0},
			"cuff_orientation_deg": 0.0,
			"cuff_width": 32.0,
			"cuff_depth": 18.0,
			"cuff_round_radius": 5.0,
			"stem_length": 0.0,
			"stem_width": 6.0,
			"stem_distance_from_piece": 0.0,
			"stem_dist": 200.0,
			"joint_color_hex": l.get("cuff_color_hex", "#EA7829"),
			"joint_color_name": l.get("cuff_color_name", "orange"),
			"z_index": 0,
			"clearance_tolerance_deg": 20.0,
			"is_detached": false,
		})
	return {
		"id": level_id,
		"title": "Level %d" % level_id,
		"source": "in-game-edit-overlay",
		"pieces": pieces_obj,
		"links": links_obj,
	}

func _load_from_dict(data: Dictionary) -> void:
	_placed_pieces.clear()
	_placed_links.clear()
	_selected_piece_idx = -1
	_next_piece_id = 1
	for p in data.get("pieces", []):
		# Map color_name → hex.
		var cn: String = p.get("color_name", "orange")
		var ch: String = p.get("color_hex", "")
		if ch == "":
			ch = _color_to_hex(COLOR_HEX.get(_color_enum_from_name(cn), Color.WHITE))
		# Read the modern gaps[] format. Fall back to legacy gap_deg field
		# if the file predates the schema upgrade.
		var gap_deg_v: float = 270.0
		var gap_width_v: float = 70.0
		var gap_tol_v: float = 16.0
		var closed: bool = bool(p.get("closed", false))
		if p.has("gaps") and p["gaps"] is Array and (p["gaps"] as Array).size() > 0:
			var g0: Dictionary = (p["gaps"] as Array)[0]
			gap_deg_v = float(g0.get("center_angle_deg", 270.0))
			gap_width_v = float(g0.get("width_deg", 70.0))
			gap_tol_v = float(g0.get("tolerance_deg", 16.0))
		elif p.has("gap_deg"):
			gap_deg_v = float(p["gap_deg"])
		_placed_pieces.append({
			"id": p.get("id", "piece_%d" % _next_piece_id),
			"color_name": cn,
			"color_hex": ch,
			"x": float(p["x"]),
			"y": float(p["y"]),
			"radius": int(p.get("radius", 80)),
			"thickness": int(p.get("thickness", 22)),
			"gap_deg": gap_deg_v,
			"gap_width_deg": gap_width_v,
			"gap_tolerance_deg": gap_tol_v,
			"shape": p.get("shape", "CIRCLE"),
			"closed": closed,
		})
		_next_piece_id += 1
	for l in data.get("links", []):
		# Always derive the cuff color from the SOURCE piece's color
		# (the parent ring in the chain). The reference game's
		# convention is "cuff = parent ring color" — the cuff visually
		# belongs to the parent, like a plug on its side. This also
		# self-heals any legacy JSONs that had the wrong color stored.
		var from_id_str: String = String(l["from_id"])
		var src_color_hex: String = "#EA7829"
		var src_color_name: String = "orange"
		for pp in _placed_pieces:
			if String(pp["id"]) == from_id_str:
				src_color_hex = String(pp.get("color_hex", "#EA7829"))
				src_color_name = String(pp.get("color_name", "orange"))
				break
		_placed_links.append({
			"from_id": l["from_id"],
			"to_id": l["to_id"],
			"cuff_color_name": src_color_name,
			"cuff_color_hex": src_color_hex,
		})
	puzzle_preview.queue_redraw()

func _color_enum_from_name(n: String) -> ActiveColor:
	match n:
		"orange": return ActiveColor.ORANGE
		"cyan":   return ActiveColor.CYAN
		"purple": return ActiveColor.PURPLE
		"red":    return ActiveColor.RED
		"green":  return ActiveColor.GREEN
	return ActiveColor.ORANGE

# Convert a Godot Color to a "#RRGGBB" hex string, RGBA-correct.
func _color_to_hex(c: Color) -> String:
	var r: int = int(round(c.r * 255))
	var g: int = int(round(c.g * 255))
	var b: int = int(round(c.b * 255))
	return "#%02X%02X%02X" % [r, g, b]
