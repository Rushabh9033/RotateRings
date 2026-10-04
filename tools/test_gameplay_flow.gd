extends SceneTree

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const LevelDatabaseScript = preload("res://data/level_database.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("\n==============================================")
	print("       GAMEPLAY FLOW SIMULATION TEST         ")
	print("==============================================")

	var success_l2 = test_level_2()
	var success_l3 = test_level_3()

	if success_l2 and success_l3:
		print("==============================================")
		print("SUCCESS: Both Level 2 and Level 3 passed simulation!")
		print("==============================================\n")
		quit(0)
	else:
		print("FAILED: Simulation did not pass.")
		quit(1)

func test_level_2() -> bool:
	print("\n--- Testing Level 2 Flow ---")
	var def = LevelDatabaseScript.get_level(2)
	var pieces := []
	var links := []
	var piece_map := {}

	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		p.position = p_def.position
		pieces.append(p)
		piece_map[p_def.id] = p

	for l_def in def.links:
		var link = l_def.duplicate()
		var from_p = piece_map.get(link.from_piece_id)
		var to_p = piece_map.get(link.to_piece_id)
		if from_p and to_p:
			from_p.set_meta("had_children_initially", true)
			to_p.set_meta("had_parents_initially", true)
			var diff_pos: Vector2 = to_p.position - from_p.position
			link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
			link.stem_dist = diff_pos.length()
			link.is_detached = false
		links.append(link)

	var orange = piece_map[&"ring_0"]
	var blue = piece_map[&"ring_1"]
	var purple = piece_map[&"ring_2"]

	# Test 1: Orange is parent holding Blue -> Orange cannot rotate!
	if PuzzleRulesScript.is_piece_rotatable(orange, pieces, links):
		print("❌ Orange should be blocked from rotating while holding Blue!")
		return false
	print("✅ Orange is correctly BLOCKED from rotating while holding Blue")

	# Test 2: Blue rotates to 180° -> aligns with Orange's cuff -> detaches & releases
	blue.rotation_degrees = 180.0
	blue.current_angle_deg = 180.0

	var detached_any := false
	for link in links:
		if link.to_piece_id == blue.piece_id and not link.is_detached:
			var parent_p = piece_map[link.from_piece_id]
			var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - blue.radius)
			var cuff_rel: Vector2 = pos_cuff - blue.position
			var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			if blue.is_angle_in_any_gap(angle_deg):
				link.is_detached = true
				detached_any = true

	if not detached_any:
		print("❌ Blue failed to detach from Orange's cuff at 180°!")
		return false
	print("✅ Blue detached from Orange's cuff")

	blue.state = RingPiece2DScript.State.RELEASED
	print("✅ Blue released/shattered")

	# Test 3: Now Orange has no active children -> Orange CAN rotate!
	if not PuzzleRulesScript.is_piece_rotatable(orange, pieces, links):
		print("❌ Orange should be rotatable now that Blue is released!")
		return false
	print("✅ Orange is now rotatable")

	# Test 4: Orange rotates to 61° -> aligns with Purple's cuff -> detaches & releases
	orange.rotation_degrees = 61.0
	orange.current_angle_deg = 61.0

	detached_any = false
	for link in links:
		if link.to_piece_id == orange.piece_id and not link.is_detached:
			var parent_p = piece_map[link.from_piece_id]
			var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - orange.radius)
			var cuff_rel: Vector2 = pos_cuff - orange.position
			var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			if orange.is_angle_in_any_gap(angle_deg):
				link.is_detached = true
				detached_any = true

	if not detached_any:
		print("❌ Orange failed to detach from Purple's cuff at 61°!")
		return false
	print("✅ Orange detached from Purple's cuff")

	orange.state = RingPiece2DScript.State.RELEASED
	# Purple cascade check: Purple has no children and no parents
	if not PuzzleRulesScript.is_piece_releasable(purple, pieces, links):
		print("❌ Purple should cascade release after Orange detaches!")
		return false
	print("✅ Purple cascade released")
	return true

func test_level_3() -> bool:
	print("\n--- Testing Level 3 Flow ---")
	var def = LevelDatabaseScript.get_level(3)
	var pieces := []
	var links := []
	var piece_map := {}

	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		p.position = p_def.position
		pieces.append(p)
		piece_map[p_def.id] = p

	for l_def in def.links:
		var link = l_def.duplicate()
		var from_p = piece_map.get(link.from_piece_id)
		var to_p = piece_map.get(link.to_piece_id)
		if from_p and to_p:
			from_p.set_meta("had_children_initially", true)
			to_p.set_meta("had_parents_initially", true)
			var diff_pos: Vector2 = to_p.position - from_p.position
			link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
			link.stem_dist = diff_pos.length()
			link.is_detached = false
		links.append(link)

	var blue = piece_map[&"ring_0"]
	var orange = piece_map[&"ring_1"]
	var purple = piece_map[&"ring_2"]
	var red = piece_map[&"ring_3"]

	# Blue holds Orange and Purple -> Blue cannot rotate!
	if PuzzleRulesScript.is_piece_rotatable(blue, pieces, links):
		print("❌ Blue should be blocked from rotating while holding children!")
		return false
	print("✅ Blue correctly blocked while holding children")

	# Step 1: Purple rotates to 239° -> aligns with Blue's cuff -> detaches & releases
	purple.rotation_degrees = 239.0
	purple.current_angle_deg = 239.0

	var detached_any := false
	for link in links:
		if link.to_piece_id == purple.piece_id and not link.is_detached:
			var parent_p = piece_map[link.from_piece_id]
			var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - purple.radius)
			var cuff_rel: Vector2 = pos_cuff - purple.position
			var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			if purple.is_angle_in_any_gap(angle_deg):
				link.is_detached = true
				detached_any = true

	if not detached_any:
		print("❌ Purple failed to detach from Blue's cuff at 239°!")
		return false
	purple.state = RingPiece2DScript.State.RELEASED
	print("✅ Step 1: Purple detached and released")

	# Step 2: Orange rotates to 301° -> aligns with Blue's cuff -> detaches from Blue!
	orange.rotation_degrees = 301.0
	orange.current_angle_deg = 301.0

	detached_any = false
	for link in links:
		if link.to_piece_id == orange.piece_id and not link.is_detached:
			var parent_p = piece_map[link.from_piece_id]
			var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - orange.radius)
			var cuff_rel: Vector2 = pos_cuff - orange.position
			var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			if orange.is_angle_in_any_gap(angle_deg):
				link.is_detached = true
				detached_any = true

	if not detached_any:
		print("❌ Orange failed to detach from Blue's cuff at 301°!")
		return false
	print("✅ Step 2: Orange detached from Blue's cuff independently while Red is still holding it!")

	# Orange is still held by Red, so Orange does NOT release yet
	if PuzzleRulesScript.is_piece_releasable(orange, pieces, links):
		print("❌ Orange should NOT release yet because Red is still holding it!")
		return false
	print("✅ Orange stays in place because Red's cuff is still attached")

	# But Blue now has BOTH children detached (Purple and Orange) -> Blue releases!
	if not PuzzleRulesScript.is_piece_releasable(blue, pieces, links):
		print("❌ Blue should cascade release now that all its children detached!")
		return false
	blue.state = RingPiece2DScript.State.RELEASED
	print("✅ Blue cascade released")

	# Step 3: Orange rotates to 59° -> aligns with Red's cuff -> detaches from Red!
	orange.rotation_degrees = 59.0
	orange.current_angle_deg = 59.0

	detached_any = false
	for link in links:
		if link.to_piece_id == orange.piece_id and not link.is_detached:
			var parent_p = piece_map[link.from_piece_id]
			var world_rad: float = deg_to_rad(parent_p.rotation_degrees + link.collar_angle_deg)
			var dir := Vector2.from_angle(world_rad)
			var pos_cuff: Vector2 = parent_p.position + dir * (link.stem_dist - orange.radius)
			var cuff_rel: Vector2 = pos_cuff - orange.position
			var angle_deg := fposmod(rad_to_deg(cuff_rel.angle()), 360.0)
			if orange.is_angle_in_any_gap(angle_deg):
				link.is_detached = true
				detached_any = true

	if not detached_any:
		print("❌ Orange failed to detach from Red's cuff at 59°!")
		return false
	print("✅ Step 3: Orange detached from Red's cuff")

	# Now Orange has NO remaining parents -> Orange releases!
	if not PuzzleRulesScript.is_piece_releasable(orange, pieces, links):
		print("❌ Orange should release now that all parent cuffs detached!")
		return false
	orange.state = RingPiece2DScript.State.RELEASED
	print("✅ Orange released")

	# And Red has no remaining children -> Red releases!
	if not PuzzleRulesScript.is_piece_releasable(red, pieces, links):
		print("❌ Red should cascade release now that Orange detached!")
		return false
	red.state = RingPiece2DScript.State.RELEASED
	print("✅ Red cascade released")

	return true
