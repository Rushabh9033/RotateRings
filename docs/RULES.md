# RULES.md — Rotate Rings Stack Locks

- **Engine:** Godot 4.7.2 (Stable)
- **Language:** GDScript 2.0 (Strict typing enabled)
- **Rendering:** Mobile / Compatibility (OpenGL 3.3 / WebGL friendly)
- **Resolution Base:** 720 x 1280 (Portrait, Stretch mode: `canvas_items`, Aspect: `expand`)
- **Input Handling:** Polar `atan2` touch/mouse delta tracking on `_input()` / `_unhandled_input()`
- **Scene Architecture:** Node-based composition (`GameMain` -> `Board` -> `Ring`)
- **State Management:** Finite State Machine on GameBoard (`IDLE`, `DRAGGING`, `CHECKING_UNLOCK`, `ANIMATING`, `LEVEL_COMPLETE`)
- **Audio:** Procedural WebAudio/Godot `AudioStreamGenerator` for zero-asset tactile clicks and unlock chimes.
