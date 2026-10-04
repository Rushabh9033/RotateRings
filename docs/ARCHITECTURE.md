# ARCHITECTURE.md — Rotate Rings Godot Architecture

## 1. Directory Structure
```
RotateRings/
├── project.godot
├── docs/
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   ├── DESIGN.md
│   ├── RULES.md
│   ├── TASKS.md
│   ├── DECISIONS.md
│   └── MEMORY.md
├── scenes/
│   ├── Main.tscn           # Main game entry point & UI overlay
│   ├── Board.tscn          # Game board holding rings and checking alignment
│   ├── Ring.tscn           # Individual draggable rotating C-ring with gap
│   ├── ParticleBurst.tscn  # Particle explosion on ring unlock
│   └── UI/
│       ├── HUD.tscn        # Level info, moves counter, restart button
│       └── VictoryModal.tscn # Level complete celebration popup
├── scripts/
│   ├── Main.gd             # Game controller & level loader
│   ├── Board.gd            # Ring unlock logic & alignment checks
│   ├── Ring.gd             # Polar rotation, dragging, snap physics, custom arc drawing
│   ├── SoundSynth.gd       # Procedural audio clicks & unlock melody generator
│   └── LevelData.gd        # Handcrafted level definitions & generator
└── assets/
    └── icons/              # SVG icons & textures
```

## 2. Data Flow & Unlock Logic
1. `Ring.gd` calculates polar drag relative to its center and emits `rotated_to(angle)`.
2. When mouse/touch releases, `Ring.gd` snaps smoothly to 15° increments and signals `drag_finished`.
3. `Board.gd` receives `drag_finished` and tests:
   - For concentric rings: checks if inner ring gap angle $\theta_i$ overlaps outer ring gap angle $\theta_o$ ($|\text{angle\_diff}(\theta_i, \theta_o)| < \text{threshold}$).
   - If unlocked, `Ring.gd` plays spring fly-off animation (`Tween`), emits sound chime, and removes itself from the board.
4. When `Board.get_remaining_rings() == 0`, triggers `VictoryModal` and advances level!
