#!/usr/bin/env python3
"""
Comprehensive Level Extractor for RotateRings
Processes all screenshots, extracts level data, generates GDScript definitions.
"""

import os
import re
import json
from pathlib import Path
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass, asdict
from collections import defaultdict


@dataclass
class RingSpec:
    """Specification for a single ring."""
    radius: float
    shape: int  # 0=C, 1=S, 2=T, 3=O
    gaps: int  # 0=closed, 1=one gap, 2=two gaps
    turn_angle: float  # rotation angle in degrees
    color: int  # palette index
    thickness: float = 16.0
    
@dataclass
class ConnectorSpec:
    """Specification for a connector between rings."""
    parent_id: int
    child_id: int
    angle: float  # angle from parent to child in degrees
    
@dataclass
class LockSpec:
    """Specification for a lock between two rings."""
    ring_a: int
    ring_b: int
    
@dataclass
class LevelSpec:
    """Complete specification for a level."""
    level_id: int
    title: str
    instruction: str
    rings: List[RingSpec]
    connectors: List[ConnectorSpec]
    locks: List[LockSpec]
    root_id: int = 0


class LevelExtractor:
    """Extracts level definitions from screenshots."""
    
    SHAPE_MAP = {'circle': 0, 'square': 1, 'triangle': 2, 'oval': 3}
    COLOR_MAP = {
        'cyan': 0, 'blue': 0, 'light_blue': 0,
        'orange': 1,
        'purple': 2, 'violet': 2,
        'red': 3,
        'green': 4, 'dark_green': 4,
        'blue2': 5,
        'orange2': 6,
        'teal': 7, 'turquoise': 7
    }
    
    def __init__(self, screenshots_dir: str):
        self.screenshots_dir = Path(screenshots_dir)
        self.level_map: Dict[int, LevelSpec] = {}
        
    def process_all_screenshots(self, use_cached: bool = False):
        """Process all screenshots and build level definitions."""
        screenshot_files = self._get_sorted_screenshot_files()
        
        print(f"Found {len(screenshot_files)} screenshot files")
        
        # For each screenshot, we need to:
        # 1. Read the image and extract level number from the UI
        # 2. Analyze the ring structure
        # 3. Build the level specification
        
        for filepath in screenshot_files:
            print(f"Processing {filepath.name}")
            # This would use vision AI to analyze the screenshot
            # For now, return placeholder
            
    def _get_sorted_screenshot_files(self) -> List[Path]:
        """Get all screenshot files sorted by filename."""
        files = [f for f in self.screenshots_dir.glob("*.jpeg") 
                if not f.name.endswith('.import')]
        return sorted(files)
    
    def export_to_gdscript(self, output_path: str):
        """Export all level definitions to GDScript format."""
        lines = [
            "# AUTO-GENERATED - DO NOT EDIT MANUALLY",
            "# Generated from screenshots in ALL 2to100 levels/",
            "",
            "extends RefCounted",
            "",
            "# Level definitions extracted from screenshots",
            "",
        ]
        
        # Generate match statement for each level
        lines.append("static func get_level_spec(level_id: int) -> Dictionary:")
        lines.append("\tmatch level_id:")
        
        for level_id in sorted(self.level_map.keys()):
            level_lines = self._generate_level_code(self.level_map[level_id])
            lines.extend(level_lines)
        
        lines.append("\t\t_:")
        lines.append("\t\t\treturn {}")
        
        with open(output_path, 'w') as f:
            f.write('\n'.join(lines))
        
        print(f"Exported GDScript to {output_path}")
    
    def _generate_level_code(self, spec: LevelSpec) -> List[str]:
        """Generate GDScript code for a single level."""
        lines = [f"\t\t{spec.level_id}:"]
        
        # Build the level structure based on the spec
        root = self._find_ring_by_id(spec, spec.root_id)
        
        if root and root.gaps > 0:
            lines.append(f"\t\t\treturn _open_root({root.radius}, {root.turn_angle:.1f}, [")
        else:
            shape = self._shape_name(root.shape if root else 0)
            radius = root.radius if root else 60.0
            lines.append(f"\t\t\treturn _closed({radius}, {shape}, [")
        
        # Add children recursively
        children = self._get_children(spec, spec.root_id)
        for child_id, angle in children:
            child_lines = self._generate_ring_code(spec, child_id, angle, "\t\t\t\t")
            lines.extend(child_lines)
        
        lines.append("\t\t\t])")
        
        return lines
    
    def _generate_ring_code(self, spec: LevelSpec, ring_id: int, angle: float, indent: str) -> List[str]:
        """Generate code for a ring and its children."""
        lines = []
        ring = self._find_ring_by_id(spec, ring_id)
        
        if not ring:
            return lines
        
        children = self._get_children(spec, ring_id)
        
        if not children:
            # Leaf ring
            lines.append(f"{indent}_k({angle:.1f}, {ring.radius}, {ring.turn_angle:.1f}),")
        else:
            # Ring with children
            lines.append(f"{indent}_k({angle:.1f}, {ring.radius}, {ring.turn_angle:.1f}, [")
            for child_id, child_angle in children:
                child_lines = self._generate_ring_code(spec, child_id, child_angle, indent + "\t")
                lines.extend(child_lines)
            lines.append(f"{indent}]),")
        
        return lines
    
    def _find_ring_by_id(self, spec: LevelSpec, ring_id: int) -> Optional[RingSpec]:
        """Find a ring by its ID."""
        if ring_id < len(spec.rings):
            return spec.rings[ring_id]
        return None
    
    def _get_children(self, spec: LevelSpec, parent_id: int) -> List[Tuple[int, float]]:
        """Get all children of a ring with their connection angles."""
        children = []
        for conn in spec.connectors:
            if conn.parent_id == parent_id:
                children.append((conn.child_id, conn.angle))
        return children
    
    def _shape_name(self, shape: int) -> str:
        """Convert shape int to constant name."""
        names = {0: 'C', 1: 'S', 2: 'T', 3: 'O'}
        return names.get(shape, 'C')


def main():
    screenshots_dir = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
    extractor = LevelExtractor(screenshots_dir)
    
    # Process all screenshots
    extractor.process_all_screenshots()
    
    # Export to GDScript
    extractor.export_to_gdscript("extracted_levels.gd")


if __name__ == '__main__':
    main()
