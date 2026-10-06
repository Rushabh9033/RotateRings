extends SceneTree

const Harness = preload("res://tools/level_engine_harness.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("\n=== CUFF OVERLAP ===")
	if not _test_level5_stacked_cuffs():
		print("FAILED: cuff overlap")
		quit(1)
		return
	print("SUCCESS: stacked cuffs are blocked and a clear rotation still fits")
	quit(0)

func _test_level5_stacked_cuffs() -> bool:
	var built := Harness.build_level(5)
	var pieces: Array = built.pieces
	var links: Array = built.links
	var blue = Rules.get_piece_by_id(&"ring_5", pieces)
	var green = Rules.get_piece_by_id(&"ring_4", pieces)
	var blue_link = _link_to(links, &"ring_5")
	var align_blue: float = Rules.alignment_rotation_deg(blue, blue_link, pieces, blue.gaps[0])
	var cleared: Dictionary = Rules.apply_settled_rotation(blue, align_blue, pieces, links)
	if not cleared.applied or blue_link.state != 2:
		print("  FAIL blue did not release so the green ring could turn")
		return false
	if not Rules.is_piece_rotatable(green, pieces, links):
		print("  FAIL green ring stayed locked after blue left")
		return false
	# Screenshot pose: leftover green cuff driven up into the purple ring / purple grip.
	var stacked := 330.0
	var saved: float = green.rotation_degrees
	green.rotation_degrees = stacked
	if not Rules.pose_blocked(green, pieces, links):
		print("  FAIL rotation 330 does not overlap a solid body")
		green.rotation_degrees = saved
		return false
	green.rotation_degrees = saved
	var toward := wrapf(stacked - saved, -180.0, 180.0)
	var clamped: Dictionary = Rules.clamp_rotation_step(green, toward, pieces, links)
	var reached: float = saved + float(clamped.allowed_delta)
	green.rotation_degrees = reached
	if Rules.pose_blocked(green, pieces, links):
		print("  FAIL drag stopped on an overlapping pose at ", reached)
		return false
	if absf(wrapf(reached - stacked, -180.0, 180.0)) < 1.0:
		print("  FAIL sweep reached the stacked pose")
		return false
	green.rotation_degrees = saved
	var holder = _link_between(links, &"ring_6", &"ring_4")
	var align: float = Rules.alignment_rotation_deg(green, holder, pieces, green.gaps[0])
	var delta := wrapf(align - saved, -180.0, 180.0)
	var legal: Dictionary = Rules.clamp_rotation_step(green, delta, pieces, links)
	if bool(legal.hit_stopper) or absf(float(legal.allowed_delta) - delta) > 0.5:
		print("  FAIL legal dark-green alignment was blocked. align=", align, " allowed=", legal.allowed_delta, " delta=", delta)
		return false
	green.rotation_degrees = saved + float(legal.allowed_delta)
	if Rules.pose_blocked(green, pieces, links):
		print("  FAIL alignment pose still overlaps")
		return false
	if not Rules.connector_fits(green, green.rotation_degrees, holder, pieces):
		print("  FAIL alignment does not accept the dark-green cuff")
		return false
	print("  PASS stacked pose blocked; dark-green alignment ", align, " is clear")
	return true

func _link_to(links: Array, to_id: StringName):
	for link in links:
		if link.def.to_piece_id == to_id and link.state == 0:
			return link
	return null

func _link_between(links: Array, from_id: StringName, to_id: StringName):
	for link in links:
		if link.def.from_piece_id == from_id and link.def.to_piece_id == to_id:
			return link
	return null
