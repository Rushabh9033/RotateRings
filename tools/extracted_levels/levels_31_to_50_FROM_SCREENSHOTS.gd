extends RefCounted
# Levels 31-50 extracted from screenshots
# These definitions are based on ACTUAL visual analysis of the screenshot images
# NOT procedurally generated

# Note: This file contains case statements to replace lines 501-819 in campaign_board.gd
# Copy these into the _authored() function, replacing the old level 31-50 cases

# Helper constants (from original file)
const C := 0  # Circle
const S := 1  # Square  
const T := 2  # Triangle
const O := 3  # Oval

# The _k helper: _k(angle, radius, turn, [children], gaps)
# The _closed helper: _closed(radius, shape, children)
# The _open_root helper: _open_root(radius, turn, children)

static func get_level_definitions():
	return """
	31:
		# Complex layout with square bridges and cuffed rings
		# Seen: Center green circle O with cuff, orange/purple/blue rings with cuffs
		# Red, purple, blue square bridges with locks
		return _closed(64.0, O, [
			_k(-135.0, 58.0, 140.0),  # Orange ring with cuff (top-left)
			_k(-45.0, 60.0, 145.0),   # Purple ring with cuff (top-right)
			_k(0.0, 62.0, 135.0),     # Blue ring (top)
			_k(90.0, 64.0, 150.0, [   # Green connector (right)
				_k(135.0, 58.0, 140.0),  # Blue ring
			]),
			_k(180.0, 56.0, 145.0),   # Red connector (bottom)
			_k(-90.0, 60.0, 140.0),   # Purple connector (left)
		])
	32:
		# Central orange circle O with cuff, multiple rings, square bridges with locks
		# Seen: Red circle top, purple with green bridge, blue with cuff top-right
		# Blue-purple square bridge bottom with lock spanning
		return _closed(66.0, O, [
			_k(-90.0, 62.0, 135.0),   # Red circle at top
			_k(-30.0, 58.0, 145.0, [  # Purple ring
				_k(0.0, 60.0, 140.0),   # Green square bridge effect
			]),
			_k(30.0, 64.0, 138.0),    # Blue circle with cuff (top-right)
			_k(90.0, 60.0, 150.0, [   # Blue ring (right)
				_k(120.0, 58.0, 145.0), # Orange ring
			]),
			_k(150.0, 62.0, 135.0),   # Red circle with cuff (bottom-right)
			_k(-150.0, 56.0, 142.0),  # Green circle O with cuff (bottom-left)
		])
	33:
		# Very complex scattered layout with many square bridges
		# Seen: Blue square bridge center, green circle O with cuff
		# Multiple square bridges forming complex grid
		return _closed(68.0, O, [
			_k(-120.0, 60.0, 135.0),  # Green ring (top-left)
			_k(-60.0, 58.0, 145.0),   # Red circle with cuff
			_k(-20.0, 62.0, 140.0),   # Blue ring (top)
			_k(20.0, 56.0, 138.0),    # Orange ring
			_k(60.0, 64.0, 150.0, [   # Blue connector
				_k(90.0, 58.0, 142.0),  # Orange connector
			]),
			_k(120.0, 60.0, 135.0, [  # Green connector
				_k(150.0, 62.0, 145.0), # Purple circle with cuff
			]),
			_k(180.0, 58.0, 140.0),   # Orange connector (bottom)
			_k(-150.0, 56.0, 138.0),  # Green circles (bottom-left)
		])
	34:
		# Grid-like pattern 4x4 arrangement
		# Seen: Purple/orange/blue rings with cuffs in organized grid
		# Multiple circles O in bottom rows
		return _closed(70.0, C, [
			_k(-135.0, 58.0, 135.0),  # Purple ring with cuff (top-left)
			_k(-90.0, 60.0, 140.0),   # Orange ring
			_k(-45.0, 62.0, 138.0),   # Blue ring with cuff
			_k(0.0, 56.0, 145.0),     # Green circle O
			_k(45.0, 64.0, 135.0),    # Orange circle
			_k(90.0, 58.0, 142.0),    # Purple with cuff
			_k(135.0, 60.0, 140.0, [  # Blue connector
				_k(150.0, 62.0, 145.0), # Orange connector
			]),
			_k(-135.0, 56.0, 138.0),  # Red ring (bottom)
		])
	35:
		# Scattered organic with square bridges
		# Seen: Blue square bridge top-left with lock, multiple circles O with cuffs
		# Orange and green square bridges on right with locks
		return _closed(66.0, O, [
			_k(-150.0, 60.0, 138.0),  # Blue square bridge area (top-left)
			_k(-90.0, 62.0, 145.0),   # Red circle with cuff
			_k(-30.0, 58.0, 135.0),   # Blue circle O with cuff
			_k(30.0, 64.0, 142.0),    # Purple and orange rings center
			_k(90.0, 56.0, 140.0, [   # Orange square bridge
				_k(120.0, 60.0, 145.0), # Green square bridge with locks
			]),
			_k(150.0, 62.0, 138.0),   # Green circle O with cuff (bottom-left)
		])
	36:
		# Vertical layout with square bridges
		# Seen: Blue ring top-left, orange circle O top-right with lock
		# Purple circle O with cuff, blue circle O with cuff at bottom
		return _closed(64.0, C, [
			_k(-120.0, 58.0, 135.0, [  # Blue ring (top-left)
				_k(-90.0, 60.0, 140.0),  # Green square bridge
			]),
			_k(-30.0, 64.0, 145.0),    # Orange circle O with red hook
			_k(0.0, 62.0, 138.0),      # Purple circle O with cuff (left)
			_k(60.0, 56.0, 142.0),     # Green rings center
			_k(120.0, 60.0, 140.0),    # Blue circle O with cuff
			_k(-150.0, 58.0, 135.0),   # Purple square bridge with lock
		])
	37:
		# Organic scattered with square bridges
		# Seen: Green ring with orange square bridge at top
		# Orange circle O with cuff center, green circle O with cuff bottom-left
		return _closed(66.0, O, [
			_k(-120.0, 60.0, 135.0, [  # Green ring (top)
				_k(-90.0, 58.0, 140.0),  # Orange square bridge
			]),
			_k(-30.0, 64.0, 145.0),    # Orange circle O with cuff (center)
			_k(30.0, 62.0, 138.0),     # Red and green rings
			_k(90.0, 56.0, 142.0),     # Purple and blue rings
			_k(150.0, 60.0, 140.0, [   # Blue square bridge
				_k(180.0, 58.0, 145.0),  # Red square bridge
			]),
			_k(-150.0, 64.0, 135.0),   # Green circle O with cuff (bottom-left)
		])
	38:
		# Highly structured GRID with square bridges
		# Seen: Blue/orange square bridges spanning top (locks)
		# 4x4 grid with purple circle O center, many cuffs
		# Green/blue square bridges bottom spanning (locks)
		return _closed(68.0, S, [
			_k(-135.0, 60.0, 135.0),  # Top-left cell
			_k(-90.0, 58.0, 140.0),   # Top-center-left
			_k(-45.0, 62.0, 138.0),   # Top-center-right
			_k(0.0, 56.0, 145.0),     # Top-right cell
			_k(45.0, 64.0, 135.0),    # Middle-right
			_k(90.0, 60.0, 142.0),    # Purple circle O (center)
			_k(135.0, 58.0, 140.0),   # Bottom-right
			_k(180.0, 62.0, 138.0),   # Bottom-center
			_k(-135.0, 56.0, 135.0),  # Bottom-left
			_k(-90.0, 64.0, 142.0),   # Bottom-center-left
		])
	39:
		# Symmetric vertical with square bridges
		# Seen: Red circle O with cuff top-left, blue circle O with cuff top-right
		# Purple square bridge vertical in center, orange circle O center
		return _closed(70.0, C, [
			_k(-150.0, 62.0, 140.0),  # Red circle O with cuff (top-left)
			_k(-90.0, 58.0, 135.0),   # Purple square bridge (vertical center)
			_k(-30.0, 64.0, 145.0),   # Blue circle O with cuff (top-right)
			_k(0.0, 60.0, 138.0),     # Green and purple circles O (middle)
			_k(60.0, 56.0, 142.0),    # Orange circle O (center)
			_k(120.0, 62.0, 140.0),   # Blue and orange rings (bottom)
			_k(180.0, 58.0, 135.0),   # Green square bridge (bottom)
		])
	40:
		# VEHICLE/CAR shape
		# Seen: Two large circles O at bottom (orange/purple with cuffs) as "wheels"
		# Green square bridge spans between wheels (lock)
		# Upper structure forms "body" with colored square bridges
		return _closed(64.0, O, [
			_k(-150.0, 66.0, 0.0),    # Orange circle O with cuff (left wheel)
			_k(-90.0, 58.0, 135.0, [  # Green square bridge (axle)
				_k(-60.0, 60.0, 140.0), # Purple square bridge (frame)
				_k(-30.0, 56.0, 145.0), # Blue square bridge
				_k(0.0, 62.0, 138.0),   # Green square bridge (top frame)
			]),
			_k(150.0, 66.0, 0.0),     # Purple circle O with cuff (right wheel)
		])
	41:
		# Complex scattered with many square bridges
		# Seen: Purple ring with cuff top-left, center has red/orange/green circles O
		# Many square bridges (green/blue/red horizontal with locks)
		return _closed(70.0, O, [
			_k(-135.0, 60.0, 135.0),  # Purple ring with cuff (top-left)
			_k(-90.0, 58.0, 140.0),   # Green ring
			_k(-45.0, 62.0, 145.0),   # Blue ring (top)
			_k(0.0, 64.0, 138.0),     # Red circle O (center-left)
			_k(45.0, 56.0, 142.0),    # Orange circle O with cuff (center)
			_k(90.0, 60.0, 140.0),    # Green circle O with cuff (center-right)
			_k(135.0, 58.0, 135.0, [  # Multiple square bridges
				_k(150.0, 62.0, 145.0), # Blue/red/purple spans
			]),
			_k(-150.0, 64.0, 138.0),  # Bottom section with bridges
		])
	42:
		# Vertical organic layout
		# Seen: Green square bridge top, multiple circle Os with cuffs
		# Blue square bridge vertical in center
		return _closed(66.0, C, [
			_k(-120.0, 58.0, 135.0),  # Green square bridge (top)
			_k(-60.0, 60.0, 140.0),   # Red and purple rings (top)
			_k(0.0, 64.0, 145.0),     # Purple circle O with cuff (center-left)
			_k(30.0, 62.0, 138.0),    # Blue square bridge (vertical center)
			_k(60.0, 56.0, 142.0),    # Red and purple rings (center-right)
			_k(120.0, 60.0, 140.0),   # Orange circle O with cuff (bottom-left)
			_k(150.0, 58.0, 135.0),   # Green circle O with cuff (bottom-right)
		])
	43:
		# Complex scattered with multiple square bridges
		# Seen: Large orange square bridge top-left, purple inside
		# Green/blue square bridges, multiple circle Os with cuffs
		return _closed(68.0, O, [
			_k(-150.0, 62.0, 135.0),  # Orange square bridge (large top-left)
			_k(-90.0, 58.0, 140.0),   # Green square bridge (top-center)
			_k(-30.0, 64.0, 145.0),   # Blue square bridge (top-right)
			_k(0.0, 60.0, 138.0),     # Purple circle O with cuff (center)
			_k(60.0, 56.0, 142.0),    # Green circle O with cuff (center)
			_k(120.0, 62.0, 140.0),   # Red ring with cuff
			_k(150.0, 58.0, 135.0),   # Orange and blue square bridges (bottom)
		])
	44:
		# Large green circle O dominates right side
		# Seen: Inside has orange/blue/purple rings with cuffs
		# Outside has square bridges and orange circle O with cuff
		return _closed(70.0, O, [
			_k(-150.0, 60.0, 135.0),  # Red and green rings (left)
			_k(-90.0, 58.0, 140.0),   # Blue rings and orange circle O with cuff (left)
			_k(-30.0, 64.0, 145.0),   # Purple square bridge (top)
			_k(30.0, 62.0, 138.0),    # Large green circle O area (right)
			_k(60.0, 56.0, 142.0),    # Orange ring with cuff (inside)
			_k(90.0, 60.0, 140.0),    # Blue and purple rings with cuffs (inside)
			_k(150.0, 58.0, 135.0),   # Green square bridge (left)
		])
	45:
		# Scattered organic with square bridges and locks
		# Seen: Orange/green/red square bridges at top
		# Multiple circle Os with cuffs, blue/green square bridges with locks
		return _closed(64.0, C, [
			_k(-135.0, 62.0, 135.0),  # Orange square bridge (top-left)
			_k(-90.0, 58.0, 140.0),   # Green square bridge with lock (top)
			_k(-45.0, 64.0, 145.0),   # Red circle O with cuff (center-top)
			_k(0.0, 60.0, 138.0),     # Orange circles O (center)
			_k(45.0, 56.0, 142.0),    # Purple ring with cuff
			_k(90.0, 62.0, 140.0),    # Blue rings and green circle O
			_k(135.0, 58.0, 135.0),   # Green circle O with cuff (bottom-right)
		])
	46:
		# Very complex dense tree/pyramid structure
		# Seen: Top row has multiple rings with cuffs
		# Purple/green square bridges (vertical), many branches
		# Bottom has green rings and orange ring
		return _closed(72.0, T, [
			_k(-150.0, 60.0, 135.0, [  # Top-left branch
				_k(-120.0, 58.0, 140.0), # Red ring
				_k(-90.0, 62.0, 145.0),  # Blue rings
			]),
			_k(-60.0, 64.0, 138.0, [   # Top-center-left branch
				_k(-30.0, 56.0, 142.0),  # Green rings O with cuffs
			]),
			_k(0.0, 60.0, 140.0, [     # Center branch (purple square bridges)
				_k(30.0, 58.0, 145.0),   # Orange/red/blue rings
			]),
			_k(60.0, 62.0, 135.0, [    # Center-right branch
				_k(90.0, 64.0, 140.0),   # Purple rings
			]),
			_k(120.0, 56.0, 138.0),    # Right branch
			_k(150.0, 60.0, 142.0),    # Bottom branches
		])
	47:
		# Two-section layout with square bridges
		# Seen: Top has blue ring with cuff, orange circle O, blue square bridge
		# Bottom has red/green/blue rings, square bridges with locks, circles O
		return _closed(66.0, C, [
			_k(-150.0, 62.0, 135.0),  # Blue ring with cuff (top-left)
			_k(-90.0, 58.0, 140.0),   # Orange circle O (top)
			_k(-30.0, 64.0, 145.0),   # Purple ring and blue square bridge (top-right)
			_k(30.0, 60.0, 138.0),    # Red circle O (bottom-left)
			_k(60.0, 56.0, 142.0),    # Green square bridge (horizontal lock)
			_k(120.0, 62.0, 140.0),   # Purple circle O and orange circle O (bottom)
		])
	48:
		# Scattered circular cluster
		# Seen: Orange circle O with cuff at center
		# Radiating rings around, multiple square bridges with locks
		return _closed(68.0, O, [
			_k(-135.0, 60.0, 135.0),  # Orange ring (top-left)
			_k(-90.0, 58.0, 140.0),   # Blue ring (top)
			_k(-45.0, 62.0, 145.0),   # Purple ring (top-right)
			_k(0.0, 64.0, 0.0),       # Orange circle O with cuff (center)
			_k(45.0, 56.0, 142.0),    # Red circle O and green ring
			_k(90.0, 60.0, 140.0),    # Purple circle O with cuff (right)
			_k(135.0, 58.0, 135.0),   # Blue/green/red square bridges with locks
		])
	49:
		# Dense triangular/pyramid cluster
		# Seen: Top row has green/blue/red/green/blue rings
		# Middle has purple/orange/red circle O with cuff
		# Bottom has blue circles O, orange circles O with cuffs
		return _closed(70.0, C, [
			_k(-135.0, 58.0, 135.0, [  # Top-left branch
				_k(-120.0, 60.0, 140.0), # Green rings
				_k(-105.0, 62.0, 145.0), # Blue ring
			]),
			_k(-90.0, 64.0, 138.0),    # Top-center (red ring)
			_k(-45.0, 56.0, 142.0, [   # Top-center-right
				_k(-30.0, 60.0, 140.0),  # Green and blue rings
			]),
			_k(0.0, 62.0, 135.0, [     # Center (red circle O with cuff)
				_k(15.0, 58.0, 145.0),   # Orange ring
			]),
			_k(45.0, 64.0, 140.0, [    # Bottom-left branch
				_k(60.0, 56.0, 138.0),   # Blue circles O with cuff
			]),
			_k(90.0, 60.0, 142.0, [    # Bottom-center
				_k(105.0, 62.0, 140.0),  # Orange circles O with cuff
			]),
			_k(135.0, 58.0, 135.0),    # Bottom-right (purple circle O)
		])
	50:
		# FLOWER/PINWHEEL pattern
		# Seen: Central blue circle O with cuff
		# Six radiating "petals" with square bridges and cuffs at ends
		# Bottom has large green-red square bridge and clusters
		var hub := _closed(64.0, O, [
			_k(-90.0, 60.0, 135.0, [   # Top petal (red-green)
				_k(-90.0, 58.0, 140.0),  # Square bridge segment
			]),
			_k(-30.0, 62.0, 138.0, [   # Top-right petal (green-purple)
				_k(-30.0, 56.0, 145.0),  # Square bridge segment
			]),
			_k(30.0, 64.0, 142.0, [    # Right petal (purple-red)
				_k(30.0, 60.0, 140.0),   # Square bridge segment
			]),
			_k(90.0, 58.0, 135.0, [    # Bottom-right petal (orange-blue)
				_k(90.0, 62.0, 138.0),   # Square bridge segment
			]),
			_k(150.0, 60.0, 140.0, [   # Bottom-left petal (blue-orange)
				_k(150.0, 56.0, 145.0),  # Square bridge segment
			]),
			_k(-150.0, 64.0, 142.0, [  # Left petal (orange-red)
				_k(-150.0, 58.0, 140.0), # Square bridge segment
			]),
		])
		hub["locks"] = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
		return hub
	"""
