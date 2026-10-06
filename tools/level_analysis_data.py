# Level Screenshot Analysis Data
# This file will store extracted data from each screenshot for batch processing

import json

# Template for level data extraction
level_data_template = {
    "level_id": 0,
    "screenshot_file": "",
    "analyzed": False,
    "rings": [
        # Each ring: {
        #   "id": 0,
        #   "radius": 60.0,
        #   "shape": "circle",  # circle, square, triangle, oval
        #   "gaps": 1,  # 0=closed, 1=one gap, 2=two gaps
        #   "rotation": 120.0,  # initial rotation in degrees
        #   "color": "cyan",  # visual color for mapping
        #   "position_rel": [0, 0],  # relative position for validation
        # }
    ],
    "connectors": [
        # Each connector: {
        #   "parent_id": 0,
        #   "child_id": 1,
        #   "angle": -90.0,  # angle from parent to child
        # }
    ],
    "locks": [
        # Each lock: [ring_a_id, ring_b_id]
    ],
    "notes": ""  # Any special observations
}

# This will be populated as we analyze screenshots
levels_data = {}

def save_level_data(level_id: int, data: dict):
    """Save data for a specific level."""
    levels_data[level_id] = data
    with open('level_analysis_data.json', 'w') as f:
        json.dump(levels_data, f, indent=2)

def load_level_data():
    """Load previously saved level data."""
    global levels_data
    try:
        with open('level_analysis_data.json', 'r') as f:
            levels_data = json.load(f)
    except FileNotFoundError:
        levels_data = {}
    return levels_data

# Analysis helper functions

def estimate_radius(ring_visual_data):
    """Estimate radius from visual measurements."""
    # This would use pixel measurements from screenshot
    # For now, return typical values
    typical_radii = [54.0, 56.0, 58.0, 60.0, 62.0, 64.0, 66.0, 68.0, 70.0, 72.0, 74.0, 76.0, 78.0]
    return 60.0  # Placeholder

def estimate_angle(parent_pos, child_pos):
    """Estimate angle from parent to child based on positions."""
    import math
    dx = child_pos[0] - parent_pos[0]
    dy = child_pos[1] - parent_pos[1]
    angle = math.degrees(math.atan2(dy, dx))
    return round(angle, 1)

def detect_shape(ring_visual):
    """Detect ring shape from visual appearance."""
    # Analyze visual to determine if circle, square, triangle, or oval
    return "circle"  # Placeholder

def detect_gaps(ring_visual):
    """Detect number of gaps in ring."""
    # Analyze visual to count gaps
    return 1  # Placeholder

def estimate_rotation(ring_visual):
    """Estimate initial rotation angle of ring."""
    # Measure gap orientation
    return 120.0  # Placeholder

if __name__ == '__main__':
    load_level_data()
    print(f"Loaded {len(levels_data)} levels from previous analysis")
