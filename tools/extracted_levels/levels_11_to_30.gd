# Extracted Levels 11-30 from screenshots
# Generated from manual analysis of level geometry

extends RefCounted

const C := 0  # Circle/open ring
const S := 1  # Square
const T := 2  # Triangle  
const O := 3  # Offset/oval

# Helper functions matching campaign_board.gd structure
static func _n(r: float, shape: int, gaps: int, turn: float, color: int, kids: Array, bridge: bool = false, extra: Array = []) -> Dictionary:
	return {
		"r": r,
		"shape": shape,
		"gaps": gaps,
		"turn": turn,
		"color": color,
		"kids": kids,
		"bridge": bridge,
		"extra": extra,
		"thick": 16.0,
	}

static func _leaf(r: float, turn: float, gaps: int = 1) -> Dictionary:
	return _n(r, C, gaps, turn, 0, [])

static func _k(angle: float, radius: float, turn: float, children: Array = [], gaps: int = 1) -> Array:
	return [angle, _n(radius, C, gaps, turn, 0, children.duplicate())]

static func _closed(radius: float, shape: int, children: Array, bridge: bool = false) -> Dictionary:
	return _n(radius, shape, 0, 0.0, 0, children, bridge, [])

static func _open_root(radius: float, turn: float, children: Array) -> Dictionary:
	return _n(radius, C, 1, turn, 0, children)

static func _hold(r: float, shape: int, kids: Array, bridge: bool = false, extra: Array = []) -> Dictionary:
	return _n(r, shape, 0, 0, 0, kids, bridge, extra)

# Level definitions

static func level_11() -> Dictionary:
	# Structure: Top row: red C, light cyan C, purple C with honey
	# Middle row: light cyan full, dark blue full with honey
	# Bottom row: light cyan C with honey, green C, orange full
	return _open_root(66, 132.0, [
		_k(-115, 68, 136.0),  # Red C-ring top-left
		_k(-35, 56, 148.0),   # Light cyan C-ring top-center
		_k(60, 64, 140.0, [   # Purple C-ring top-right (has honey)
			_k(145, 58, 158.0), # Connector to dark blue full
		]),
		_k(180, 72, 136.0, [  # Dark blue full middle (has honey)
			_k(-90, 60, 145.0, [  # Light cyan C-ring bottom-left (has honey)
				_k(-180, 58, 152.0), # Green C-ring bottom-center
			]),
		]),
		_k(100, 64, 142.0, [  # Orange full bottom-right
			_k(180, 62, 138.0),
		]),
	])

static func level_12() -> Dictionary:
	# Structure: Light cyan C-ring on left with locks
	# Green C-ring middle, light cyan full with honey on right
	# Dark blue C-ring and orange C-ring at bottom
	# Purple bar at top, orange bar middle-left, dark blue bar middle-right
	return _closed(70, C, [
		_k(-110, 60, 132.0, [  # Light cyan C-ring left
			_k(-20, 56, 149.0, [], 1),  # Orange bar
		]),
		_k(70, 64, 132.0, [    # Green C-ring right
			_k(160, 58, 149.0, [   # Light cyan full (has honey)
				_k(250, 62, 136.0),    # Dark blue C-ring
			]),
		]),
	])

static func level_13() -> Dictionary:
	# Structure: Complex tree with multiple paths
	# Dark blue C-ring root, green curvy connector, red full ring
	# Multiple branches with honey markers in purple and orange rings
	# Light cyan chains with green C-rings at bottom
	return _open_root(70, 90.0, [
		_k(-90, 68, 135.0, [    # Dark blue C-ring top-left
			_k(-10, 62, 148.0, [   # Green curved connector
				_k(80, 56, 142.0),     # Branch continuation
			]),
		]),
		_k(0, 72, 90.0, [       # Red full ring center
			_k(90, 64, 145.0, [    # Light cyan branch
				_k(180, 58, 152.0, [   # Orange C-ring (has honey)
					_k(270, 60, 138.0, [   # Purple C-ring
						_k(0, 66, 155.0),      # Full purple ring (has honey)
					]),
				]),
			]),
		]),
		_k(180, 68, 135.0, [    # Red C-ring bottom
			_k(270, 58, 148.0, [   # Orange C-ring (has honey)
				_k(0, 62, 142.0, [     # Purple full ring bottom
					_k(90, 56, 155.0),     # Another purple ring (has honey)
				]),
			]),
		]),
		_k(-180, 64, 145.0),    # Green full ring bottom-left
	])

static func level_14() -> Dictionary:
	# Structure: Grid-like structure with many small rings
	# 3 rows of connected rings forming a symmetrical pattern
	# Top row: orange C, green cross, purple C-ring
	# Middle rows: Multiple small rings connected in sequence
	# Bottom row: green C, light cyan full, red full
	# Has 3 honey markers distributed across rings
	return _closed(64, C, [
		_k(-90, 58, 130.0, [     # Orange C-ring top-left
			_k(-50, 62, 145.0, [    # Green cross connector
				_k(-10, 56, 138.0, [    # Purple C-ring top
					_k(30, 60, 152.0, [     # Dark blue C-ring
						_k(70, 58, 140.0, [     # Orange C-ring middle-right
							_k(110, 64, 148.0, [    # Red C-ring
								_k(150, 62, 135.0),     # Green C-ring
							]),
						]),
					]),
				]),
			]),
		]),
		_k(90, 66, 132.0, [      # Dark blue C-ring middle
			_k(130, 58, 146.0, [    # Green C-ring
				_k(170, 60, 138.0, [    # Light cyan full (has honey)
					_k(210, 56, 150.0, [    # Red full (has honey)
						_k(250, 62, 142.0),     # Orange C-ring bottom
					]),
				]),
			]),
		]),
		_k(-70, 64, 135.0, [     # Green C-ring bottom-left (has honey)
			_k(-30, 58, 148.0),      # Light cyan C-ring bottom
		]),
	])

static func level_15() -> Dictionary:
	# Structure: Nested rings with curved connectors
	# Large purple arc at top, multiple paths downward
	# Green curved sections, light cyan and blue rings scattered
	# Red rings at bottom-left with honey markers
	# Orange curved sections creating complex paths
	return _closed(72, C, [
		_k(-150, 64, 128.0, [    # Green C-ring top-left
			_k(-90, 58, 142.0, [    # Dark blue curved section
				_k(-30, 62, 135.0, [    # Green curved section
					_k(30, 56, 148.0),      # Light cyan C-ring
				]),
			]),
		]),
		_k(0, 68, 90.0, [        # Purple arc top-center
			_k(60, 60, 145.0, [     # Light cyan curved section
				_k(120, 58, 138.0, [    # Green C-ring
					_k(180, 64, 152.0),     # Purple C-ring right
				]),
			]),
		]),
		_k(-90, 66, 132.0, [     # Red ring bottom-left (has honey)
			_k(-30, 58, 146.0, [    # Light cyan curved section
				_k(30, 62, 140.0, [     # Red ring (has honey)
					_k(90, 56, 154.0),      # Orange C-ring (has honey)
				]),
			]),
		]),
		_k(150, 60, 135.0, [     # Orange curved section bottom-right
			_k(210, 58, 148.0),     # Light cyan C-ring
		]),
	])

static func level_16() -> Dictionary:
	# Structure: Central red full ring with radiating connections
	# Orange ring at top with honey
	# Dark blue and purple C-rings to sides
	# Green C-rings form middle layer
	# Bottom has green, purple, orange, and blue rings with honey markers
	return _closed(68, O, [
		_k(0, 62, 90.0),        # Orange full ring top (has honey)
		_k(-60, 58, 132.0, [    # Dark blue C-ring left
			_k(-120, 60, 148.0),   # Green C-ring bottom-left
		]),
		_k(60, 64, 132.0, [     # Purple C-ring right
			_k(120, 56, 148.0, [   # Green C-ring
				_k(180, 58, 142.0),    # Red full ring center
			]),
		]),
		_k(-180, 66, 135.0, [   # Green C-ring bottom-left
			_k(-120, 60, 150.0, [  # Red full ring
				_k(-60, 58, 140.0, [   # Purple C-ring
					_k(0, 62, 155.0, [     # Orange full ring (has honey)
						_k(60, 56, 145.0),     # Dark blue full ring (has honey)
					]),
				]),
			]),
		]),
		_k(120, 64, 138.0, [    # Light cyan C-ring bottom-right
			_k(180, 58, 152.0),    # Orange C-ring
		]),
	])

static func level_17() -> Dictionary:
	# Structure: Vertical chain structure
	# Top: Green C-ring with honey, red connector
	# Middle: Orange and red C-rings
	# Light cyan C-ring center, connecting to dark blue and purple
	# Bottom: Complex arrangement with green, light cyan, red rings
	# Multiple branches with honey in orange and green rings
	return _open_root(64, 90.0, [
		_k(0, 66, 130.0, [      # Green C-ring top (has honey)
			_k(90, 58, 145.0, [    # Red connector
				_k(180, 60, 138.0),    # Orange C-ring
			]),
		]),
		_k(90, 68, 132.0, [     # Light cyan C-ring middle
			_k(180, 62, 148.0, [   # Purple curved section
				_k(270, 56, 140.0, [   # Dark blue full ring
					_k(0, 58, 155.0, [     # Orange C-ring (has honey)
						_k(90, 64, 145.0),     # Branch continuation
					]),
				]),
			]),
		]),
		_k(180, 66, 135.0, [    # Green C-ring bottom-left (has honey)
			_k(270, 58, 150.0, [   # Light cyan C-ring
				_k(0, 60, 142.0, [     # Red C-ring
					_k(90, 56, 158.0, [    # Dark blue C-ring
						_k(180, 62, 148.0),    # Purple curved section
					]),
				]),
			]),
		]),
	])

static func level_18() -> Dictionary:
	# Structure: Mixed shapes with bars (locks)
	# Top: Red rounded rectangle with 2 locks, purple C-rings on sides
	# Orange rings in upper portion
	# Green diagonal bar connector, multiple honey markers
	# Light cyan and dark blue rings at bottom, orange C-ring bottom-right
	# Purple bar at bottom-right
	return _closed(66, S, [  # Red rounded rectangle shape
		_k(-90, 60, 0.0),      # Purple C-ring left (lock)
		_k(90, 60, 0.0),       # Purple C-ring right (lock)
		_k(-45, 58, 135.0, [   # Orange C-ring upper-left
			_k(-90, 62, 148.0, [  # Green diagonal connector
				_k(-135, 56, 142.0, [  # Orange full ring center (has honey)
					_k(-180, 58, 155.0),   # Green C-ring
				]),
			]),
		]),
		_k(0, 64, 130.0, [     # Green C-ring right (has honey)
			_k(45, 60, 145.0, [    # Dark blue C-ring
				_k(90, 56, 138.0),     # Purple C-ring
			]),
		]),
		_k(-135, 62, 132.0, [  # Light cyan C-ring bottom-left
			_k(-180, 58, 148.0, [  # Dark blue full ring (has honey)
				_k(-225, 64, 140.0, [  # Light cyan C-ring
					_k(-270, 60, 155.0),   # Orange C-ring bottom-right
				]),
			]),
		]),
	], false, [[90, 60], [-90, 60]])  # Locks on left and right purple rings

static func level_19() -> Dictionary:
	# Structure: Highly complex with many bars (connectors)
	# Multiple vertical and horizontal bar segments
	# Top section has purple, dark blue, and light cyan bars
	# Red C-ring left with honey, light cyan full ring middle-left (has honey)
	# Orange and purple curved sections throughout
	# Green curved sections at bottom, connecting to light cyan ring (has honey)
	# Rounded rectangle shapes at bottom (purple and light cyan)
	return _open_root(68, 90.0, [
		_k(-135, 58, 0.0, [     # Purple bar top-left
			_k(-90, 0, 0.0),       # (Bar segment, no ring)
		]),
		_k(-45, 62, 0.0, [      # Dark blue bar top
			_k(0, 0, 0.0, [        # (Bar segment)
				_k(45, 0, 0.0),        # Light cyan bar top-right
			]),
		]),
		_k(90, 60, 0.0, [       # Light cyan bar right
			_k(135, 0, 0.0),       # (Bar segment)
		]),
		_k(-180, 66, 132.0, [   # Red C-ring left (has honey)
			_k(-135, 58, 148.0, [  # Light cyan full ring (has honey)
				_k(-90, 64, 140.0, [   # Green curved section
					_k(-45, 56, 155.0, [   # Orange C-ring
						_k(0, 60, 145.0, [     # Red C-ring middle (has honey)
							_k(45, 58, 158.0, [    # Purple curved section
								_k(90, 62, 148.0),     # Green curved section
							]),
						]),
					]),
				]),
			]),
		]),
		_k(135, 64, 130.0, [    # Green C-ring bottom-left
			_k(180, 58, 145.0, [   # Light cyan bar bottom
				_k(-135, 60, 0.0),     # (Bar segment)
			]),
		]),
		_k(-90, 62, 135.0, [    # Green C-ring bottom-right
			_k(-45, 56, 150.0, [   # Light cyan C-ring (has honey)
				_k(0, 0, 0.0),         # Purple rounded rectangle bottom
			]),
		]),
	])

static func level_20() -> Dictionary:
	# Structure: Large red circle containing nested rings
	# Forms a face-like pattern with 2 small rings as eyes
	# Green and dark blue small rings at top (eyes)
	# Light cyan and orange smallest rings inside purple arcs (glasses)
	# Has honey markers in the tiny eye rings
	# Angular shapes at top edges (green-blue and green-orange connectors)
	return _closed(150, O, [  # Large red outer circle
		_k(-135, 0, 0.0, [      # Green-blue angular connector top-left
			_k(-90, 0, 0.0),        # (Lock/connector segment)
		]),
		_k(-45, 0, 0.0, [       # Green-orange angular connector top-right
			_k(0, 0, 0.0),          # (Lock/connector segment)
		]),
		_k(-120, 56, 90.0, [    # Green small ring left-eye (has honey)
			_k(-90, 0, 0.0),        # Inner structure
		]),
		_k(-60, 58, 90.0, [     # Dark blue small ring right-eye (has honey)
			_k(-30, 0, 0.0),        # Inner structure
		]),
		_k(0, 68, 180.0, [      # Purple arc glasses frame bottom
			_k(-30, 42, 90.0, [    # Light cyan tiniest ring left (has honey)
				_k(0, 0, 0.0),         # Inner dot
			]),
			_k(30, 44, 90.0, [     # Orange tiniest ring right (has honey)
				_k(0, 0, 0.0),         # Inner dot
			]),
		]),
	])

static func level_21() -> Dictionary:
	# Structure: Dense grid/web of bars creating intricate pattern
	# Many horizontal and vertical bar segments with locks
	# Forms almost a circuit-board like appearance
	# Multiple lock points throughout the structure
	# Organized in roughly 4 horizontal layers
	# Colors distributed across: light cyan, purple, green, orange, dark blue, red
	# No visible honey markers in this level
	return _open_root(0, 0.0, [  # No central ring, starts with bar network
		# Top layer bars
		_k(-180, 0, 0.0, [      # Light cyan bar far-left
			_k(-150, 0, 0.0, [     # Purple bar
				_k(-120, 0, 0.0),      # (Lock point)
			]),
		]),
		_k(-90, 0, 0.0, [       # Red bar top-center
			_k(-60, 0, 0.0, [      # Green bar
				_k(-30, 0, 0.0),       # (Lock point)
			]),
		]),
		_k(0, 0, 0.0, [         # Green bar top-right
			_k(30, 0, 0.0, [       # Light cyan bar
				_k(60, 0, 0.0),        # (Lock point)
			]),
		]),
		# Second layer
		_k(-165, 0, 0.0, [      # Light cyan vertical segment
			_k(-135, 0, 0.0, [     # Green L-shape
				_k(-105, 0, 0.0),      # (Lock point)
			]),
		]),
		_k(-75, 0, 0.0, [       # Dark blue vertical
			_k(-45, 0, 0.0, [      # Orange segment
				_k(-15, 0, 0.0, [      # Purple segment
					_k(15, 0, 0.0),        # Green segment (lock)
				]),
			]),
		]),
		# Third layer
		_k(-150, 0, 0.0, [      # Green horizontal bar
			_k(-120, 0, 0.0, [     # Light cyan segment
				_k(-90, 0, 0.0, [      # Purple L-shape
					_k(-60, 0, 0.0),       # (Lock point)
				]),
			]),
		]),
		_k(-30, 0, 0.0, [       # Orange horizontal
			_k(0, 0, 0.0, [        # Light cyan segment
				_k(30, 0, 0.0, [       # Orange segment
					_k(60, 0, 0.0),        # (Lock point)
				]),
			]),
		]),
		# Bottom layer
		_k(-180, 0, 0.0, [      # Red bar bottom-left
			_k(-150, 0, 0.0, [     # Green bar
				_k(-120, 0, 0.0),      # (Lock point)
			]),
		]),
		_k(-90, 0, 0.0, [       # Purple bar bottom-center
			_k(-60, 0, 0.0),       # (Lock point)
		]),
	])

static func level_22() -> Dictionary:
	# Structure: Large red circle with complex internal network
	# Top section has smaller rings and bars radiating outward
	# Purple C-ring top-left (has honey)
	# Orange and light cyan branches with connectors
	# Center contains green C-ring (has honey), orange C-ring, light cyan C-ring (has honey)
	# Red circle encloses a smaller section
	# Bottom has light cyan bar with orange connector
	# Dark blue C-ring bottom-center
	# Right side has red and green bars with locks
	return _closed(145, O, [  # Large red outer circle
		_k(-135, 60, 132.0, [   # Purple C-ring top-left (has honey)
			_k(-90, 58, 148.0, [   # Orange connector
				_k(-45, 0, 0.0, [      # (Bar segment to lock)
					_k(0, 0, 0.0),         # Red bar lock
				]),
			]),
		]),
		_k(-45, 62, 135.0, [    # Orange C-ring top
			_k(0, 64, 150.0, [     # Light cyan connector
				_k(45, 58, 142.0, [    # Dark blue full ring
					_k(90, 56, 155.0),     # Green C-ring
				]),
			]),
		]),
		_k(90, 66, 130.0, [     # Red bar right side
			_k(135, 0, 0.0),       # Green bar with lock
		]),
		_k(0, 88, 90.0, [       # Inner red circle center
			_k(-45, 58, 145.0, [   # Green C-ring inside (has honey)
				_k(-90, 60, 158.0, [   # Orange C-ring
					_k(-135, 56, 148.0),   # Light cyan C-ring (has honey)
				]),
			]),
		]),
		_k(180, 64, 132.0, [    # Light cyan bar bottom
			_k(-135, 0, 0.0, [     # Orange connector bar
				_k(-90, 0, 0.0),       # (Lock segment)
			]),
		]),
		_k(-90, 62, 138.0),     # Dark blue C-ring bottom-center
	])

static func level_23() -> Dictionary:
	# Structure: Dense cluster of overlapping rings
	# Top row: green full ring with light cyan full ring (has honey), green C-ring with honey
	# Middle rows have orange full rings with purple and light cyan arcs
	# Center has green circle with red curved section, dark blue C-ring below
	# Bottom section has green C-rings, dark blue full ring (has honey), light cyan C-ring
	# Red C-ring and orange full ring at bottom-right edge
	# Purple C-ring bottom-center
	return _open_root(66, 90.0, [
		_k(-150, 62, 90.0, [    # Purple full ring top-left
			_k(-90, 58, 145.0, [   # Light cyan C-ring
				_k(-30, 64, 138.0),    # Orange full ring
			]),
		]),
		_k(-90, 68, 90.0, [     # Green full ring top (has light cyan inside)
			_k(0, 60, 90.0, [      # Light cyan full ring (has honey)
				_k(90, 56, 155.0),     # Dark blue C-ring
			]),
		]),
		_k(0, 64, 132.0, [      # Green C-ring top-right (has honey)
			_k(90, 58, 148.0, [    # Orange connector
				_k(180, 62, 140.0),    # Purple C-ring
			]),
		]),
		_k(90, 72, 90.0, [      # Orange full ring middle-top
			_k(0, 66, 145.0, [     # Green circle center
				_k(-90, 58, 158.0, [   # Red curved section
					_k(-180, 60, 148.0, [  # Green C-ring
						_k(-270, 56, 162.0),   # Dark blue C-ring
					]),
				]),
			]),
			_k(180, 64, 135.0),    # Light cyan C-ring middle-right
		]),
		_k(180, 58, 132.0, [    # Green C-ring bottom-left
			_k(-90, 62, 148.0, [   # Dark blue full ring (has honey)
				_k(0, 56, 142.0, [     # Light cyan C-ring
					_k(90, 60, 155.0),     # Red C-ring
				]),
			]),
		]),
		_k(-45, 64, 138.0, [    # Orange full ring bottom-right
			_k(45, 58, 152.0),     # Purple C-ring bottom
		]),
	])

static func level_24() -> Dictionary:
	# Structure: Layered grid structure with multiple rings and bars
	# Top row: green C-ring (has honey), light cyan full ring, orange C-ring
	# Second row: orange C-ring, purple full ring with purple L-connector
	# Third row (red bar) connects dark blue C-ring, green C-ring (has honey), orange C-ring
	# Fourth row: light cyan C-ring, dark blue full ring
	# Fifth row: dark blue C-ring, green full ring, purple curved, red full ring
	# Bottom row: green T-connector, light cyan full ring (has honey), orange bar with lock
	return _open_root(0, 0.0, [  # No central root, complex grid starts
		# Top layer
		_k(-180, 58, 132.0, [   # Green bar left (has honey on green C)
			_k(-150, 60, 148.0, [  # Light cyan full ring
				_k(-120, 62, 140.0, [  # Dark blue C-ring
					_k(-90, 56, 155.0, [   # Orange C-ring
						_k(-60, 64, 145.0, [   # Red C-ring
							_k(-30, 58, 158.0),    # Purple full ring
						]),
					]),
				]),
			]),
		]),
		# Middle layer (red horizontal bar)
		_k(0, 0, 0.0, [         # Red bar spanning width
			_k(-30, 62, 135.0, [   # Light cyan C-ring
				_k(0, 60, 148.0, [     # Dark blue C-ring
					_k(30, 58, 142.0),     # Green C-ring (has honey)
				]),
			]),
			_k(60, 56, 138.0, [    # Orange C-ring
				_k(90, 64, 152.0),     # Purple curved section
			]),
		]),
		# Lower layer
		_k(-150, 66, 130.0, [   # Dark blue C-ring bottom-left
			_k(-120, 58, 145.0, [  # Green full ring
				_k(-90, 60, 138.0, [   # Light cyan C-ring
					_k(-60, 56, 152.0, [   # Purple curved section
						_k(-30, 62, 145.0),    # Red full ring
					]),
				]),
			]),
		]),
		# Bottom layer
		_k(-180, 0, 0.0, [      # Green T-connector left
			_k(-150, 0, 0.0, [     # Light cyan bar
				_k(-120, 64, 132.0, [  # Light cyan full ring (has honey)
					_k(-90, 0, 0.0, [      # Orange bar
						_k(-60, 0, 0.0),       # (Lock point)
					]),
				]),
			]),
		]),
	])

static func level_25() -> Dictionary:
	# Structure: Organic flowing design with curved connectors
	# Top has purple curved section (has honey), light cyan curved section
	# Orange C-ring top-right connecting to dark blue L-shape
	# Red C-ring left, orange curved section
	# Light cyan full ring center (has honey) with green curved section below
	# Purple and dark blue curved sections with green L-shape
	# Bottom has orange C-ring (has honey), green L-connector with dark blue curved section
	return _open_root(64, 90.0, [
		_k(-150, 60, 125.0, [   # Purple curved section top-left (has honey)
			_k(-90, 58, 142.0, [   # Light cyan curved section
				_k(-30, 62, 135.0, [   # Orange C-ring
					_k(30, 56, 150.0),     # Dark blue L-shape
				]),
			]),
		]),
		_k(-180, 66, 130.0, [   # Red C-ring left
			_k(-120, 64, 148.0, [  # Orange curved section
				_k(-60, 58, 140.0, [   # Light cyan full ring center (has honey)
					_k(0, 60, 155.0, [     # Green curved section
						_k(60, 56, 145.0),     # Dark blue curved section
					]),
				]),
			]),
		]),
		_k(90, 62, 132.0, [     # Purple curved section right
			_k(150, 58, 148.0, [   # Dark blue curved section
				_k(-150, 0, 0.0),      # Green L-connector
			]),
		]),
		_k(180, 64, 138.0, [    # Orange C-ring bottom (has honey)
			_k(-120, 0, 0.0, [     # Green L-shape
				_k(-60, 0, 0.0),       # Dark blue curved section (lock)
			]),
		]),
	])

static func level_26() -> Dictionary:
	# Structure: Symmetrical radial pattern with central light cyan full ring
	# Top layer: green C-ring, orange connector, purple C-ring
	# Upper-middle: dark blue C-ring left, purple curved, red C-ring right
	# Center: light cyan full ring hub
	# Lower-middle: orange C-ring, green C-ring
	# Bottom: light cyan C-ring (has honey), light cyan full ring (has honey), red C-ring (has honey)
	# All arranged in roughly circular pattern around center
	return _closed(72, C, [  # Central light cyan full ring
		_k(-180, 58, 130.0, [   # Green C-ring top-left
			_k(-135, 60, 145.0, [  # Orange connector
				_k(-90, 56, 138.0),    # Purple C-ring top-right
			]),
		]),
		_k(-120, 62, 132.0, [   # Dark blue C-ring left
			_k(-60, 58, 148.0, [   # Purple curved section
				_k(0, 64, 140.0),      # Light cyan full ring left
			]),
		]),
		_k(60, 60, 135.0, [     # Red C-ring right
			_k(120, 56, 150.0, [   # Orange curved section
				_k(180, 58, 142.0),    # Purple C-ring bottom
			]),
		]),
		_k(-90, 66, 128.0, [    # Orange C-ring bottom-left
			_k(-30, 62, 145.0, [   # Green C-ring
				_k(30, 58, 138.0),     # Red C-ring
			]),
		]),
		_k(90, 64, 132.0, [     # Light cyan C-ring bottom-right (has honey)
			_k(150, 60, 148.0, [   # Light cyan full ring (has honey)
				_k(-150, 56, 155.0),   # Red C-ring (has honey)
			]),
		]),
	])

static func level_27() -> Dictionary:
	# Structure: Mix of rings and long bars
	# Top: orange full ring (has honey), green L-bar, dark blue bar, purple bar
	# Middle-top: dark blue C-ring, purple C-ring left, orange bar right
	# Center: light cyan full ring with green C-ring (has honey), dark blue C-ring (has honey)
	# Middle-bottom: purple L-bar, light cyan C-ring, green full ring
	# Bottom: orange and green bars, green C-ring, red bar with lock
	return _open_root(68, 90.0, [
		_k(-180, 64, 90.0, [    # Orange full ring top-left (has honey)
			_k(-135, 0, 0.0, [     # Green L-bar
				_k(-90, 0, 0.0, [      # Dark blue bar top
					_k(-45, 0, 0.0),       # Purple bar
				]),
			]),
		]),
		_k(-120, 60, 132.0, [   # Dark blue C-ring left
			_k(-60, 58, 148.0, [   # Purple C-ring
				_k(0, 0, 0.0),         # Orange bar right
			]),
		]),
		_k(0, 72, 90.0, [       # Light cyan full ring center
			_k(-45, 62, 145.0, [   # Green C-ring (has honey)
				_k(-90, 56, 158.0, [   # Dark blue C-ring (has honey)
					_k(-135, 60, 148.0),   # Purple curved section
				]),
			]),
			_k(45, 64, 140.0, [    # Orange C-ring right
				_k(90, 58, 155.0),     # Light cyan curved section
			]),
		]),
		_k(135, 0, 0.0, [       # Purple L-bar bottom-right
			_k(180, 66, 132.0, [   # Light cyan C-ring
				_k(-135, 60, 148.0, [  # Green full ring
					_k(-90, 58, 142.0, [   # Orange C-ring
						_k(-45, 62, 158.0),    # Dark blue curved section
					]),
				]),
			]),
		]),
		_k(-180, 0, 0.0, [      # Orange bar bottom-left
			_k(-135, 0, 0.0, [     # Green bar
				_k(-90, 56, 135.0, [   # Green C-ring
					_k(-45, 0, 0.0),       # Red bar with lock
				]),
			]),
		]),
	])

static func level_28() -> Dictionary:
	# Structure: Dense overlapping rings creating complex puzzle
	# Top: dark blue C-ring (has honey), green C-ring
	# Upper-middle: green full ring, red full ring, light cyan C-ring (has honey)
	# Center: purple C-ring, light cyan curved section with bar lock
	# Lower-middle: light cyan C-ring, green C-ring, orange full ring
	# Bottom: red full ring, purple C-ring, orange C-ring with red bar, light cyan bar lock
	# Multiple honey markers: dark blue, light cyan, green rings
	return _open_root(66, 90.0, [
		_k(-150, 58, 130.0, [   # Dark blue C-ring top (has honey)
			_k(-90, 60, 145.0, [   # Green C-ring
				_k(-30, 56, 138.0),    # Light cyan C-ring
			]),
		]),
		_k(-120, 64, 132.0, [   # Green full ring left
			_k(-60, 62, 148.0, [   # Red full ring
				_k(0, 58, 140.0, [     # Light cyan C-ring (has honey)
					_k(60, 60, 155.0),     # Purple curved section
				]),
			]),
		]),
		_k(30, 66, 135.0, [     # Purple C-ring right
			_k(90, 58, 150.0, [    # Orange C-ring
				_k(150, 0, 0.0),       # Light cyan bar lock
			]),
		]),
		_k(0, 68, 90.0, [       # Light cyan curved section center
			_k(45, 62, 145.0, [    # Green C-ring (has honey)
				_k(90, 56, 158.0, [    # Light cyan C-ring
					_k(135, 60, 148.0),    # Orange C-ring
				]),
			]),
		]),
		_k(180, 64, 132.0, [    # Red full ring bottom-left
			_k(-135, 58, 148.0, [  # Purple C-ring
				_k(-90, 60, 142.0, [   # Orange full ring
					_k(-45, 56, 155.0, [   # Light cyan C-ring
						_k(0, 0, 0.0, [        # Red bar
							_k(45, 0, 0.0),        # Light cyan bar lock
						]),
					]),
				]),
			]),
		]),
	])

static func level_29() -> Dictionary:
	# Structure: Complex web of bars and rings
	# Top: light cyan C-ring, purple bar with lock, green bar
	# Upper section: purple curved section, light cyan C-ring, green C-ring (has honey)
	# Middle: dark blue C-ring, light cyan full ring, orange curved section with green bar lock
	# Center-right: purple U-shape bar, orange C-ring, light cyan bar, green-red connector
	# Lower-left: green curved section with lock, light cyan bar
	# Bottom: orange full ring (has honey), dark blue full ring, purple full ring (has honey)
	# Red C-ring, orange bar, green C-ring bottom-right
	return _open_root(0, 0.0, [  # No central root, complex bar structure
		# Top section
		_k(-180, 0, 0.0, [      # Green bar far-left
			_k(-150, 0, 0.0, [     # Purple bar with lock
				_k(-120, 0, 0.0),      # Light cyan C-ring
			]),
		]),
		_k(-90, 60, 125.0, [    # Purple curved section top
			_k(-30, 58, 142.0, [   # Light cyan C-ring
				_k(30, 56, 135.0),     # Green C-ring (has honey)
			]),
		]),
		_k(0, 0, 0.0, [         # Green bar top-right
			_k(30, 0, 0.0, [       # Dark blue bar
				_k(60, 0, 0.0),        # (Lock point)
			]),
		]),
		# Middle section
		_k(-120, 64, 130.0, [   # Dark blue C-ring left
			_k(-60, 62, 148.0, [   # Light cyan full ring
				_k(0, 58, 140.0, [     # Orange curved section
					_k(60, 0, 0.0),        # Green bar lock
				]),
			]),
		]),
		_k(90, 0, 0.0, [        # Purple U-shape bar right
			_k(120, 60, 145.0, [   # Orange C-ring
				_k(150, 0, 0.0, [      # Light cyan bar
					_k(180, 0, 0.0),       # Green-red connector
				]),
			]),
		]),
		# Bottom section
		_k(-180, 0, 0.0, [      # Green curved section bottom-left (lock)
			_k(-150, 0, 0.0, [     # Light cyan bar
				_k(-120, 56, 132.0, [  # Orange full ring (has honey)
					_k(-90, 58, 148.0, [   # Dark blue full ring
						_k(-60, 60, 142.0, [   # Purple full ring (has honey)
							_k(-30, 62, 155.0),    # Red C-ring
						]),
					]),
				]),
			]),
		]),
		_k(135, 0, 0.0, [       # Orange bar bottom-right
			_k(180, 64, 138.0),    # Green C-ring
		]),
	])

static func level_30() -> Dictionary:
	# Structure: Symmetric diamond/gem shape made entirely of bars
	# Top apex: red bar, dark blue bar, green bar
	# Upper layer: purple bar left, light cyan bar center, green bar right
	# Middle layer (widest): orange bar left, green bar, light cyan bar, purple bar, orange bar, dark blue bar right
	# Lower layer: red bar left, purple bar, green bar right
	# Bottom apex converging bars
	# All elements are lock bars, no circular rings
	# Forms geometric pattern resembling a cut gemstone
	return _open_root(0, 0.0, [  # No rings, pure bar structure
		# Top apex
		_k(-180, 0, 0.0, [      # Green bar top-left
			_k(-150, 0, 0.0, [     # Red bar apex
				_k(-120, 0, 0.0),      # Dark blue bar top-right
			]),
		]),
		# Upper layer
		_k(-165, 0, 0.0, [      # Purple bar left
			_k(-135, 0, 0.0, [     # Light cyan bar center
				_k(-105, 0, 0.0),      # Green bar right
			]),
		]),
		# Middle wide layer
		_k(-150, 0, 0.0, [      # Orange bar far-left
			_k(-120, 0, 0.0, [     # Green bar
				_k(-90, 0, 0.0, [      # Light cyan bar center
					_k(-60, 0, 0.0, [      # Purple bar
						_k(-30, 0, 0.0, [      # Orange bar
							_k(0, 0, 0.0),         # Dark blue bar far-right
						]),
					]),
				]),
			]),
		]),
		# Lower layer
		_k(-165, 0, 0.0, [      # Red bar bottom-left
			_k(-135, 0, 0.0, [     # Purple bar
				_k(-105, 0, 0.0),      # Green bar bottom-right
			]),
		]),
		# Bottom apex
		_k(-180, 0, 0.0, [      # Light cyan bar
			_k(-150, 0, 0.0),      # Green bar bottom apex
		]),
	])

# Helper to get level by number
static func get_level(level_id: int) -> Dictionary:
	match level_id:
		11: return level_11()
		12: return level_12()
		13: return level_13()
		14: return level_14()
		15: return level_15()
		16: return level_16()
		17: return level_17()
		18: return level_18()
		19: return level_19()
		20: return level_20()
		21: return level_21()
		22: return level_22()
		23: return level_23()
		24: return level_24()
		25: return level_25()
		26: return level_26()
		27: return level_27()
		28: return level_28()
		29: return level_29()
		30: return level_30()
		_: return {}
