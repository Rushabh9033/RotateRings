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
	TOGGLE_LOCK,
}

var _is_active: bool = false
var _pieces: Array = []              # [{id, piece, def, center, radius, locked}]
var _dragging_piece_idx: int = -1
var _drag_offset: Vector2 = Vector2.ZERO
var _drag_mode: int = DragMode.NONE
var _puzzle: Node = null

# Per-resize state for connector length
var _resizing_link_idx: int = -1       # index into _puzzle.active_links
var _resize_axis_dir: Vector2 = Vector2.ZERO  # unit vector from cuff to parent piece
var _resize_original_stem_dist: float = 0.0
var _resize_original_offset: float = 0.0

# Public API --------------------------------------------------------------

func set_puzzle(p: Node) -> void:
	_puzzle = p

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

func _process(_delta: float) -> void:
	# Refresh centers each frame in case pieces animate.
	for i in range(_pieces.size()):
		var p = _pieces[i]["piece"]
		if is_instance_valid(p):
			_pieces[i]["center"] = p.global_position

# Snap helper: rounds to nearest grid_size multiple, optionally aligning to a guide.
func _snap(v: float) -> float:
	return round(v / grid_size) * grid_size

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
		# Radius resize handles
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
			DragMode.RESIZE_CONNECTOR:
				_commit_resize_connector(local_pos)
				_resizing_link_idx = -1
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
			DragMode.RESIZE_CONNECTOR:
				if _resizing_link_idx >= 0:
					_apply_resize_connector(local_pos)
					accept_event()

# Hit-tests --------------------------------------------------------------

# Section 12: Arrow-key nudge for the currently selected piece.
# Shift+Arrow = 10-unit (per directive: Shift+Arrow = 10 units).
# Snap is OPTIONAL — toggle off via snap_enabled.
func _handle_key_nudge(event: InputEventKey) -> void:
	if not event.pressed or event.echo: return
	if _dragging_piece_idx < 0 or _dragging_piece_idx >= _pieces.size(): return
	var unit: float = nudge_unit * 10.0 if event.shift_pressed else nudge_unit
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
	var p = _pieces[_dragging_piece_idx]
	var np: Vector2 = p["piece"].global_position + Vector2(dx, dy)
	if snap_enabled:
		np = Vector2(_snap(np.x), _snap(np.y))
	p["piece"].global_position = np
	p["center"] = np
	p["def"].position = np
	# Live-save so the level reflects the change without waiting for drag-end.
	_save_all_pieces()
	queue_redraw()

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
		# Handle sits at the TOP of the ring (12 o'clock world, but rotated by piece)
		var a = 90.0  # top-of-ring in screen-up convention
		var hx = p["center"].x + cos(deg_to_rad(a)) * (p["radius"] + 22.0)
		var hy = p["center"].y + sin(deg_to_rad(a)) * (p["radius"] + 22.0)
		if Vector2(hx, hy).distance_to(local_pos) <= 16.0:
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
	var snapped = Vector2(_snap(drop_pos.x - _drag_offset.x), _snap(drop_pos.y - _drag_offset.y))
	# Auto-align guides if near them
	var viewport_size := get_viewport_rect().size
	snapped = _auto_align(snapped, viewport_size)
	p["piece"].global_position = snapped
	p["center"] = snapped
	var pdef = p["def"]
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
	# Live update the ring piece's radius field too.
	var piece = p["piece"]
	if piece and "radius" in piece:
		piece.radius = new_rad
		if "queue_redraw" in piece: piece.queue_redraw()
	queue_redraw()
	# Force the puzzle to redraw the connector at the new boundary.
	if _puzzle and _puzzle.has_method("_redraw_connectors"):
		_puzzle._redraw_connectors()

func _commit_resize_radius(idx: int, _drop_pos: Vector2) -> void:
	# Persist on release.
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
	var gp: Node = _puzzle.get_parent()
	while gp != null and not gp.has_method("load_level_by_id"):
		gp = gp.get_parent()
	if gp == null:
		if debug_print: print("_save_all_pieces: gameplay screen not found in parent chain")
		return
	var level_id: int = -1
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
	for x in range(0, int(sz.x), int(grid_size)):
		draw_line(Vector2(x, 0), Vector2(x, sz.y), grid_color, 1.0)
	for y in range(0, int(sz.y), int(grid_size)):
		draw_line(Vector2(0, y), Vector2(sz.x, y), grid_color, 1.0)

func _draw_guides() -> void:
	var sz = get_viewport_rect().size
	var guide_color = Color(0.95, 0.7, 0.3, 0.7)
	# Vertical center
	draw_line(Vector2(sz.x * 0.5, 0), Vector2(sz.x * 0.5, sz.y), guide_color, 1.0)
	# Horizontal mid-band
	draw_line(Vector2(0, sz.y * 0.5), Vector2(sz.x, sz.y * 0.5), guide_color, 1.0)

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
		# Body outline
		var outline_color = Color(0.4, 0.4, 0.4, 0.4) if p["locked"] else Color(0.95, 0.7, 0.3, 0.85)
		draw_arc(pos, radius + 6.0, 0, 360, 64, outline_color, 2.0)
		# Drag-to-move grip dot at the right rim
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
		# Top-edge handle for radius resize
		var top_handle = pos + Vector2(0, -(radius + 22.0))
		draw_circle(top_handle, 9.0, Color(0.95, 0.7, 0.3, 0.95))
		# Small triangle below handle to indicate "pull to grow"
		draw_line(top_handle + Vector2(-4, 0), pos + Vector2(0, -radius - 2), Color(0.95, 0.7, 0.3, 0.6), 1.5)
		draw_line(top_handle + Vector2(4, 0), pos + Vector2(0, -radius - 2), Color(0.95, 0.7, 0.3, 0.6), 1.5)
		# Center mark for the dragged piece
		if is_dragging:
			draw_circle(pos, 4.0, Color(0.95, 0.7, 0.3))

	# Debug ID mode (Section 14): per-piece ID, center, bbox, gap boundaries,
	# motion axis, z_index. Renders as overlays on top of the gameplay pieces
	# so the user can see exactly which authored value maps to which object.
	if show_debug_ids:
		_draw_debug_ids_for_pieces()
