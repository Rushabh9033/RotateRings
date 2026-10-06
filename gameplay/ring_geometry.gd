class_name RingGeometry

extends RefCounted

static func get_solid_arcs(gaps: Array) -> Array:
	if gaps.is_empty():
		return [{ "start": 0.0, "end": TAU }]
	
	var normalized_gaps: Array = []
	for gap in gaps:
		if gap == null: continue
		var center_val: float = float(gap.get("center_angle_deg", 0.0)) if gap is Dictionary else float(gap.center_angle_deg)
		var width_val: float = float(gap.get("width_deg", 0.0)) if gap is Dictionary else float(gap.width_deg)
		if width_val <= 0.0: continue
		var c = deg_to_rad(fposmod(center_val, 360.0))
		var hw = deg_to_rad(width_val * 0.5)
		normalized_gaps.append({ "center": c, "hw": hw })
	
	if normalized_gaps.is_empty():
		return [{ "start": 0.0, "end": TAU }]
	
	normalized_gaps.sort_custom(func(a, b): return a.center < b.center)
	
	var solid_arcs: Array = []
	for i in range(normalized_gaps.size()):
		var current_gap = normalized_gaps[i]
		var next_gap = normalized_gaps[(i + 1) % normalized_gaps.size()]
		
		var start_arc = fposmod(current_gap.center + current_gap.hw, TAU)
		var end_arc = fposmod(next_gap.center - next_gap.hw, TAU)
		
		# If there's only 1 gap, it wraps around back to itself
		if normalized_gaps.size() == 1:
			end_arc = fposmod(current_gap.center - current_gap.hw, TAU)
		
		# Handle wrapping where end_arc is numerically less than start_arc
		var arc_len = fposmod(end_arc - start_arc, TAU)
		
		if arc_len > 0.001:
			# Return the start and the absolute length for easy drawing
			solid_arcs.append({ "start": start_arc, "length": arc_len, "end": start_arc + arc_len })
		
	return solid_arcs
