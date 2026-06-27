---
title: Borrowed Space — Roadmap
status: locked
last_edited: 2026-06-26
tags:
  - roadmap
  - phase-2
  - phase-3
  - phase-4
  - phase-5
  - convention
  - text-first-build
aliases:
  - ROADMAP
  - Roadmap
phase: 2
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

**Status:** Locked (text-first build order). The phase sequence and module breakdown are stable; sub-deliverables within each phase are negotiable.
**Purpose:** Lock the *sequence* of work between now and ship-out. Captures what's planned, what's negotiable, and what's deliberately deferred.

---

## North star (carried from VISION)

> A being-promoted-into-uncertainty roguelike with a multi-run dismantling arc, set in a He-3 monopoly estate built by oligarch-founded sabotage; the AI remembers; each captain is a single increment of dismantling; defiant oligarch defectors, conscripts-as-protagonists, and stations that endure.

---

## Build order (LOCKED)

**Text-first, then combat module, then art pass.**

Why:
- The narrative layer (Ink), trait system, and cover-test mechanic *are coupled* with combat — combat hooks in narrative cannot be deferred cleanly.
- Building combat first risks shipping a strong combat engine that *cannot tell story well.*
- Building art first risks the same — beautiful screens that lack game state.
- Text-first *proves the storytelling* before thousands of lines of combat/art code exist.

**Implications:**
- Phase 2 produces a text-first playable run with placeholder paper-blocks. **Done.**
- Phase 3 is *system-rich*: overworld, mission board, encounter pool, CQB combat, genship origins, voice corpus — all wired through the narrative layer. Art remains paper-blocks throughout.
- Phase 4 is the *only* visual phase — art pass on top of the proven narrative+combat skeleton.
- Phase 5 ships.

---

## Module breakdown (LOCKED COUNT: 8 + glue)

The system has eight modules plus one cross-cutting glue layer. They are *interfaces* — agents can work any one independently as long as the interface contracts are honored.

### Game systems (1–4)

| # | Module | Responsibility |
|---|---|---|
| 1 | **State machine** | Captain + crew + ledger state. Persists across runs and beats. Singleton (`Persist`). |
| 2 | **Captain generation** | Origin matrix × archetype × trait pool × He-3 literacy tier. 6 genships (incl. Coalition). |
| 3 | **Narrative runner** | Ink/JSON-beat story layer. Ledger-bound variables. Crew-aware choices. |
| 4 | **Crew system** | Procedural generation, bond mechanism, departure, casualty pipeline + journal. |

### Gameplay systems (5–9, Phase 3 actual split)

| # | Module | Responsibility | Phase |
|---|---|---|---|
| 5 | **Overworld / travel** | Hex-axial belt map, per-move clock (fuel/suspicion/day), station nodes, cartography. | 3a |
| 6 | **Mission board** | Offer generation (corps/genship/private/trustee sources), standing-gated availability, continuation threads. | 3c |
| 7 | **Encounter pool** | Weighted encounter selection by hex kind + ship state, 30+ entries across 5 categories. | 3d |
| 8 | **CQB combat** | 6×6 tactical grid, 2 AP/turn, cover/fold/flanking, aggro AI, casualty→tribute→ledger pipeline. | 3e |
| 9 | **Genship origins** | Per-origin mechanical data (corp relationships, unique content chains, narrative flavor, AI tone). | 3f |

### Content data (narrative/data/, feeds runtime loaders)

| File | Purpose | Phase |
|---|---|---|
| `captain-origins.json` | 6 genship origins × mechanical data (corp relationships, content chains, AI tone) | 3f |
| `npc-archetypes.json` | 5 archetypes × 21 variants for crew generation | 2e |
| `belt_factions.json` | Belt faction definitions (B1/B2/B3): leadership, politics, leverage | 3 |
| `defector_contacts.json` | Named NPC defector contacts tied to Trust families | 3 |
| `heritage_tags.json` | 12 captain country-fragment heritage tags | 3 |
| `last_mile_dispensary.json` | Healthcare/pharma belt faction (anti-Trust radiation monopoly) | 3 |
| `mars_sites.json` | Mars surface sites with dismantling hooks | 3 |
| `trust_families.json` | Trust family definitions (T1–T8) for dismantling arc | 3 |
| `encounter-pool.json` | 30+ weighted encounter entries across 5 categories | 3d |
| `aliens.json` | 4 CQB enemy archetypes + weapon validation | 3e |
| `stations.json` | 10 named stations (faction-matched to cartography) | 3a.2 |
| `cartography.json` | Hex belt topology, 10 stations STATION_01..STATION_10 | 3a.1 |
| `voice_fragments.json` | 50 `die_in_throes` + 50 `captain_journal` staged entries (3g landing target) | 3e.4 |

### Cross-cutting

| # | Module | Responsibility |
|---|---|---|
| 14 | **Voice corpus** | `die_in_throes` + `captain_journal` fragments (split from `voice_fragments.json` in 3g). Feeds casualty tributes + journal entries. |
| 15 | **UI / art** | Paper pipeline. Station interiors, paper-frame staging. **Phase 4 only.** |

### Module dependencies

```
[1 State] → [2 CaptainGen] → [3 Narrative] → [5 Travel] → [7 Encounter Pool]
   ↓            ↓              ↓               ↓              ↓
  [Ledger] ← [4 Crew]    [8 CQB]      [6 Mission Board]   ↓
   ↓            ↓              ↓              ↓         [14 Voice]
[10 Content] ←─────────────┴──────────────┘              ↓
                                                      [15 UI/Art]
```

The combat module **calls into** the narrative layer through Ink beats; the narrative layer does *not* depend on combat. This asymmetry means combat can be swapped or rewritten without narrative refactoring.

## Phase boundaries (current)

| Phase | Title | Goal | Output | Status |
|---|---|---|---|---|
| **1** | World bible | Lock the setting, lore, mechanics, narrative layer | 9 docs + 2 sample beats | **DONE** — `f0426c9` |
| **2** | Text-first scaffold | Repo conventions, Godot 4 layout, ink wrapper, persistence, narrative-data, test harness, sample playable run | One playable text-first run, no art, no combat | **DONE** — 55/55 GUT pass, 7/7 sub-deliverables shipped |
| **3** | **Encounter + combat + narrative systems** | Overworld travel, mission board, encounter pool, CQB combat, genship origins, voice corpus — all wired into the narrative layer | Combat delivers story; modules 5–8 (per old split) or 3a–3g (actual split) shipped | **DONE** — 91/90+1 GUT pass, 576 asserts |
| **4** | Paper art pass | One character + one background validates paper pipeline | 1 character, 1 background, color tests; rendering validated | PLANNED |
| **5** | Ship out | Build, publish, README polish | Publicly playable browser build | PLANNED |

Sub-deliverable tracking on issue board.

These are *non-binding* phase boundaries. We adjust when reality demands.

---

## Phase 2 — Scaffold (LOCKED text-first)

**Goal:** Make one run *playable* with paper-blocks for art, real Ink for narrative, real cross-run persistence for the dismantling arc, but **no** combat. The AI briefing + crew meetup + a single "see one station" beat is the floor.

### 2a. Repo conventions — ✅ committed (#1)

| Deliverable | Description |
|---|---|
| `AGENTS.md` | Workflow contract for any agent or contributor. **Locked.** |
| `HANDOFF.md` | Current state. Verified working features. Known issues. |
| `CHANGELOG.md` | Dated commits with summaries. |
| `TODO.md` | Active work, in-progress, queued. |
| `ISSUES.md` | Bug + enhancement tracking (mirrored from GitHub Issues). |

### 2b. Godot 4 project layout — ✅ committed (#2)

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
│   └── tool/                  # utility scripts (dice.gd, etc.)
└── test/
    └── test_captain.gd        # smoke-tests with GUT or scene-bundled
```

Verified: Godot **4.6.2.stable** imports the project cleanly with `--headless --import`. The `.godot/` cache directory is generated on first run; `.gitignore` excludes it. `*.uid` and `*.import` files are tracked (Godot 4 UID requirement).

### 2c. Ink wrapper — ✅ committed (#3)

Locked decision: **Path A — inkjs via JS bridge (primary). Path C — native GDScript player (fallback).** Full rationale in `docs/INK_INTEGRATION.md`.

The narrative layer talks to a thin Godot wrapper, not to inkjs directly. Wrapper API:

- `bind_external(state_dict, ledger)` — sync the Ink runtime variables with the persistence layer
- `choose(choice_id)` — make a choice, returns next state
- `get_current_text()` — read what's on screen
- `apply_to_state(captain_obj)` — apply the latest flagged state changes

Compiled `ink.json` outputs live in `res://narrative/build/`, regenerated from `godot/narrative/beats/*.ink` sources on save. A Node auto-rebuilds on save.

### 2d. Persistence layer — ✅ done

Single `data/persist.json` per save slot.

Schema matches §1 *campaign state* from `docs/PERSISTENCE.md`. Lives in `godot/Assets/data/persist.json`.

Saves on:
- Run outcome (player ends current run)
- Each bond-shift
- Each ledger-decision-impact

Implementation:
- `Persist` singleton with `_init()`, `save()`, `load()`, `reset()`.
- JSON-encoded. Schema validated against `docs/PERSISTENCE.md` §1 shape.
- Mutex-locked reads/writes (GDScript doesn't have native mutex; we use a flag-based lock).

### 2e. Narrative-data shape — ✅ done

Three JSON files in `narrative/data/`:

- `narrative/data/captain-origins.json` — 6 genship × N countries matrix the player picks at run-start
- `narrative/data/npc-archetypes.json` — 6-8-variant generator per archetype
- `narrative/data/ledger.json` — persisted ledger of past captains, names, outcomes

**Zero lore in these files** — just structure. The Ink reads them as text-tables.

### 2f. Test harness — ✅ done

GUT (Godot Unit Test) — runs headless.

Tests to write:
- Captain origin locked to matrix
- Trait pool correctly drawn on archetype
- Cover-test rolls correctly against expected band
- Persist save/load round-trips
- Ink variables flow into persistence

A `scripts/test.sh` shell wrapper aggregating Godot CLI output.

### 2g. Sample playable run — ✅ done

**Phase 2's ONLY deliverable.** A single playable run.

Sequence:
1. Pick a genship origin (optional country fragment).
2. Pick an archetype (3 options).
3. Run the AI briefing (`run-start.ink`).
4. Meet 2 procedurally-generated crew.
5. Pick a destination on the overworld.
6. Arrive at a station, run a brief encounter, return.
7. End-of-run summary: Ledger entry.

**No combat. No cover-test fail arcs. No art beyond placeholder paper-blocks.**

Acceptance: Godot project builds + runs in headless; playthrough logs all 7 steps; ledger entry visible in persistence after run. Blocks phase 3+.

---

## Phase 3 — Encounter + Combat + Narrative Systems (shipped sub-phases tracked)

**Goal:** Wire the full run loop: overworld travel, mission board, encounter pool, CQB combat, genship origins, and voice corpus — all feeding through the narrative layer. Art stays paper-blocks throughout.

| Sub-phase | Title | Status |
|---|---|---|
| 3a | Overworld + travel system (hex belt, ship state, per-move clock) | **DONE** |
| 3b | *(skipped — merged into 3e)* | — |
| 3c | Mission board (offer generation, standing gates, continuation) | **DONE** |
| 3d | Encounter pool (schema + 30-entry expansion + NarrativeData loader) | **DONE** |
| 3e | CQB combat (grid + AI + Ink beats + casualty pipeline) | **DONE** |
| 3f | Genship origins (data expansion + runtime wiring) | **DONE** |
| 3g | Voice corpus split (`die_in_throes` + `captains_journal`, 50 each) | **DONE** |

Design lock: `docs/COMBAT.md` (CQB-first, space combat deferred). The narrative layer calls into combat through Ink beats; casualty outcomes write to ledger + journal.

**Modular:** if any subsystem doesn't pan out, it can be swapped without rewriting narrative logic (the narrative layer depends on data contracts, not implementations).

---

## Phase 4 — Paper art pass (draft)

**Goal:** Validate the paper-pipeline runs end-to-end *without* filling the whole game with art.

- **Sub-deliverable 4a:** 1 character concept (silhouette + 1 accent color)
- **Sub-deliverable 4b:** 1 background (1 parallax layer)
- **Sub-deliverable 4c:** 1 station interior frame

Test: drop into Godot at 1080p, paper-frame-rendered, no animation.

If this validates, we move on. If paper-pipeline ends up ugly / slow / mismatched with what we want, we surface the problem here and decide whether to keep the pipeline or change it.

---

## Phase 5 — Ship out

**Goal:** Public playability polish.

- 5a: build pipeline (Godot → web export)
- 5b: itch.io / self-host README
- 5c: opening pitch paragraph (re-uses VISION)

---

## Non-negotiables (carried from VISION)

These can flex on phasing, but not on outcome. Each is a deliverable that's expected *eventually*:

1. **Story before combat.** Combat must surface story beats.
2. **Class-disparity constant.** Every faction reveals it.
3. **Captain's imposter-secret is escalated-not-exposed.** Multi-run reveal.
4. **Procedural events reference the ledger.** Dead carried forward.

---

## Negotiables

We *can* defer these without breaking the project:

- Permadeath vs roster damage vs ironman (deferred until prototype feel)
- Tactical resolution mechanism (turn-based grid vs. real-time-with-pause) — phase 3 question
- Era narrowing or widening (we landed at ~80yrs; could go to 100)
- Whether the [G6-Coalition PLACEHOLDER] default trait pool can be excluded
- Save-data scope (full-persistence vs. summary-ledger-only)

---

## Open questions for the future

These are questions I want answered *before* they bite us later:

1. What is the player's name-or-pseudonym convention? Display? Caps?
2. Where is "the player" in the AI briefing? As a hand on a control? A pulled-up bunk? A standing figure?
3. How do we display ledger entries? Comma-separated noun list? Pop-up graphic?
4. Is there a class-passing visual cue? Does the player-avatar wear a mask-and-twist-of-character they're-conscious-of?
5. What's the 3rd archetype (Substitute Body)'s visible difference? — *tbd in rename pass*

(These don't block phase 2. They block phase 4 — paper art.)

---

## What *is* blocked

- Phase 3g (voice corpus): ready to build; no blockers.
- Phase 4: blocked on Phase 3 completion (3g remaining).
- Phase 5: blocked on Phase 4.

---

## When does a phase end?

A phase ends when:

1. The phase's deliverables are committed.
2. The phase's tests pass in headless dev environment.
3. The phase's contribution to a single-run experience is *playable*.

If a phase is *not* playable when it's "done," it isn't done — it's a deferred phase.

[End of ROADMAP.md v2.]
