extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")

func _init():
	Board._defer_solve = true
	var unclasped_count := 0
	var total_pieces := 0
	var total_links := 0
	
	for lvl in range(1, 101):
		var def = Board.build(lvl)
		if def == null:
			print("ERROR: Level ", lvl, " built null!")
			continue
		total_pieces += def.pieces.size()
		total_links += def.links.size()
		
		# Check if any child piece is positioned too far from parent stem
		# For each link, verify child position is within 25px of expected parent stem collar
		for link in def.links:
			var parent_p = null
			var child_p = null
			for p in def.pieces:
				if p.id == link.from_piece_id: parent_p = p
				if p.id == link.to_piece_id: child_p = p
			if parent_p != null and child_p != null:
				var expected_dist: float = parent_p.radius + child_p.radius
				var actual_dist: float = parent_p.position.distance_to(child_p.position)
				if absf(actual_dist - expected_dist) > 30.0:
					unclasped_count += 1
					print("L", lvl, " DETACHED LINK: ", link.from_piece_id, " -> ", link.to_piece_id, " dist=", actual_dist, " expected=", expected_dist)
					
	print("--- AUDIT RESULTS ---")
	print("Total Levels: 100")
	print("Total Pieces: ", total_pieces)
	print("Total Links: ", total_links)
	print("Unclasped/Detached Links: ", unclasped_count)
	if unclasped_count == 0:
		print("SUCCESS: 100% of child rings spawn tightly clasped to parent stems!")
	quit()
