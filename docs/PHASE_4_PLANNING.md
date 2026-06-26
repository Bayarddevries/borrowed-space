# Phase 4 — Paper Art Pass (Planning Doc)

> **Status:** Not started. **Blocked on:** (you decide below).
>
> **ROADMAP reference:** "1 character + 1 background validates paper pipeline. If pipeline is ugly/slow, we surface it here and decide."

---

## What Phase 4 is (and isn't)

**Phase 4 is a pipeline-validation phase, NOT a full art pass.** The ROADMAP says:

> One character concept (silhouette + 1 accent color)
> One background (1 parallax layer)
> One station interior frame
> Drop into Godot at 1080p, paper-frame-rendered, no animation

If these 3 pieces prove the pipeline works, Phase 4 is done. Full game art happens as a separate production pass — not in this phase.

---

## Three open questions that block Phase 4 planning

These need your answers before anyone can write a brief:

### 1. Paper pipeline — what toolchain?

Three viable paths, very different resource requirements:

| Path | Tooling | Skill needed | Cost |
|---|---|---|---|
| **Hand-drawn + scan** | Pen, paper, scanner/camera, GIMP/Photoshop for cleanup | Traditional art skills | ~$0 |
| **Digital papercut (raster)** | Procreate / Affinity Photo / Krita on tablet | Digital illustration | ~$10-100 one-time |
| **Procedural paper texture (shader)** | Godot shader + noise textures | Godot shader programming | $0 (paid agent's lane) |
| **Affinity Designer / Illustrator (vector)** | Vector illustration exported to Godot sprites | Vector art skills | ~$70 one-time |

**Your answer decides the tooling budget and which agent handles it.**

### 2. Who makes the art?

| Scenario | What we need |
|---|---|
| **You draw it** | Time + tablet/pen if digital |
| **Hire an artist** | Budget + spec sheet |
| **Paid agent builds the pipeline, commissioning brief instead of art** | A written "art spec" doc they can hand off |
| **Defer — no one makes art yet, keep ASCII** | Minimal cost, indefinitely playable but ugly |

The ROADMAP says "validate the pipeline" so the most honest option might be: **paid agent writes a shader-based procedural paper effect** (one Godot shader, costs no budget, validates the concept in-engine).

### 3. Done bar — what counts as "validated"?

Suggestion from the ROADMAP: one character silhouette + one parallax background + one station interior frame. But:

- Do these need to be **animated** (idle bob, parallax scroll)?
- Do they need **correct aspect ratio and resolution** for a 1920×1080 window?
- Is **"looks like paper in Godot"** good enough, or does it need to match a reference image first?

---

## My recommendation (if you want one)

**Lowest risk path:** Paid agent writes a **procedural paper-texture Godot shader** (no art budget, validates the pipeline, makes ASCII text look like it's on paper). That proves the concept. Actual character/background art gets its own later phase when you're ready to commission or draw.

If that sounds right, say "go" and I'll write a brief. If you want to answer the three questions above first, I'll write the plan around your answers. Your call.
