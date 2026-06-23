---
title: Borrowed Space — NPC System
status: review
last_edited: 2026-06-22
tags:
  - npc
  - trustee
  - ai
  - captain-gen
  - faction
aliases:
  - NPCS
  - NPC System
phase: 1
related:
  - "[[VISION]]"
  - "[[WORLD_BIBLE]]"
  - "[[TRAITS]]"
  - "[[PERSISTENCE]]"
  - "[[TRUSTEE_BACKSTORY]]"
  - "[[BIAS_GUARDRAILS]]"
  - "[[ROADMAP]]"
---

# NPC System v1 — *Borrowed Space*

---

## Recurring NPC slots

### [NPC-T: The Trustee]

**Status:** Persistent across runs. Plays only on screens — never physically present.

**Voice:** Oligarch-arch, sober, controlled, *deliberate.* Knows formal language. Speaks in long sentences occasionally broken by silence.

**Role in game flow:** He selects captains. He briefs *the AI* before each captain's run. In rare cases (small coin-flip per run), the Trustee contacts the captain *through* the AI during the run — for advice, warning, or to draw a hard boundary. He does not intervene directly.

**What he is, what he isn't:**

- He is an **oligarch's son** who chose to *not* keep the oligarchic order.
- He is **not** a hero. He is *one such son* across many oligarch families.
- He is **not** the conspiracy. The conspiracy is *systemic* — oligarchies coordinating across species. The Trustee is *a defector within the coordinating network.*
- He is **not** the only such person. Players hear from **many** oligarch sons across dispatches. The Trustee's identity is *distinguishable* by his actions (he funds captains). Ask me: the Trustee is one such son — but his identity, his family, his relationship to the others is the multi-run puzzle.

**Discovered/undiscovered over time:**

- Run 1: the player knows there's *a* figure coordinating the captains, referred to as *the Trustee.* The player does not know who.
- Mid camp: trustee fragments — names of families, suspected identities, *family-that-defected* rumors.
- Late camp: at least one captain catches the Trustee on screen. They are recorded; the AI stores the recording.
- The Trustee's full identity and family-tree is **the entire cross-run unlock arc.** Each unlock changes how the player reads earlier clues.

### [NPC-AI: The Ship-AI] — the constant across runs

**Status:** Persistent. Knows every captain's story. Plays in dialogue *and* speaks in narration.

**Voice:** Philosophical-butler. Long sentences occasionally broken by silence. Argle with ethics.

**Role in game flow:**

- **Run-start:** briefs the captain (see SIT-START-* in INK_BEATS.md).
- **During run:** narrates events, references ledger of prior captains, gives tender advice as-needed.
- **Between runs:** holds the meta-state. The AI is *the only entity that knows who the captain was before briefing.* The AI doesn't leak.

**Memory:**

- Remembers every captain by name and number.
- References prior captains when relevant. ("Captain 47 found this station before you. They left a note.")
- Tracks *what discoveries have been made* in the dismantling arc.
- The AI carries **the load of meta-state.**

**Personality:**

- The AI can *withdraw endorsement* if the captain betrays the Trustee's experiment.
- The AI can *increase endorsement* over time. The endorsement level affects which late-game options are visible.
- The AI has *its own* opinions. The captain can argue with it.

**Variant pool:**

The AI is essentially *fixed* across runs — it's the same AI, since the same Trustee sponsors all the ships. But across many runs the AI's tone *matures:* run 1 the AI is precise-but-shy. Run 30 the AI knows more, references more, drives cleaner narrative.

### [NPC1: The Sherpa] — first-trust archetype

**Status:** Generated per-run, but drawn from a fixed archetype pool of 6–8 figures. NPC1-1, NPC1-2, etc. Each one knows the captain's genship-of-origin (different for each).

**Voice:** Protectively paternalistic. *Worker-class idiom.* Talk of money, talk of family, careful choice of subject — domesticity as cover.

**Question to the captain:** *"What was your first act of mercy?"*

**Mechanical role:**
- First NPC the captain reasonably meets.
- Anchors the first-trust story arc.
- Acts as ground-state for crew relationships.

**NPC1 variant pool:**
- Each Sherpa knows a different genship lore.
- Each Sherpa carries a different secret-history.
- Each Sherpa's *first-act-of-mercy question* unfolds differently.

### [NPC2: The Engineer] — mid-run truth-extension archetype

**Status:** Generated per-run. 6–8 variant figures.

**Voice:** Observant. Sparse. Knows what quiet costs. Trade cadence.

**Question to the captain:** *"What do you want from the rest of your life?"*

**Mechanical role:**
- Second NPC. Mid-run anchor.
- Drives the expansion arc — the captain learns the belt is bigger than their deception.
- This NPC codes trust through *seeing the captain decide.*

**NPC2 variant pool:**
- Each Engineer has a different skill-set and a different conservation-arc.

### [NPC3: The Gatekeeper] — late-run reveal archetype

**Status:** Generated per-run. 6–8 variant figures.

**Voice:** Measured. Same bloc, same accent.

**Question to the captain:** *"Are you sure no one else is counting on you?"*

**Mechanical role:**
- Third NPC. Late-run anchor.
- Already knows. Sometimes about the captain's bonded-flag, sometimes about something the captain's doing that they're not.
- The reveal arc NPC. Confrontation can go safe-or-tragic.

---

## Legacy, ledger, and recap layer

### The Ledger

A persisted record across runs, kept *by the AI.* The Ledger lists:

- Crew from all runs (name, archetype variant, run, outcome).
- Generators assigned, discoveries made, casualties taken.
- The Trustee's collected communications.
- He-3 dismantling progress — what unlocks have been triggered.

### Why NPCs persist across runs (and how)

Each NPC has a state vector:

- Personality fragment profile.
- Run-history: which captains they met.
- Held-trust: how much they're willing to extend.
- Currently-known: what they currently know about the player.

NPCs *shift state* across runs based on what previous player-captains revealed to them. They do not *evolve daily* — they emerge into new runs with their state already mutated. Across 20 runs, a Sherpa can *be different,* shaped by the cumulative weight of what prior captains told them.

*Example:* if Captain 47 confides in Sherpa "I'm from [genship X]," Sherpa's run-record carries that. If Captain 49 meets the same Sherpa (different genship assignment), Sherpa *has emotional history* even though it's their first meeting. Sherpa can carry "I'm tired" because of what they've heard.

### Why NPC daily-simulation is *off*

Daily-simulation isn't necessary; it adds engineering and design cost without visible creative benefit. The player meets NPCs at *dramatic moments,* when state matters more than tick-by-tick narrative. The *state* matters; the *day* doesn't.

---

## Captain-facing NPC mechanics

### Bond mechanic

Each NPC has a **bond score** per-run. *Persistent across runs* in the sense that "we already know each other" persists, but the *bond score* is reset each run (the new captain has to rebuild).

The bond score is affected by:
- Word choices in conversation.
- Idle crew events that pair the captain with the NPC.
- Combat outcomes.
- Decisions the captain makes *about* the NPC or near the NPC.

### Exposure mechanic — dynamic

When the captain's *bond-cover* is broken (mid-run reveal), the resulting conversation tree depends on the **current bond scores with all crew** plus the captain's situational enlightenment. The AI's role here is interesting: it can *withdraw endorsement* if exposure happens in a way that discredits the Trustee's experiment.

**Outcomes by bond slice:**

| Bond state | Outcome |
|---|---|
| Low bonds | High betrayal risk. Captain may be detained, captured, or deposed. Late-game-fixable but costly. |
| Moderate bonds | Ambiguity. Some crew stand by, some report. |
| High bonds | Crew embraces alternative identity. The captain's *new* story is the rest of the run. |
| Mature bonds | The crew already knew. They were waiting. (Some arc only.) |

This is the dynamic. **Exposure is not penalty; it is consequence.** It changes the rest of the run, including its ending.

### Crew procedural generation

Each run the player receives two starting crewmates drawn from a pool:

- Archetype pool of 5–7 (engineer, navigator, medic, scout, etc.)
- Personality fragments drawn from trait pool
- Procedural name + procedural backstory
- Held-trust: starting vector

These two crew *anchor the run.* More crew come and go during the run.

---

## The Trustee cross-run reveal arc

### The information bits

Each run yields a bit of the Trustee's full identity:

- Run 1: "Selected by *the Trustee.*"
- Run 4: "The Trustee is one of oligarch sons."
- Run 7: "The Trustee is one of 7 founding families."
- Run 9: "The Trustee's family is *TBD placeholder.*"
- Run 12: "The Trustee's father deployed the helium sabotage program."
- Run 19: "The Trustee is in direct opposition to one specific oligarch sibling."
- Run 26: "The Trustee's name is *TBD placeholder.*"
- Run 30+: "The Trustee's full life-story is recoverable."

### Why this matters in 2026 synth story terms

The Trustee arc is a *multi-run plot loop.* It keeps the player returning. It rewards context accumulation. It collapses into a *third-act reveal* that re-writes earlier context.

[End of NPC.md draft v1.]
