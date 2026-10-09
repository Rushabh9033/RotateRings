extends RefCounted
class_name EditorClipboard

# ==============================================================================
# EditorClipboard — small in-process storage for the editor's three
# clipboards: object (full piece or link snapshot), size (just the
# shape-specific dimension fields), color (single Color).
#
# Section 3 of the precision-editor mandate.
#
# Held in memory; not persisted. The LevelDocument remains the source of truth
# for saved state. This is just transient scratch space for COPY / PASTE /
# DUPLICATE / SIZE-COPY / SIZE-PASTE / SIZE-MATCH / COLOR-COPY / COLOR-PASTE.
# ==============================================================================

const SHAPE_SIZE_FIELDS := {
	0: ["radius", "thickness"],          # CIRCLE
	1: ["radius", "thickness", "corner_radius"],  # ROUNDED_SQUARE
	2: ["radius", "thickness"],          # ROUNDED_TRIANGLE
	3: ["radius", "radius_y", "thickness"],  # OVAL
	4: ["length", "width", "thickness"], # STRAIGHT
	5: ["length", "length_b", "width", "thickness"],  # L_SHAPE
	6: ["path_points"],                  # PATH (uniform scale, see doc)
}

# Deep-copied piece or link dicts. `kind` is "piece" or "link".
var object: Dictionary = {}
var object_kind: String = ""

# Last copied SIZE — just the shape-specific dimension fields, not the
# whole piece. Used by MATCH SIZE so a user can copy size from piece A
# and apply to piece B without copying position/rotation/gaps.
var size: Dictionary = {}
var size_shape: int = 0

# Last copied color (any Color, RGBA). Used by the Inspector's color
# copy/paste and by the editor's toolbar.
var color: Color = Color.WHITE

# ----- object clipboard -----

func copy_object(dict: Dictionary, kind: String) -> void:
	object = dict.duplicate(true)
	object_kind = kind

func paste_object():
	# Returns a NEW dict with a unique id, ready to be inserted.
	if object.is_empty() or object_kind.is_empty():
		return null
	var copy: Dictionary = object.duplicate(true)
	# Caller is responsible for assigning a unique id and position offset.
	return copy

func has_object() -> bool: return not object.is_empty()
func get_object_kind() -> String: return object_kind

# ----- size clipboard -----

func copy_size_from_piece(p: Dictionary) -> void:
	var shape: int = int(p.get("shape_type", 0))
	size_shape = shape
	size = {}
	var fields: Array = SHAPE_SIZE_FIELDS.get(shape, ["radius", "thickness"])
	for f in fields:
		if p.has(f):
			size[f] = p[f]

func apply_size_to_piece(p: Dictionary) -> bool:
	if size.is_empty(): return false
	var target_shape: int = int(p.get("shape_type", 0))
	if target_shape != size_shape:
		# Different shape types — still try to copy the common field
		# (radius always exists), but skip fields the target doesn't have.
		for f in size:
			if p.has(f):
				p[f] = size[f]
		return true
	# Same shape — copy all size fields.
	for f in size:
		if p.has(f):
			p[f] = size[f]
	return true

func has_size() -> bool: return not size.is_empty()
func get_size_shape() -> int: return size_shape

# ----- color clipboard -----

func copy_color(c: Color) -> void:
	color = c
func paste_color() -> Color: return color
func has_color() -> bool: return true  # always has at least Color.WHITE