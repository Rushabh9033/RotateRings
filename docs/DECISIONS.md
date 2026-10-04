# DECISIONS.md — Rotate Rings Decision Log

## DECISION-001: Procedural Arc Drawing over Static Sprites
Date: 2026-10-03
Context: Rings need arbitrary radii, gap widths, and line thicknesses across levels.
Options:
  A: Static pre-rendered PNG ring textures
  B: Procedural Vector `_draw()` with antialiased `draw_arc` / `draw_polyline`
Chosen: Option B (Procedural Vector Drawing)
Reason: Perfect pixel sharpness on any screen resolution (iPad, 4K monitor, mobile), dynamic color theming, and zero asset loading overhead.
Tradeoffs: Slightly more GDScript math for collision bounds, solved with simple polar coordinate distance checking.

## DECISION-002: Procedural Sound Synthesis vs External Audio Files
Date: 2026-10-03
Context: Need tactile clicks on rotation and chimes on unlock without external audio files.
Options:
  A: External WAV/MP3 files
  B: Godot AudioStreamGenerator procedural sine/square wave synth in GDScript
Chosen: Option B
Reason: 100% self-contained, instant pitch-shifting for ring layers, ultra-lightweight.
