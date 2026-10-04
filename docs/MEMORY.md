# MEMORY.md — Live Snapshot

## Current State (updated: 2026-10-04)
- **Project:** LOOPSHIFT (RotateRings) — Godot 4.7.2
- **Status:** Professional Grade Geometry & UI Complete across All 12 Levels

## Complete System Audit & Professionalism Overhaul:
1. **Full 12-Level Geometry Audit (`tools/audit_levels.py`):**
   - Audited every level for minimum stem lengths (>= 30px) and non-linked ring clearance (>= 15px).
   - Recomputed and spaced all levels with collisions or squished stems:
     - **Level 5:** Re-spaced 7-ring web to match real video reference (`level5_14.png`). Stems increased to 40px–76px (previously 0px squished collisions).
     - **Level 6:** Symmetrical 9-ring clover with central closed O-ring (all stems 53px–116px, zero collisions).
     - **Level 7:** Symmetrical twin pillar Y-arches with 46px stems.
     - **Level 9:** Symmetrical zigzag ribbon with identical 50.5px stems.
     - **Level 10:** Dual-gap center with 44px stems on both sides.
     - **Level 11:** Mathematically regular hexagonal star with 46px stems between all adjacent vertices.
     - **Level 12:** Grand finale master knot with 45px–53px stems.
   - Result: **12 / 12 Levels verified with zero collisions and generous stems**.

2. **Visual & Rendering Polish:**
   - **Rounded Cuff Collar (`puzzle_controller.gd`):** Replaced sharp blocky rectangles with `_draw_rounded_rect` (pill/capsule collar with 5px radius). Encases the 24px tube cleanly with width 28px and span 34px.
   - **Seamless Injection-Molded Stems (`puzzle_controller.gd`):** Separated connector drawing into `stems_layer` (z=0, underneath ring body) and `cuffs_layer` (z=5, above ring tube). The opaque ring body (`pieces_container` at z=2) seamlessly encloses the stem base with a flared fillet, completely eliminating visible seams, cuts, or internal shadows.
   - **Soft Downward Drop Shadow (`ring_piece_2d.gd`):** Replaced shifted oversized arc with dual-layer diffused downward shadow matching tube thickness. Completely eliminated ugly protruding gray halos and top-edge artifacts.
   - **Seamless Round End-Caps:** Hemispherical rounded ends matching the exact ring body color.
   - **Pause / Victory Modal Occlusion:** Set `z_index = 100` and `z_as_relative = false` on `PauseModal` and `VictoryModal`. Modals now 100% cover all gameplay connectors, rings, and HUD without any bleed-through.

3. **Gameplay Mechanics & Physical Stopper Collision:**
   - **Connector-to-Connector Physical Blocker (`puzzle_rules.gd`, `drag_rotation_controller.gd`):** When rotating a ring whose outgoing stem approaches an attached incoming cuff (e.g. Level 2 Orange vs Purple's cuff), rotation is physically clamped at the contact threshold (`24.0°`). The player cannot rotate through the connector, triggers a lock rattle sound and haptic vibration on hit, forcing the player to rotate the other way to reach the gap.
   - **Synchronized Connector Jiggle Vibration (`drag_rotation_controller.gd`):** When tapping a locked ring (e.g. Level 3 Blue holding children), `jiggle_locked_piece` uses `tween_method` to animate the rotation and emit `rotation_changed` on every frame of the vibration. The attached stems and cuffs vibrate in 100% rigid synchronization with the ring before settling back to resting position.
   - **Level 3 Geometry Alignment (`level_database.gd`):** Symmetrical rhombus orientation with Blue top ring opening facing UP (`270.0°`) matching video reference (`level3_play.png`). Independent cuff detachment for Orange across both Blue and Red parents.
   - **Level 4 Symmetrical Constellation & Solvability (`level_database.gd`):** Fixed all piece orientations and solution steps matching video reference (`level4_52.png`). DarkGreen top ring faces UP (`270.0°`), Blue bottom ring faces DOWN (`90.0°`), left rings (Cyan, Red) face LEFT (`180.0°`), and right rings (Orange, LightGreen) face RIGHT (`0.0°`). Solvability verified end-to-end with sequential cuff releases leading to central closed Purple O-ring cascade.
   - **Collision Impact Particles (`gameplay/collision_spark_burst.gd`, `puzzle_rules.gd`, `puzzle_controller.gd`):** When any connector rotates and hits an obstacle / blocker or when a locked piece jiggles upon tap, a high-intensity burst of 18 radial sparks, diamond flash stars, and expanding shockwave ring emits directly at the collision contact point matching the game reference video.
   - **Level 5 Topology & Solvability Alignment (`level_database.gd`):** Synchronized piece start angles and link directions directly with video reference (`lvl5_sec_00.png`):
     - Orange (`ring_0`) starts at 315.0° (opening facing top-right, held on solid body by Cyan).
     - Cyan (`ring_1`) starts at 0.0° (opening facing East, held by Purple).
     - Purple (`ring_2`) starts at 270.0° (opening facing North, held by Red).
     - Red (`ring_3`) starts at 180.0° (opening facing West).
     - LightGreen (`ring_4`) starts at 90.0° (opening facing South, held by Purple & DarkGreen).
     - Blue (`ring_5`) starts at 90.0° (opening facing South, held by LightGreen).
     - DarkGreen (`ring_6`) starts at 0.0° (holding LightGreen, freed via gap alignment cascade).
     - Result: Zero cuffs in gaps at spawn; resolves deadlock on last 3 rings; 100% solvable end-to-end.
   - **All 12 Levels Deep Solvability & Spawn Audit (`tools/test_all_levels_solvability.gd`):** Audited and resolved start angle orientations across Levels 8, 9, 11, and 12:
     - Level 8: r3 start angle corrected to 90.0° (eliminates cuff-in-gap overlap at 270°).
     - Level 9: r3 start angle corrected to 90.0° (eliminates cuff-in-gap overlap with r2 and r4).
     - Level 11: r1 start angle set to 270.0° and r5 to 270.0° (eliminates stopper collisions and cuff-in-gap).
     - Level 12: r3 start angle set to 0.0° (eliminates cuff-in-gap and blocker hit with incoming cuff at 90°).
     - Result: **12 / 12 Levels verified: 0 cuffs inside gaps at start, 100% solvable to 0 pieces**.

4. **Headless & In-Engine Verification:**
   - `test_all_levels_solvability.gd`: PASSED (12 / 12 Levels audited for spawn clearance and full solution paths).
   - `test_lvl5_sim.gd`: PASSED (Level 5 verified end-to-end with 0 remaining pieces).
   - `test_collision_particles.gd`: PASSED (Sparks burst instantiated and processed at contact points).
   - `test_level_4.gd`: PASSED (Level 4 complete 8-step solve sequence and cascade release).
   - `test_jiggle_connectors.gd`: PASSED (98 rotation events emitted during jiggle, connectors vibrate with ring, rests at 270.0°).
   - `test_connector_blocker.gd`: PASSED (Clockwise blocked at +36.9°, counter-clockwise free to -119.0°).
   - `test_gameplay_flow.gd`: PASSED (Levels 2 and 3 end-to-end solve simulations).
   - `audit_levels.py`: 12 / 12 Levels PASSED.
   - In-engine screenshots captured and verified:
     - `verify_level_5.png`: Exact match with video reference `lvl5_sec_00.png` with zero cuffs in gaps.
     - `verify_collision_particles.png`: Real-time impact spark burst and shockwave ring at contact point.
     - `verify_level_4.png`: 100% exact visual match with video reference `level4_52.png`.
     - `jiggle_frame_peak.png`: Both connectors vibrating synchronously with the ring.
     - `verify_level_2.png`: Seamless molded stem-to-ring transitions.
     - `verify_pause_modal.png`: Zero connector leak-through behind Pause modal.
     - `verify_level_3.png`: Correct rhombus alignment and symmetric Blue top ring.
      - `verify_contact_sparkle_crop.png`: Confirmed 4-point golden sparkle star with warm amber glow halo and white core sits precisely at the boundary interface where the rotating connector head meets the other ring's outer rim.

5. **Contact Point Geometry, Golden Sparkle & Touch Sound Overhaul:**
   - **Precise Contact Point Math (`gameplay/puzzle_rules.gd`):** When rotation is clamped by an obstacle, `clamp_rotation_step` computes the exact midpoint between the rotating connector head (`pos_stem_head`) and the colliding ring body's outer circumference (`contact_on_parent`). Eliminated the bug where particles previously showed up on the stationary incoming cuff.
   - **Original 4-Point Golden Star Sparkle (`gameplay/collision_spark_burst.gd`):** Matches `sparkle_crop.png` with a 4-point golden star polygon, 4-point diagonal diamond rays, brilliant white center core, warm radial amber aura, and orbiting glittering star specks. Scaled smoothly from frame 0 with local puzzle coordinates and `z_index = 25`.
   - **Tactile Touch Sound Effect (`app/audio_service.gd`, `gameplay/drag_rotation_controller.gd`):** Synthesized `generate_touch_clack()` (1550Hz click + 460Hz hollow body tap with fast exponential decay). Wired `play_connector_touch()` to fire when pieces bump into each other during rotation.

6. **Premium Transformation Phase 1 - Smart Framing & Physics Drops:**
   - **Smart Puzzle Framing (`GameplayScreen.gd`, `puzzle_controller.gd`):** Added `get_puzzle_bounds()` to calculate the exact spatial requirements of all instantiated rings based on local coordinates. The gameplay screen now uses `_frame_puzzle()` to dynamically scale and center the `PuzzleController` perfectly within the safe UI area, ensuring all levels (whether 2 rings or 20 rings) are beautifully centered and never overlap the top or bottom HUD.
   - **RigidBody2D Physics Drops (`dropped_ring_2d.gd`, `release_animator.gd`):** Replaced the old "scale up and fade out" animation with a real physics implementation. Released rings are now instantiated as a `DroppedRing2D` (a `RigidBody2D`), retaining their exact arc geometry and visual state (thickness, color, gaps, rotation). A random central and torque impulse is applied to create a satisfying, weighty gravity drop off the screen, preparing the ground for mascot interactions in future phases.

7. **Premium Transformation Phase 2 & 3 - Mascot & Journey Map:**
   - **Mascot Companion (`mascot_companion.gd`):** Built a handcrafted 2D procedural ring-sprite mascot (Rayman-style floating hands, soft circle body) using `_draw()`. Implemented a robust state machine (IDLE, WATCHING, REACT_GOOD, REACT_BAD, CATCHING, CELEBRATING).
   - **Gameplay Screen Integration (`GameplayScreen.gd`):** Mascot dynamically spawns on the HUD and reacts to gameplay. When rings unlock, it jumps and celebrates. 
   - **Signature Completion Portal Sequence:** When the final ring drops (`DroppedRing2D`), the Mascot immediately jumps to the center of the screen, freezes the falling ring in mid-air (stops physics), and triggers a massive visual expansion tween transforming the ring into a bright portal to the next level (Variant B from prompt).
   - **Vertical Level Journey Map (`LevelSelectScreen.gd`, `journey_path_drawer.gd`):** Completely tore out the rigid `GridContainer`. Implemented a math-driven S-curve (`sin(lvl)`) vertical scrolling map where levels are placed organically. A custom `_draw()` node renders smooth connecting paths and dotted lines between the journey nodes.

8. **Premium Transformation Phase 4 - Interactive Tutorial:**
   - **Handcrafted Animated Tutorial (`tutorial_hand.gd`, `hint_controller.gd`):** Built a stylized, soft-shaded 2D hand using `_draw()`. Replaced the basic "scale pulse" hint with a full path-following swipe animation that demonstrates exactly how to drag the correct ring to its target angle.
   - **Auto-Trigger & Interrupt:** The tutorial automatically plays when starting Level 1. It smoothly loops the swipe animation, but instantly fades out and destroys itself the moment the player touches a ring (`piece_selected` signal), respecting player agency.
