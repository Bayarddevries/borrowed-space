---
title: Borrowed Space — Roadmap
status: draft
last_edited: 2026-06-22
tags:
  - roadmap
  - phase-2
  - phase-3
  - phase-4
  - phase-5
  - convention
aliases:
  - ROADMAP
  - Roadmap
phase: 1
related:
  - "[[_CONVENTIONS]]"
  - "[[VISION]]"
  - "[[WORLD_BIBLE]]"
  - "[[HE3_INDUSTRY]]"
  - "[[NPCS]]"
  - "[[TRAITS]]"
  - "[[PERSISTENCE]]"
  - "[[TRUSTEE_BACKSTORY]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Roadmap — *Borrowed Space*

**Status:** Draft. Not yet locked. Subject to redirect during phase 2.
**Purpose:** Lock the *sequence* of work between now and ship-out. Captures what's planned, what's negotiable, and what's deliberately deferred.

---

## North star (carried from VISION)

> A being-promoted-into-uncertainty roguelike with a multi-run dismantling arc, set in a He-3 monopoly estate built by oligarch-founded sabotage; the AI remembers; each captain is a single increment of dismantling; defiant oligarch defectors, conscripts-as-protagonists, and stations that endure.

---

## Phase boundaries (current)

| Phase | Title | Goal | Output | Status |
|---|---|---|---|---|
| **1** | World bible | Lock the setting, lore, mechanics, narrative layer | 9 docs + 2 sample beats | **DONE** — committed `f0426c9` |
| **2** | Scaffold | Repo conventions, Godot 4 layout, Ink wrapper, narrative-data shape; runs end-to-end with placeholder art | Playable empty room + scripted AI demo | NEXT |
| **3** | Paper art v1 | One character + one background renders in Godot, paper-pipeline validated | 1 character, 1 background, color tests | PLANNED |
| **4** | Combat-fill | Ship battle v0 (4 turns), cover-test, fold mechanic, ledger persistence | A winning or losing combat clears story beats | PLANNED |
| **5** | Ship out | Build, publish to itch.io or self-host page, basic public README | Publicly playable browser build | PLANNED |

These are *non-binding* phase boundaries. We adjust when reality demands.

---

## Phase 2 — Scaffold (draft)

**Goal:** Make one run *playable* with paper-blocks for art, real Ink for narrative, real cross-run persistence for the dismantling arc, but **no** combat. The AI briefing + crew meetup + a single "see one station" beat is the floor.

### 2a. Repo conventions

| Deliverable | Description |
|---|---|
| `AGENTS.md` | Workflow contract for any agent or contributor — copies from Metis Trail's. |
| `HANDOFF.md` | Current state. Verified working features. Known issues. |
| `CHANGELOG.md` | Dated commits with summaries. |
| `TODO.md` | Active work, in-progress, queued. |
| `ISSUES.md` | Bug + enhancement tracking (mirrored from GitHub Issues). |

I copy the Metis Trail conventions since they work for our workflow.

### 2b. Godot 4 project layout

```
godot/
├── project.godot              # Godot 4 project root
├── assets/
│   ├── sprites/               # 2D frames (placeholder paper-blocks for phase 2)
│   └── data/                  # JSON / YAML persistence
├── scenes/
│   ├── run_start.tscn         # run-boot scene
│   ├── overworld.tscn         # the belt node map
│   ├── station.tscn           # a station
│   └── combat/                # combat scenes placeholders
├── scripts/
│   ├── captain.gd             # captain state + He-3 literacy tier
│   ├── crew.gd                # crew member
│   ├── ai.gd                  # ship-AI wrapper — talks to ink-engine
│   ├── ink_runner.gd          # ink ink-engine bridge
│   └── tool/                  # utility scripts
└── test/
    └── test_captain.gd        # smoke-tests with GUT or scene-bundled
```

I'll build this in `godot/`. Naming is consistent with Godot 4 conventions.

### 2c. Ink wrapper

- We use `inkjs` via a thin Godot wrapper rather than a third-party plugin. Goal: keep the story layer **ours.**
- The wrapper exposes:
  - `bind_external(state_dict, ledger)` — sync the Ink runtime variables with the persistence layer
  - `choose(choice_id)` — make a choice, returns next state
  - `get_current_text()` — read what's on screen
  - `apply_to_state(captain_obj)` — apply the latest flagged state changes
- The Ink runtimes' `ink.json` output lives in `narrative/build/` and is regenerated from `narrative/beats/*.ink` sources.
- I write a Node that auto-rebuilds on save.

### 2d. Persistence layer

- Single `data/persist.json` per save slot.
- Schema matches §1 *campaign state* from PERSISTENCE.md.
- Saves on:
  - Run outcome (player ends current run)
  - Each bond-shift
  - Each ledger-decision-impact

I'll write a `Persist` singleton with hooks for `save()` and `load()`.

### 2e. Narrative-data shape

The narrative-data shapes are the **data files** *outside* Ink that Ink reads at runtime. These are:

- `narrative/data/captain-origins.json` — the 6 genship × N countries matrix the player picks at run-start
- `narrative/data/npc-archetypes.json` — the 6–8-variant generator per archetype
- `narrative/data/ledger.json` — the persisted ledger of past captains, names, outcomes

These have **zero lore in them** — just structure. The Ink reads them as text-tables.

### 2f. Test harness

- GUT (Godot Unit Test) — runs headless. Verify:
  - Captain origin locked to matrix
  - Trait pool correctly drawn on archetype
  - Cover-test rolls correctly against expected band
  - Persist save/load round-trips
  - Ink variables flow into persistence
- `npm run test` style — a single tail-aggregating test shell script for Godot CLI

### 2g. Sample playable run

The single playable thing in phase 2 is:
1. Pick a genship origin (optional country fragment).
2. Pick an archetype (3 options).
3. Run the AI briefing (run-start.ink).
4. Meet 2 procedurally-generated crew.
5. Pick a destination on the overworld.
6. Arrive at a station, run a brief encounter, return.
7. End-of-run summary: Ledger entry.

No combat. No cover-test fail arcs. No art beyond placeholder paper-blocks. **One playable run** is phase 2's *only deliverable.*

---

## Phase 3 — Paper art v1

**Goal:** Validate the paper-pipeline runs end-to-end *without* filling the whole game with art.

- **Sub-deliverable 3a:** 1 character concept (silhouette + 1 accent color)
- **Sub-deliverable 3b:** 1 background (1 parallax layer)
- **Sub-deliverable 3c:** 1 station interior frame

Test: drop into Godot at 1080p, paper-frame-rendered, no animation.

If this validates, we move on. If paper-pipeline ends up ugly / slow / mismatched with what we want, we surface the problem here and decide whether to keep the pipeline or change it.

---

## Phase 4 — Combat-fill

**Goal:** Make ship battles v0 functional: 4 turns, two ships, 1 grid, tactical resolution. Combat must deliver story content.
- 4a: ship-battle grid (god math)
- 4b: cover-test in run
- 4c: bond-shift moments during combat
- 4d: ledger persistence after combat

---

## Phase 5 — Ship out

**Goal:** Public playability polish.
- 5a: build pipeline (Godot → web export)
- 5b: itch.io / self-host README
- 5c: opening pitch paragraph (re-uses VISION)

---

## Non-negotiables (carried from VISION)

These can flex on phasing, but not on outcome. Each is a deliverable that's expected *eventually*, not necessarily in phase 5:

1. **Story before combat.** Combat must surface story beats.
2. **Class-disparity constant.** Every faction reveals it.
3. **Captain's imposter-secret is escalated-not-exposed.** Multi-run reveal.
4. **Procedural events reference the ledger.** Dead carried forward.

---

## Negotiables

We *can* defer these without breaking the project. They're listed in VISION.md; restated here for sequencing:

- Permadeath vs roster damage vs ironman (deferred until prototype feel)
- Tactical resolution mechanism (turn-based grid vs. real-time-with-pause)
- Number of in-run days vs. number of in-run missions
- Era narrowing or widening (we landed at ~80yrs; could go to 100)
- Whether the [G6-Coalition PLACEHOLDER] default trait pool can be excluded
- Save-data scope (full-persistence vs. summary-ledger-only)

---

## Open questions for the future

These are questions I want answered *before* they bite us later:

1. **What is the player's name-or-pseudonym convention?** Display? Caps?
2. **Where is "the player" in the AI briefing?** As a hand on a control? A pulled-up bunk? A standing figure?
3. **How do we display ledger entries?** Comma-separated noun list? Pop-up graphic?
4. **Is there a class-passing visual cue?** Does the player-avatar wear a mask-and-twist-of-character they're-conscious-of?
5. **What's the 3rd archetype (Substitute Body)'s visible difference?** — *tbd in rename pass*

(These don't block phase 2. They block phase 3.)

---

## What *is* blocked

- Phase 2 block: nothing right now. We can start.
- Phase 3 block: we need to know what kind of paper-pipeline success looks like in prototype — validation step before 2nd character drawn.
- Phase 4 block: phase 2 must be playable with placeholder build before combat-fill runs.
- Phase 5 block: phase 4 + 3 must be done.

---

## When does a phase end?

A phase ends when:

1. The phase's deliverables are committed.
2. The phase's tests pass in headless dev environment.
3. The phase's contribution to a single-run experience is *playable*.

If a phase is *not* playable when it's "done," it isn't done — it's a deferred phase.

[End of ROADMAP.md draft v1.]
