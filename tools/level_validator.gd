extends RefCounted
class_name LevelValidator

func run_audit() -> Dictionary:
	var db = load("res://data/level_database.gd").new()
	var report = {
		"pass": [],
		"warning": [],
		"fail": [],
		"exploits": []
	}
	
	for level_id in range(1, db.get_total_levels() + 1):
		var def = db.get_level(level_id)
		var result = _validate_level(level_id, def)
		
		if result["fails"].size() > 0:
			report["fail"].append({ "id": level_id, "title": def.title, "issues": result["fails"] })
		elif result["warnings"].size() > 0:
			report["warning"].append({ "id": level_id, "title": def.title, "issues": result["warnings"] })
		else:
			report["pass"].append(level_id)
			
	return report

func _validate_level(level_id: int, def) -> Dictionary:
	var fails = []
	var warnings = []
	
	var pieces = def.pieces
	var links = def.links
	
	# 1. Validate Rings
	for p in pieces:
		var is_root = true
		for l in links:
			if l.to_piece_id == p.id:
				is_root = false
				break
		
		var is_leaf = true
		for l in links:
			if l.from_piece_id == p.id:
				is_leaf = false
				break
				
		var gaps = p.gaps
		if gaps.size() == 0:
			if not is_root:
				fails.append("Ring " + str(p.id) + " has NO GAP but is a child (impossible to release).")
			else:
				warnings.append("Ring " + str(p.id) + " has NO GAP (Pure root O-ring).")
		
		if gaps.size() > 1:
			warnings.append("Ring " + str(p.id) + " has multiple gaps.")
			
	# 2. Validate Graph Connectivity
	var adj = {}
	for p in pieces:
		adj[p.id] = []
	for l in links:
		adj[l.from_piece_id].append(l.to_piece_id)
		adj[l.to_piece_id].append(l.from_piece_id)
		
	var visited = {}
	var components = 0
	for p in pieces:
		if not visited.has(p.id):
			components += 1
			var q = [p.id]
			visited[p.id] = true
			while q.size() > 0:
				var curr = q.pop_front()
				for neighbor in adj[curr]:
					if not visited.has(neighbor):
						visited[neighbor] = true
						q.append(neighbor)
	
	if components > 1:
		fails.append("Puzzle has " + str(components) + " disconnected components.")
		
	# 3. Validate Connector Placements (Cannot start inside a gap)
	for l in links:
		var from_p = _get_piece(l.from_piece_id, pieces)
		var to_p = _get_piece(l.to_piece_id, pieces)
		
		if not from_p or not to_p:
			fails.append("Link " + str(l.id) + " references missing rings.")
			continue
			
		var diff_pos: Vector2 = to_p.position - from_p.position
		var collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.start_angle_deg, 360.0)
		
		var in_gap = false
		for gap in from_p.gaps:
			var gap_center = gap.center_angle_deg
			var gap_half = gap.width_deg * 0.5
			var dist = minf(absf(collar_angle_deg - gap_center), 360.0 - absf(collar_angle_deg - gap_center))
			if dist <= gap_half:
				in_gap = true
				break
				
		if in_gap:
			fails.append("Link " + str(l.id) + " stem originates INSIDE the gap of parent " + str(from_p.id) + "!")
			
		# Check overlap (visual spacing)
		var dist = diff_pos.length()
		var min_safe = 40.0 # very close
		if dist < min_safe:
			warnings.append("Link " + str(l.id) + " is extremely short (" + str(dist) + "px). Rings overlap too much.")
			
	# 4. Global spacing (unrelated rings overlapping)
	for i in range(pieces.size()):
		for j in range(i + 1, pieces.size()):
			var p1 = pieces[i]
			var p2 = pieces[j]
			var dist = p1.position.distance_to(p2.position)
			if dist < (p1.radius + p2.radius - 20.0):
				# check if they are linked
				var linked = false
				for l in links:
					if (l.from_piece_id == p1.id and l.to_piece_id == p2.id) or (l.from_piece_id == p2.id and l.to_piece_id == p1.id):
						linked = true
						break
				if not linked:
					warnings.append("Unrelated rings " + str(p1.id) + " and " + str(p2.id) + " overlap visually (dist: " + str(dist) + ").")
					
	return { "fails": fails, "warnings": warnings }

func _get_piece(id: StringName, pieces: Array):
	for p in pieces:
		if p.id == id:
			return p
	return null
