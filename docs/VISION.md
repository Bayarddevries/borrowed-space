---
title: Borrowed Space — Vision
status: review
last_edited: 2026-06-22
tags:
  - vision
  - northstar
  - project
aliases:
  - VISION
  - Vision
phase: 1
related:
  - "[[_CONVENTIONS]]"
  - "[[WORLD_BIBLE]]"
  - "[[TRUSTEE_BACKSTORY]]"
  - "[[PERSISTENCE]]"
  - "[[HE3_INDUSTRY]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Borrowed Space — Vision

**Fleet:** 5+1 genships (5 full-size governmental flagships: NA, EU, Russia, Asia, Middle East + 1 sub-generation Coalition genship). Names placeholder until rename pass.

---

## What we're making

A 2.5D roguelike space RPG about *being promoted into uncertainty*. You play a freshly-selected captain of a small ship sailing the asteroid belt since ~80 years post-launch. Earth has collapsed ecologically — a collapse that the wealthy engineered, knowing they'd no longer control the surface as waters rose. They sabotaged allied governments' self-sustaining genship programs. They founded Mars He-3 mines two years before departure. He-3 is now the only viable fuel for genships, freighters, and most space vehicles — and the cartels that own the mines control humanity's continued flight.

A mysterious figure on the screens — **the Trustee** — selects captains like you from the genship lower decks. **The Trustee is the son of an oligarch,** one of several such defectors. He funds experimental programs; his network of captains is the first surface-visible defector project. The Trustee's identity is multi-run-discoverable. Each run, the player reveals one piece.

Every captain's run contributes to **breaking the He-3 monopoly** — piece by piece, discovery by discovery. Each captain leaves *permanent impact on the belt landscape.* Stations defended or destroyed stay that way. NPCs persist across runs with cumulative state. The He-3 system is a *machine,* and the machine can be brought down over time.

The ship's AI **briefs you on run-start.** The AI is the only entity that knows who you were before. It carries memory across runs. It references prior captains by name. It narrates prior captains as lessons.

You sail into the belt. You pick up crew — conscripts who don't know what you are. You survive diplomacy, combat, ship-board politics, and the cost of small injustices. You discover how the He-3 system is wired. **The AI remembers. The dismantling accumulates.**

---

## What this is *not*

- This is **not** a FTL clone. The combat is in service of story, not the inverse.
- This is **not** a power-fantasy. The captain is *fragile*.
- This is **not** an AI-art pipeline. Every frame is hand-drawn.
- This is **not** a faction-of-the-week game. We have a small cast of faction *roles* that we write into the world deeply.
- This is **not** one-pass storytelling. The He-3 conspiracy is **multi-run dismantling.**
- This is **not** an "oligarch haters" game. The Trustee is an oligarch's *son*. He *knows* the class he came from. The game is about people with resources choosing not to be their parents.

---

## Non-negotiables (read these when we lose the plot)

These are the four conditions that, if violated, mean the project went off-mission:

### 1. Story before combat
Combat exists to deliver story beats. Tactical depth is allowed — praising *challenging to play right* — but **a winning combat that returns no story content is a failure**. Conversely a losing combat that returns distributed story content is still a successful encounter.

### 2. Class-disparity is the captain's constant
Every faction, NPC, and encounter must make class-disparity visible *in some new way*. Factions that don't surface disparity get cut. The captain's imposter-secret is *only legible* against the texture of that disparity.

### 3. The He-3 conspiracy is dismantling, not collapsing
The conspiracy does not auto-destroy itself through player action. Each run contributes *one increment* of dismantling. The dismantling completes across many runs; it doesn't complete in one run. We don't write an "end of the world" beat.

**Expansion:** the imposter-secret was a v0 framing; in v1 the captain's relational arc is built around bond-coverage not imposter-defense. Cover-test results feed the dynamic exposure mechanic; mid-run exposure is consequence not penalty.

### 4. Procedural events reference the ledger across runs
Dead crew, past captains, prior-run betrayals — all get called *into* future encounters. A captain's first officer who fell in a previous run should come up by name in dispatch traffic, in crew dialogues, in memory-driven story branches.

---

## Negotiables (we can change these without breaking the project)

- Permadeath vs roster damage vs ironman (deferred until prototype feel)
- Tactical resolution mechanism (turn-based grid vs. real-time-with-pause)
- Number of in-run days vs. number of in-run missions
- Era narrowing or widening (we landed at ~80yrs)
- Whether the Coalition genship default trait pool can be excluded
- Save-data scope (full-persistence vs. summary-ledger-only)
- Whether the conspiracy arc ends with "dismantling" or "outright destruction"

---

## Inspirations (we are not copying any of these — we are *adjacent*)

| Inspiration | What we steal | What we don't |
|---|---|---|
| **Wildermyth** | Paper-pipeline, character-driven emergent narratives, time-advances-relationships, legacy of past runs | Not top-down tactical; not frame-by-frame moment-shots |
| **FTL** | Roguelike ship-management, encounter-card events, faction reputation, ledger-of-the-fallen | Not FTL's tactical pause-aligned combat |
| **Caves of Qud** | Worldbuilding density, banded canon, hidden-traits | Not text-parser-first; not decade-late saving |
| **XCOM** | Tactical grid combat, squad-of-few, permadeath possibility | Not base-management arc; not research-tree gating |
| **Banner Saga** | Choice-driven caravan mode, consequences of leadership | Not explicit narrative stanzas |
| **Mass Effect** | Crew-relationship topology, repeated-character callback | Not dialogue-wheel; not cinematic-camera |
| **Inkle (80 Days / Sorcery!)** | Procedural templating of narrative branches, vermillion-card state | Not text-parser; not single-branching linear |

---

## Tone and voice

The captain is *fragile.* Every encounter is a tension between *keeping the lie alive* and *doing the right thing*. Players feel the weight of small injustices. Combat is not "fun combat" — combat is "necessary combat." When the captain loses a crew member, that's not a setback; that's a *loss that lands in the ledger.*

The visual look: **hand-drawn paper-pipeline.** Frame-based, layered parallax paper backgrounds. The aesthetic is "graphic novel reading itself on screen." No animation, no rigs. Poses make the action.

---

## The team

- **Solo developer.** Founding author. Drawing skill, narrative instinct, system-design taste. Mornings for art, afternoons for code, evenings for writing.
- **AI co-pilot.** Agent system that holds world bible, runs scaffolding, drafts story arcs, audits for bias consistency, and gates code-only changes through the lock-plan-first workflow.

The AI agent's job is *to write the deliverable, not the report* — to ship playable content, not audits. The AI is responsible for bias-check on every draft; the developer retains veto.

---

## Collaboration contract (AI + Solo dev)

1. The AI never commits until the solo developer signs off on a draft.
2. The AI audits every draft for unintentional cultural bias before delivering.
3. The AI flags anti-stereotype risks during concept work, before they become entrenched.
4. The AI keeps world-bible versions in time-stamped docs/ subdirectories; older versions are kept, never deleted.
5. Capitalized terms and names are *placeholder* until the rename pass at end of phase 1.
6. Always consult the AI's memory for context before stating prior decisions; don't re-litigate locked content.
7. The developer counters respected, but the developer is the project's center. Their cultural voice is non-negotiable.

---

## What we are *not* doing first

We are not:
- Building tactical combat before the overworld exists.
- Building narrative before the trait system exists.
- Pinning story names until the rename pass lands.
- Naming the Trust member-factions until the rename pass lands.
- Calling the Trustee's family by name until mid-game reveal.

---

## North star (this is the line we read when we lose the plot)

> **A being-promoted-into-uncertainty roguelike with a multi-run dismantling arc, set in a He-3 monopoly estate built by oligarch-founded sabotage; the AI remembers; each captain is a single increment of dismantling; defiant oligarch defectors, conscripts-as-protagonists, and stations that endure.**

[End of VISION.md draft v2.]
