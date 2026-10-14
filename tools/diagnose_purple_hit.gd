extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var def = UserLevels.build(25)
	var r1 = null
	var s1 = null
	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		if p.piece_id == &"purple_r1":
			r1 = p
		elif p.piece_id == &"purple_s1":
			s1 = p

	print("r1 pos: ", r1.position, " radius: ", r1.radius, " gaps: ", r1.gaps)
	print("s1 pos: ", s1.position, " path: ", s1.def.path_points)
	var pts = Rules._get_piece_polyline(s1)
	for i in range(pts.size() - 1):
		var p1 = s1.position + pts[i]
		var p2 = s1.position + pts[i+1]
		var seg_len = p1.distance_to(p2)
		var steps = maxi(int(seg_len / 8.0), 1)
		for s in range(steps + 1):
			var pt = p1.lerp(p2, float(s) / float(steps))
			if Rules._point_on_tube(r1, pt, 0.0):
				print("HIT at pt: ", pt, " dist to r1: ", pt.distance_to(r1.position))
	quit(0)
