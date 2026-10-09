extends Control

# In-game level editor overlay (lives as a child of PuzzleArea).
# When edit mode is on, the user can:
#   1. Drag any ring's BODY to reposition it (snap-to-grid + auto-align on drop).
#   2. Drag any ring's TOP-EDGE handle to resize its radius.
#   3. Drag any cuff's "+" handle along the link axis to make the connector longer/shorter.
#   4. Click the lock icon next to a ring to lock / unlock it (locked rings don't drag).
# Each drag-end writes the new positions/sizes/lengths back to
# data/user_levels/<level>.json.
#
# The overlay does NOT replace the puzzle controller — the puzzle keeps
# rendering normally behind it. The overlay just intercepts clicks/hovers
# while edit-mode is on.

const LevelDatabaseScript = preload("res://data/level_database.gd")
const UserLevelsScript = preload("res://data/user_levels.gd")
const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")

signal edit_mode_changed(is_on: bool)
signal piece_moved(piece_id: String, position: Vector2)

@export var debug_print: bool = false
@export var grid_size: float = 20.0       # px per snap step
@export var align_threshold: float = 12.0  # px — drop within this range snaps to guide
@export var show_debug_ids: bool = false   # Section 14: show piece ID, center, bbox, gap, motion-axis, z_index as text overlays.
@export var snap_enabled: bool = true      # Section 12: Snap must be OPTIONAL. Toggle off for reference reconstruction.
@export var nudge_unit: float = 1.0        # Section 12: Arrow = 1 unit nudge, Shift+Arrow = 10 units (then divided by 10).

enum DragMode {
	NONE,
	MOVE_PIECE,
	RESIZE_RADIUS,
	RESIZE_CONNECTOR,
	RESIZE_AXIS,
	ROTATE_PIECE,
	TOGGLE_LOCK,
	DRAG_GAP,
}

# Per-shape axis-routing for the resize handles. Keyed by PieceDefinition.ShapeType int.
# Each value is { "x": field_name, "y": field_name }. The field named "x" is
# mutated when the user drags the piece's LOCAL +X (right) handle; "y" is
# mutated for LOCAL +Y (down) handle. Negative axes drag the opposite field
# by the same delta.
const SHAPE_AXIS_FIELDS := {
	0: {"x": "radius",      "y": "radius"},          # CIRCLE  (uniform)
	1: {"x": "radius",      "y": "radius"},          # ROUNDED_SQUARE
	2: {"x": "radius",      "y": "radius"},          # ROUNDED_TRIANGLE
	3: {"x": "radius",      "y": "radius_y"},        # OVAL
	4: {"x": "length",      "y": "width"},           # STRAIGHT
	5: {"x": "length",      "y": "length_b"},        # L_SHAPE
	6: {"x": "path_scale",  "y": "path_scale"},      # PATH (uniform scale)
}

var _is_active: bool = false
var _pieces: Array = []              # [{id, piece, def, center, radius, locked, path_anchor_dist}]
var _dragging_piece_idx: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_mode: int = DragMode.NONE
var _puzzle: Node = null

# Per-resize state for the new axis-aware drag.
# _resize_axis is one of: Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP
# (in the piece's LOCAL frame). Negative axes mirror the positive one.
var _resize_axis: Vector2 = Vector2.ZERO
var _resize_original_field_value: float = 0.0
var _resize_original_dist_along_axis: float = 0.0
var _resize_original_path_anchor: float = 0.0  # PATH: average radial distance from center at axis start

# Per-rotate state for the dashed rotate ring.
var _rotate_start_angle: float = 0.0     # piece.rotation_degrees at drag start
var _rotate_start_mouse_angle: float = 0.0  # mouse angle from piece center at drag start

# R toggles rotate mode (no piece grabbed). When rotate_mode is true the
# arrow keys nudge the SELECTED piece's rotation instead of position.
var rotate_mode: bool = false:
	set(v):
		rotate_mode = v
		emit_signal("rotate_mode_changed", v)
		queue_redraw()

signal rotate_mode_changed(is_on: bool)

# Selected piece index (for keyboard nudges when no body drag is active).
var _selected_piece_idx: int = -1

# Per-resize state for connector length
var _resizing_link_idx: int = -1       # index into _puzzle.active_links
var _resize_axis_dir: Vector2 = Vector2.ZERO  # unit vector from cuff to parent piece
var _resize_original_stem_dist: float = 0.0
var _resize_original_offset: float = 0.0

# Public API --------------------------------------------------------------

func set_puzzle(p: Node) -> void:
	_puzzle = p

# Injected by the gameplay screen so _save_all_pieces() doesn't have to walk
# the parent chain looking for current_level_id. Falls back to the walk if
# not injected (back-compat with old callers).
var _level_id: int = -1

func set_level_id(lid: int) -> void:
	_level_id = lid

func toggle(active: bool) -> void:
	_is_active = active
	if active:
		show()
	else:
		hide()
	set_process(active)
	set_process_input(active)
	_refresh_pieces()
	emit_signal("edit_mode_changed", active)
	queue_redraw()

func is_active() -> bool:
	return _is_active

# Internal ----------------------------------------------------------------

func _ready() -> void:
	hide()
	set_process(false)
	set_process_input(false)
	z_index = 10

func _refresh_pieces() -> void:
	_pieces.clear()
	if not _is_active: return
	if _puzzle == null: return
	# Pieces are children of puzzle.pieces_container.
	var container = _puzzle.get("pieces_container") if _puzzle else null
	if container == null:
		container = _puzzle
	for child in container.get_children():
		if not (child is Node2D): continue
		var d = child.def if "def" in child else null
		if d == null: continue
		var pdef = d
		var entry := {
			"id": String(pdef.id),
			"piece": child,
			"def": pdef,
			"center": child.global_position,
			"radius": float(pdef.radius),
			"locked": false,
		}
		_pieces.append(entry)

	# Default selection: first unlocked piece, so arrow keys have a target.
	if _selected_piece_idx < 0 or _selected_piece_idx >= _pieces.size():
		for i in range(_pieces.size()):
			if not _pieces[i]["locked"]:
				_selected_piece_idx = i
				break

func _process(_delta: float) -> void:
	# Refresh centers each frame in case pieces animate.
	for i in range(_pieces.size()):
		var p = _pieces[i]["piece"]
		if is_instance_valid(p):
			_pieces[i]["center"] = p.global_position

# Snap helper: rounds to nearest grid_size multiple, optionally aligning to a guide.
func _snap(v: float) -> float:
	return round(v / grid_size) * grid_size

# ==============================================================================
# Gap drag handles (M12) — drag the gap center or one of the two edges
# ==============================================================================

enum GapDragKind { NONE, CENTER, LEFT_EDGE, RIGHT_EDGE }

# Returns [piece_idx, gap_idx, kind] or [-1, -1, NONE].
func _hit_test_gap_handle(local_pos: Vector2) -> Array:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		var def: Resource = p["def"]
		if def == null: continue
		if not "gaps" in def or def.gaps.is_empty(): continue
		if def.is_property_locked("gaps"): continue
		var piece_obj = p["piece"]
		var rot: float = float(piece_obj.rotation_degrees) if piece_obj != null and "rotation_degrees" in piece_obj else 0.0
		var r: float = float(p["radius"])
		for gi in range(def.gaps.size()):
			var g: Resource = def.gaps[gi]
			var center_deg: float = float(g.center_angle_deg)
			var width_deg: float = float(g.width_deg)
			var left_deg: float = fposmod(center_deg - width_deg * 0.5, 360.0)
			var right_deg: float = fposmod(center_deg + width_deg * 0.5, 360.0)
			var world_left: float = rot + left_deg
			var world_right: float = rot + right_deg
			var world_center: float = rot + center_deg
			var pt_left: Vector2 = p["center"] + Vector2(cos(deg_to_rad(world_left)), sin(deg_to_rad(world_left))) * r
			var pt_right: Vector2 = p["center"] + Vector2(cos(deg_to_rad(world_right)), sin(deg_to_rad(world_right))) * r
			var pt_center: Vector2 = p["center"] + Vector2(cos(deg_to_rad(world_center)), sin(deg_to_rad(world_center))) * r
			if pt_center.distance_to(local_pos) <= 14.0:
				return [i, gi, GapDragKind.CENTER]
			if pt_left.distance_to(local_pos) <= 10.0:
				return [i, gi, GapDragKind.LEFT_EDGE]
			if pt_right.distance_to(local_pos) <= 10.0:
				return [i, gi, GapDragKind.RIGHT_EDGE]
	return [-1, -1, GapDragKind.NONE]

var _gap_drag_piece_idx: int = -1
var _gap_drag_gap_idx: int = -1
var _gap_drag_kind: int = GapDragKind.NONE
var _gap_drag_start_mouse_angle: float = 0.0
var _gap_drag_start_value: float = 0.0

func _begin_gap_drag(piece_idx: int, gap_idx: int, kind: int, local_pos: Vector2) -> void:
	_dragging_piece_idx = piece_idx
	_selected_piece_idx = piece_idx
	_gap_drag_piece_idx = piece_idx
	_gap_drag_gap_idx = gap_idx
	_gap_drag_kind = kind
	_gap_drag_start_mouse_angle = (local_pos - _pieces[piece_idx]["center"]).angle()
	var g: Resource = _pieces[piece_idx]["def"].gaps[gap_idx]
	_gap_drag_start_value = float(g.center_angle_deg) if kind == GapDragKind.CENTER else float(g.width_deg)

func _apply_gap_drag(local_pos: Vector2) -> void:
	if _gap_drag_piece_idx < 0: return
	var p = _pieces[_gap_drag_piece_idx]
	var piece_obj = p["piece"]
	var rot: float = float(piece_obj.rotation_degrees) if piece_obj != null and "rotation_degrees" in piece_obj else 0.0
	# Current mouse angle minus start = delta in degrees (in piece-local frame).
	var cur_local_angle: float = fposmod((local_pos - p["center"]).angle() - deg_to_rad(rot), 360.0)
	var start_local: float = fposmod(_gap_drag_start_mouse_angle - deg_to_rad(rot), 360.0)
	var delta_deg: float = rad_to_deg(cur_local_angle - start_local)
	# Normalize delta to (-180, 180] so dragging clockwise isn't a huge jump.
	if delta_deg > 180.0: delta_deg -= 360.0
	if delta_deg < -180.0: delta_deg += 360.0
	var def: Resource = p["def"]
	var g: Resource = def.gaps[_gap_drag_gap_idx]
	if _gap_drag_kind == GapDragKind.CENTER:
		g.center_angle_deg = fposmod(_gap_drag_start_value + delta_deg, 360.0)
	elif _gap_drag_kind == GapDragKind.LEFT_EDGE:
		var new_center: float = _gap_drag_start_value + delta_deg
		var new_width: float = absf(delta_deg) * 2.0
		g.center_angle_deg = fposmod(new_center, 360.0)
		g.width_deg = maxf(8.0, new_width)
	elif _gap_drag_kind == GapDragKind.RIGHT_EDGE:
		var new_width: float = absf(delta_deg) * 2.0
		g.width_deg = maxf(8.0, new_width)
	if piece_obj != null and "queue_redraw" in piece_obj:
		piece_obj.queue_redraw()
	queue_redraw()

func _commit_gap_drag() -> void:
	_save_all_pieces()

# Auto-align: if within align_threshold of a canvas guide, snap to it. Returns
# the snapped position with auto-align applied.
func _auto_align(pos: Vector2, viewport_size: Vector2) -> Vector2:
	var out: Vector2 = pos
	var ax: float = pos.x
	var ay: float = pos.y
	# Horizontal guides: left edge (0), center (W/2), right edge (W)
	var guides_x: Array[float] = [0.0, viewport_size.x * 0.5, float(viewport_size.x)]
	for gx in guides_x:
		if absf(ax - gx) <= align_threshold:
			ax = gx; break
	# Vertical guides: top hud area (200), visible center (605), bottom hud top (1080)
	var guides_y: Array[float] = [200.0, viewport_size.y * 0.5, 1080.0]
	for gy in guides_y:
		if absf(ay - gy) <= align_threshold:
			ay = gy; break
	return Vector2(ax, ay)

func _gui_input(event: InputEvent) -> void:
	if not _is_active: return
	if event is InputEventKey:
		_handle_key_nudge(event)
		return
	if not (event is InputEventMouseButton or event is InputEventMouseMotion): return
	var local_pos = get_local_mouse_position()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Measurement tool takes priority over everything else when active.
		if measure_mode:
			if _measure_state == MeasureMode.WAIT_A:
				_measure_a = local_pos
				_measure_state = MeasureMode.WAIT_B
				accept_event()
				queue_redraw()
				return
			elif _measure_state == MeasureMode.WAIT_B:
				_measure_b = local_pos
				_measure_state = MeasureMode.SHOW
				accept_event()
				queue_redraw()
				return
			else:
				# SHOW: start a new measurement.
				_measure_a = local_pos
				_measure_state = MeasureMode.WAIT_B
				accept_event()
				queue_redraw()
				return
		# Try lock-toggle first (priority)
		var lock_hit = _hit_test_lock(local_pos)
		if lock_hit >= 0:
			_toggle_lock(lock_hit)
			accept_event()
			return
		# Connector resize handles
		var conn_hit = _hit_test_connector_handle(local_pos)
		if conn_hit >= 0:
			_begin_resize_connector(conn_hit, local_pos)
			accept_event()
			return
		# Rotation ring handle (around the body). Higher priority than axis
		# handles so the dashed ring never steals a hit that was meant for
		# a resize dot near the body.
		var rot_hit = _hit_test_rotate_ring(local_pos)
		if rot_hit >= 0:
			_begin_rotate(rot_hit, local_pos)
			accept_event()
			return
		# Axis-aware resize handle. Returns (piece_idx, local_axis) or (-1, ZERO).
		var axis_res = _hit_test_axis_handle(local_pos)
		if axis_res[0] >= 0:
			_begin_resize_axis(axis_res[0], axis_res[1], local_pos)
			accept_event()
			return
		# Gap handle (M12). Returns (piece_idx, gap_idx, kind).
		var gap_res = _hit_test_gap_handle(local_pos)
		if gap_res[0] >= 0:
			_begin_gap_drag(gap_res[0], gap_res[1], int(gap_res[2]), local_pos)
			accept_event()
			return
		# Legacy single-radius handle (kept for back-compat smoke tests).
		var rad_hit = _hit_test_radius_handle(local_pos)
		if rad_hit >= 0:
			_begin_resize_radius(rad_hit, local_pos)
			accept_event()
			return
		# Body drag (lowest priority)
		var body_hit = _hit_test_body(local_pos)
		if body_hit >= 0:
			if _pieces[body_hit]["locked"]:
				if debug_print: print("Piece locked, ignoring drag")
				accept_event()
				return
			_dragging_piece_idx = body_hit
			_selected_piece_idx = body_hit
			_drag_mode = DragMode.MOVE_PIECE
			var p = _pieces[body_hit]
			_drag_offset = local_pos - p["center"]
			accept_event()
			return
	elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match _drag_mode:
			DragMode.MOVE_PIECE:
				_commit_move(_dragging_piece_idx, local_pos)
				_dragging_piece_idx = -1
				_drag_mode = DragMode.NONE
				accept_event()
			DragMode.RESIZE_RADIUS:
				_commit_resize_radius(_dragging_piece_idx, local_pos)
				_dragging_piece_idx = -1
				_drag_mode = DragMode.NONE
				accept_event()
			DragMode.RESIZE_AXIS:
				_commit_resize_axis(_dragging_piece_idx)
				_dragging_piece_idx = -1
				_drag_mode = DragMode.NONE
				accept_event()
			DragMode.RESIZE_CONNECTOR:
				_commit_resize_connector(local_pos)
				_resizing_link_idx = -1
				_drag_mode = DragMode.NONE
				accept_event()
			DragMode.ROTATE_PIECE:
				_commit_rotate()
				_dragging_piece_idx = -1
				_drag_mode = DragMode.NONE
				accept_event()
			DragMode.DRAG_GAP:
				_commit_gap_drag()
				_dragging_piece_idx = -1
				_gap_drag_piece_idx = -1
				_gap_drag_kind = GapDragKind.NONE
				_drag_mode = DragMode.NONE
				accept_event()
			_:
				pass
	elif event is InputEventMouseMotion:
		match _drag_mode:
			DragMode.MOVE_PIECE:
				if _dragging_piece_idx >= 0:
					var new_pos = local_pos - _drag_offset
					var snapped = Vector2(_snap(new_pos.x), _snap(new_pos.y))
					var p = _pieces[_dragging_piece_idx]
					p["piece"].global_position = snapped
					p["center"] = snapped
					accept_event()
			DragMode.RESIZE_RADIUS:
				if _dragging_piece_idx >= 0:
					_apply_resize_radius(_dragging_piece_idx, local_pos)
					accept_event()
			DragMode.RESIZE_AXIS:
				if _dragging_piece_idx >= 0:
					_apply_resize_axis(_dragging_piece_idx, local_pos)
					accept_event()
			DragMode.RESIZE_CONNECTOR:
				if _resizing_link_idx >= 0:
					_apply_resize_connector(local_pos)
					accept_event()
			DragMode.ROTATE_PIECE:
				if _dragging_piece_idx >= 0:
					_apply_rotate(_dragging_piece_idx, local_pos)
					accept_event()
			DragMode.DRAG_GAP:
				if _gap_drag_piece_idx >= 0:
					_apply_gap_drag(local_pos)
					accept_event()
					accept_event()

# Hit-tests --------------------------------------------------------------

# Section 12: Arrow-key nudge for the currently selected piece.
# Shift+Arrow = 10-unit (per directive: Shift+Arrow = 10 units).
# Snap is OPTIONAL — toggle off via snap_enabled.
# R toggles rotate-mode. In rotate-mode, arrow keys nudge the SELECTED piece's
# rotation by 5° (Shift = 45°). Outside rotate-mode, arrow keys nudge position
# by `nudge_unit` (Shift = nudge_unit * 10).
func _handle_key_nudge(event: InputEventKey) -> void:
	if not event.pressed or event.echo: return
	# Ctrl shortcuts (M19 / M20): undo, redo, copy, paste, duplicate, delete.
	if event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed:
		match event.keycode:
			KEY_Z:
				accept_event()
				if _document != null: _document.undo()
				queue_redraw()
				return
			KEY_C:
				accept_event()
				_copy_selected_to_clipboard()
				return
			KEY_V:
				accept_event()
				_paste_from_clipboard()
				return
			KEY_D:
				accept_event()
				_duplicate_selected()
				return
			KEY_DELETE, KEY_BACKSPACE:
				accept_event()
				_delete_selected()
				return
	if event.ctrl_pressed and event.shift_pressed and not event.alt_pressed:
		if event.keycode == KEY_Z:
			accept_event()
			if _document != null: _document.redo()
			queue_redraw()
			return
	if event.ctrl_pressed and not event.shift_pressed and not event.alt_pressed:
		if event.keycode == KEY_Y:
			accept_event()
			if _document != null: _document.redo()
			queue_redraw()
			return
	# R alone toggles rotate-mode (independent of selection so the user can
	# flip modes before they pick a piece).
	if event.keycode == KEY_R and not event.shift_pressed and not event.ctrl_pressed and not event.alt_pressed:
		rotate_mode = not rotate_mode
		accept_event()
		return
	# M alone toggles measure mode.
	if event.keycode == KEY_M and not event.shift_pressed and not event.ctrl_pressed and not event.alt_pressed:
		measure_mode = not measure_mode
		accept_event()
		return
	var target_idx: int = _dragging_piece_idx if _dragging_piece_idx >= 0 else _selected_piece_idx
	if target_idx < 0 or target_idx >= _pieces.size(): return
	var p = _pieces[target_idx]
	if p["locked"]: return

	if rotate_mode:
		# Arrow keys nudge rotation: 5° / Shift=45° / Alt=1° (precision).
		var step: float = 45.0 if event.shift_pressed else (1.0 if event.alt_pressed else 5.0)
		var ddeg: float = 0.0
		match event.keycode:
			KEY_LEFT:  ddeg = -step
			KEY_RIGHT: ddeg = step
			KEY_UP:    ddeg = -step
			KEY_DOWN:  ddeg = step
			_:
				return
		accept_event()
		var piece_obj = p["piece"]
		var def: Resource = p["def"]
		var cur: float = float(piece_obj.rotation_degrees) if "rotation_degrees" in piece_obj else float(def.start_angle_deg)
		var new_deg: float = fposmod(cur + ddeg, 360.0)
		if snap_enabled and not event.alt_pressed:
			# Alt is "precision" — no snap.
			new_deg = _snap_angle(new_deg, 5.0 if not event.shift_pressed else 45.0)
		piece_obj.rotation_degrees = new_deg
		if "current_angle_deg" in piece_obj:
			piece_obj.current_angle_deg = new_deg
		def.start_angle_deg = new_deg
		_save_all_pieces()
		queue_redraw()
		return

	# Position nudge. M8: arrow=1u, Shift=10u, Alt=0.1u.
	var unit: float = nudge_unit
	if event.shift_pressed: unit *= 10.0
	if event.alt_pressed: unit *= 0.1
	var dx: float = 0.0
	var dy: float = 0.0
	match event.keycode:
		KEY_LEFT:   dx = -unit
		KEY_RIGHT:  dx = unit
		KEY_UP:     dy = -unit
		KEY_DOWN:   dy = unit
		_:
			return
	accept_event()
	var np: Vector2 = p["piece"].global_position + Vector2(dx, dy)
	if snap_enabled and not event.alt_pressed:
		# Alt is "precision" — no snap.
		np = Vector2(_snap(np.x), _snap(np.y))
	p["piece"].global_position = np
	p["center"] = np
	p["def"].position = np
	# Live-save so the level reflects the change without waiting for drag-end.
	_save_all_pieces()
	queue_redraw()

func _snap_angle(deg: float, step: float) -> float:
	if step <= 0.0: return deg
	return round(deg / step) * step

# Optional LevelDocument binding so Ctrl+Z / Ctrl+Y can use it directly. The
# overlay still works for pieces that live in the runtime without a doc.
var _document: Resource = null
func set_document(doc) -> void:
	_document = doc
func _copy_selected_to_clipboard() -> void:
	if _selected_piece_idx < 0: return
	var p = _pieces[_selected_piece_idx]
	var def: Resource = p["def"]
	# Reuse the Inspector's clipboard if present; otherwise stash in
	# a singleton-ish dict the paste path reads.
	_clipboard_payload = def.to_dict() if def != null else {}
func _paste_from_clipboard() -> void:
	if _clipboard_payload.is_empty(): return
	if _document != null:
		# Use the document's paste_piece so we get undo support.
		var new_id: String = _document.paste_piece(_clipboard_payload, Vector2(20, 20))
		emit_signal("document_changed_requested", new_id)
		_save_all_pieces()
		queue_redraw()
		return
	# Fall back: insert into the puzzle directly.
	if _puzzle == null: return
	var new_piece = PieceDefinitionScript.new()
	new_piece.apply_dict(_clipboard_payload)
	new_piece.id = StringName("piece_copy_%d" % Time.get_ticks_msec())
	_puzzle.current_level_def.pieces.append(new_piece)
	_puzzle.load_level(_puzzle.current_level_def)
	_save_all_pieces()
	queue_redraw()
func _duplicate_selected() -> void:
	if _selected_piece_idx < 0: return
	var p = _pieces[_selected_piece_idx]
	if _document != null:
		var new_id: String = _document.duplicate_piece(String(p["id"]), Vector2(20, 20))
		emit_signal("document_changed_requested", new_id)
		_save_all_pieces()
		queue_redraw()
		return
	# Runtime fallback
	_copy_selected_to_clipboard()
	_paste_from_clipboard()
func _delete_selected() -> void:
	if _selected_piece_idx < 0: return
	var p = _pieces[_selected_piece_idx]
	if _document != null:
		_document.delete_piece(String(p["id"]))
		_selected_piece_idx = -1
		_save_all_pieces()
		queue_redraw()
		return
	# Runtime fallback
	if _puzzle == null: return
	var def = _puzzle.current_level_def
	var keep: Array = []
	for pp in def.pieces:
		if String(pp.id) != String(p["id"]):
			keep.append(pp)
	def.pieces.clear()
	for pp in keep: def.pieces.append(pp)
	_puzzle.load_level(def)
	_save_all_pieces()
	queue_redraw()

var _clipboard_payload: Dictionary = {}
signal document_changed_requested(selection_hint: String)

# Measurement tool (M10). State = "idle" | "wait_a" | "wait_b" | "show". When
# the user clicks with the M tool active, the click points are stored here.
enum MeasureMode { IDLE, WAIT_A, WAIT_B, SHOW }
var measure_mode: bool = false:
	set(v):
		measure_mode = v
		if v: _measure_state = MeasureMode.WAIT_A
		else:  _measure_state = MeasureMode.IDLE
		queue_redraw()
var _measure_state: int = MeasureMode.IDLE
var _measure_a: Vector2 = Vector2.ZERO
var _measure_b: Vector2 = Vector2.ZERO

# Status panel (M25) — show when something is selected.
var show_status_panel: bool = true

func _hit_test_body(local_pos: Vector2) -> int:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		var d = (p["center"] - local_pos).length()
		if d <= p["radius"] + 14.0:
			return i
	return -1

func _hit_test_lock(local_pos: Vector2) -> int:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		var lock_pos = p["center"] + Vector2(-(p["radius"] + 14.0), 0)
		if (lock_pos - local_pos).length() <= 12.0:
			return i
	return -1

func _hit_test_radius_handle(local_pos: Vector2) -> int:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		# Handle sits at the TOP of the ring body (12 o'clock in the ring's LOCAL
		# frame), rotated by the piece's current rotation so it tracks the ring
		# as the user drags it. Without the rotation term the handle drifts off
		# the visible top after the first drag.
		var piece_obj = p["piece"]
		var a: float = 90.0
		if piece_obj != null and "rotation_degrees" in piece_obj:
			a = 90.0 + float(piece_obj.rotation_degrees)
		var hx = p["center"].x + cos(deg_to_rad(a)) * (p["radius"] + 22.0)
		var hy = p["center"].y + sin(deg_to_rad(a)) * (p["radius"] + 22.0)
		if Vector2(hx, hy).distance_to(local_pos) <= 16.0:
			return i
	return -1

# Axis-aware resize handles. Returns [piece_idx, local_axis_vector].
# local_axis is in the piece's local frame: Vector2.RIGHT (1,0), DOWN (0,1),
# LEFT (-1,0), UP (0,-1). The hit zone is a circle radius=14 at the boundary
# point on each side, rotated by the piece's current rotation.
func _hit_test_axis_handle(local_pos: Vector2) -> Array:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		var piece_obj = p["piece"]
		var rot_deg: float = 0.0
		if piece_obj != null and "rotation_degrees" in piece_obj:
			rot_deg = float(piece_obj.rotation_degrees)
		var shape: int = int(p["def"].shape_type) if p["def"] != null and "shape_type" in p["def"] else 0
		# The four local axis vectors; rotated into world space.
		var axes: Array = [
			Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1),
		]
		for ax in axes:
			var world_ax: Vector2 = ax.rotated(deg_to_rad(rot_deg))
			var boundary: float = PieceGeometry.get_boundary_distance_for_piece(p["def"], ax.angle())
			var hit_pos: Vector2 = p["center"] + world_ax * (boundary + 16.0)
			if hit_pos.distance_to(local_pos) <= 14.0:
				return [i, ax]
	return [-1, Vector2.ZERO]

# Rotation ring: a hit zone on a dashed outer ring radius+30 around each piece.
# Returns the piece idx if the local pos is within 14px of the ring's circle,
# AND the angle from the piece center is consistent with the visible arrow
# marker (3-o'clock by default). The full ring is hittable; the arrow is just
# a visual cue.
func _hit_test_rotate_ring(local_pos: Vector2) -> int:
	for i in range(_pieces.size() - 1, -1, -1):
		var p = _pieces[i]
		var piece_obj = p["piece"]
		if piece_obj == null or not ("rotation_degrees" in piece_obj): continue
		var ring_r: float = float(p["radius"]) + 30.0
		var d: float = (p["center"] - local_pos).length()
		if absf(d - ring_r) <= 14.0:
			return i
	return -1

func _hit_test_connector_handle(local_pos: Vector2) -> int:
	# Look for a connector whose cuff (rendered at pos_cuff) is under the mouse.
	# But since we're an overlay, we need to compute pos_cuff ourselves.
	if _puzzle == null: return -1
	for idx in range(_puzzle.active_links.size()):
		var link_node = _puzzle.active_links[idx]
		var from_p = PuzzleRulesScript.get_piece_by_id(link_node.def.from_piece_id, _puzzle.active_pieces)
		if not is_instance_valid(from_p): continue
		if float(link_node.current_stem_dist) <= 1.0: continue
		var world_angle_rad := deg_to_rad(from_p.rotation_degrees + link_node.def.collar_angle_deg)
		var dir := Vector2.from_angle(world_angle_rad)
		var child_r: float = _get_child_boundary_distance(link_node, dir)
		var pos_cuff: Vector2 = from_p.position + dir * (link_node.current_stem_dist - child_r)
		if pos_cuff.distance_to(local_pos) <= 18.0:
			return idx
	return -1

func _get_child_boundary_distance(link_node, dir: Vector2) -> float:
	# Mirror of puzzle_controller.gd logic for child radius extraction.
	if _puzzle == null: return 0.0
	for p in _puzzle.active_pieces:
		if p and p.piece_id == link_node.def.to_piece_id:
			return float(p.radius)
	return 24.0

# Lock toggle ------------------------------------------------------------

func _toggle_lock(idx: int) -> void:
	_pieces[idx]["locked"] = not _pieces[idx]["locked"]
	queue_redraw()

# Body move commit --------------------------------------------------------

func _commit_move(idx: int, drop_pos: Vector2) -> void:
	var p = _pieces[idx]
	var pdef = p["def"]
	# Section 4 lock guard: if 'position' is locked, do not move.
	if pdef != null and pdef.is_property_locked("position"):
		if debug_print: print("Piece %s position locked; move ignored" % p["id"])
		return
	var snapped = Vector2(_snap(drop_pos.x - _drag_offset.x), _snap(drop_pos.y - _drag_offset.y))
	# Auto-align guides if near them
	var viewport_size := get_viewport_rect().size
	snapped = _auto_align(snapped, viewport_size)
	p["piece"].global_position = snapped
	p["center"] = snapped
	if pdef != null:
		pdef.position = snapped
	emit_signal("piece_moved", p["id"], snapped)
	_save_all_pieces()
	queue_redraw()

# Radius resize ---------------------------------------------------------

func _begin_resize_radius(idx: int, local_pos: Vector2) -> void:
	_dragging_piece_idx = idx
	_drag_mode = DragMode.RESIZE_RADIUS
	var p = _pieces[idx]
	var d = (local_pos - p["center"]).length()
	p["resize_start_radius"] = float(p["radius"])
	p["resize_start_dist"] = d

func _apply_resize_radius(idx: int, local_pos: Vector2) -> void:
	var p = _pieces[idx]
	# Section 4 size lock guard.
	if p["def"] != null and p["def"].is_property_locked("size"):
		if debug_print: print("Piece %s size locked; resize ignored" % p["id"])
		return
	var start_dist: float = float(p["resize_start_dist"])
	var start_rad: float = float(p["resize_start_radius"])
	if start_dist < 1.0: return
	var cur_dist = (local_pos - p["center"]).length()
	# New radius = original radius shifted by the delta in mouse distance.
	# Clamp 30..200.
	var new_rad = clamp(start_rad + (cur_dist - start_dist), 30.0, 200.0)
	p["radius"] = new_rad
	var pdef: Resource = p["def"]
	if pdef != null:
		pdef.radius = new_rad
		# OVAL has independent Y radius — keep it in lockstep so authored
		# dimensions don't drift when the user drags the resize handle.
		if int(pdef.shape_type) == int(PieceDefinition.ShapeType.OVAL):
			pdef.radius_y = new_rad
	# Live update the ring piece's radius field too.
	var piece = p["piece"]
	if piece and "radius" in piece:
		piece.radius = new_rad
		if int(pdef.shape_type) == int(PieceDefinition.ShapeType.OVAL):
			piece.radius_y = new_rad
		if "queue_redraw" in piece: piece.queue_redraw()
	queue_redraw()
	# Force the puzzle to redraw the connector at the new boundary.
	if _puzzle and _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()

func _commit_resize_radius(idx: int, _drop_pos: Vector2) -> void:
	# Persist on release.
	_save_all_pieces()

# Axis-aware resize --------------------------------------------------------

# SHAPE_AXIS_FIELDS maps each shape type to the two field names that should
# be mutated when the user drags along +X / +Y in the piece's LOCAL frame.
# For non-uniform shapes (OVAL, STRAIGHT, L_SHAPE) the X and Y fields differ.
# For PATH the X field name is "path_scale" — handled specially (uniform scale).

func _begin_resize_axis(idx: int, local_axis: Vector2, local_pos: Vector2) -> void:
	_dragging_piece_idx = idx
	_selected_piece_idx = idx
	_drag_mode = DragMode.RESIZE_AXIS
	_resize_axis = local_axis
	var p = _pieces[idx]
	var def: Resource = p["def"]
	var shape: int = int(def.shape_type) if def != null and "shape_type" in def else 0
	var routing: Dictionary = SHAPE_AXIS_FIELDS.get(shape, {"x": "radius", "y": "radius"})
	# Use the absolute-axis field: positive axes use +X, negative axes use +Y
	# (the routing dict maps both polarities). Negative axes still read the
	# matching field — sign of the drag delta is applied at apply time.
	var field_name: String = routing["x"] if absf(local_axis.x) > 0.5 else routing["y"]
	if def != null and field_name in def:
		_resize_original_field_value = float(def.get(field_name))
	else:
		_resize_original_field_value = 0.0
	# Remember how far the mouse was along the world axis at drag start so
	# we can compute the delta in apply.
	var piece_obj = p["piece"]
	var rot_deg: float = float(piece_obj.rotation_degrees) if piece_obj != null and "rotation_degrees" in piece_obj else 0.0
	var world_axis: Vector2 = local_axis.rotated(deg_to_rad(rot_deg))
	_resize_original_dist_along_axis = (local_pos - p["center"]).dot(world_axis)
	# For PATH we scale path_points by a ratio; remember the average radial
	# distance from the piece center at drag-start so we can map the
	# per-frame drag delta to a uniform scale factor.
	if shape == 6:
		var pts = def.path_points if def != null and "path_points" in def else []
		var sum: float = 0.0
		var count: int = 0
		for pt in pts:
			sum += Vector2(pt.x, pt.y).length()
			count += 1
		_resize_original_path_anchor = sum / maxf(1.0, float(count))

func _apply_resize_axis(idx: int, local_pos: Vector2) -> void:
	var p = _pieces[idx]
	# Section 4 size lock guard.
	if p["def"] != null and p["def"].is_property_locked("size"):
		if debug_print: print("Piece %s size locked; axis resize ignored" % p["id"])
		return
	var def: Resource = p["def"]
	var shape: int = int(def.shape_type) if def != null and "shape_type" in def else 0
	var routing: Dictionary = SHAPE_AXIS_FIELDS.get(shape, {"x": "radius", "y": "radius"})
	var field_name: String = routing["x"] if absf(_resize_axis.x) > 0.5 else routing["y"]
	var piece_obj = p["piece"]
	var rot_deg: float = float(piece_obj.rotation_degrees) if piece_obj != null and "rotation_degrees" in piece_obj else 0.0
	var world_axis: Vector2 = _resize_axis.rotated(deg_to_rad(rot_deg))
	var cur_along: float = (local_pos - p["center"]).dot(world_axis)
	var delta: float = cur_along - _resize_original_dist_along_axis

	# OVAL Y-axis needs to read/write radius_y, not radius. Map both polarities
	# of Y to the y field (the routing dict stores the canonical field name).
	# Apply a 2x move delta → 2x field change (1:1 with screen distance).
	var new_val: float = _resize_original_field_value + delta

	# Clamp to a reasonable authoring range. Tight lower bound so connectors
	# always have somewhere to land; upper bound matches the existing legacy
	# clamp on the circle resize handle.
	if shape == 6:
		# PATH: scale every path_point's distance from origin by new_val /
		# _resize_original_path_anchor.
		if _resize_original_path_anchor > 0.001:
			var factor: float = new_val / _resize_original_path_anchor
			factor = clamp(factor, 0.25, 4.0)
			var pts = def.path_points if def != null and "path_points" in def else []
			for i in range(pts.size()):
				var pt: Vector2 = Vector2(pts[i].x, pts[i].y)
				var new_pt: Vector2 = pt * factor
				pts[i] = {"x": float(new_pt.x), "y": float(new_pt.y)}
			def.path_points = pts
	else:
		# Snap to integer when snap is enabled so authored values stay clean.
		if snap_enabled:
			new_val = round(new_val)
		new_val = clamp(new_val, 16.0, 400.0)
		if def != null and field_name in def:
			def.set(field_name, new_val)
		# Keep runtime fields (ring_piece_2d.radius / .radius_y) in sync.
		if piece_obj != null:
			if field_name == "radius" and "radius" in piece_obj:
				piece_obj.radius = new_val
			elif field_name == "radius_y" and "radius_y" in piece_obj:
				piece_obj.radius_y = new_val
		# p["radius"] is the cached display radius for OVAL/CIRCLE — keep it
		# consistent with whatever was just changed.
		if field_name == "radius":
			p["radius"] = new_val
		elif field_name == "radius_y" and p["def"] != null and "radius" in p["def"]:
			# OVAL: display radius only follows when shape is uniform.
			pass

	if piece_obj != null and "queue_redraw" in piece_obj:
		piece_obj.queue_redraw()
	queue_redraw()
	if _puzzle and _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()

func _commit_resize_axis(idx: int) -> void:
	_save_all_pieces()

# Rotation drag ------------------------------------------------------------

func _begin_rotate(idx: int, local_pos: Vector2) -> void:
	_dragging_piece_idx = idx
	_selected_piece_idx = idx
	_drag_mode = DragMode.ROTATE_PIECE
	var p = _pieces[idx]
	var piece_obj = p["piece"]
	_rotate_start_angle = float(piece_obj.rotation_degrees) if piece_obj != null and "rotation_degrees" in piece_obj else float(p["def"].start_angle_deg)
	_rotate_start_mouse_angle = (local_pos - p["center"]).angle()

func _apply_rotate(idx: int, local_pos: Vector2) -> void:
	var p = _pieces[idx]
	# Section 4 rotation lock guard.
	if p["def"] != null and p["def"].is_property_locked("rotation"):
		if debug_print: print("Piece %s rotation locked; rotate ignored" % p["id"])
		return
	var cur_mouse_angle: float = (local_pos - p["center"]).angle()
	var delta_deg: float = rad_to_deg(cur_mouse_angle - _rotate_start_mouse_angle)
	if snap_enabled:
		delta_deg = _snap_angle(delta_deg, 5.0)
	var new_deg: float = fposmod(_rotate_start_angle + delta_deg, 360.0)
	var piece_obj = p["piece"]
	if piece_obj != null and "rotation_degrees" in piece_obj:
		piece_obj.rotation_degrees = new_deg
		if "current_angle_deg" in piece_obj:
			piece_obj.current_angle_deg = new_deg
	var def: Resource = p["def"]
	if def != null:
		def.start_angle_deg = new_deg
	queue_redraw()
	if _puzzle and _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()

func _commit_rotate() -> void:
	_save_all_pieces()

# Connector resize ------------------------------------------------------

func _begin_resize_connector(link_idx: int, local_pos: Vector2) -> void:
	_resizing_link_idx = link_idx
	_drag_mode = DragMode.RESIZE_CONNECTOR
	var link_node = _puzzle.active_links[link_idx]
	var from_p_v = PuzzleRulesScript.get_piece_by_id(link_node.def.from_piece_id, _puzzle.active_pieces)
	if not is_instance_valid(from_p_v): return
	var from_p: Node2D = from_p_v
	var world_angle_rad := deg_to_rad(from_p.rotation_degrees + link_node.def.collar_angle_deg)
	_resize_axis_dir = Vector2.from_angle(world_angle_rad)
	_resize_original_stem_dist = float(link_node.current_stem_dist)
	# Use global_position consistently for both begin and apply so the parent
	# transforms cancel.
	var from_pos: Vector2 = from_p.global_position
	_resize_original_offset = (local_pos - from_pos).dot(_resize_axis_dir)

func _apply_resize_connector(local_pos: Vector2) -> void:
	# Project the mouse onto the link axis to find desired stem distance.
	var link_node = _puzzle.active_links[_resizing_link_idx]
	var from_p_v = PuzzleRulesScript.get_piece_by_id(link_node.def.from_piece_id, _puzzle.active_pieces)
	if not is_instance_valid(from_p_v): return
	# Section 4 connectors lock guard on the parent piece.
	if from_p_v.def != null and from_p_v.def.is_property_locked("connectors"):
		if debug_print: print("Connector on %s locked; resize ignored" % from_p_v.def.id)
		return
	var from_p: Node2D = from_p_v
	# Use from_p.global_position (consistent with begin), so projection stays
	# anchored on the parent's current world position even if Node2D parent
	# of pieces_container transforms during a drop animation.
	var from_pos: Vector2 = from_p.global_position
	var along: float = (local_pos - from_pos).dot(_resize_axis_dir)
	var delta: float = along - _resize_original_offset
	var new_dist: float = clamp(_resize_original_stem_dist + delta, 40.0, 600.0)
	link_node.current_stem_dist = new_dist
	queue_redraw()
	if _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()

func _commit_resize_connector(_drop_pos: Vector2) -> void:
	# Persist the new stem_dist back to the def so JSON survives reload.
	var link_node = _puzzle.active_links[_resizing_link_idx]
	link_node.def.stem_dist = float(link_node.current_stem_dist)
	# Re-run bind to ensure cuff geometry stays consistent with the new distance.
	if _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()
	_save_all_pieces()

# Save (unchanged from previous) -----------------------------------------

func _save_all_pieces() -> void:
	if _puzzle == null: return
	# Prefer the injected level id (set by GameplayScreen via set_level_id).
	# Fall back to the parent-chain walk only if not injected (legacy caller).
	var level_id: int = _level_id
	if level_id <= 0:
		var gp: Node = _puzzle.get_parent()
		while gp != null and not gp.has_method("load_level_by_id"):
			gp = gp.get_parent()
		if gp == null:
			if debug_print: print("_save_all_pieces: gameplay screen not found in parent chain")
			return
		if "current_level_id" in gp:
			level_id = int(gp.current_level_id)
	if level_id <= 0:
		if debug_print: print("_save_all_pieces: bad level_id=", level_id)
		return
	var pieces_obj: Array = []
	for entry in _pieces:
		var pdef = entry["def"]
		var d: Dictionary = (pdef as PieceDefinition).to_dict()
		# Overlay-only metadata that is NOT in PieceDefinition schema.
		d["locked"] = bool(entry["locked"])
		pieces_obj.append(d)
	var links_obj: Array = []
	for pl in _puzzle.active_links:
		var ld = pl.def
		var ld_d: Dictionary = (ld as LinkDefinition).to_dict()
		# Runtime-only state (not authored, lives in ConnectorRuntime).
		ld_d["runtime_current_stem_dist"] = float(pl.current_stem_dist)
		links_obj.append(ld_d)
	var data = {
		"id": level_id,
		"title": "Level %d" % level_id,
		"source": "in-game-edit-overlay",
		"pieces": pieces_obj,
		"links": links_obj,
	}
	var path := "res://data/user_levels/%d.json" % level_id
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		if debug_print: print("_save_all_pieces: FileAccess.open failed for ", path, " err=", FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(data, "  "))
	f.close()
	if debug_print:
		print("Saved %d.json after edit (%d pieces, %d links)" % [level_id, pieces_obj.size(), links_obj.size()])

func _color_name(c: Color) -> String:
	var palette := {
		"orange": Color("#EA7829"),
		"cyan":   Color("#32ADDA"),
		"purple": Color("#7B61FF"),
		"red":    Color("#E63946"),
		"green":  Color("#3EC6B0"),
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

func _color_hex(c: Color) -> String:
	var r: int = int(round(c.r * 255))
	var g: int = int(round(c.g * 255))
	var b: int = int(round(c.b * 255))
	return "#%02X%02X%02X" % [r, g, b]

# Draw debug ID labels for each piece (Section 14). Always rendered behind
# gameplay pieces (this function is called BEFORE the piece rendering loop)
# so the user sees the real ring on top with a small ID label nearby.
func _draw_debug_ids_for_pieces() -> void:
	if _puzzle == null: return
	var container = _puzzle.get("pieces_container") if _puzzle else null
	if container == null: container = _puzzle
	var font = ThemeDB.fallback_font
	if font == null: return
	var label_color = Color(0.05, 0.05, 0.1, 0.92)
	var bg_color = Color(1.0, 1.0, 1.0, 0.65)
	for child in container.get_children():
		if not (child is Node2D): continue
		var d = child.def if "def" in child else null
		if d == null: continue
		var pos: Vector2 = child.global_position
		var radius: float = float(d.radius)
		# Bounding box outline.
		draw_rect(Rect2(pos.x - radius, pos.y - radius, radius * 2, radius * 2),
				Color(0.0, 0.4, 0.8, 0.5), false, 2.0)
		# ID label at the piece center.
		var id_text: String = String(d.id)
		draw_string(font, pos + Vector2(-30, 5), id_text,
				HORIZONTAL_ALIGNMENT_CENTER, 60, 18, label_color)
		# Coordinate label below.
		var coord_text: String = "(%d, %d)" % [int(pos.x), int(pos.y)]
		draw_string(font, pos + Vector2(-30, radius + 18), coord_text,
				HORIZONTAL_ALIGNMENT_CENTER, 60, 14, label_color)
		# Radius label above.
		var r_text: String = "r=%d t=%d z=%d" % [int(radius), int(float(d.thickness)), int(d.z_index)]
		draw_string(font, pos + Vector2(-30, -radius - 8), r_text,
				HORIZONTAL_ALIGNMENT_CENTER, 60, 14, label_color)
		# Gap summary.
		if d.gaps.size() > 0:
			var first_gap = d.gaps[0]
			var g_text: String = "gap[0]: %d° wide" % int(float(first_gap.width_deg))
			draw_string(font, pos + Vector2(-30, radius + 32), g_text,
					HORIZONTAL_ALIGNMENT_CENTER, 60, 14, label_color)
		# Motion axis indicator.
		var axis: Vector2 = d.motion_axis if d.motion_axis.length_squared() > 0.001 else Vector2.RIGHT
		draw_line(pos, pos + axis.normalized() * (radius * 0.6),
				Color(0.4, 0.0, 0.7, 0.85), 2.0)
		# Connector ID labels.
	if _puzzle.active_links != null:
		for pl in _puzzle.active_links:
			var ld = pl.def
			var from_p = PuzzleRulesScript.get_piece_by_id(ld.from_piece_id, _puzzle.active_pieces)
			if not is_instance_valid(from_p): continue
			var world_angle_rad := deg_to_rad(from_p.rotation_degrees + ld.collar_angle_deg)
			var dir := Vector2.from_angle(world_angle_rad)
			var child_r: float = float(ld.cuff_depth) * 0.5
			var pos_cuff: Vector2 = from_p.position + dir * (float(pl.current_stem_dist) - child_r)
			var link_text: String = String(ld.id) + "  d=" + str(int(float(pl.current_stem_dist)))
			draw_string(font, pos_cuff + Vector2(-30, 4), link_text,
					HORIZONTAL_ALIGNMENT_CENTER, 60, 14, Color(0.6, 0.2, 0.0, 0.9))

# Drawing -----------------------------------------------------------------

func _draw_grid() -> void:
	var sz = get_viewport_rect().size
	var grid_color = Color(0.85, 0.7, 0.55, 0.18)
	var step: int = int(grid_size) if grid_size >= 4.0 else 4
	for x in range(0, int(sz.x), step):
		draw_line(Vector2(x, 0), Vector2(x, sz.y), grid_color, 1.0)
	for y in range(0, int(sz.y), step):
		draw_line(Vector2(0, y), Vector2(sz.x, y), grid_color, 1.0)
	# Rulers: top and left edges with numeric ticks (every 50 units).
	var tick_step: int = 50
	var tick_color = Color(0.95, 0.7, 0.3, 0.85)
	var font = ThemeDB.fallback_font
	if font != null:
		for x in range(0, int(sz.x), tick_step):
			draw_line(Vector2(x, 0), Vector2(x, 12), tick_color, 1.0)
			if x % 100 == 0:
				draw_string(font, Vector2(x + 2, 11), str(x), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.7, 0.3, 0.9))
		for y in range(0, int(sz.y), tick_step):
			draw_line(Vector2(0, y), Vector2(12, y), tick_color, 1.0)
			if y % 100 == 0:
				draw_string(font, Vector2(2, y - 1), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.95, 0.7, 0.3, 0.9))

func _draw_guides() -> void:
	var sz = get_viewport_rect().size
	var guide_color = Color(0.95, 0.7, 0.3, 0.7)
	# Vertical center
	draw_line(Vector2(sz.x * 0.5, 0), Vector2(sz.x * 0.5, sz.y), guide_color, 1.0)
	# Horizontal mid-band
	draw_line(Vector2(0, sz.y * 0.5), Vector2(sz.x, sz.y * 0.5), guide_color, 1.0)
	# User-defined guides from the LevelDocument (if any).
	if _document != null:
		for g in _document.guides:
			var axis_s: String = String((g as Dictionary).get("axis", "x"))
			var val: float = float((g as Dictionary).get("value", 0.0))
			if axis_s == "x":
				draw_line(Vector2(val, 0), Vector2(val, sz.y), Color(0.55, 0.95, 0.4, 0.85), 1.5)
			else:
				draw_line(Vector2(0, val), Vector2(sz.x, val), Color(0.55, 0.95, 0.4, 0.85), 1.5)

func _draw() -> void:
	if not _is_active: return
	_draw_grid()
	_draw_guides()
	# Pre-compute connector positions for the visible handles.
	var link_cuff_positions: Dictionary = {}
	if _puzzle:
		for idx in range(_puzzle.active_links.size()):
			var link_node = _puzzle.active_links[idx]
			var from_p = PuzzleRulesScript.get_piece_by_id(link_node.def.from_piece_id, _puzzle.active_pieces)
			if not is_instance_valid(from_p): continue
			if float(link_node.current_stem_dist) <= 1.0: continue
			var world_angle_rad := deg_to_rad(from_p.rotation_degrees + link_node.def.collar_angle_deg)
			var dir := Vector2.from_angle(world_angle_rad)
			var child_r: float = _get_child_boundary_distance(link_node, dir)
			var pos_cuff: Vector2 = from_p.position + dir * (link_node.current_stem_dist - child_r)
			link_cuff_positions[idx] = {
				"pos": pos_cuff,
				"dir": dir,
				"color": link_node.def.joint_color if link_node.def.joint_color != Color.TRANSPARENT else from_p.ring_color,
			}
			# Connector handle marker
			draw_circle(pos_cuff, 10.0, Color(0.95, 0.7, 0.3, 0.95))
			# Plus sign
			draw_line(pos_cuff + Vector2(-6, 0), pos_cuff + Vector2(6, 0), Color(0.2, 0.13, 0.08), 2.0)
			draw_line(pos_cuff + Vector2(0, -6), pos_cuff + Vector2(0, 6), Color(0.2, 0.13, 0.08), 2.0)
	for i in range(_pieces.size()):
		var p = _pieces[i]
		var pos: Vector2 = p["center"]
		var radius: float = float(p["radius"])
		var is_dragging := (i == _dragging_piece_idx and _drag_mode == DragMode.MOVE_PIECE)
		var piece_obj = p["piece"]
		var handle_rot_deg: float = 0.0
		if piece_obj != null and "rotation_degrees" in piece_obj:
			handle_rot_deg = float(piece_obj.rotation_degrees)
		# Body outline
		var outline_color = Color(0.4, 0.4, 0.4, 0.4) if p["locked"] else Color(0.95, 0.7, 0.3, 0.85)
		draw_arc(pos, radius + 6.0, 0, 360, 64, outline_color, 2.0)
		# Rotation ring: dashed outer circle at radius+30, with a directional
		# arrow at the 3-o'clock position pointing along +X (so the user
		# understands "drag me to spin").
		if not p["locked"]:
			var rot_ring_r: float = radius + 30.0
			# Dashed effect: 12 short arcs around the circle.
			var segs := 24
			for s in range(segs):
				if s % 2 == 1: continue
				var a0 := TAU * float(s) / float(segs)
				var a1 := TAU * float(s + 1) / float(segs)
				draw_arc(pos, rot_ring_r, a0, a1, 8, Color(0.55, 0.32, 0.12, 0.85), 1.5, true)
			# Directional arrow head at the 3-o'clock position. Pointing
			# tangentially (counter-clockwise) so it reads as "rotate me."
			var arrow_pos: Vector2 = pos + Vector2(rot_ring_r, 0)
			draw_circle(arrow_pos, 9.0, Color(0.95, 0.7, 0.3, 0.95))
			# Arrow shape — two short tangential lines.
			draw_line(arrow_pos + Vector2(-4, -6), arrow_pos + Vector2(4, 0), Color(0.2, 0.13, 0.08, 0.9), 2.0)
			draw_line(arrow_pos + Vector2(-4, 6), arrow_pos + Vector2(4, 0), Color(0.2, 0.13, 0.08, 0.9), 2.0)
		# Drag-to-move grip dot at the right rim (still useful as a "grab here"
		# affordance; not the same as the rotate ring above).
		var grip_pos = pos + Vector2(radius + 18.0, 0)
		draw_circle(grip_pos, 8.0, Color(0.95, 0.7, 0.3, 0.95))
		# Lock icon at the LEFT rim (small box + dot)
		var lock_pos = pos + Vector2(-(radius + 18.0), 0)
		var locked: bool = bool(p["locked"])
		var lock_bg = Color(0.95, 0.7, 0.3, 0.95) if not locked else Color(0.85, 0.25, 0.25, 0.95)
		draw_circle(lock_pos, 12.0, lock_bg)
		if locked:
			# Closed lock — slash
			draw_line(lock_pos + Vector2(-6, -6), lock_pos + Vector2(6, 6), Color(1, 1, 1), 2.0)
		else:
			# Open lock — small dot in middle
			draw_circle(lock_pos, 3.0, Color(1, 1, 1, 0.9))
		# Axis-aware resize handles: one dot on each cardinal direction in the
		# piece's local frame, with a small arrow showing which axis it drags.
		# Works on EVERY shape because we use PieceGeometry's boundary function
		# to place the dot on the actual outline.
		if not p["locked"] and p["def"] != null:
			var shape_t: int = int(p["def"].shape_type) if "shape_type" in p["def"] else 0
			var routing: Dictionary = SHAPE_AXIS_FIELDS.get(shape_t, {"x": "radius", "y": "radius"})
			var cardinals: Array = [
				{"ax": Vector2(1, 0), "label": "x"},
				{"ax": Vector2(-1, 0), "label": "x"},
				{"ax": Vector2(0, 1), "label": "y"},
				{"ax": Vector2(0, -1), "label": "y"},
			]
			for c in cardinals:
				var ax_local: Vector2 = c["ax"]
				var ax_world: Vector2 = ax_local.rotated(deg_to_rad(handle_rot_deg))
				var boundary: float = PieceGeometry.get_boundary_distance_for_piece(p["def"], ax_local.angle())
				var dot_pos: Vector2 = pos + ax_world * (boundary + 14.0)
				draw_circle(dot_pos, 7.0, Color(0.95, 0.7, 0.3, 0.95))
				draw_arc(dot_pos, 7.0, 0, TAU, 16, Color(0.2, 0.13, 0.08, 0.9), 1.5, true)
				# Tiny arrow inside the dot pointing along its axis.
				var arrow_dir: Vector2 = ax_world
				draw_line(dot_pos - arrow_dir * 4.0, dot_pos + arrow_dir * 4.0, Color(0.2, 0.13, 0.08, 0.95), 1.5)
			# Gap drag handles (M12). One center dot + two edge dots on the
			# boundary circle, at the gap's center and edges.
			if not p["locked"] and "gaps" in p["def"] and p["def"].gaps.size() > 0:
				for gi in range(p["def"].gaps.size()):
					var g: Resource = p["def"].gaps[gi]
					var cd: float = float(g.center_angle_deg)
					var wd: float = float(g.width_deg)
					var ld: float = fposmod(cd - wd * 0.5, 360.0)
					var rd: float = fposmod(cd + wd * 0.5, 360.0)
					var wc: float = handle_rot_deg + cd
					var wl: float = handle_rot_deg + ld
					var wr: float = handle_rot_deg + rd
					var pt_c: Vector2 = pos + Vector2(cos(deg_to_rad(wc)), sin(deg_to_rad(wc))) * radius
					var pt_l: Vector2 = pos + Vector2(cos(deg_to_rad(wl)), sin(deg_to_rad(wl))) * radius
					var pt_r: Vector2 = pos + Vector2(cos(deg_to_rad(wr)), sin(deg_to_rad(wr))) * radius
					# Draw the gap arc boundary in white so the user sees the
					# actual gap they're editing.
					draw_arc(pos, radius, deg_to_rad(wl), deg_to_rad(wr), 16, Color(0.95, 0.95, 0.95, 0.6), 1.5, true)
					# Center handle: orange diamond.
					draw_circle(pt_c, 7.0, Color(0.95, 0.7, 0.3, 0.95))
					draw_arc(pt_c, 7.0, 0, TAU, 16, Color(0.2, 0.13, 0.08, 0.9), 1.2, true)
					# Edge handles: small triangles.
					draw_circle(pt_l, 5.0, Color(0.95, 0.4, 0.7, 0.95))
					draw_circle(pt_r, 5.0, Color(0.95, 0.4, 0.7, 0.95))
		# Center mark for the dragged piece
		if is_dragging:
			draw_circle(pos, 4.0, Color(0.95, 0.7, 0.3))
		# Selected-piece badge — extra glow around the active selection so the
		# user knows which piece arrow keys will affect.
		if i == _selected_piece_idx and not p["locked"]:
			draw_arc(pos, radius + 10.0, 0, TAU, 64, Color(0.20, 0.55, 0.95, 0.85), 2.5, true)
	# Rotate-mode badge: a small caption in the top-left of the overlay so
	# users know that arrow keys now nudge rotation, not position.
	if rotate_mode:
		var font = ThemeDB.fallback_font
		if font != null:
			var badge := "ROTATE MODE  (R to exit, Shift+Arrow = 45\u00b0)"
			draw_rect(Rect2(8, 8, 360, 22), Color(0.20, 0.55, 0.95, 0.95), true)
			draw_string(font, Vector2(14, 24), badge, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color.WHITE)

	# Debug ID mode (Section 14): per-piece ID, center, bbox, gap boundaries,
	# motion axis, z_index. Renders as overlays on top of the gameplay pieces
	# so the user can see exactly which authored value maps to which object.
	if show_debug_ids:
		_draw_debug_ids_for_pieces()

	# Measurement tool (M10) overlay.
	if measure_mode:
		_draw_measurement()

	# Status panel (M25) — show the selected piece's numbers.
	if show_status_panel and _selected_piece_idx >= 0 and _selected_piece_idx < _pieces.size():
		_draw_status_panel()

func _draw_measurement() -> void:
	var font = ThemeDB.fallback_font
	if font == null: return
	var color_a = Color(0.2, 0.85, 0.95, 0.95)
	var color_b = Color(0.95, 0.45, 0.2, 0.95)
	# Cross-hairs on the picked points.
	draw_circle(_measure_a, 6.0, color_a)
	draw_circle(_measure_b, 6.0, color_b)
	draw_string(font, _measure_a + Vector2(8, -6), "A", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color_a)
	draw_string(font, _measure_b + Vector2(8, -6), "B", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color_b)
	if _measure_state == MeasureMode.SHOW:
		draw_line(_measure_a, _measure_b, Color(0.9, 0.9, 0.5, 0.85), 2.0)
		var dx: float = _measure_b.x - _measure_a.x
		var dy: float = _measure_b.y - _measure_a.y
		var dist: float = sqrt(dx * dx + dy * dy)
		var angle: float = fposmod(rad_to_deg(atan2(dy, dx)), 360.0)
		var mid: Vector2 = (_measure_a + _measure_b) * 0.5
		var lines: Array = [
			"d=%.2f" % dist,
			"dx=%.2f dy=%.2f" % [dx, dy],
			"angle=%.2f\u00b0" % angle,
		]
		var box_h: int = 16 * lines.size() + 8
		draw_rect(Rect2(mid.x - 60, mid.y - box_h, 200, box_h), Color(0, 0, 0, 0.6), true)
		for i in range(lines.size()):
			draw_string(font, mid + Vector2(-56, -box_h + 16 + 14 * i), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
	elif _measure_state == MeasureMode.WAIT_B:
		# Live preview: draw a line from A to the current mouse position.
		var m: Vector2 = get_local_mouse_position()
		draw_line(_measure_a, m, Color(0.6, 0.6, 0.5, 0.5), 1.5)

func _draw_status_panel() -> void:
	var p = _pieces[_selected_piece_idx]
	var def: Resource = p["def"]
	if def == null: return
	var font = ThemeDB.fallback_font
	if font == null: return
	var lines: Array = [
		"%s  (%s)" % [String(def.id), _shape_short(def)],
		"x=%.2f  y=%.2f" % [float(def.position.x), float(def.position.y)],
		"radius=%.2f  thickness=%.2f" % [float(def.radius), float(def.thickness)],
		"start_angle=%.2f" % float(def.start_angle_deg),
		"gaps=%d  z_index=%d" % [def.gaps.size(), int(def.z_index)],
	]
	var sz = get_viewport_rect().size
	var panel_w: int = 280
	var panel_h: int = 16 * lines.size() + 14
	draw_rect(Rect2(sz.x - panel_w - 12, 36, panel_w, panel_h), Color(0, 0, 0, 0.55), true)
	for i in range(lines.size()):
		draw_string(font, Vector2(sz.x - panel_w - 4, 36 + 18 + 14 * i), lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _shape_short(def: Resource) -> String:
	match int(def.shape_type):
		0: return "CIRCLE"
		1: return "ROUNDED_SQUARE"
		2: return "ROUNDED_TRIANGLE"
		3: return "OVAL"
		4: return "STRAIGHT"
		5: return "L_SHAPE"
		6: return "PATH"
	return "?"
