---
name: rotate-rings-level-designer
description: Expert system for designing Rotate Rings levels using structured archetypes, multi-shape geometry, and rigorous solver validation.
---

# Rotate Rings Level Designer

This skill is the **PERMANENT RULEBOOK** Antigravity must follow whenever creating, repairing, regenerating, or reviewing Rotate Rings levels.

## Mandatory Workflow
**NEVER** design a level first and hope it works. Follow this exact workflow:
1. **UNDERSTAND CURRENT RUNTIME RULES**
2. **CHOOSE LEVEL INTENT** (e.g., Chain, Fork, Diamond Dependency)
3. **DESIGN TOPOLOGY**
4. **GENERATE/PLACE PIECES** (mixing shapes and radii)
5. **VALIDATE GEOMETRY** (no zero-length stems, no overlaps)
6. **RUN RUNTIME-ACCURATE SOLVER**
7. **SEARCH FOR SHORTCUTS**
8. **CHECK MOBILE READABILITY**
9. **RATE DIFFICULTY**
10. **ACCEPT OR REJECT LEVEL** (No level is accepted merely because it renders.)

## Geometry & Shape Foundation
The engine uses `PieceGeometry` to calculate exact boundaries for:
- `ShapeType.CIRCLE`
- `ShapeType.ROUNDED_SQUARE`
- `ShapeType.ROUNDED_TRIANGLE`
- `ShapeType.OVAL`

**Rule**: Do NOT just draw a square and pretend it's a circle. The game handles boundary offsets correctly.
**Rule**: NEVER create unsupported zero-length standard connectors between same-center pieces. Concentric rings are fine, but they cannot be linked to each other radially across distance 0.

## Level Archetypes & Design Templates
Do not generate completely random graphs. Use structured archetypes:
- **CHAIN**: A ? B ? C ? D
- **FORK**: One parent holding multiple children.
- **MULTI-PARENT GATE**: A ? C ? B. C must sequentially escape two different constraints.
- **DIAMOND DEPENDENCY**: A branching path that converges.
- **TWO-STAGE LOCK**: Outer puzzle releases middle dependency, revealing final lock.
- **DUAL-GAP DECISION**: One piece uses two gaps to clear distinct constraints.
- **MIXED-SHAPE SPATIAL LOCK**: Circle + Rounded Square arranged so geometry matters.

## What "Hard" Means
Difficulty comes from:
- Dependency order (deciding which connector to clear first).
- Multi-parent relationships.
- Using different gaps correctly.
- Shape-specific spatial reasoning.

**DO NOT** use:
- Tiny touch targets / microscopic gaps / precision frustration.
- Exploiting collision bugs.
- Stale DETACHED connectors.

## Difficulty Bands
- **Levels 13-20 (MEDIUM-HARD)**: ~6-8 meaningful optimal player actions.
- **Levels 21-30 (HARD)**: ~8-10 meaningful optimal actions.
- **Levels 31-40 (VERY HARD)**: ~10-12 meaningful optimal actions.
- **Levels 41-50 (EXPERT)**: ~12-16 meaningful optimal actions.
(Do not count automatic cascades as meaningful decisions).

## Hard Quality Gate
Before accepting a level, ensure:
- **GEOMETRY PASS**: No zero-length links, valid gap positions.
- **SOLVER PASS**: Genuinely solvable, using only runtime-accurate actions.
- **EXPLOIT PASS**: No unintended shortcuts.

## Solver Proof Package
For every accepted level, output a Solver Proof Package containing:
- Level ID, Difficulty, Shapes Used, Piece Count, Link Count.
- Shortest legal moves, Par, Direct Clears, Cascade Clears.
- Validation PASS, Solver PASS, Exploit PASS.
