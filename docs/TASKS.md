# TASKS.md — Rotate Rings Vertical Slice Plan

## TASK-001: Core Engine & Project Setup
Status: [x] DONE
North Star: Godot 4 project initialized with portrait viewport, dark theme background, and clean launch.
Slice:
  - [x] Initialize `project.godot` with 720x1280 resolution, canvas_items stretch mode.
  - [x] Create `scenes/Main.tscn` and `scripts/Main.gd`.
  - [x] Verify clean launch via `godot --path .` (L3 Behavioral).

## TASK-002: Procedural Ring Entity & Polar Dragging
Status: [x] DONE
North Star: Single ring renders with antialiased C-arc and responds to smooth polar touch/mouse dragging with inertia.
Slice:
  - [x] Create `scenes/Ring.tscn` and `scripts/Ring.gd`.
  - [x] Implement procedural `_draw()` arc rendering with custom gap angle and rounded caps.
  - [x] Implement `_unhandled_input()` polar angle tracking (`atan2`), drag offset, momentum, and angular snapping.
  - [x] Test interaction.

## TASK-003: Multi-Layer Concentric Rings & Unlock Alignment Math
Status: [x] DONE
North Star: 3 concentric rings on the board; matching gaps ejects inner rings outwards sequentially.
Slice:
  - [x] Create `scenes/Board.tscn` and `scripts/Board.gd`.
  - [x] Implement gap alignment detection algorithm across nested ring layers.
  - [x] Implement pop-out tween animation (`Tween.TRANS_BACK`) when a ring is unlocked.

## TASK-004: Game Feel, Procedural Audio & Particle Juice
Status: [x] DONE
North Star: Tactile audio clicks on rotation, particle burst on unlock, and victory screen.
Slice:
  - [x] Create `scripts/SoundSynth.gd` with procedural click sound & unlock chord synth.
  - [x] Create `scenes/ParticleBurst.tscn` for sparkling ring disintegration.
  - [x] Implement `scenes/UI/VictoryModal.tscn` and Next Level progression.

## TASK-005: 10 Handcrafted Puzzle Levels & Polish
Status: [x] DONE
North Star: Smooth difficulty curve from 2-ring tutorial to complex 4-ring multi-gap puzzles.
Slice:
  - [x] Build `scripts/LevelData.gd` with 10 progressive puzzle stages.
  - [x] Polish UI HUD (Level counter, Restart button, Moves tracker).
  - [x] Verify complete playthrough of all 10 levels.

## TASK-006: Premium Physics Ring Drop
Status: [x] DONE
North Star: When a ring unlocks, it converts to a RigidBody2D and naturally falls via gravity instead of vanishing.
Slice:
  - [x] Create `DroppedRing2D` (RigidBody2D) capable of rendering the exact `RingPiece2D` visual parameters.
  - [x] Modify `release_animator.gd` to spawn `DroppedRing2D` on ring release, applying initial angular and linear impulse.
  - [x] Remove the old scale/fade out and ensure ring drop feels weighty and premium.
  - [x] Commit: feat(TASK-006): convert released rings to falling RigidBody2D

## TASK-007: Smart Puzzle Camera Framing
Status: [x] DONE
North Star: The camera dynamically sizes and centers the puzzle so it always fits perfectly in the viewable area, leaving room for UI.
Slice:
  - [x] Calculate total puzzle bounds in `puzzle_controller.gd`.
  - [x] Update PuzzleController scale/position dynamically based on viewport aspect ratio.
  - [x] Commit: feat(TASK-007): implement smart puzzle framing camera
## TASK-008: Ring-World Mascot Companion
Status: [x] DONE
North Star: An original character interacts with the gameplay (watching, reacting, celebrating) and anchors the completion sequence.
Slice:
  - [x] Create `MascotCompanion` scene and state machine.
  - [x] Add basic procedural animation states (Idle, Watch, React, Catch).
  - [x] Integrate into `GameplayScreen` to observe ring drops and puzzle progress.
  - [x] Commit: feat(TASK-008): add ring-world mascot companion

## TASK-009: Signature Completion Sequence
Status: [x] DONE
North Star: The final released ring falls, is caught by the mascot, and transforms into a portal for the next level.
Slice:
  - [x] Detect the final ring drop in `puzzle_controller.gd`.
  - [x] Trigger Mascot "Catch & Portal" animation sequence.
  - [x] Transition smoothly to the next level/world map instead of just a popup.
  - [x] Commit: feat(TASK-009): implement mascot portal completion sequence

## TASK-010: Vertical Level Journey World
Status: [x] DONE
North Star: Replace rigid grid layout with a dynamic, vertical, curving path map.
Slice:
  - [x] Refactor `LevelSelectScreen.gd` to remove `GridContainer`.
  - [x] Calculate S-curve node placements.
  - [x] Create `journey_path_drawer.gd` to render connective lines and dots.
  - [x] Commit: feat(TASK-010): implement vertical level journey map

## TASK-011: Handcrafted Interactive Tutorial
Status: [x] DONE
North Star: Create an animated, procedural tutorial hand that guides the player through Level 1 with clear visual swipes instead of just a scale pulse.
Slice:
  - [x] Create `TutorialHand` (CanvasItem) that renders a stylized, soft-shaded hand.
  - [x] Implement path-following animation to simulate dragging the correct ring to its target angle.
  - [x] Integrate into `hint_controller.gd` so it plays automatically on Level 1, and on-demand for hints.
  - [x] Commit: feat(TASK-011): implement animated tutorial hand
