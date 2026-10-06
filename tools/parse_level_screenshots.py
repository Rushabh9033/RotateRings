#!/usr/bin/env python3
"""
Level Screenshot Parser for RotateRings
Analyzes screenshots and generates level definitions matching campaign_board.gd format.
"""

import os
import json
import re
from pathlib import Path
from typing import List, Dict, Tuple, Optional
import base64


class LevelScreenshotParser:
    """Parses level screenshots and generates GDScript level definitions."""
    
    # Color mapping from screenshots to game palette indices
    COLOR_MAP = {
        'cyan': 0, 'blue': 0,
        'orange': 1,
        'purple': 2, 'violet': 2,
        'red': 3,
        'green': 4, 'dark_green': 4,
        'light_blue': 5,
        'light_orange': 6,
        'teal': 7, 'turquoise': 7
    }
    
    # Shape constants
    SHAPE_CIRCLE = 0  # C
    SHAPE_SQUARE = 1  # S
    SHAPE_TRIANGLE = 2  # T
    SHAPE_OVAL = 3  # O
    
    def __init__(self, screenshots_dir: str):
        self.screenshots_dir = Path(screenshots_dir)
        self.levels = {}
        
    def get_screenshot_files(self) -> List[Tuple[int, Path]]:
        """Get all screenshot files and extract level numbers from filenames."""
        files = []
        jpeg_files = sorted([f for f in self.screenshots_dir.glob("*.jpeg") 
                            if not f.name.endswith('.import')])
        
        # Map files to level numbers based on order
        # Files are sorted alphabetically, which should give us levels 2-100
        for i, filepath in enumerate(jpeg_files, start=2):
            files.append((i, filepath))
            
        return files[:99]  # Ensure we only take 99 files for levels 2-100
    
    def analyze_screenshot_with_vision(self, filepath: Path) -> Dict:
        """
        Analyze a screenshot using AI vision to extract level geometry.
        Returns structured data about rings, connectors, gaps, etc.
        """
        # This is a placeholder - will be implemented with actual vision analysis
        # For now, return a template structure
        return {
            'level_id': 0,
            'rings': [],
            'connectors': [],
            'locks': []
        }
    
    def parse_level_geometry(self, level_id: int, vision_data: Dict) -> Dict:
        """
        Convert vision analysis data into level definition structure.
        """
        rings = []
        connectors = []
        
        # Process each ring from vision data
        for ring_data in vision_data.get('rings', []):
            ring = {
                'radius': ring_data.get('radius', 60.0),
                'shape': ring_data.get('shape', self.SHAPE_CIRCLE),
                'gaps': ring_data.get('gaps', 1),
                'turn': ring_data.get('rotation', 120.0),
                'color': self.COLOR_MAP.get(ring_data.get('color', 'cyan'), 0),
                'children': []
            }
            
            # Process child rings
            for child_data in ring_data.get('children', []):
                child = {
                    'angle': child_data.get('angle', 0.0),
                    'ring': self.parse_ring_recursive(child_data)
                }
                ring['children'].append(child)
            
            rings.append(ring)
        
        return {
            'level_id': level_id,
            'root': rings[0] if rings else {},
            'locks': vision_data.get('locks', [])
        }
    
    def parse_ring_recursive(self, ring_data: Dict) -> Dict:
        """Recursively parse ring and its children."""
        ring = {
            'radius': ring_data.get('radius', 60.0),
            'shape': ring_data.get('shape', self.SHAPE_CIRCLE),
            'gaps': ring_data.get('gaps', 1),
            'turn': ring_data.get('rotation', 120.0),
            'color': 0,
            'children': []
        }
        
        for child_data in ring_data.get('children', []):
            child = {
                'angle': child_data.get('angle', 0.0),
                'ring': self.parse_ring_recursive(child_data)
            }
            ring['children'].append(child)
        
        return ring
    
    def generate_gdscript_definition(self, level_data: Dict) -> str:
        """Generate GDScript code for level definition."""
        level_id = level_data['level_id']
        root = level_data['root']
        
        # Generate the GDScript code
        code_lines = [f"\t{level_id}:"]
        
        # Check if it's a simple open root with children
        if root.get('gaps', 0) > 0:
            code_lines.append(f"\t\treturn _open_root({root['radius']}, {root['turn']:.1f}, [")
        else:
            # Closed root
            shape = self._shape_const(root.get('shape', 0))
            code_lines.append(f"\t\treturn _closed({root['radius']}, {shape}, [")
        
        # Add children
        for child in root.get('children', []):
            code_lines.extend(self._generate_child_code(child, indent="\t\t\t"))
        
        code_lines.append("\t\t])")
        
        return "\n".join(code_lines)
    
    def _generate_child_code(self, child: Dict, indent: str) -> List[str]:
        """Generate GDScript code for a child ring recursively."""
        lines = []
        angle = child['angle']
        ring = child['ring']
        
        # Check if leaf or has children
        if not ring.get('children'):
            # Leaf node
            turn = ring.get('turn', 120.0)
            gaps = ring.get('gaps', 1)
            lines.append(f"{indent}_k({angle:.1f}, {ring['radius']}, {turn:.1f}),")
        else:
            # Node with children
            turn = ring.get('turn', 120.0)
            lines.append(f"{indent}_k({angle:.1f}, {ring['radius']}, {turn:.1f}, [")
            for sub_child in ring['children']:
                lines.extend(self._generate_child_code(sub_child, indent + "\t"))
            lines.append(f"{indent}]),")
        
        return lines
    
    def _shape_const(self, shape: int) -> str:
        """Convert shape int to GDScript constant."""
        shapes = {0: 'C', 1: 'S', 2: 'T', 3: 'O'}
        return shapes.get(shape, 'C')
    
    def process_all_screenshots(self) -> Dict[int, Dict]:
        """Process all screenshots and return level definitions."""
        screenshot_files = self.get_screenshot_files()
        
        print(f"Found {len(screenshot_files)} screenshot files")
        
        for level_id, filepath in screenshot_files:
            print(f"Processing Level {level_id}: {filepath.name}")
            
            # Analyze screenshot
            vision_data = self.analyze_screenshot_with_vision(filepath)
            vision_data['level_id'] = level_id
            
            # Parse into level definition
            level_def = self.parse_level_geometry(level_id, vision_data)
            self.levels[level_id] = level_def
        
        return self.levels
    
    def export_level_definitions(self, output_file: str):
        """Export all level definitions to a JSON file."""
        with open(output_file, 'w') as f:
            json.dump(self.levels, f, indent=2)
        print(f"Exported level definitions to {output_file}")
    
    def generate_gdscript_file(self, output_file: str):
        """Generate a complete GDScript file with all level definitions."""
        lines = [
            "# Generated level definitions from screenshots",
            "# Levels 2-100",
            "",
            "static func _screenshot_levels(level_id: int) -> Dictionary:"
        ]
        
        # Add match statement
        lines.append("\tmatch level_id:")
        
        for level_id in sorted(self.levels.keys()):
            level_code = self.generate_gdscript_definition(self.levels[level_id])
            lines.append(level_code)
        
        lines.extend([
            "\t\t_:",
            "\t\t\treturn {}",
            ""
        ])
        
        with open(output_file, 'w') as f:
            f.write('\n'.join(lines))
        
        print(f"Generated GDScript file: {output_file}")


def main():
    screenshots_dir = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
    parser = LevelScreenshotParser(screenshots_dir)
    
    # Process all screenshots
    parser.process_all_screenshots()
    
    # Export to JSON
    parser.export_level_definitions("level_definitions.json")
    
    # Generate GDScript
    parser.generate_gdscript_file("generated_levels.gd")


if __name__ == '__main__':
    main()
