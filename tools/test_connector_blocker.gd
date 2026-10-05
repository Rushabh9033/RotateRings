extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")
const PieceDef = preload("res://data/piece_definition.gd")
const GapDef = preload("res://data/gap_definition.gd")
const LinkDef = preload("res://data/link_definition.gd")
const Connector = preload("res://gameplay/connector_runtime.gd")

func _init() -> void:
	var gap := [GapDef.new(0.0, 56.0, 6.0)]
	var child = RingPiece.new()
	child.setup(PieceDef.new(&"child", Vector2(480, 400), 76.0, 24.0, Color.WHITE, 20.0, gap))
	child.position = Vector2(480, 400)
	var parent = RingPiece.new()
	parent.setup(PieceDef.new(&"parent", Vector2(300, 400), 76.0, 24.0, Color.WHITE, 0.0, gap))
	parent.position = Vector2(300, 400)
	var anchor = RingPiece.new()
	anchor.setup(PieceDef.new(&"anchor", Vector2(120, 400), 76.0, 24.0, Color.WHITE, 0.0, []))
	anchor.position = Vector2(120, 400)
	var pieces: Array = [anchor, parent, child]
	var hold_def = LinkDef.new(&"hold", parent.piece_id, child.piece_id, Color.WHITE)
	Rules.bind_connector(hold_def, parent.position, parent.rotation_degrees, child.position)
	var link = Connector.new(hold_def)
	link.current_stem_dist = hold_def.stem_dist
	var anchor_def = LinkDef.new(&"anchor_hold", anchor.piece_id, parent.piece_id, Color.WHITE)
	Rules.bind_connector(anchor_def, anchor.position, anchor.rotation_degrees, parent.position)
	var anchor_link = Connector.new(anchor_def)
	anchor_link.current_stem_dist = anchor_def.stem_dist
	var links: Array = [anchor_link, link]
	var blocked: Dictionary = Rules.clamp_rotation_step(parent, 50.0, pieces, links)
	if absf(float(blocked.allowed_delta)) > 0.01 or not bool(blocked.hit_stopper):
		print("FAILED: parent with an engaged child was allowed to rotate")
		quit(1)
		return
	var align: float = Rules.alignment_rotation_deg(child, link, pieces, child.gaps[0])
	var cleared: Dictionary = Rules.apply_settled_rotation(child, align, pieces, links)
	if not cleared.applied or link.state != Connector.State.DETACHED:
		print("FAILED: child could not clear the engaged cuff")
		quit(1)
		return
	if not Rules.is_piece_rotatable(parent, pieces, links):
		print("FAILED: parent stayed locked after the child constraint cleared")
		quit(1)
		return
	var free: Dictionary = Rules.clamp_rotation_step(parent, 50.0, pieces, links)
	if absf(float(free.allowed_delta) - 50.0) > 0.01:
		print("FAILED: cleared parent could not take the same 50° step")
		quit(1)
		return
	print("SUCCESS: parent lock follows engaged outgoing connectors")
	quit(0)
