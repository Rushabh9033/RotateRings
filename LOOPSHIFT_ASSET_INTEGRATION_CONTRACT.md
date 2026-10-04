# LOOPSHIFT — ASSET INTEGRATION CONTRACT

This file is authoritative for every production visual asset supplied by the user/ChatGPT for LOOPSHIFT.

Claude Code is the implementation/integration agent.
The supplied assets are the approved art direction.

---

## 1. CORE VISUAL RULE

LOOPSHIFT is a **2D portrait mobile game**.

The production assets are intentionally designed as:

**2D sprites/vector artwork with a polished 3D-like visual feel.**

This means:
- the gameplay is 2D;
- the project must remain 2D;
- do not convert assets into 3D meshes;
- do not replace them with 3D geometry;
- do not introduce Perspective/Camera3D-based gameplay;
- highlights, depth, glossy shading, shadows, bevel-like lighting, and volume may be baked into the 2D artwork to create a premium 3D-like appearance.

The goal is:
**2D mechanics + premium dimensional visual treatment.**

---

## 2. ASSET AUTHORITY

Every production asset explicitly supplied by the user/ChatGPT is authoritative.

Claude Code MUST NOT:
- redesign it;
- redraw it;
- regenerate it;
- substitute it with an AI-generated alternative;
- replace it with a generic Godot shape;
- recolor it without explicit instruction;
- change its proportions;
- change its visual language;
- remove highlights/shadows;
- flatten its dimensional appearance;
- add unrelated decorations;
- crop important visual content;
- stretch it non-uniformly.

Claude may:
- import it;
- position it;
- uniformly scale it;
- rotate it;
- animate it;
- mask it when required by a designed effect;
- change opacity for transitions;
- combine it with approved shaders/effects;
- create hit areas/collision/data around it;
- optimize import settings without visibly degrading it.

If any proposed implementation would visibly alter the approved asset, preserve the asset and adapt the code instead.

---

## 3. CONSISTENCY IS NON-NEGOTIABLE

All assets generated for this game belong to ONE art system.

Do not mix:
- flat vector icons with glossy rendered icons;
- cartoon assets with realistic assets;
- different shadow directions;
- different highlight directions;
- inconsistent outline weights;
- unrelated color palettes;
- random gradients;
- different bevel/depth treatments;
- mismatched levels of gloss.

Whenever a new asset is introduced, compare it with existing approved production assets before integration.

The final game must look as though every asset was created by the same art team.

---

## 4. MOBILE-FIRST RULE

All art is designed for a portrait mobile game.

Reference layout:
- portrait
- approximately 9:16 to 20:9 phone aspect ratios
- scalable to tablets

Claude must never design gameplay around a desktop landscape window.

Desktop editor use is only for development/testing.

In-game composition must always be evaluated in portrait dimensions.

---

## 5. SINGLE-ASSET WORKFLOW

Production assets will normally be supplied ONE AT A TIME.

Each supplied asset should be treated independently.

Do not assume that one PNG is a sprite sheet unless explicitly stated.

Do not automatically atlas unrelated production assets.

Maintain clear mapping:

`asset filename -> exact gameplay/UI purpose`

If an asset's role is unclear, inspect the associated user instruction or manifest before using it.

---

## 6. RECOMMENDED FOLDER STRUCTURE

Place approved production assets under:

```text
res://assets/production/
  puzzle/
    rings/
    special_pieces/

  ui/
    icons/
    buttons/
    badges/
    screens/

  backgrounds/
    chapter_01/
    chapter_02/
    chapter_03/
    chapter_04/
    chapter_05/

  vfx/
    particles/
    glows/
    overlays/

  tutorial/

  branding/
```

Temporary programmer/debug art must NOT be stored with final production assets.

Use:

```text
res://assets/debug/
```

for temporary visuals.

Before shipping, no debug placeholder should be referenced by production scenes.

---

## 7. FILE NAMING

Preserve filenames supplied with approved assets wherever possible.

Recommended naming convention:

```text
ring_open_cobalt_01.png
ring_open_coral_01.png
ring_dual_gap_cobalt_01.png
ring_d_shape_jade_01.png

ui_icon_restart_01.png
ui_icon_hint_01.png
ui_icon_settings_01.png

fx_release_spark_01.png
fx_alignment_glow_01.png

bg_chapter_01_porcelain_01.png
```

Do not rename production assets casually after they are referenced in scenes/resources.

---

## 8. PNG / TRANSPARENCY RULES

For isolated puzzle pieces, icons, VFX sprites, and decorative elements:

- preserve transparency;
- do not add a black/white rectangle behind the asset;
- avoid destructive background removal if the original alpha is already correct;
- inspect alpha after import.

If an asset unexpectedly contains a baked background:
- do not silently modify the source file;
- report the issue;
- use a non-destructive fix only if visually safe;
- otherwise classify it as NEEDS USER CHECK.

---

## 9. ASPECT RATIO / SCALING

Never non-uniformly stretch artwork.

Use uniform scaling.

Maintain:
- original aspect ratio;
- intended silhouette;
- intended stroke thickness relationship;
- intended gap shape.

If the game needs a different size:
- scale the entire asset uniformly;
- adjust layout/code around it.

Do not squash a circular ring into an ellipse just to fit the screen.

---

## 10. TEXTURE IMPORT QUALITY

For production 2D art:

- use appropriate filtering for smooth high-resolution artwork;
- enable mipmaps only where they materially improve scaled rendering;
- avoid compression settings that create visible halos/banding;
- verify alpha edges;
- verify no dark fringe appears around transparent glossy assets;
- ensure mobile texture memory remains reasonable.

Never degrade the asset merely to reduce file size without profiling.

---

## 11. PUZZLE LOGIC MUST NOT DEPEND ON SPRITE PIXELS

The production ring image is VISUAL ART.

Gameplay rules must use independent deterministic data.

Do NOT use:
- pixel color;
- visual highlight;
- sprite opacity;
- baked shadow;
- exact image edge sampling

as the authoritative puzzle geometry.

Use mathematical/gameplay data for:
- ring center;
- effective radius;
- gap angle;
- gap width;
- blocker relationships;
- rotation limits;
- release conditions;
- touch/hit geometry.

The sprite follows the gameplay state.

The gameplay state must not be inferred from the rendered pixels.

---

## 12. HIT AREA RULE

Visible ring thickness and touch hit area do not need to be identical.

For mobile usability:
- use a forgiving touch region;
- keep it centered/aligned with the ring;
- avoid forcing the player to tap a narrow glossy stroke exactly.

Invisible hit geometry is allowed and encouraged.

It must not alter the visual asset.

---

## 13. ROTATION RULE

The complete visual asset rotates as one 2D object.

Do not independently rotate:
- highlights;
- baked shadow layers;
- glossy bands

unless the art asset was explicitly provided as separate layers for that purpose.

For the standard production ring asset:
- treat the supplied appearance as one coherent sprite;
- rotate it around its intended center pivot.

The gameplay rotation remains mathematically controlled by the ring system.

---

## 14. PIVOT / CENTER

For every puzzle-piece asset:
- determine/verify intended center;
- ensure the visual center matches gameplay rotation center;
- use a stable centered pivot;
- never compensate for an incorrect pivot with random positional offsets scattered through code.

If an asset needs a known pivot offset:
- define it once in its PieceDefinition/resource.

---

## 15. VISUAL STATES

Do not create completely different replacement artwork for every state unless supplied.

Use controlled runtime treatment around the authoritative base asset.

Recommended states:

### Normal
Unmodified approved asset.

### Selected
Allowed additions:
- subtle glow;
- slight scale lift;
- controlled shadow adjustment;
- selection overlay.

### Blocked
Allowed additions:
- restrained desaturation/tint overlay;
- tiny resistance animation;
- small lock indicator if designed.

### Near Alignment
Allowed additions:
- controlled glow pulse;
- small target arc.

### Released
Allowed:
- position/rotation/scale animation;
- opacity near final exit;
- particles/trail.

Never permanently bake runtime state modifications back into the source production PNG.

---

## 16. COLOR VARIANTS

If separate colored production assets are supplied, use those exact assets.

Do not reproduce color variants by arbitrary `modulate` values unless explicitly authorized.

Why:
the 3D-like visual feel may contain intentionally different highlight, saturation, shadow, and edge treatments per color.

A simple tint may reduce quality.

---

## 17. UI ASSET RULES

Production UI artwork/icons from the user/ChatGPT are authoritative.

Claude must:
- use consistent icon sizing;
- preserve optical weight;
- use containers/anchors for layout;
- keep touch areas larger than visible icons;
- preserve safe-area spacing;
- maintain portrait-first composition.

Do not put text inside supplied icon assets unless it is part of the approved design.

Use actual Godot text for dynamic labels.

---

## 18. BACKGROUND ASSETS

Backgrounds may be:
- full-screen portrait images;
- procedural systems;
- layered assets.

For supplied portrait backgrounds:
- use aspect-fill/crop carefully;
- protect important composition;
- do not stretch;
- verify on tall phones and tablets.

The puzzle must remain visually dominant.

---

## 19. VFX ASSETS

VFX assets supplied by the user/ChatGPT should be used as ingredients, not spammed.

Respect the GDD juice rules.

Particles should:
- reinforce success;
- remain readable;
- be short;
- avoid covering ring gaps;
- avoid overwhelming the puzzle.

---

## 20. SHADERS

Shaders may enhance supplied assets but must preserve the art direction.

Acceptable:
- subtle selection glow;
- controlled sheen;
- mask/reveal;
- release dissolve if designed;
- tiny highlight pulse;
- background grain.

Not acceptable:
- rainbow hue cycling;
- extreme bloom;
- random distortion;
- effects that flatten or obscure the supplied artwork.

---

## 21. SOURCE ASSET PROTECTION

Do not destructively edit the original production asset.

If a derived version is needed:
- preserve original;
- create derived output with a clear filename;
- document why it exists.

Example:

```text
ring_open_cobalt_01.png
ring_open_cobalt_01_mask.png
```

Never overwrite the authoritative original without explicit instruction.

---

## 22. ASSET MANIFEST

Maintain:

```text
res://assets/production/ASSET_MANIFEST.md
```

For each asset record:

```text
Filename:
Category:
Purpose:
Source status: APPROVED PRODUCTION
Native size:
Transparency:
Godot scene/resource using it:
Notes:
```

Update the manifest whenever a new approved asset is integrated.

---

## 23. NO UNSOLICITED ASSET GENERATION

Claude Code must NOT decide that an approved production asset is “missing” and generate a stylistically unrelated replacement.

If a final asset has not yet been supplied:
1. use a clearly marked temporary programmer asset;
2. keep it under `assets/debug/`;
3. record it as temporary;
4. make replacement easy;
5. continue engineering where possible.

Do not present the temporary asset as final production art.

---

## 24. ART REVIEW GATE

Whenever several new production assets are integrated, perform a visual review in portrait mode.

Check:
- same 2D-with-3D-feel art style;
- same gloss/depth language;
- same highlight behavior;
- coherent palette;
- matching quality;
- correct scale;
- no stretched artwork;
- transparent edges clean;
- no debug assets visible;
- puzzle remains readable.

If any supplied asset appears inconsistent, do not secretly redesign it.
Flag it as NEEDS USER CHECK.

---

## 25. CLAUDE'S RESPONSIBILITY VS ART DIRECTOR

### User / ChatGPT Art Director Owns
- final visual style;
- production puzzle-piece assets;
- colors/material appearance;
- UI asset appearance;
- icon appearance;
- backgrounds;
- decorative art;
- VFX artwork;
- visual consistency decisions.

### Claude Code Owns
- import;
- scene integration;
- layout;
- responsive behavior;
- gameplay code;
- deterministic puzzle geometry;
- input;
- animation;
- shader implementation around approved art;
- particles using approved assets;
- performance;
- testing;
- debugging;
- builds.

Claude Code must not silently take over the Art Director role.

---

## 26. FINAL SHIPPING CHECK

Before declaring the game shippable:

- every production image reference resolves;
- no production asset is accidentally replaced by debug art;
- no placeholder icons remain;
- no asset is non-uniformly stretched;
- all isolated sprites preserve alpha;
- all ring centers/pivots are correct;
- gameplay hit geometry aligns with visuals;
- all supplied art is used at intended quality;
- art is visually consistent in portrait mode;
- no unauthorized recolors/redesigns are present.

Report remaining visual uncertainty as:

**NEEDS USER CHECK**

Do not call inconsistent or placeholder visual work complete.
