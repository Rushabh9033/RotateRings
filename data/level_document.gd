extends Resource
class_name LevelDocument

# ==============================================================================
# LevelDocument — single source of truth for an editable level.
#
# Sections 32 of the precision-editor mandate: "ONE shared LevelDocument +
# serializer + editor state used by LevelEditor, PieceEditOverlay, UserLevels,
# runtime loader."
#
# Pieces are stored as Dictionary snapshots that mirror PieceDefinition.to_dict()
# so the serializer is lossless by construction. Links are stored as Dictionary
# snapshots that mirror LinkDefinition.to_dict().
#
# All mutations go through `apply_edit()` which:
#   - snapshots the document for undo
#   - applies the edit via a caller's callable
#   - emits `document_changed` so the UI re-renders
#
# Save / load is a thin wrapper over the schema's to_dict / apply_dict so any
# future PieceDefinition field round-trips automatically.
# ==============================================================================

signal document_changed()
signal undo_state_changed(can_undo: bool, can_redo: bool)

const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LevelDefinitionScript = preload("res://data/level_definition.gd")

@export var level_id: int = 0
@export var title: String = ""
@export var instruction: String = ""
@export var par_moves: int = 1
@export var theme_id: StringName = &"porcelain"

# Authored frame transform (Section 23). Applies uniformly when the runtime
# loads the level. Persists through save/reload as authored.
@export var frame_scale: float = 1.0
@export var frame_offset_x: float = 0.0
@export var frame_offset_y: float = 0.0
@export var frame_anchor: StringName = &"auto"   # auto / center / top-left

# The actual data — piece dicts and link dicts (lossless with schema).
var pieces: Array = []
var links: Array = []

# Per-piece property locks (Section 4). Stored as a dict-of-bools keyed by
# piece id. Default = all unlocked. Per-piece keys: position, size, rotation,
# gaps, motion, visual, connectors.
var locks: Dictionary = {}

# Size-master linking (Section 15). When present, followers are auto-resized
# when the master changes. Keyed by piece id; value is { "master": "id", "what":
# "size" | "thickness" | "radius" | ... }.
var size_links: Dictionary = {}

# User-defined guides (Section 12). Each entry: { "axis": "x"|"y", "value": float }.
var guides: Array = []

# Custom guides placed from the reference image (Section 17).
var reference_guides: Array = []

# Grid / snap settings (Section 11). Independent toggles per Section 11.
var grid_size: float = 20.0
var snap_to_grid: bool = false
var snap_to_piece_centers: bool = false
var snap_to_edges: bool = false
var snap_to_guides: bool = false
var snap_to_connector_points: bool = false

# Nudge step (Section 10). 1 / 10 / 0.1 / 2 / 5 / custom.
var nudge_step: float = 1.0
var nudge_shift_multiplier: float = 10.0
var nudge_alt_multiplier: float = 0.1

# Dirty flag (unsaved path so Section 25 "do not lose unsaved work" works).
var is_dirty: bool = false

# Undo / redo stacks. Each entry is { pieces, links, locks, size_links,
# guides, reference_guides, frame_* }. We snapshot only what can change via
# apply_edit; identity fields (level_id, title) don't go on the stack.
const _UNDO_LIMIT := 200
var _undo_stack: Array = []
var _redo_stack: Array = []

# ==============================================================================
# Lifecycle
# ==============================================================================

func _init() -> void:
	# Default constructor: empty document.
	pass

# Build a LevelDocument from an existing LevelDefinition (the schema's
# authoring container). Lossless — every authored field becomes one piece of
# state, and any future PieceDefinition field is preserved automatically.
static func from_level_definition(def) -> LevelDocument:
	var doc := LevelDocument.new()
	if def == null: return doc
	doc.level_id = int(def.level_id)
	doc.title = String(def.title)
	doc.instruction = String(def.instruction)
	doc.par_moves = int(def.par_moves)
	doc.theme_id = def.theme_id
	for p in def.pieces:
		doc.pieces.append((p as PieceDefinitionScript).to_dict())
	for l in def.links:
		doc.links.append((l as LinkDefinitionScript).to_dict())
	return doc

# Convert back to a LevelDefinition (consumed by gameplay runtime).
func to_level_definition() -> Resource:
	var def = LevelDefinitionScript.new()
	def.level_id = level_id
	def.chapter_id = 1
	def.title = title
	def.instruction = instruction
	def.par_moves = par_moves
	def.theme_id = theme_id
	for pd in pieces:
		var p := PieceDefinitionScript.new()
		p.apply_dict(pd)
		def.pieces.append(p)
	for ld in links:
		var l := LinkDefinitionScript.new()
		l.apply_dict(ld)
		def.links.append(l)
	return def

# Serialize the document to a JSON-safe Dictionary (matches the on-disk shape).
func to_json_dict() -> Dictionary:
	return {
		"id": level_id,
		"title": title,
		"instruction": instruction,
		"par_moves": par_moves,
		"theme_id": String(theme_id),
		"frame_scale": float(frame_scale),
		"frame_offset_x": float(frame_offset_x),
		"frame_offset_y": float(frame_offset_y),
		"frame_anchor": String(frame_anchor),
		"pieces": pieces.duplicate(true),
		"links": links.duplicate(true),
		"locks": locks.duplicate(true),
		"size_links": size_links.duplicate(true),
		"guides": guides.duplicate(true),
		"reference_guides": reference_guides.duplicate(true),
		"grid_size": float(grid_size),
		"snap_to_grid": bool(snap_to_grid),
		"snap_to_piece_centers": bool(snap_to_piece_centers),
		"snap_to_edges": bool(snap_to_edges),
		"snap_to_guides": bool(snap_to_guides),
		"snap_to_connector_points": bool(snap_to_connector_points),
		"nudge_step": float(nudge_step),
		"nudge_shift_multiplier": float(nudge_shift_multiplier),
		"nudge_alt_multiplier": float(nudge_alt_multiplier),
		"source": "level-document",
	}

# Load from a JSON dict (matches the on-disk shape). Lossless.
func apply_json_dict(d: Dictionary) -> void:
	level_id = int(d.get("id", level_id))
	title = String(d.get("title", ""))
	instruction = String(d.get("instruction", ""))
	par_moves = int(d.get("par_moves", 1))
	theme_id = StringName(String(d.get("theme_id", "porcelain")))
	frame_scale = float(d.get("frame_scale", 1.0))
	frame_offset_x = float(d.get("frame_offset_x", 0.0))
	frame_offset_y = float(d.get("frame_offset_y", 0.0))
	frame_anchor = StringName(String(d.get("frame_anchor", "auto")))
	pieces.clear()
	for pd in d.get("pieces", []):
		pieces.append(pd.duplicate(true))
	links.clear()
	for ld in d.get("links", []):
		links.append(ld.duplicate(true))
	locks.clear()
	for k in d.get("locks", {}):
		locks[k] = (d["locks"][k] as Dictionary).duplicate(true)
	size_links.clear()
	for k in d.get("size_links", {}):
		size_links[k] = (d["size_links"][k] as Dictionary).duplicate(true)
	guides.clear()
	for g in d.get("guides", []):
		guides.append(g.duplicate(true))
	reference_guides.clear()
	for g in d.get("reference_guides", []):
		reference_guides.append(g.duplicate(true))
	grid_size = float(d.get("grid_size", 20.0))
	snap_to_grid = bool(d.get("snap_to_grid", false))
	snap_to_piece_centers = bool(d.get("snap_to_piece_centers", false))
	snap_to_edges = bool(d.get("snap_to_edges", false))
	snap_to_guides = bool(d.get("snap_to_guides", false))
	snap_to_connector_points = bool(d.get("snap_to_connector_points", false))
	nudge_step = float(d.get("nudge_step", 1.0))
	nudge_shift_multiplier = float(d.get("nudge_shift_multiplier", 10.0))
	nudge_alt_multiplier = float(d.get("nudge_alt_multiplier", 0.1))
	# Reset history on load — undo only makes sense within a session.
	_undo_stack.clear()
	_redo_stack.clear()
	is_dirty = false
	emit_signal("document_changed")
	emit_signal("undo_state_changed", false, false)

# Save to a JSON file at res://data/user_levels/<n>.json (Section 27 verify).
func save_to_disk(path: String) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null: return false
	f.store_string(JSON.stringify(to_json_dict(), "  "))
	f.close()
	is_dirty = false
	return true

# Load from disk.
static func load_from_disk(path: String) -> LevelDocument:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null: return null
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY: return null
	var doc := LevelDocument.new()
	doc.apply_json_dict(parsed)
	return doc

# ==============================================================================
# Mutations (Section 19 / 22)
# ==============================================================================

# All edits route through this so undo/redo and dirty tracking work. The
# caller passes a Callable that mutates the document in-place. The Callable
# receives no arguments and returns nothing. It can be a method reference
# (e.g. `self._set_piece_radius`), a lambda, or any Callable.
func apply_edit(mutator: Callable) -> void:
	# Snapshot for undo before mutating.
	_undo_stack.append(_snapshot_state())
	if _undo_stack.size() > _UNDO_LIMIT:
		_undo_stack.pop_front()
	# Any new edit invalidates the redo stack.
	_redo_stack.clear()
	# Run the edit.
	mutator.call()
	is_dirty = true
	emit_signal("document_changed")
	emit_signal("undo_state_changed", _undo_stack.size() > 0, false)

# Undo the last edit (Ctrl+Z).
func undo() -> bool:
	if _undo_stack.is_empty(): return false
	# Snapshot current for redo.
	_redo_stack.append(_snapshot_state())
	if _redo_stack.size() > _UNDO_LIMIT:
		_redo_stack.pop_front()
	# Pop the most recent undo and restore it.
	var snap: Dictionary = _undo_stack.pop_back()
	_restore_state(snap)
	is_dirty = true
	emit_signal("document_changed")
	emit_signal("undo_state_changed", _undo_stack.size() > 0, _redo_stack.size() > 0)
	return true

# Redo (Ctrl+Y / Ctrl+Shift+Z).
func redo() -> bool:
	if _redo_stack.is_empty(): return false
	_undo_stack.append(_snapshot_state())
	if _undo_stack.size() > _UNDO_LIMIT:
		_undo_stack.pop_front()
	var snap: Dictionary = _redo_stack.pop_back()
	_restore_state(snap)
	is_dirty = true
	emit_signal("document_changed")
	emit_signal("undo_state_changed", _undo_stack.size() > 0, _redo_stack.size() > 0)
	return true

func can_undo() -> bool: return _undo_stack.size() > 0
func can_redo() -> bool: return _redo_stack.size() > 0

# ==============================================================================
# Locks (Section 4)
# ==============================================================================

# Check whether a given property is locked on a piece. Returns true if the
# piece is locked. Caller passes the property name (position, size, rotation,
# gaps, motion, visual, connectors).
func is_property_locked(piece_id: String, property: String) -> bool:
	if not locks.has(piece_id): return false
	return bool((locks[piece_id] as Dictionary).get(property, false))

func set_property_lock(piece_id: String, property: String, locked: bool) -> void:
	apply_edit(func():
		if not locks.has(piece_id):
			locks[piece_id] = {}
		(locks[piece_id] as Dictionary)[property] = locked
	)

func toggle_property_lock(piece_id: String, property: String) -> bool:
	var before := is_property_locked(piece_id, property)
	set_property_lock(piece_id, property, not before)
	return not before

func get_locks(piece_id: String) -> Dictionary:
	if not locks.has(piece_id): return {}
	return (locks[piece_id] as Dictionary).duplicate(true)

# ==============================================================================
# Size master / follower linking (Section 15)
# ==============================================================================

func link_size_to_master(follower_id: String, master_id: String, what: String) -> void:
	apply_edit(func():
		size_links[follower_id] = {"master": master_id, "what": what}
	)

func unlink_size(follower_id: String) -> void:
	apply_edit(func():
		size_links.erase(follower_id)
	)

func apply_size_link_for_field(master_id: String, field_name: String, new_value: float) -> void:
	# Walk all followers that link to this master with the matching 'what'
	# key. Update their field. Called from a setter so undo still works
	# through the original setter's apply_edit.
	for fid in size_links.keys():
		var entry: Dictionary = size_links[fid]
		if String(entry.get("master", "")) != master_id: continue
		if String(entry.get("what", "")) != field_name: continue
		for p in pieces:
			if String(p.get("id", "")) == fid:
				p[field_name] = new_value
				break

# ==============================================================================
# Snap / guides (Section 11 / 12)
# ==============================================================================

func add_guide(axis: String, value: float) -> void:
	apply_edit(func():
		guides.append({"axis": axis, "value": float(value)})
	)

func remove_guide(index: int) -> void:
	apply_edit(func():
		if index >= 0 and index < guides.size():
			guides.remove_at(index)
	)

# Snap a coordinate to the nearest enabled target. Returns the snapped coord.
func snap_coordinate(coord: Vector2) -> Vector2:
	var out: Vector2 = coord
	if snap_to_grid and grid_size > 0.001:
		out.x = round(out.x / grid_size) * grid_size
		out.y = round(out.y / grid_size) * grid_size
	if snap_to_guides:
		for g in guides:
			var v: float = float((g as Dictionary).get("value", 0.0))
			if String((g as Dictionary).get("axis", "x")) == "x":
				if absf(out.x - v) < grid_size:
					out.x = v
			else:
				if absf(out.y - v) < grid_size:
					out.y = v
	return out

# ==============================================================================
# Object clipboard (Section 3): Duplicate / Copy / Paste / Size Match.
# All routed through apply_edit so undo works.
# ==============================================================================

# Duplicate a piece. Returns the new piece's id, or "" on failure. The
# duplicate is offset by (offset.x, offset.y) from the source so the user
# sees it. Caller can pass offset=Vector2.ZERO for in-place.
func duplicate_piece(source_id: String, offset: Vector2 = Vector2(20, 20)) -> String:
	var src: Dictionary = find_piece(source_id)
	if src.is_empty(): return ""
	var new_id: String = generate_unique_piece_id(String(src.get("id", "piece")).split("_")[0] if "_" in String(src.get("id", "")) else "piece")
	var copy: Dictionary = src.duplicate(true)
	copy["id"] = new_id
	copy["x"] = float(copy.get("x", 0.0)) + offset.x
	copy["y"] = float(copy.get("y", 0.0)) + offset.y
	var captured_id := new_id
	apply_edit(func():
		pieces.append(copy)
	)
	return new_id

# Paste a piece from a clipboard dict. Generates a unique id and inserts.
# Returns the new id, or "" if the dict isn't a piece.
func paste_piece(piece_dict: Dictionary, offset: Vector2 = Vector2(20, 20)) -> String:
	if piece_dict.is_empty() or not piece_dict.has("shape_type"):
		return ""
	var new_id: String = generate_unique_piece_id("piece")
	var copy: Dictionary = piece_dict.duplicate(true)
	copy["id"] = new_id
	copy["x"] = float(copy.get("x", 0.0)) + offset.x
	copy["y"] = float(copy.get("y", 0.0)) + offset.y
	apply_edit(func():
		pieces.append(copy)
	)
	return new_id

# Delete a piece by id. Also removes any links that reference it.
func delete_piece(piece_id: String) -> bool:
	var target: String = piece_id
	var had: bool = false
	for p in pieces:
		if String(p.get("id", "")) == target:
			had = true; break
	if not had: return false
	apply_edit(func():
		var keep: Array = []
		for p in pieces:
			if String(p.get("id", "")) != target:
				keep.append(p)
		pieces.clear()
		for p in keep: pieces.append(p)
		var keep_links: Array = []
		for l in links:
			if String(l.get("from_id", "")) != target and String(l.get("to_id", "")) != target:
				keep_links.append(l)
		links.clear()
		for l in keep_links: links.append(l)
	)
	return true

# Delete a link by id.
func delete_link(link_id: String) -> bool:
	var had: bool = false
	for l in links:
		if String(l.get("id", "")) == link_id:
			had = true; break
	if not had: return false
	apply_edit(func():
		var keep: Array = []
		for l in links:
			if String(l.get("id", "")) != link_id:
				keep.append(l)
		links.clear()
		for l in keep: links.append(l)
	)
	return true

# Match size from a source piece to one or more target piece ids. Uses the
# EditorClipboard shape table. Properties that are locked on the target are
# Add a new empty piece at the given position. Returns the new piece's id.
# The piece is OPEN_CIRCLE with default radius, thickness, and color (so the
# user can immediately grab its handles and resize it). The schema field set
# is the full set the editor can later mutate.
func add_piece(at_position: Vector2 = Vector2(360, 640), shape: int = 0) -> String:
	var new_id: String = generate_unique_piece_id("piece")
	var piece_dict: Dictionary = {
		"id": new_id,
		"shape_type": int(shape),
		"piece_type": 1,  # OPEN_CIRCLE
		"x": float(at_position.x),
		"y": float(at_position.y),
		"start_angle_deg": 0.0,
		"radius": 60.0,
		"radius_y": 60.0,
		"thickness": 22.0,
		"length": 100.0,
		"length_b": 60.0,
		"width": 24.0,
		"height": 60.0,
		"corner_radius": 8.0,
		"path_points": [],
		"color": Color("#EA7829"),
		"color_hex": "#EA7829",
		"color_name": "orange",
		"motion_model": 0,  # ROTATE
		"motion_axis": {"x": 1.0, "y": 0.0},
		"slide_min": -1000.0,
		"slide_max": 1000.0,
		"slide_path": [],
		"role": 0,  # NORMAL
		"z_index": 1,
		"gaps": [{
			"center_angle_deg": 90.0,
			"width_deg": 80.0,
			"tolerance_deg": 16.0,
		}],
		"initially_locked": false,
		"locked": false,
		"property_locks": {},
		"release_direction": {"x": 1.0, "y": 0.0},
		"target_exit_angle_deg": 0.0,
	}
	var captured := piece_dict
	apply_edit(func():
		pieces.append(captured)
	)
	return new_id

# Add a link between two pieces (M5 free connector authoring). The link is
# in CLEARING state by default and snaps to the from-piece's local right
# cuff at radius + cuff_depth. The from-piece must be a valid id; the
# to-piece can be the same id only if from-piece's gap is large enough
# (M6 multi-connector). Returns the new link's id, or "" on failure.
func add_link(from_id: String, to_id: String) -> String:
	var from_p: Dictionary = find_piece(from_id)
	var to_p: Dictionary = find_piece(to_id)
	if from_p.is_empty() or to_p.is_empty(): return ""
	# Section 4 connectors lock guard.
	if is_property_locked(from_id, "connectors"): return ""
	var new_id: String = generate_unique_link_id("link")
	# Compute a default collar angle from the world vector to the child.
	var dx: float = float(to_p["x"]) - float(from_p["x"])
	var dy: float = float(to_p["y"]) - float(from_p["y"])
	var collar: float = 0.0
	if absf(dx) > 0.001 or absf(dy) > 0.001:
		collar = fposmod(rad_to_deg(atan2(dy, dx)) - float(from_p.get("start_angle_deg", 0.0)), 360.0)
	var link_dict: Dictionary = {
		"id": new_id,
		"from_id": from_id,
		"to_id": to_id,
		"collar_angle_deg": collar,
		"cuff_center_local": {"x": 0.0, "y": 0.0},
		"cuff_orientation_deg": 0.0,
		"cuff_width": 32.0,
		"cuff_depth": 18.0,
		"cuff_round_radius": 5.0,
		"stem_length": 200.0,
		"stem_width": 6.0,
		"stem_distance_from_piece": maxf(60.0, sqrt(dx * dx + dy * dy)),
		"joint_color_hex": "#32ADDA",
		"joint_color_name": "cyan",
		"clearance_tolerance_deg": 16.0,
		"is_detached": false,
	}
	var captured_link := link_dict
	apply_edit(func():
		links.append(captured_link)
	)
	return new_id

# not changed (Section 4 lock guard). All mutations happen inside a single
# apply_edit so undo rolls them back as a unit.
func match_size_from_piece(source_id: String, target_ids: Array) -> int:
	var src: Dictionary = find_piece(source_id)
	if src.is_empty(): return 0
	var SHAPE_SIZE_FIELDS: Dictionary = preload("res://data/editor_clipboard.gd").SHAPE_SIZE_FIELDS
	var src_shape: int = int(src.get("shape_type", 0))
	var fields: Array = SHAPE_SIZE_FIELDS.get(src_shape, ["radius", "thickness"])
	# Pre-compute the changes so apply_edit can run them as a single mutator.
	var edits: Array = []  # [{ tid, field, value }, ...]
	for tid in target_ids:
		var target: Dictionary = find_piece(String(tid))
		if target.is_empty(): continue
		if is_property_locked(String(tid), "size"): continue
		var tgt_shape: int = int(target.get("shape_type", 0))
		if tgt_shape == src_shape:
			for f in fields:
				if src.has(f):
					edits.append({"tid": String(tid), "field": String(f), "value": src[f]})
		else:
			for f in fields:
				if src.has(f) and target.has(f):
					edits.append({"tid": String(tid), "field": String(f), "value": src[f]})
	if edits.is_empty(): return 0
	var captured_edits := edits
	apply_edit(func():
		for e in captured_edits:
			var tgt: Dictionary = find_piece(String(e["tid"]))
			if not tgt.is_empty():
				tgt[String(e["field"])] = e["value"]
	)
	return captured_edits.size()

# ==============================================================================
# Helpers — used by the editor UI and tests
# ==============================================================================

# Look up a piece by id. Returns the dict or null.
func find_piece(piece_id: String) -> Dictionary:
	for p in pieces:
		if String(p.get("id", "")) == piece_id:
			return p
	return {}

# Look up a link by id. Returns the dict or null.
func find_link(link_id: String) -> Dictionary:
	for l in links:
		if String(l.get("id", "")) == link_id:
			return l
	return {}

# Generate a unique piece id given a prefix. Used by Duplicate (Section 3).
func generate_unique_piece_id(prefix: String = "piece") -> String:
	var n: int = 1
	while n < 100000:
		var candidate := "%s_%d" % [prefix, n]
		if find_piece(candidate).is_empty():
			return candidate
		n += 1
	return "%s_%d" % [prefix, 100000]

# Generate a unique link id given a prefix.
func generate_unique_link_id(prefix: String = "link") -> String:
	var n: int = 1
	while n < 100000:
		var candidate := "%s_%d" % [prefix, n]
		if find_link(candidate).is_empty():
			return candidate
		n += 1
	return "%s_%d" % [prefix, 100000]

# ==============================================================================
# Internal: snapshot / restore for undo
# ==============================================================================

func _snapshot_state() -> Dictionary:
	return {
		"pieces": pieces.duplicate(true),
		"links": links.duplicate(true),
		"locks": locks.duplicate(true),
		"size_links": size_links.duplicate(true),
		"guides": guides.duplicate(true),
		"reference_guides": reference_guides.duplicate(true),
		"frame_scale": float(frame_scale),
		"frame_offset_x": float(frame_offset_x),
		"frame_offset_y": float(frame_offset_y),
		"frame_anchor": String(frame_anchor),
		"grid_size": float(grid_size),
		"snap_to_grid": bool(snap_to_grid),
		"snap_to_piece_centers": bool(snap_to_piece_centers),
		"snap_to_edges": bool(snap_to_edges),
		"snap_to_guides": bool(snap_to_guides),
		"snap_to_connector_points": bool(snap_to_connector_points),
		"nudge_step": float(nudge_step),
		"nudge_shift_multiplier": float(nudge_shift_multiplier),
		"nudge_alt_multiplier": float(nudge_alt_multiplier),
	}

func _restore_state(snap: Dictionary) -> void:
	pieces.clear()
	for p in snap.get("pieces", []):
		pieces.append((p as Dictionary).duplicate(true))
	links.clear()
	for l in snap.get("links", []):
		links.append((l as Dictionary).duplicate(true))
	locks.clear()
	for k in snap.get("locks", {}):
		locks[k] = ((snap["locks"] as Dictionary)[k] as Dictionary).duplicate(true)
	size_links.clear()
	for k in snap.get("size_links", {}):
		size_links[k] = ((snap["size_links"] as Dictionary)[k] as Dictionary).duplicate(true)
	guides.clear()
	for g in snap.get("guides", []):
		guides.append((g as Dictionary).duplicate(true))
	reference_guides.clear()
	for g in snap.get("reference_guides", []):
		reference_guides.append((g as Dictionary).duplicate(true))
	frame_scale = float(snap.get("frame_scale", 1.0))
	frame_offset_x = float(snap.get("frame_offset_x", 0.0))
	frame_offset_y = float(snap.get("frame_offset_y", 0.0))
	frame_anchor = StringName(String(snap.get("frame_anchor", "auto")))
	grid_size = float(snap.get("grid_size", 20.0))
	snap_to_grid = bool(snap.get("snap_to_grid", false))
	snap_to_piece_centers = bool(snap.get("snap_to_piece_centers", false))
	snap_to_edges = bool(snap.get("snap_to_edges", false))
	snap_to_guides = bool(snap.get("snap_to_guides", false))
	snap_to_connector_points = bool(snap.get("snap_to_connector_points", false))
	nudge_step = float(snap.get("nudge_step", 1.0))
	nudge_shift_multiplier = float(snap.get("nudge_shift_multiplier", 10.0))
	nudge_alt_multiplier = float(snap.get("nudge_alt_multiplier", 0.1))