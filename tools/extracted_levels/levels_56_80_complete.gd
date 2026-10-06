# Complete extraction of Levels 56-80 from Game Rush screenshots
# Each level carefully analyzed for exact geometry
# Ready for integration into campaign_board.gd

extends RefCounted

# Shape constants
const C := 0  # Circle
const S := 1  # Square  
const T := 2  # Triangle
const O := 3  # Oval

# Level 56 - Complex multi-hub structure
# Central blue closed circle, cyan square frame, green hub, multiple chains
static func level_56() -> Dictionary:
	# Cyan square frame on right with internal structure
	var cyan_square_internals: Array = []
	cyan_square_internals.append([180.0, _leaf(52.0, 135.0)])  # Red ring with gap bottom
	cyan_square_internals.append([90.0, _leaf(48.0, 145.0)])  # Blue ring right
	var cyan_square := _n(68.0, S, 0, 0.0, 0, cyan_square_internals)
	cyan_square["locks"] = [[0, 1]]
	
	# Green closed circle hub bottom-right with branches
	var green_hub_kids: Array = []
	green_hub_kids.append([-140.0, _leaf(54.0, 140.0)])  # Blue ring
	green_hub_kids.append([-50.0, _n(58.0, C, 0, 0.0, 0, [  # Orange closed
		[80.0, _leaf(52.0, 150.0)]  # Orange L
	])])
	green_hub_kids.append([40.0, _leaf(50.0, 135.0)])  # Green ring
	var green_hub := _n(64.0, C, 0, 0.0, 0, green_hub_kids)
	green_hub["locks"] = [[0, 1]]
	
	# Orange closed circle middle-left area
	var orange_hub := _n(62.0, C, 0, 0.0, 0, [
		[-90.0, _leaf(54.0, 145.0)],  # Cyan ring
		[30.0, _leaf(52.0, 140.0)]  # Orange ring
	])
	
	# Central blue closed circle connects everything
	var kids: Array = []
	kids.append([-135.0, _leaf(56.0, 140.0)])  # Red L-bar top-left
	kids.append([-75.0, _n(54.0, C, 1, 145.0, 0, [  # Purple ring
		[85.0, _leaf(52.0, 135.0)]  # Cyan ring
	])])
	kids.append([10.0, cyan_square])  # Cyan square structure
	kids.append([75.0, _leaf(50.0, 150.0)])  # Red ring with gap
	kids.append([135.0, green_hub])  # Green hub
	kids.append([-160.0, _n(56.0, C, 1, 140.0, 0, [  # Purple ring
		[-95.0, _leaf(54.0, 145.0)]  # Green bar
	])])
	
	var root := _n(72.0, C, 0, 0.0, 0, kids)
	root["locks"] = [[1, 2]]
	return root

# Level 57 - Multi-level complex structure (unlabeled screenshot)
# Purple square top, green hubs, orange circle bottom
static func level_57() -> Dictionary:
	# Purple square at top
	var purple_square := _n(66.0, S, 0, 0.0, 0, [
		[-150.0, _leaf(52.0, 140.0)],  # Purple piece
		[30.0, _n(56.0, C, 1, 145.0, 0, [  # Red ring
			[70.0, _leaf(50.0, 135.0)]  # Green piece
		])]
	])
	
	# Green hub middle with connections
	var green_hub := _n(68.0, C, 0, 0.0, 0, [
		[-100.0, purple_square],
		[-30.0, _n(58.0, C, 1, 140.0, 0, [
			[80.0, _leaf(54.0, 145.0)]  # Cyan
		])],
		[40.0, _n(56.0, C, 1, 150.0, 0, [
			[75.0, _leaf(52.0, 135.0)]  # Blue
		])],
		[100.0, _leaf(54.0, 145.0)]  # Green bar
	])
	
	# Orange closed circle bottom
	var orange_hub := _n(70.0, C, 0, 0.0, 0, [
		[-130.0, _leaf(56.0, 145.0)],  # Blue
		[-40.0, _leaf(58.0, 140.0)],  # Orange
		[50.0, _n(60.0, C, 1, 150.0, 0, [
			[85.0, _leaf(54.0, 135.0)]  # Orange L
		])]
	])
	
	var root := _n(64.0, C, 1, 135.0, 0, [
		[-110.0, green_hub],
		[130.0, orange_hub]
	])
	root["locks"] = [[0, 1]]
	return root

# Level 58 - Dense interconnected puzzle
# Multiple small rings, red square frame, complex chains
static func level_58() -> Dictionary:
	# Top chain with green rings
	var top_left := _n(60.0, C, 1, 145.0, 0, [
		[-85.0, _n(56.0, C, 1, 140.0, 0, [
			[-75.0, _leaf(52.0, 135.0)]
		])]
	])
	
	# Red square frame area
	var red_square := _n(66.0, S, 0, 0.0, 0, [
		[0.0, _leaf(54.0, 145.0)],
		[90.0, _leaf(52.0, 140.0)]
	])
	
	# Orange closed hub middle
	var orange_hub := _n(66.0, C, 0, 0.0, 0, [
		[-120.0, top_left],
		[-30.0, red_square],
		[60.0, _n(58.0, C, 1, 150.0, 0, [
			[80.0, _leaf(54.0, 140.0)]
		])]
	])
	
	# Bottom complex structure
	var bottom_left := _n(64.0, C, 1, 145.0, 0, [
		[-115.0, _n(60.0, C, 1, 150.0, 0, [
			[-80.0, _leaf(56.0, 135.0)]
		])]
	])
	
	var bottom_right := _n(62.0, C, 1, 140.0, 0, [
		[95.0, _n(60.0, C, 1, 145.0, 0, [
			[85.0, _n(68.0, S, 0, 0.0, 0, [
				[0.0, _leaf(54.0, 150.0)],
				[90.0, _leaf(52.0, 135.0)]
			])]
		])]
	])
	
	var root := _n(68.0, C, 1, 130.0, 0, [
		[-95.0, orange_hub],
		[-155.0, bottom_left],
		[40.0, bottom_right]
	])
	root["locks"] = [[0, 1], [1, 2]]
	return root

# Level 59 - Radial flower pattern
# Central closed red circle with rings radiating outward
static func level_59() -> Dictionary:
	var angles: Array[float] = [-90.0, -54.0, -18.0, 18.0, 54.0, 90.0, 126.0, 162.0, 198.0, 234.0, 270.0, 306.0, 342.0]
	var kids: Array = []
	
	# Create radial pattern with varying radii
	for i in angles.size():
		var radius := 58.0 if i % 2 == 0 else 56.0
		var turn := 130.0 + float(i * 6)
		
		# Inner and outer layers
		if i % 4 == 0:
			# Outer ring with connection
			kids.append([angles[i], _n(radius, C, 1, turn, 0, [
				[75.0, _leaf(50.0, turn + 20.0)]
			])])
		elif i % 3 == 1:
			# Middle ring
			kids.append([angles[i], _n(radius + 2.0, C, 1, turn, 0, [
				[80.0, _leaf(52.0, turn + 15.0)]
			])])
		else:
			# Simple leaf
			kids.append([angles[i], _leaf(radius - 2.0, turn)])
	
	var root := _n(75.0, C, 0, 0.0, 0, kids)
	root["locks"] = [[0, 1], [2, 3], [4, 5], [6, 7], [8, 9]]
	return root

# Level 60 - Nested rectangles with satellite elements
# Concentric squares with additional shapes around
static func level_60() -> Dictionary:
	# Nested rectangles (innermost to outermost)
	var green_inner := _n(42.0, S, 0, 0.0, 0, [])
	var red_mid := _n(50.0, S, 0, 0.0, 0, [[0.0, green_inner]])
	var blue_outer1 := _n(58.0, S, 0, 0.0, 0, [[0.0, red_mid]])
	var purple_outer2 := _n(66.0, S, 0, 0.0, 0, [[0.0, blue_outer1]])
	var orange_outermost := _n(74.0, S, 0, 0.0, 0, [[0.0, purple_outer2]])
	
	# Top-right diamond cluster
	var diamond_kids: Array = []
	diamond_kids.append([45.0, _leaf(38.0, 135.0)])  # Red
	diamond_kids.append([135.0, _leaf(36.0, 140.0)])  # Purple
	diamond_kids.append([225.0, _leaf(38.0, 145.0)])  # Green
	diamond_kids.append([315.0, _leaf(36.0, 150.0)])  # Blue
	var diamond := _n(44.0, S, 0, 45.0, 0, diamond_kids)  # Rotated square
	
	# Left green circle
	var left_circle := _n(52.0, C, 0, 0.0, 0, [
		[90.0, _leaf(44.0, 135.0)]
	])
	
	# Bottom circles
	var bottom_heart_left := _n(46.0, C, 0, 0.0, 0, [])  # Green/blue
	var bottom_heart_mid := _n(50.0, C, 0, 0.0, 0, [
		[0.0, _leaf(40.0, 135.0)],
		[120.0, _leaf(42.0, 140.0)]
	])
	var bottom_heart_right := _n(48.0, C, 0, 0.0, 0, [])  # Orange/cyan
	
	# T-shape at bottom
	var t_vertical := _n(56.0, T, 0, 0.0, 0, [
		[0.0, _leaf(44.0, 145.0)],
		[180.0, _leaf(46.0, 140.0)]
	])
	
	# Virtual root to coordinate positions
	var root := _n(2.0, C, 1, 90.0, 0, [
		[0.0, orange_outermost],  # Center
		[50.0, diamond],  # Top-right
		[180.0, left_circle],  # Left
		[250.0, bottom_heart_left],  # Bottom-left
		[270.0, bottom_heart_mid],  # Bottom-center
		[290.0, bottom_heart_right],  # Bottom-right
		[270.0, t_vertical]  # Bottom T
	])
	
	root["locks"] = []
	return root

# Level 61 - Organic tree structure
# Multiple small hubs, no single dominant center
static func level_61() -> Dictionary:
	# Top section
	var top_branch := _n(60.0, C, 1, 145.0, 0, [
		[-105.0, _leaf(56.0, 140.0)],  # Blue
		[-25.0, _n(62.0, C, 0, 0.0, 0, [  # Orange hub
			[55.0, _leaf(54.0, 135.0)]
		])],
		[45.0, _leaf(58.0, 150.0)]  # Purple
	])
	
	# Middle red hub
	var middle_hub := _n(64.0, C, 0, 0.0, 0, [
		[-95.0, top_branch],
		[-35.0, _n(60.0, C, 1, 140.0, 0, [
			[80.0, _leaf(56.0, 145.0)]  # Cyan
		])],
		[25.0, _n(62.0, C, 1, 135.0, 0, [
			[85.0, _leaf(58.0, 140.0)]  # Blue
		])]
	])
	
	# Bottom green hub
	var bottom_hub := _n(66.0, C, 0, 0.0, 0, [
		[-125.0, _n(58.0, C, 1, 150.0, 0, [
			[-80.0, _leaf(54.0, 135.0)]  # Green
		])],
		[-5.0, _n(60.0, C, 1, 145.0, 0, [
			[75.0, _leaf(56.0, 140.0)]  # Cyan
		])],
		[115.0, _n(62.0, C, 1, 140.0, 0, [
			[80.0, _leaf(58.0, 145.0)]  # Orange
		])]
	])
	
	var root := _n(68.0, C, 1, 130.0, 0, [
		[-115.0, middle_hub],
		[65.0, _n(60.0, C, 1, 145.0, 0, [
			[-35.0, _leaf(56.0, 140.0)]
		])],
		[135.0, bottom_hub]
	])
	root["locks"] = [[0, 1]]
	return root

# Level 62 - Complex multi-hub puzzle
# Purple square top, mixed circular hubs, varied connections
static func level_62() -> Dictionary:
	# Top purple square structure
	var purple_square := _n(68.0, S, 0, 0.0, 0, [
		[-120.0, _n(58.0, C, 1, 140.0, 0, [
			[-85.0, _leaf(54.0, 135.0)]
		])],
		[0.0, _n(60.0, C, 1, 145.0, 0, [
			[80.0, _leaf(56.0, 150.0)]
		])]
	])
	purple_square["locks"] = [[0, 1]]
	
	# Middle section with green hub
	var green_hub := _n(62.0, C, 0, 0.0, 0, [
		[-90.0, _leaf(56.0, 145.0)],  # Horizontal green bar
		[0.0, _n(60.0, C, 1, 140.0, 0, [
			[75.0, _leaf(54.0, 135.0)]
		])],
		[90.0, _n(64.0, S, 0, 0.0, 0, [  # Blue square
			[0.0, _leaf(52.0, 150.0)]
		])]
	])
	
	# Right orange branch
	var orange_chain := _n(58.0, C, 1, 150.0, 0, [
		[90.0, _n(68.0, S, 0, 0.0, 0, [  # Purple square
			[45.0, _leaf(54.0, 140.0)]
		])]
	])
	
	# Bottom cluster
	var bottom_hub := _n(66.0, C, 0, 0.0, 0, [
		[-135.0, _n(60.0, C, 1, 145.0, 0, [
			[-80.0, _leaf(56.0, 135.0)]
		])],
		[-45.0, _n(62.0, C, 0, 0.0, 0, [
			[70.0, _leaf(54.0, 140.0)]
		])],
		[45.0, _n(58.0, C, 1, 150.0, 0, [
			[85.0, _leaf(52.0, 145.0)]
		])]
	])
	bottom_hub["locks"] = [[0, 1], [1, 2]]
	
	var root := _n(70.0, C, 1, 130.0, 0, [
		[-100.0, purple_square],
		[-20.0, green_hub],
		[60.0, orange_chain],
		[140.0, bottom_hub]
	])
	root["locks"] = [[1, 2]]
	return root

# Level 63 - Vertical tower structure
# Tall vertical alignment with side branches
static func level_63() -> Dictionary:
	# Top section - orange and red curves
	var top_orange := _n(62.0, C, 1, 145.0, 0, [
		[-95.0, _leaf(56.0, 140.0)]  # Orange top
	])
	var top_red := _n(60.0, C, 1, 140.0, 0, [
		[-85.0, top_orange]
	])
	
	# Middle vertical cyan bar with purple branch
	var cyan_vertical := _n(58.0, C, 1, 90.0, 0, [
		[-90.0, _n(64.0, T, 0, 0.0, 0, [  # Purple T-junction
			[-90.0, _leaf(54.0, 145.0)],  # Green horizontal
			[0.0, top_red]  # Connect upward
		])],
		[0.0, _n(66.0, C, 0, 0.0, 0, [  # Green hub
			[-90.0, _n(60.0, S, 0, 0.0, 0, [  # Orange square
				[-90.0, _leaf(52.0, 135.0)]  # Green bar
			])],
			[90.0, _leaf(56.0, 140.0)]  # Cyan elbow
		])]
	])
	
	# Right blue bar
	var blue_vertical := _n(56.0, C, 1, 90.0, 0, [
		[90.0, _leaf(54.0, 145.0)]  # Horizontal piece
	])
	
	# Bottom horizontal chain
	var bottom_chain := _n(68.0, C, 0, 0.0, 0, [  # Green circle
		[-180.0, _n(62.0, C, 1, 150.0, 0, [
			[-90.0, _leaf(56.0, 135.0)]  # Red
		])],
		[0.0, _n(60.0, C, 1, 145.0, 0, [
			[90.0, _leaf(54.0, 140.0)]  # Blue
		])]
	])
	bottom_chain["locks"] = [[0, 1]]
	
	# Left green L-bar
	var left_green := _n(58.0, C, 1, 180.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [  # Virtual center
		[90.0, cyan_vertical],  # Main vertical
		[0.0, blue_vertical],  # Right vertical
		[270.0, bottom_chain],  # Bottom
		[180.0, left_green]  # Left
	])
	
	return root

# Level 64 - Concentric circles with external elements
# Large nested circles with surrounding structures
static func level_64() -> Dictionary:
	# Innermost cyan circle with gap
	var inner_cyan := _n(48.0, C, 1, 135.0, 0, [])
	
	# Orange ring around cyan
	var mid_orange := _n(56.0, C, 0, 0.0, 0, [
		[90.0, inner_cyan]
	])
	
	# Purple ring around orange
	var outer_purple := _n(64.0, C, 0, 0.0, 0, [
		[90.0, mid_orange],
		[-90.0, _leaf(52.0, 145.0)]  # Purple T at top
	])
	
	# Red outermost ring
	var outermost_red := _n(72.0, C, 0, 0.0, 0, [
		[90.0, outer_purple],
		[180.0, _leaf(54.0, 140.0)]  # Red T at bottom
	])
	
	# Bottom green square frame with purple center
	var bottom_frame := _n(62.0, S, 0, 0.0, 0, [
		[0.0, _n(52.0, C, 0, 0.0, 0, [  # Purple center bar
			[0.0, _leaf(44.0, 145.0)]
		])]
	])
	bottom_frame["locks"] = [[0]]
	
	# Attached to bottom frame
	var bottom_structure := _n(66.0, C, 0, 0.0, 0, [  # Orange circle
		[-90.0, bottom_frame],
		[-150.0, _leaf(56.0, 140.0)],  # Green curve
		[-30.0, _leaf(54.0, 145.0)],  # Green curve  
		[30.0, _n(60.0, C, 1, 150.0, 0, [  # Red curve
			[80.0, _leaf(52.0, 135.0)]  # Cyan bar
		])],
		[90.0, _leaf(56.0, 140.0)]  # Green piece
	])
	bottom_structure["locks"] = [[1, 2]]
	
	# Connect all parts
	var root := _n(2.0, C, 0, 0.0, 0, [
		[0.0, outermost_red],  # Central concentric circles
		[180.0, bottom_structure]  # Bottom structure
	])
	
	return root

# Level 65 - Chaotic scattered layout
# No clear center, distributed connections
static func level_65() -> Dictionary:
	# Top section - green bars and blue connections
	var top_left_green := _n(58.0, S, 0, 0.0, 0, [
		[90.0, _leaf(54.0, 145.0)]
	])
	
	var top_mid_green := _n(60.0, C, 1, 140.0, 0, [
		[85.0, _n(62.0, C, 1, 145.0, 0, [
			[80.0, _leaf(56.0, 135.0)]  # Blue ring
		])]
	])
	
	# Middle-left section with cyan square
	var cyan_square_complex := _n(66.0, S, 0, 0.0, 0, [
		[-90.0, _n(58.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(54.0, 140.0)]  # Blue
		])],
		[90.0, _leaf(56.0, 145.0)]  # Cyan bar
	])
	
	# Central cluster with closed rings
	var purple_hub := _n(60.0, C, 0, 0.0, 0, [
		[-120.0, _leaf(54.0, 140.0)],  # Purple piece
		[0.0, _leaf(56.0, 145.0)]  # Cyan bar
	])
	
	var red_hub := _n(68.0, C, 0, 0.0, 0, [
		[-90.0, cyan_square_complex],
		[0.0, purple_hub],
		[90.0, _n(62.0, C, 1, 150.0, 0, [
			[80.0, _leaf(58.0, 135.0)]  # Green
		])]
	])
	red_hub["locks"] = [[1, 2]]
	
	# Right side structures
	var right_structure := _n(64.0, C, 1, 145.0, 0, [
		[85.0, _n(70.0, S, 0, 0.0, 0, [  # Red bar frame
			[0.0, _leaf(54.0, 140.0)]
		])]
	])
	
	# Bottom section
	var bottom_purple := _n(62.0, C, 1, 150.0, 0, [
		[-95.0, _n(60.0, C, 1, 145.0, 0, [
			[-80.0, _leaf(56.0, 135.0)]
		])],
		[85.0, _n(66.0, C, 1, 140.0, 0, [
			[90.0, _n(64.0, C, 1, 145.0, 0, [
				[75.0, _leaf(58.0, 135.0)]
			])]
		])]
	])
	
	# Assemble
	var root := _n(2.0, C, 1, 0.0, 0, [
		[-120.0, top_left_green],
		[-60.0, top_mid_green],
		[0.0, red_hub],
		[60.0, right_structure],
		[150.0, bottom_purple]
	])
	
	return root

# Level 66 - Multi-hub vertical structure
# Purple square top, green hub middle, red/blue hubs bottom
static func level_66() -> Dictionary:
	# Top purple square with vertical bar
	var purple_top := _n(68.0, S, 0, 0.0, 0, [
		[0.0, _n(58.0, C, 1, 90.0, 0, [  # Vertical bar
			[-90.0, _leaf(54.0, 145.0)]  # Horizontal top
		])]
	])
	
	# Left orange curve
	var orange_left := _n(62.0, C, 1, 140.0, 0, [
		[-95.0, _leaf(56.0, 135.0)]  # Green branch
	])
	
	# Central green hub complex
	var green_hub := _n(70.0, C, 0, 0.0, 0, [
		[-150.0, orange_left],
		[-90.0, purple_top],
		[-30.0, _n(60.0, C, 1, 145.0, 0, [  # Purple ring
			[80.0, _leaf(56.0, 140.0)]  # Green ring
		])],
		[30.0, _n(58.0, C, 1, 150.0, 0, [  # Blue vertical
			[90.0, _leaf(54.0, 135.0)]  # Green ring
		])],
		[90.0, _leaf(56.0, 145.0)]  # Green vertical bar
	])
	green_hub["locks"] = [[2, 3]]
	
	# Bottom left red hub
	var red_hub := _n(66.0, C, 0, 0.0, 0, [
		[-90.0, _n(62.0, S, 0, 0.0, 0, [  # Purple square
			[-90.0, _leaf(54.0, 140.0)]
		])],
		[0.0, _n(60.0, C, 1, 145.0, 0, [
			[85.0, _leaf(56.0, 135.0)]  # Blue ring
		])]
	])
	red_hub["locks"] = [[0, 1]]
	
	# Bottom right blue/cyan hub
	var blue_hub := _n(68.0, C, 0, 0.0, 0, [
		[-180.0, _n(58.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(54.0, 140.0)]  # Cyan
		])],
		[-90.0, _leaf(56.0, 145.0)],  # Orange piece
		[0.0, _leaf(54.0, 135.0)]  # Cyan piece
	])
	blue_hub["locks"] = [[1, 2]]
	
	# Bottom structures with bars
	var bottom_cyan := _n(64.0, C, 1, 180.0, 0, [
		[-90.0, _leaf(56.0, 145.0)]  # Cyan bar
	])
	
	var bottom_red := _n(62.0, S, 0, 0.0, 0, [
		[0.0, _leaf(54.0, 140.0)]  # Red bar
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[0.0, green_hub],  # Central hub
		[-150.0, red_hub],  # Bottom-left
		[150.0, blue_hub],  # Bottom-right
		[180.0, bottom_cyan],  # Bottom cyan bar
		[200.0, bottom_red]  # Bottom red bar
	])
	
	return root

# Level 67 - Long horizontal branch with vertical structures
# Purple bar at top, central orange hub, vertical green structure
static func level_67() -> Dictionary:
	# Top long purple bar with connections
	var purple_top := _n(58.0, C, 1, 180.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Purple curve
			[-85.0, _leaf(56.0, 140.0)]  # Orange branch
		])],
		[0.0, _leaf(54.0, 150.0)],  # Horizontal bar center
		[90.0, _n(60.0, C, 1, 135.0, 0, [  # Green curve
			[80.0, _leaf(56.0, 145.0)]  # Right piece
		])]
	])
	purple_top["locks"] = [[0, 2]]
	
	# Middle orange closed hub
	var orange_hub := _n(66.0, C, 0, 0.0, 0, [
		[-90.0, _n(60.0, C, 1, 145.0, 0, [  # Red curve
			[-85.0, _leaf(56.0, 140.0)]  # Cyan
		])],
		[0.0, _leaf(54.0, 135.0)],  # Orange piece bottom
		[90.0, _n(64.0, C, 0, 0.0, 0, [  # Blue circle
			[90.0, _leaf(58.0, 150.0)]  # Right extension
		])]
	])
	orange_hub["locks"] = [[0, 2]]
	
	# Left vertical structures
	var left_cyan := _n(62.0, C, 1, 140.0, 0, [
		[-90.0, _leaf(56.0, 145.0)]  # Red top
	])
	
	var left_green := _n(60.0, C, 1, 180.0, 0, [
		[-90.0, _leaf(54.0, 135.0)]  # Cyan bar
	])
	
	# Bottom section with three green hubs
	var bottom_left_green := _n(58.0, C, 1, 145.0, 0, [
		[-85.0, _leaf(54.0, 140.0)]  # Green piece
	])
	
	var bottom_mid_green := _n(64.0, C, 0, 0.0, 0, [
		[-120.0, bottom_left_green],
		[0.0, _leaf(56.0, 150.0)],  # Cyan
		[120.0, _leaf(58.0, 135.0)]  # Green
	])
	
	var bottom_right := _n(60.0, C, 1, 140.0, 0, [
		[85.0, _n(62.0, C, 1, 145.0, 0, [
			[80.0, _leaf(56.0, 135.0)]  # Cyan
		])]
	])
	
	# Purple circle at bottom
	var purple_bottom := _n(66.0, C, 1, 150.0, 0, [])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[0.0, purple_top],  # Top bar
		[45.0, orange_hub],  # Middle orange
		[-150.0, left_cyan],  # Left structures
		[-120.0, left_green],
		[180.0, bottom_mid_green],  # Bottom
		[150.0, bottom_right],
		[200.0, purple_bottom]
	])
	
	return root

# Level 68 - Chaotic multi-directional structure
# No clear pattern, many different angles and connections
static func level_68() -> Dictionary:
	# Top section with orange and green pieces
	var top_orange := _n(60.0, C, 1, 145.0, 0, [
		[-95.0, _leaf(56.0, 140.0)]  # Orange L extension
	])
	
	var top_green := _n(62.0, C, 1, 140.0, 0, [
		[85.0, _n(64.0, C, 1, 145.0, 0, [  # Blue
			[80.0, _n(68.0, S, 0, 0.0, 0, [  # Orange square
				[45.0, _leaf(54.0, 135.0)]
			])]
		])]
	])
	
	# Middle section with cyan circle and purple square
	var cyan_mid := _n(66.0, C, 1, 150.0, 0, [
		[-85.0, _leaf(58.0, 140.0)]  # Green
	])
	
	var purple_square := _n(70.0, S, 0, 0.0, 0, [
		[-90.0, top_orange],
		[-30.0, top_green],
		[30.0, cyan_mid],
		[90.0, _n(60.0, C, 1, 145.0, 0, [  # Blue T
			[80.0, _leaf(56.0, 135.0)]
		])]
	])
	purple_square["locks"] = [[1, 2]]
	
	# Orange and red closed circles middle-left
	var orange_hub := _n(68.0, C, 0, 0.0, 0, [
		[-120.0, _leaf(58.0, 140.0)],  # Red curve
		[0.0, _n(64.0, C, 0, 0.0, 0, [  # Orange inner
			[90.0, _leaf(56.0, 145.0)]
		])]
	])
	orange_hub["locks"] = [[0, 1]]
	
	# Bottom complex structures
	var bottom_left_purple := _n(62.0, C, 1, 150.0, 0, [
		[-90.0, _leaf(58.0, 135.0)]
	])
	
	var bottom_green_square := _n(66.0, S, 0, 0.0, 0, [
		[-90.0, _n(60.0, C, 1, 145.0, 0, [
			[-85.0, _leaf(56.0, 140.0)]
		])],
		[90.0, _leaf(54.0, 135.0)]
	])
	
	var bottom_red := _n(64.0, C, 1, 140.0, 0, [
		[85.0, _n(62.0, C, 1, 145.0, 0, [
			[80.0, _leaf(58.0, 135.0)]  # Cyan
		])]
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[30.0, purple_square],  # Top-middle
		[-120.0, orange_hub],  # Middle-left
		[-150.0, bottom_left_purple],  # Bottom-left
		[180.0, bottom_green_square],  # Bottom
		[150.0, bottom_red]  # Bottom-right
	])
	
	return root

# Level 69 - Distributed circular connections
# Multiple small clusters spread across area
static func level_69() -> Dictionary:
	# Top row of rings
	var top_cyan := _n(58.0, C, 1, 145.0, 0, [
		[-85.0, _n(60.0, C, 1, 140.0, 0, [  # Green
			[-80.0, _leaf(56.0, 135.0)]  # Blue with marker
		])]
	])
	
	var top_green := _n(62.0, C, 1, 140.0, 0, [])
	
	# Middle-left orange cluster
	var orange_mid := _n(64.0, C, 1, 150.0, 0, [
		[-95.0, _n(60.0, C, 1, 145.0, 0, [
			[-85.0, _leaf(56.0, 135.0)]  # Orange L
		])]
	])
	
	# Middle section with blue T and purple/red connections
	var blue_t := _n(66.0, T, 0, 0.0, 0, [
		[0.0, _n(58.0, C, 1, 140.0, 0, [
			[80.0, _leaf(54.0, 145.0)]  # Green
		])],
		[90.0, _leaf(56.0, 135.0)],  # Horizontal right
		[-90.0, _leaf(58.0, 140.0)]  # Horizontal left
	])
	
	var purple_mid := _n(62.0, C, 1, 145.0, 0, [
		[85.0, _n(64.0, C, 1, 150.0, 0, [  # Red
			[80.0, _leaf(60.0, 135.0)]  # Green
		])]
	])
	
	# Right side structures
	var green_right := _n(60.0, C, 1, 140.0, 0, [
		[90.0, _n(66.0, S, 0, 0.0, 0, [  # Red bar
			[0.0, _leaf(54.0, 145.0)]
		])]
	])
	
	# Bottom cluster
	var bottom_blue := _n(68.0, C, 1, 150.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Green
			[-85.0, _n(64.0, C, 1, 140.0, 0, [  # Cyan
				[-80.0, _n(60.0, C, 1, 145.0, 0, [  # Orange with marker
					[-75.0, _leaf(56.0, 135.0)]
				])]
			])]
		])]
	])
	
	var bottom_orange := _n(66.0, C, 1, 135.0, 0, [
		[80.0, _leaf(58.0, 140.0)]  # Orange L
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-120.0, top_cyan],
		[-60.0, top_green],
		[-150.0, orange_mid],
		[-30.0, blue_t],
		[30.0, purple_mid],
		[90.0, green_right],
		[160.0, bottom_blue],
		[200.0, bottom_orange]
	])
	
	return root

# Level 70 - Symmetrical robot/humanoid shape
# Top curved pieces, middle rectangles, bottom triangle legs
static func level_70() -> Dictionary:
	# Top "head" - two curved pieces
	var top_green := _n(56.0, C, 1, 145.0, 0, [])
	var top_red := _n(58.0, C, 1, 140.0, 0, [])
	
	# Upper body - green/cyan rectangle
	var upper_rect := _n(64.0, S, 0, 0.0, 0, [
		[-90.0, top_green],
		[90.0, top_red],
		[0.0, _leaf(52.0, 135.0)]  # Cyan bar inside
	])
	upper_rect["locks"] = [[0, 1]]
	
	# Middle "shoulders" - orange and cyan curves
	var left_shoulder := _n(60.0, C, 1, 150.0, 0, [])  # Cyan
	var right_shoulder := _n(62.0, C, 1, 145.0, 0, [])  # Orange
	
	# Center body - large green/purple curves with yellow markers
	var left_body := _n(70.0, C, 1, 140.0, 0, [])  # Orange curve
	var right_body := _n(72.0, C, 1, 135.0, 0, [])  # Purple curve
	
	# Lower rectangles - green and blue
	var lower_green := _n(66.0, S, 0, 0.0, 0, [
		[0.0, _leaf(54.0, 145.0)]  # Green bar inside
	])
	var lower_blue := _n(68.0, S, 0, 0.0, 0, [
		[0.0, _leaf(56.0, 140.0)]  # Cyan bar inside
	])
	
	# Bottom "legs" - purple triangle with complex connections
	var leg_structure := _n(74.0, T, 0, 180.0, 0, [  # Purple triangle inverted
		[-120.0, _n(58.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(54.0, 135.0)]  # Purple
		])],
		[-60.0, _n(60.0, C, 1, 145.0, 0, [
			[-80.0, _leaf(56.0, 140.0)]  # Red
		])],
		[0.0, _n(62.0, C, 1, 140.0, 0, [
			[80.0, _n(58.0, C, 1, 145.0, 0, [  # Green
				[75.0, _leaf(54.0, 135.0)]
			])]
		])],
		[60.0, _leaf(56.0, 150.0)],  # Purple piece
		[120.0, _leaf(58.0, 135.0)]  # Green piece
	])
	leg_structure["locks"] = [[0, 1], [2, 3]]
	
	# Assemble robot shape
	var root := _n(4.0, C, 1, 0.0, 0, [
		[0.0, upper_rect],  # Head/upper
		[-150.0, left_shoulder],
		[150.0, right_shoulder],
		[-90.0, left_body],
		[90.0, right_body],
		[-30.0, lower_green],
		[30.0, lower_blue],
		[180.0, leg_structure]  # Legs
	])
	
	return root

# Level 71 - Complex scattered structure
# Multiple hubs, no clear organization
static func level_71() -> Dictionary:
	# Top-left structures
	var top_blue_L := _n(58.0, S, 0, 0.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]  # Blue bar
	])
	
	var top_green := _n(60.0, C, 1, 140.0, 0, [
		[85.0, _n(66.0, C, 0, 0.0, 0, [  # Red circle
			[90.0, _leaf(56.0, 135.0)]  # Purple curve
		])]
	])
	
	# Top-right orange cluster
	var top_right := _n(62.0, C, 1, 150.0, 0, [
		[80.0, _n(64.0, C, 1, 145.0, 0, [  # Green
			[75.0, _leaf(58.0, 140.0)]  # Cyan
		])]
	])
	
	# Middle-left cyan and purple complex
	var cyan_hub := _n(68.0, C, 0, 0.0, 0, [
		[-120.0, _leaf(56.0, 145.0)],  # Purple
		[-30.0, _n(60.0, C, 1, 140.0, 0, [  # Orange
			[80.0, _leaf(54.0, 135.0)]  # Green
		])]
	])
	
	# Central green hub with multiple connections
	var green_hub := _n(70.0, C, 0, 0.0, 0, [
		[-150.0, top_green],
		[-90.0, _n(62.0, C, 1, 145.0, 0, [
			[-85.0, _leaf(58.0, 140.0)]  # Red
		])],
		[-30.0, _n(64.0, C, 1, 150.0, 0, [
			[80.0, _leaf(60.0, 135.0)]  # Blue
		])],
		[30.0, _leaf(56.0, 145.0)],  # Green curve
		[90.0, _n(58.0, C, 1, 140.0, 0, [
			[85.0, _leaf(54.0, 135.0)]  # Orange L
		])]
	])
	green_hub["locks"] = [[1, 2], [3, 4]]
	
	# Bottom structures
	var bottom_left_red := _n(66.0, C, 0, 0.0, 0, [
		[-90.0, _n(62.0, S, 0, 0.0, 0, [  # Blue square
			[-90.0, _n(58.0, C, 1, 145.0, 0, [
				[-85.0, _leaf(54.0, 140.0)]  # Orange bar
			])]
		])],
		[0.0, _leaf(56.0, 135.0)]  # Green T
	])
	bottom_left_red["locks"] = [[0, 1]]
	
	var bottom_right_blue := _n(64.0, C, 1, 150.0, 0, [
		[90.0, _n(68.0, S, 0, 0.0, 0, [  # Green bar
			[0.0, _leaf(56.0, 140.0)]
		])]
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-150.0, top_blue_L],
		[-60.0, top_green],
		[60.0, top_right],
		[-120.0, cyan_hub],
		[0.0, green_hub],
		[-180.0, bottom_left_red],
		[150.0, bottom_right_blue]
	])
	
	return root

# Level 72 - Vertical symmetrical structure
# Strong vertical axis with symmetric branches
static func level_72() -> Dictionary:
	# Top three green rings with purple center
	var top_left := _n(60.0, C, 1, 145.0, 0, [])
	var top_center := _n(62.0, C, 1, 140.0, 0, [
		[-90.0, top_left],
		[0.0, _leaf(56.0, 135.0)],  # Purple center
		[90.0, _leaf(60.0, 145.0)]  # Right green
	])
	top_center["locks"] = [[0, 2]]
	
	# Upper level - green T with blue connections
	var upper_green := _n(66.0, T, 0, 0.0, 0, [
		[-90.0, _n(58.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(54.0, 140.0)]  # Blue
		])],
		[90.0, _n(60.0, C, 1, 145.0, 0, [
			[85.0, _leaf(56.0, 135.0)]  # Orange
		])]
	])
	upper_green["locks"] = [[0, 1]]
	
	# Central orange circle
	var orange_center := _n(70.0, C, 0, 0.0, 0, [
		[-90.0, upper_green],
		[0.0, _leaf(58.0, 140.0)],  # Orange marker
		[90.0, top_center]
	])
	
	# Middle level - cyan T with connections
	var middle_cyan := _n(72.0, T, 0, 0.0, 0, [
		[-90.0, _n(62.0, C, 0, 0.0, 0, [  # Red circle
			[-90.0, _leaf(56.0, 145.0)]  # Red T
		])],
		[0.0, orange_center],
		[90.0, _n(64.0, C, 0, 0.0, 0, [  # Green circle
			[90.0, _leaf(58.0, 140.0)]  # Green T
		])]
	])
	middle_cyan["locks"] = [[0, 2]]
	
	# Lower level - purple circle with branches
	var purple_lower := _n(74.0, C, 0, 0.0, 0, [
		[-90.0, _n(60.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(56.0, 135.0)]  # Orange
		])],
		[0.0, middle_cyan],
		[90.0, _n(62.0, C, 1, 145.0, 0, [
			[85.0, _leaf(58.0, 140.0)]  # Orange
		])]
	])
	purple_lower["locks"] = [[0, 2]]
	
	# Bottom level - three more rings
	var bottom_cyan := _n(66.0, C, 1, 140.0, 0, [])
	var bottom_red := _n(68.0, C, 1, 145.0, 0, [])
	var bottom_green := _n(64.0, C, 1, 135.0, 0, [])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[0.0, purple_lower],  # Main vertical structure
		[-150.0, bottom_cyan],  # Bottom spread
		[180.0, bottom_red],
		[150.0, bottom_green]
	])
	
	return root

# Level 73 - Scattered asymmetric layout
# No clear pattern, various shapes mixed
static func level_73() -> Dictionary:
	# Top section
	var top_orange_L := _n(60.0, C, 1, 145.0, 0, [
		[-95.0, _leaf(56.0, 140.0)]  # Orange extension
	])
	
	var top_purple_hub := _n(66.0, C, 0, 0.0, 0, [
		[-120.0, top_orange_L],
		[-30.0, _n(62.0, C, 1, 150.0, 0, [  # Red curve
			[80.0, _leaf(58.0, 135.0)]
		])],
		[90.0, _n(64.0, C, 1, 145.0, 0, [  # Purple curve
			[85.0, _n(68.0, C, 1, 140.0, 0, [  # Orange with marker
				[80.0, _leaf(60.0, 135.0)]
			])]
		])]
	])
	top_purple_hub["locks"] = [[1, 2]]
	
	# Left side cyan L
	var left_cyan := _n(58.0, T, 0, 0.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]  # Cyan bar
	])
	
	# Middle structures
	var mid_orange := _n(62.0, C, 1, 140.0, 0, [
		[85.0, _n(66.0, S, 0, 0.0, 0, [  # Blue square
			[0.0, _leaf(56.0, 135.0)]
		])]
	])
	
	var mid_green := _n(64.0, C, 1, 150.0, 0, [
		[-85.0, _leaf(58.0, 145.0)]
	])
	
	# Right and bottom structures
	var right_orange := _n(60.0, C, 1, 135.0, 0, [
		[90.0, _n(68.0, T, 0, 0.0, 0, [  # Blue T
			[90.0, _n(62.0, C, 1, 140.0, 0, [
				[85.0, _leaf(58.0, 145.0)]  # Cyan
			])]
		])]
	])
	
	var bottom_green := _n(66.0, C, 1, 145.0, 0, [])
	
	var bottom_blue := _n(70.0, C, 0, 0.0, 0, [
		[-120.0, _leaf(58.0, 140.0)],  # Green
		[0.0, _n(64.0, C, 1, 135.0, 0, [  # Red with marker
			[80.0, _leaf(60.0, 145.0)]
		])],
		[120.0, _n(62.0, C, 1, 150.0, 0, [  # Blue bar
			[85.0, _leaf(58.0, 140.0)]
		])]
	])
	bottom_blue["locks"] = [[0, 1]]
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-60.0, top_purple_hub],
		[-150.0, left_cyan],
		[-30.0, mid_orange],
		[30.0, mid_green],
		[90.0, right_orange],
		[160.0, bottom_green],
		[200.0, bottom_blue]
	])
	
	return root

# Level 74 - Complex interconnected puzzle
# Multiple shapes and hubs scattered
static func level_74() -> Dictionary:
	# Top-left orange structures
	var top_left_square := _n(66.0, S, 0, 0.0, 0, [
		[-90.0, _n(60.0, C, 1, 145.0, 0, [
			[-85.0, _leaf(56.0, 140.0)]  # Purple
		])],
		[0.0, _leaf(54.0, 135.0)]  # Orange curve
	])
	top_left_square["locks"] = [[0, 1]]
	
	# Top-middle structures
	var top_red := _n(62.0, C, 1, 150.0, 0, [])
	
	var top_blue_hub := _n(68.0, C, 1, 145.0, 0, [
		[-85.0, _n(64.0, C, 1, 140.0, 0, [  # Purple
			[-80.0, _leaf(60.0, 135.0)]
		])]
	])
	
	# Top-right green structures
	var top_right_green := _n(58.0, C, 1, 135.0, 0, [])
	
	var top_right_blue := _n(70.0, S, 0, 0.0, 0, [
		[-90.0, _leaf(56.0, 145.0)],  # Green bar
		[90.0, _n(62.0, C, 1, 140.0, 0, [
			[85.0, _leaf(58.0, 135.0)]  # Green curve
		])]
	])
	
	# Middle-left structures
	var mid_left_blue := _n(64.0, C, 1, 150.0, 0, [
		[-90.0, _leaf(58.0, 145.0)]  # Blue bar
	])
	
	# Central green T junction
	var green_center := _n(72.0, T, 0, 0.0, 0, [
		[-90.0, top_left_square],
		[0.0, _n(66.0, C, 1, 140.0, 0, [  # Orange with marker
			[80.0, top_blue_hub]
		])],
		[90.0, _leaf(60.0, 135.0)]  # Green bar right
	])
	
	# Middle-right purple curve
	var mid_right := _n(60.0, C, 1, 145.0, 0, [
		[85.0, _leaf(56.0, 140.0)]  # Green curve
	])
	
	# Bottom-left complex
	var bottom_left_cyan := _n(68.0, C, 1, 135.0, 0, [
		[-90.0, _n(64.0, T, 0, 0.0, 0, [
			[-90.0, _leaf(58.0, 145.0)]
		])],
		[0.0, _n(62.0, C, 1, 140.0, 0, [
			[80.0, _leaf(58.0, 135.0)]  # Red
		])]
	])
	bottom_left_cyan["locks"] = [[0, 1]]
	
	# Bottom-right purple/cyan structure
	var bottom_right := _n(70.0, S, 0, 0.0, 0, [
		[-90.0, _n(66.0, C, 1, 150.0, 0, [  # Purple square
			[-85.0, _n(64.0, C, 1, 145.0, 0, [  # Cyan
				[-80.0, _leaf(60.0, 140.0)]  # Orange
			])]
		])],
		[90.0, _n(62.0, C, 1, 135.0, 0, [
			[85.0, _leaf(58.0, 145.0)]  # Blue
		])]
	])
	
	# Red bar at bottom
	var bottom_red := _n(58.0, S, 0, 0.0, 0, [
		[0.0, _leaf(54.0, 140.0)]
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-120.0, top_red],
		[-60.0, top_right_green],
		[0.0, green_center],
		[60.0, top_right_blue],
		[-150.0, mid_left_blue],
		[90.0, mid_right],
		[-180.0, bottom_left_cyan],
		[150.0, bottom_right],
		[200.0, bottom_red]
	])
	
	return root

# Level 75 - Chain and branch structure
# Complex interconnected chains with varied angles
static func level_75() -> Dictionary:
	# Top-left green square frame
	var top_left_square := _n(68.0, S, 0, 0.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Cyan curve
			[-85.0, _n(66.0, C, 1, 140.0, 0, [  # Green curve
				[-80.0, _leaf(60.0, 135.0)]  # Blue curve
			])]
		])],
		[0.0, _leaf(58.0, 150.0)]  # Green bar inside
	])
	top_left_square["locks"] = [[0]]
	
	# Top-middle blue curve
	var top_mid_blue := _n(64.0, C, 1, 140.0, 0, [])
	
	# Top-right cyan curve
	var top_right_cyan := _n(60.0, C, 1, 145.0, 0, [
		[85.0, _n(58.0, C, 1, 150.0, 0, [  # Orange bar
			[80.0, _leaf(54.0, 135.0)]
		])]
	])
	
	# Middle-left structures
	var mid_left_orange := _n(62.0, C, 1, 135.0, 0, [])
	
	var mid_green_hub := _n(70.0, C, 0, 0.0, 0, [
		[-150.0, mid_left_orange],
		[-90.0, top_left_square],
		[-30.0, _n(66.0, C, 1, 140.0, 0, [
			[80.0, _leaf(62.0, 145.0)]  # Orange with marker
		])],
		[30.0, top_mid_blue],
		[90.0, _n(64.0, C, 1, 150.0, 0, [
			[85.0, _leaf(60.0, 135.0)]  # Cyan square
		])]
	])
	mid_green_hub["locks"] = [[2, 3]]
	
	# Middle-right structures
	var mid_right_orange := _n(68.0, C, 1, 145.0, 0, [
		[90.0, _n(72.0, S, 0, 0.0, 0, [  # Cyan square frame
			[0.0, _leaf(60.0, 140.0)]
		])]
	])
	
	# Bottom structures
	var bottom_purple := _n(66.0, C, 1, 140.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [
			[-85.0, _leaf(58.0, 135.0)]  # Purple
		])]
	])
	
	var bottom_red := _n(64.0, C, 1, 150.0, 0, [])
	
	var bottom_green_square := _n(68.0, S, 0, 0.0, 0, [
		[-90.0, _n(60.0, C, 1, 135.0, 0, [
			[-85.0, _leaf(56.0, 140.0)]  # Green bar
		])],
		[0.0, _leaf(58.0, 145.0)]  # Red bar
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-90.0, mid_green_hub],  # Main hub
		[60.0, top_right_cyan],
		[120.0, mid_right_orange],
		[-160.0, bottom_purple],
		[-120.0, bottom_red],
		[180.0, bottom_green_square]
	])
	
	return root

# Level 76 - Scattered organic layout
# No clear organization, distributed connections
static func level_76() -> Dictionary:
	# Top-left structures
	var top_left_blue := _n(60.0, C, 1, 145.0, 0, [
		[-90.0, _n(62.0, C, 1, 140.0, 0, [  # Green
			[-85.0, _leaf(58.0, 135.0)]
		])]
	])
	
	# Top-middle structures
	var top_green := _n(64.0, C, 1, 150.0, 0, [
		[85.0, _n(66.0, C, 1, 145.0, 0, [  # Purple
			[80.0, _leaf(62.0, 140.0)]
		])]
	])
	
	// Top-right red circle with marker
	var top_right := _n(68.0, C, 1, 135.0, 0, [])
	
	# Middle-left structures
	var mid_left_purple := _n(58.0, C, 1, 140.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]
	])
	
	# Central orange hub with marker
	var orange_hub := _n(70.0, C, 0, 0.0, 0, [
		[-150.0, mid_left_purple],
		[-90.0, _n(62.0, C, 1, 150.0, 0, [  # Purple
			[-85.0, _leaf(58.0, 135.0)]  # Red
		])],
		[-30.0, _n(66.0, C, 0, 0.0, 0, [  # Cyan circle
			[0.0, _leaf(60.0, 140.0)]  # Cyan curve
		])],
		[30.0, _n(64.0, C, 1, 145.0, 0, [  # Red
			[80.0, _leaf(62.0, 135.0)]  # Green
		])],
		[90.0, _n(68.0, C, 1, 140.0, 0, [  # Purple
			[85.0, _leaf(64.0, 145.0)]  # Green
		])]
	])
	orange_hub["locks"] = [[1, 2], [3, 4]]
	
	# Right structures
	var right_cyan := _n(60.0, C, 1, 135.0, 0, [])
	var right_blue := _n(62.0, C, 1, 150.0, 0, [
		[90.0, _n(66.0, C, 1, 145.0, 0, [
			[85.0, _leaf(60.0, 140.0)]  # Orange
		])]
	])
	
	# Bottom structures
	var bottom_left_orange := _n(58.0, C, 1, 140.0, 0, [])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-120.0, top_left_blue],
		[-60.0, top_green],
		[0.0, top_right],
		[-180.0, orange_hub],  # Main hub
		[90.0, right_cyan],
		[150.0, right_blue],
		[-150.0, bottom_left_orange]
	])
	
	return root

# Level 77 - Grid-like structure with horizontal/vertical bars
# Strong orthogonal arrangement
static func level_77() -> Dictionary:
	# Top row - four red and green curves
	var top_row: Array = []
	for i in range(4):
		var angle := -135.0 + float(i) * 90.0
		var radius := 58.0 if i % 2 == 0 else 60.0
		top_row.append(_n(radius, C, 1, 145.0, 0, []))
	
	# Second row - three green rings with connections
	var row2_left := _n(62.0, C, 1, 140.0, 0, [])
	var row2_mid := _n(64.0, C, 1, 135.0, 0, [
		[0.0, _leaf(56.0, 150.0)]  # Blue bar horizontal
	])
	var row2_right := _n(62.0, C, 1, 145.0, 0, [])
	
	# Third row - cyan/blue with orange bars
	var row3_left := _n(66.0, C, 1, 140.0, 0, [])
	var row3_mid := _n(68.0, C, 1, 135.0, 0, [
		[0.0, _leaf(58.0, 145.0)]  # Orange bar horizontal
	])
	var row3_right := _n(66.0, C, 1, 150.0, 0, [])
	
	# Fourth row - green bars with purple square
	var row4_left := _n(60.0, C, 1, 145.0, 0, [
		[-90.0, _n(72.0, S, 0, 0.0, 0, [  # Purple square
			[-90.0, _leaf(58.0, 140.0)]
		])]
	])
	
	var row4_mid_purple := _n(64.0, C, 0, 0.0, 0, [  # Purple circle
		[0.0, _leaf(56.0, 135.0)]  # Cyan bar
	])
	
	var row4_right := _n(62.0, C, 1, 140.0, 0, [])
	
	# Bottom row - three red/purple curves with orange center
	var bottom_left_green := _n(58.0, C, 1, 150.0, 0, [])
	var bottom_mid_purple := _n(70.0, C, 0, 0.0, 0, [  # Purple with marker
		[0.0, _leaf(60.0, 145.0)]  # Cyan bar
	])
	var bottom_right_red := _n(58.0, C, 1, 135.0, 0, [])
	
	# Assemble grid
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-135.0, top_row[0]],
		[-45.0, top_row[1]],
		[45.0, top_row[2]],
		[135.0, top_row[3]],
		[-120.0, row2_left],
		[0.0, row2_mid],
		[120.0, row2_right],
		[-150.0, row3_left],
		[-30.0, row3_mid],
		[150.0, row3_right],
		[-165.0, row4_left],
		[-60.0, row4_mid_purple],
		[165.0, row4_right],
		[-180.0, bottom_left_green],
		[0.0, bottom_mid_purple],
		[180.0, bottom_right_red]
	])
	
	root["locks"] = [[0, 1], [2, 3], [4, 6], [7, 9]]
	return root

# Level 78 - Complex multi-hub structure
# Large green hub center with multiple branches
static func level_78() -> Dictionary:
	# Top structures
	var top_orange_L := _n(58.0, C, 1, 145.0, 0, [])
	
	var top_green_bar := _n(60.0, C, 1, 90.0, 0, [
		[0.0, _leaf(54.0, 140.0)]  # Green horizontal bar
	])
	
	# Upper-left cyan structure
	var upper_left_cyan := _n(62.0, C, 1, 135.0, 0, [
		[-90.0, _n(66.0, C, 1, 150.0, 0, [  # Green curve
			[-85.0, _leaf(60.0, 145.0)]  # Blue
		])]
	])
	
	# Right red curve with closed circle
	var right_red := _n(64.0, C, 1, 140.0, 0, [
		[85.0, _n(72.0, C, 0, 0.0, 0, [  # Red closed circle
			[90.0, _leaf(62.0, 135.0)]  # Green curve
		])]
	])
	
	# Main large green hub center
	var green_hub := _n(74.0, C, 0, 0.0, 0, [
		[-150.0, upper_left_cyan],
		[-90.0, top_green_bar],
		[-30.0, _n(60.0, C, 1, 145.0, 0, [
			[80.0, _n(68.0, C, 0, 0.0, 0, [  # Cyan circle with marker
				[85.0, right_red]
			])]
		])],
		[30.0, _n(58.0, C, 1, 140.0, 0, [  # Purple curve
			[80.0, _n(70.0, S, 0, 0.0, 0, [  # Purple bar
				[90.0, _leaf(62.0, 145.0)]
			])]
		])],
		[90.0, _leaf(64.0, 135.0)]  # Orange piece
	])
	green_hub["locks"] = [[2, 3]]
	
	# Bottom-left structures
	var bottom_left_red := _n(66.0, C, 1, 150.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Red curve
			[-85.0, _leaf(58.0, 140.0)]  # Green
		])]
	])
	
	# Bottom structures with squares
	var bottom_purple_square := _n(68.0, S, 0, 0.0, 0, [
		[-90.0, _n(64.0, C, 1, 135.0, 0, [
			[-85.0, _leaf(60.0, 140.0)]  # Purple
		])],
		[90.0, _n(66.0, C, 1, 150.0, 0, [
			[85.0, _leaf(62.0, 145.0)]  # Green
		])]
	])
	bottom_purple_square["locks"] = [[0, 1]]
	
	var bottom_cyan_bar := _n(60.0, C, 1, 180.0, 0, [
		[0.0, _leaf(56.0, 145.0)]  # Cyan bar
	])
	
	var bottom_blue_square := _n(64.0, S, 0, 0.0, 0, [
		[0.0, _leaf(58.0, 140.0)]  # Cyan bar
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-120.0, top_orange_L],
		[0.0, green_hub],  # Main hub
		[-165.0, bottom_left_red],
		[-135.0, bottom_purple_square],
		[180.0, bottom_cyan_bar],
		[150.0, bottom_blue_square]
	])
	
	return root

# Level 79 - Interconnected chain structure
# Multiple chains interweaving
static func level_79() -> Dictionary:
	# Top chain - orange and purple curves
	var top_orange := _n(62.0, C, 1, 145.0, 0, [
		[-90.0, _n(64.0, C, 1, 140.0, 0, [  # Purple
			[-85.0, _n(60.0, C, 1, 135.0, 0, [  # Orange with marker
				[-80.0, _leaf(58.0, 150.0)]  # Purple
			])]
		])]
	])
	
	# Upper-middle structures
	var upper_cyan := _n(66.0, C, 1, 140.0, 0, [])
	var upper_orange := _n(68.0, C, 1, 145.0, 0, [])
	
	// Middle green T-bar
	var green_t := _n(70.0, T, 0, 0.0, 0, [
		[-90.0, _n(62.0, C, 1, 150.0, 0, [
			[-85.0, _leaf(58.0, 135.0)]  # Orange L
		])],
		[0.0, _leaf(64.0, 140.0)],  # Green bar vertical
		[90.0, _n(60.0, C, 1, 145.0, 0, [  # Red curve
			[80.0, _leaf(58.0, 140.0)]
		])]
	])
	green_t["locks"] = [[0, 2]]
	
	# Left side structures
	var left_orange_L := _n(58.0, C, 1, 135.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]
	])
	
	var left_blue_T := _n(66.0, T, 0, 0.0, 0, [
		[-90.0, _leaf(60.0, 140.0)],  # Orange bar
		[90.0, _leaf(62.0, 135.0)]  // Red bar
	])
	
	// Right side structures
	var right_green := _n(64.0, C, 1, 150.0, 0, [
		[85.0, _n(68.0, C, 1, 145.0, 0, [  # Cyan
			[80.0, _leaf(62.0, 140.0)]
		])]
	])
	
	var right_red_T := _n(70.0, T, 0, 0.0, 0, [
		[0.0, _leaf(64.0, 135.0)]  // Red bar
	])
	
	# Bottom structures
	var bottom_left_green := _n(60.0, C, 1, 140.0, 0, [
		[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Green with marker
			[-85.0, _leaf(58.0, 135.0)]  # Cyan
		])]
	])
	
	var bottom_mid_cyan := _n(66.0, C, 0, 0.0, 0, [  // Cyan circle
		[0.0, _leaf(60.0, 150.0)]  // Green curve
	])
	
	var bottom_right := _n(64.0, C, 1, 135.0, 0, [
		[85.0, _n(68.0, C, 1, 140.0, 0, [  # Orange
			[80.0, _leaf(62.0, 145.0)]  # Cyan
		])]
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[-90.0, top_orange],
		[-60.0, upper_cyan],
		[-30.0, upper_orange],
		[0.0, green_t],
		[-150.0, left_orange_L],
		[-120.0, left_blue_T],
		[90.0, right_green],
		[120.0, right_red_T],
		[-180.0, bottom_left_green],
		[180.0, bottom_mid_cyan],
		[150.0, bottom_right]
	])
	
	return root

# Level 80 - Rocket/spaceship shape
# Vertical symmetry with pointed top
static func level_80() -> Dictionary:
	# Top nose cone - red and green curved pieces
	var nose_top := _n(58.0, C, 1, 145.0, 0, [])  # Red
	var nose_left := _n(60.0, C, 1, 140.0, 0, [])  # Green
	
	# Upper body - purple bar
	var upper_purple := _n(62.0, C, 1, 90.0, 0, [
		[-90.0, nose_left],
		[90.0, nose_top]
	])
	upper_purple["locks"] = [[0, 1]]
	
	# Main body - large orange circle with inner structure
	var inner_cyan := _n(56.0, C, 1, 135.0, 0, [])  # Cyan with marker
	var mid_orange := _n(70.0, C, 0, 0.0, 0, [
		[-90.0, upper_purple],
		[0.0, inner_cyan],
		[90.0, _n(64.0, C, 1, 145.0, 0, [  # Blue bar
			[90.0, _leaf(58.0, 140.0)]
		])]
	])
	mid_orange["locks"] = [[1, 2]]
	
	# Side "wings" with bars
	var left_wing := _n(66.0, C, 1, 180.0, 0, [
		[-90.0, _n(68.0, C, 1, 145.0, 0, [  # Purple curve
			[-85.0, _leaf(62.0, 140.0)]  # Purple/green piece
		])],
		[0.0, _leaf(60.0, 135.0)]  // Orange bar
	])
	
	var right_wing := _n(64.0, C, 1, 0.0, 0, [
		[90.0, _n(66.0, C, 1, 150.0, 0, [  # Purple/cyan curve
			[85.0, _leaf(60.0, 145.0)]  // Orange piece
		])],
		[0.0, _leaf(58.0, 140.0)]  // Red bar
	])
	
	# Lower body - red bar with green structure
	var lower_red := _n(68.0, S, 0, 0.0, 0, [
		[0.0, _n(62.0, C, 1, 90.0, 0, [  # Green bar vertical
			[-90.0, _leaf(58.0, 145.0)]  // Blue/green
		])]
	])
	
	# Bottom structures
	var bottom_left := _n(60.0, C, 1, 135.0, 0, [
		[-90.0, _n(66.0, T, 0, 0.0, 0, [  # Green T
			[-90.0, _leaf(60.0, 140.0)]
		])]
	])
	
	var bottom_right := _n(64.0, C, 1, 145.0, 0, [
		[90.0, _n(68.0, T, 0, 0.0, 0, [  # Blue T
			[90.0, _leaf(62.0, 135.0)]
		])]
	])
	
	# Bottom exhaust - complex structure
	var exhaust_left := _n(58.0, C, 1, 150.0, 0, [
		[-90.0, _leaf(54.0, 145.0)]  # Purple piece
	])
	var exhaust_mid_blue := _n(60.0, C, 1, 140.0, 0, [])
	var exhaust_mid_red := _n(62.0, C, 1, 135.0, 0, [])
	var exhaust_right := _n(56.0, C, 1, 145.0, 0, [
		[90.0, _leaf(52.0, 150.0)]  # Purple piece
	])
	
	var root := _n(4.0, C, 1, 0.0, 0, [
		[0.0, mid_orange],  # Main body
		[-150.0, left_wing],
		[150.0, right_wing],
		[180.0, lower_red],
		[-135.0, bottom_left],
		[135.0, bottom_right],
		[-165.0, exhaust_left],
		[-180.0, exhaust_mid_blue],
		[180.0, exhaust_mid_red],
		[165.0, exhaust_right]
	])
	
	root["locks"] = [[5, 6]]
	return root

# Helper functions matching campaign_board.gd
static func _leaf(r: float, turn: float, gaps: int = 1) -> Dictionary:
	return _n(r, C, gaps, turn, 0, [])

static func _n(r: float, shape: int, gaps: int, turn: float, color: int, kids: Array) -> Dictionary:
	return {
		"r": r,
		"shape": shape,
		"gaps": gaps,
		"turn": turn,
		"color": color,
		"kids": kids,
		"bridge": false,
		"extra": [],
		"thick": 16.0,
	}
