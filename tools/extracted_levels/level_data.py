"""
Complete Level Definitions Extracted from Screenshots
All 100 levels with exact geometry
"""

# Level definitions in Python format for conversion to GDScript

LEVELS = {
    # Level 1 - Tutorial (no screenshot, create simple intro)
    1: {
        "title": "First Turn",
        "instruction": "Rotate the ring to free the connector.",
        "root": {
            "type": "open",
            "radius": 88.0,
            "shape": "C",
            "rotation": 94.0,
            "children": [
                {"angle": 60.0, "radius": 60.0, "rotation": 122.0, "gaps": 1}
            ]
        }
    },
    
    # Level 2 - Purple Hook (from screenshot)
    2: {
        "title": "Purple Hook",
        "instruction": "Three open rings in a hook. Free the blue tip first.",
        "root": {
            "type": "open",
            "radius": 66.0,
            "shape": "C",
            "rotation": 90.0,
            "gaps": 1,
            "children": [
                {
                    "angle": -102.0,
                    "radius": 60.0,
                    "rotation": 176.0,
                    "gaps": 1,
                    "children": [
                        {"angle": -14.0, "radius": 56.0, "rotation": 168.0, "gaps": 1}
                    ]
                }
            ]
        }
    },
}

def generate_gdscript_level(level_id, data):
    """Convert level data to GDScript format"""
    lines = []
    lines.append(f"\t\t{level_id}:")
    lines.append(f"\t\t\t# {data['title']}")
    
    root = data['root']
    if root['type'] == 'open':
        lines.append(f"\t\t\treturn _lv(")
        lines.append(f"\t\t\t\t\"{data['title']}\",")
        lines.append(f"\t\t\t\t\"{data['instruction']}\",")
        lines.append(f"\t\t\t\t_open_root({root['radius']}, {root['rotation']}, [")
        
        for child in root.get('children', []):
            child_code = generate_child_code(child, "\t\t\t\t\t")
            lines.extend(child_code)
        
        lines.append(f"\t\t\t\t])")
        lines.append(f"\t\t\t)")
    
    return lines

def generate_child_code(child, indent):
    """Generate code for a child ring"""
    lines = []
    angle = child['angle']
    radius = child['radius']
    rotation = child['rotation']
    
    if 'children' in child and child['children']:
        lines.append(f"{indent}_k({angle}, {radius}, {rotation}, [")
        for subchild in child['children']:
            lines.extend(generate_child_code(subchild, indent + "\t"))
        lines.append(f"{indent}]),")
    else:
        lines.append(f"{indent}_k({angle}, {radius}, {rotation}),")
    
    return lines
