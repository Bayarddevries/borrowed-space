---
title: Borrowed Space — Genship Origin Consequences
status: draft
last_edited: 2026-06-24
tags:
  - genship
  - origin
  - faction
  - starting-stats
  - narrative
  - relationship
aliases:
  - Genship Origin
  - Origin Consequences
  - Origin
phase: 2
related:
  - "[[WORLD_BIBLE]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[MISSION_BOARD]]"
  - "[[NPCS]]"
  - "[[BIAS_GUARDRAILS]]"
  - "[[ENCOUNTER_POOL]]"
---

# Genship Origin Consequences v0.1 — *Borrowed Space

**Purpose:** Define what the captain's genship of origin means mechanically — starting stats, faction relationships, unique content, and narrative flavor. Origin should matter throughout the entire run, not just at character creation.

---

## Design principle

The genship origin is the captain's **political identity**. It shapes:
- Who they grew up with (initial crew relationships)
- What they know (H-tier baseline)
- Who welcomes them and who is suspicious (faction standing)
- What missions they have access to (early opportunities)
- What unique content they encounter (narrative exclusives)

Origin should never be a hard lock. A NAC captain *can* work with the Coalition. But they start with friction, and it takes effort to overcome. The player's choices in the run should matter more than the origin — origin is a head start, not a destiny.

---

## Origin details

Per genship, the origin defines:

| Field | Effect | Resets between runs? |
|---|---|---|
| `h_tier_default` | Starting He-3 literacy (1–4) | Yes (each captain inherits from origin, not prior captain) |
| `starting_suspicion` | Initial suspicion in home faction | Yes |
| `starting_genship_standing` | Standing with own genship faction | Yes |
| `corp_relationships` | Default standing with 7 Trust corps | Yes |
| `first_ship_class` | Flagship tier (affects early mission access) | Yes (corps access tier) |
| `tag_pool` | Starting personality traits (sub-draw from pool) | Yes |
| `unique_content` | Unique narrative branch, NPC, or encounter | Per-run availability |
| `narrative_flavor` | AI dialog tone, NPC reactions, lore references | Yes |

### NAC — North America

| Field | Value |
|---|---|
| h_tier_default | 2 (mid-tier fuel awareness) |
| starting_suspicion | 1 (Trust payrolls — always watched) |
| starting_genship_standing | +3 (home faction) |
| corp_relationships | T5 (Actuary) +2, T1 (Helios) 0, T7 (Helion) -1 |
| first_ship_class | TIER-1 (standard flagship tier) |
| tag_pool | T-P-D "faster-than-the-question", T-P-K "numeric-as-truce", T-P-L "work-that-looks-hard" |
| unique_content | **"The Payroll Papers"** — an encounter chain where the captain discovers NA conscript mortality data filed by T5. Publishing it causes massive suspicion but unlocks Act 1 faster. Only available to NAC captains with H-tier ≥2. |
| narrative_flavor | NPCs address the captain as "payroll-grade." The AI notes that NA conscripts are tracked by T5 insurance systems. Cover-tests in T5 territory are slightly harder (the system knows their file). |

### ED — European Union

| Field | Value |
|---|---|
| h_tier_default | 2 (mid-tier, procedural awareness) |
| starting_suspicion | 1 (Trust sees EU as "manageable") |
| starting_genship_standing | +3 (home faction) |
| corp_relationships | T4 (SomaGenesis) +2, T3 (Kepler) +1, T2 (Voidline) -1 |
| first_ship_class | TIER-1 |
| tag_pool | T-P-E "re-stater", T-P-J "linguistic-tense", T-P-K "numeric-as-truce" |
| unique_content | **"The Rotation File"** — an encounter chain where the captain discovers which EU citizens were rotated through Trust-held positions. The data reveals a pattern of deliberate exposure to high-risk zones. Can be leveraged as blackmail material against T4. |
| narrative_flavor | NPCs reference EU procedure. The AI notes that EU citizens are "rotated" through duty cycles, so their trust network is broad but shallow. EU captains get a unique dialog option: "What's the procedure here?" in station encounters, which grants lore and sometimes bypasses cover-tests. |

### RRA — Russia

| Field | Value |
|---|---|
| h_tier_default | 3 (high-tier, knows the cartel structure from below) |
| starting_suspicion | 0 (Trust assumes military-order keeps conscripts in line) |
| starting_genship_standing | +3 (home faction) |
| corp_relationships | T6 (Forge & Frame) +2, T4 (SomaGenesis) -3, T7 (Helion) 0 |
| first_ship_class | TIER-1 |
| tag_pool | T-P-C "kin-of-the-near-failure", T-P-K "numeric-as-truce", T-P-H "discrete-on-purpose" |
| unique_content | **"The Flu Archive"** — an encounter chain where the captain finds genetic-experimentation records held by diaspora communities. The records reveal what T4 did. RRA captains start with H-tier 3, so the Ink layer recognizes their literacy and surfaces unique options in encounters referencing the pandemic. Exposing the records causes T4 standing to drop to hostile and triggers unique Act 2 content. |
| narrative_flavor | NPCs react to RRA captains with visible class tension (officers expect deference, conscripts expect solidarity). The AI notes that RRA conscripts carry "the flu" in their collective memory — NPCs from other genships may react with fear or suspicion when they learn the captain is from RRA. |

### AC — Asia Coalition

| Field | Value |
|---|---|
| h_tier_default | 2 (mid-tier, logistics awareness) |
| starting_suspicion | 1 (Trust monitors unionized workforce) |
| starting_genship_standing | +3 (home faction) |
| corp_relationships | T2 (Voidline) +2, T6 (Forge & Frame) +1, T3 (Kepler) 0 |
| first_ship_class | TIER-1 |
| tag_pool | T-P-A "place-pattern-reader", T-P-D "faster-than-the-question", T-P-F "over-worker" |
| unique_content | **"The Freight Manifest"** — an encounter chain where the captain discovers that T2 shipping routes are used to transport more than He-3 — they move personnel and intelligence under cargo manifests. The captain can intercept, redirect, or expose these transports. Interfering with T2 routes is a primary path to Act 1 unlock. |
| narrative_flavor | NPCs reference union contracts. The AI notes that AC conscripts are "hours documented as 1x, reality 2x" — AC captains have a unique dialog option: "Who's off the clock?" in station encounters, which reveals hidden labor and unlocks intelligence-gathering opportunities. |

### SAA — South Atlantic Accord (Coalition)

| Field | Value |
|---|---|
| h_tier_default | 3 (high-tier, food scarcity breeds awareness) |
| starting_suspicion | 0 (Trust overlooks "half-size" ship) |
| starting_genship_standing | +3 (home faction — tight-knit) |
| corp_relationships | T1 (Helios) -1, T2 (Voidline) +1, T3 (Kepler) -2 |
| first_ship_class | TIER-COAL (smaller, faster, more scrappy) |
| tag_pool | T-P-A "place-pattern-reader", T-P-C "kin-of-the-near-failure", T-P-I "quiet-mountain" |
| unique_content | **"The Overlooked Network"** — an encounter chain unique to SAA captains. Because the Coalition is "half-size" and overlooked, SAA stations have become informal intelligence hubs. The captain discovers a network of Coalition smugglers, informants, and mediators who operate between factions. This network is a unique resource — it provides early access to dismantling opportunities without standing requirements. However, relying on it increases the chance of betrayal (the network is not monolithic; some members sell information to the Trust). |
| narrative_flavor | NPCs underestimate the captain. The AI notes that SAA is "the best-positioned to smuggle" and "the Trustee's captain pool often draws from here." SAA captains cover-tests are *easier* in most stations (NPCs assume they're harmless), but harder in Trust-controlled stations (if suspicion is raised, the scrutiny is intense — "a Coalition captain, *here*?"). |

### ME — Middle East

| Field | Value |
|---|---|
| h_tier_default | 2 (mid-tier, engineering awareness) |
| starting_suspicion | 1 (Trust sees accelerated program as "less safe") |
| starting_genship_standing | +3 (home faction — high-density community) |
| corp_relationships | T6 (Forge & Frame) +1, T4 (SomaGenesis) 0, T5 (Actuary) +1 |
| first_ship_class | TIER-1 |
| tag_pool | T-P-B "outsider-credible", T-P-E "re-stater", T-P-G "second-thought-fanatic" |
| unique_content | **"The Station Architects"** — an encounter chain where the captain learns that ME engineers designed several belt stations. These engineers embedded hidden spaces, shortcuts, and structural weaknesses into the stations — intentional design choices that can be exploited. ME captains gain unique access to station areas that other captains cannot reach (maintenance shafts, hidden rooms, structural weak points for sabotage). |
| narrative_flavor | NPCs react to the captain's "hospitality + architectural ritual" identity. The AI notes that ME stations are "built with design, not crammed by necessity" — ME captains get unique dialog in station encounters referencing architectural knowledge ("This station was built by my people. I know the spaces between the walls."). Cover-tests in ME stations are easier (cultural kinship). |

---

## Origin selection at run-start

The player picks:
1. **Genship** (NAC, ED, RRA, AC, SAA, ME)
2. **Country/heritage fragment** (2 options per genship — see `narrative/data/captain-origins.json`)
3. **Archetype** (A, B, or C — see WORLD_BIBLE.md Captain Generation)

These choices set the starting state. Everything else — faction standing, trait draws, H-tier progression, crew generation — flows from these picks.

The **country fragment** affects:
- `h_tier_default` (some fragments grant +1)
- `starting_suspicion` (some fragments start hotter)
- Starting personality trait (one of the 3 T-slots is pre-filled from the fragment's `tag_pool`)

---

## Cross-origin dynamics

### Crew generation bias
The first two crewmates are drawn from the captain's genship pool by default. The player can override this (asking for an outsider), but the default is "you grew up with these people."

### Faction mission availability
- Home faction missions are always available
- Rival faction missions (negative starting standing) require higher standing to unlock, but pay more (risk premium)
- Neutral faction missions are unaffected

### Origin-exclusive content
Each genship has one encounter chain that **only** captains from that origin can access. These chains are not locked *out* for other captains — they simply don't appear in the encounter pool. An NAC captain will never see "The Station Architects" unless they meet an ME NPC who shares the knowledge.

### Origin-blending through crew
If the captain recruits crew from other genships (possible mid-run), those crew members unlock dialog options and mission leads from their home faction. The player can access origin-exclusive content indirectly through crew relationships.

---

## Decay and accumulation

Origin resets between runs — each captain starts fresh with their genship's defaults. However:

- **Dismantling progress** accumulates regardless of origin. A NAC captain's Act 3 discovery carries over when the next captain is from ED.
- **Narrative memory** accumulates — the AI references prior captains and their origins. "The last three captains were from the Coalition. The Trust is watching SAA more closely now."
- **Cosmetic relics** accumulate — the ship carries traces of previous captains regardless of origin.

---

## What this doc does NOT cover (deferred)

- **Fragment-specific trait text** — the actual personality fragment descriptions for each country. Phase 2g content work.
- **Origin-exclusive encounter writing** — the actual writing of "The Payroll Papers," "The Flu Archive," etc. Phase 2g content work.
- **Trait pool generation rules** — how the 3 T-traits are drawn from the pool. Phase 2g detail work.
- **Origin UI** — how the player selects origin at run-start. Phase 3 design.

---

[End of GENSHIP ORIGIN CONSEQUENCES v0.1 draft.]
