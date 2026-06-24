---
title: Borrowed Space — Mission Board & Faction Missions
status: draft
last_edited: 2026-06-24
tags:
  - mission
  - faction
  - corporation
  - trust
  - work
  - credits
  - dismantling
aliases:
  - Mission Board
  - Missions
  - Faction Missions
phase: 2
related:
  - "[[VISION]]"
  - "[[ROADMAP]]"
  - "[[HE3_INDUSTRY]]"
  - "[[WORLD_BIBLE]]"
  - "[[GAMEPLAY_LOOP]]"
  - "[[NPCS]]"
  - "[[BIAS_GUARDRAILS]]"
---

# Mission Board & Faction Missions v0.1 — *Borrowed Space*

**Purpose:** Define the content engine that fills the belt run — who offers work, what missions exist, how they generate, and how they connect to the dismantling arc.

---

## Mission philosophy

Missions are **not** the point of the game. The point is dismantling the Trust and the relationships the captain builds along the way. Missions are the *vehicle* — they put the captain in places where encounters, discoveries, and crew moments happen.

A good mission is never just "go here, do this." It's "go here, do this, and something unexpected happens that forces a choice."

---

## Who offers work

Missions come from **four sources**:

### 1. Trust Corporations (7 families, each with a corporate front)

Each of the 7 Trust families owns a public-facing corporation. These corps hire captains for legitimate work — but the work can be exploited for dismantling.

| Trust Family | Corporation Name | Public Face | He-3 Role |
|---|---|---|---|
| T1 — Resource consortium | **Helios Extraction** | Mining operations, asteroid patents | Owns Mars mine concessions |
| T2 — Shipping alliance | **Voidline Logistics** | Freight, cargo routes, haulage | Contracts He-3 freight |
| T3 — Habitat administration | **Kepler Settlements** | Luna + Mars colony services | Decides who lives on Mars |
| T4 — Biotech / medicine | **SomaGenesis** | Medicine, agricultural research | Signed genetic-program docs |
| T5 — Finance / insurance | **Actuary Capital** | Payroll, debt, insurance | Owns conscript payrolls |
| T6 — Heavy industry | **Forge & Frame** | Ship-building, recycling, alloys | Owns the shipyards |
| T7 — Energy | **Helion Systems** | He-3 processing, fuel logistics | The core cartel |

**How corps present themselves:**
- Each corp has a public reputation (what the belt believes about them) and a private reality (what the captain discovers through missions).
- Corps are not faceless — they have named NPC handlers, corporate culture, and recurring mission types.
- Taking missions from a corp builds **standing** with that corp. High standing unlocks better jobs, access to restricted areas, and information. Low standing means the corp stops offering work.

### 2. Genships (5+1 factions)

Each genship government offers missions reflecting their political interests and internal needs.

| Genship | Mission types | What they want |
|---|---|---|
| NAC (North America) | Patrol, anti-piracy, escort | Maintain order, protect trade routes |
| ED (EU) | Diplomatic courier, inspection, mediation | Stability, fairness, procedure |
| RRA (Russia) | Convoy escort, resource security, enforcement | Order, discipline, survival |
| AC (Asia) | Freight support, logistics, trade corridor security | Commerce, union contracts |
| SAA (Coalition) | Agricultural supply runs, smuggling, intelligence | Survival, food independence, being overlooked |
| ME (Middle East) | Engineering contracts, station maintenance, cultural exchange | Community, ritual, engineering pride |

**Genship missions** tend to be more politically charged. Taking a mission from one genship may affect standing with another (e.g., escorting a Coalition food ship may reduce standing with T1, who wants Coalition agriculture to fail).

### 3. Private contracts (independent stations, NPCs, belt factions)

Independent operators post jobs on the mission board or offer them through dialog:

- **Independent stations** — repair, refuel, trade missions.
- **Belt factions** (B1-Operators, B2-Salvage, B3-Lineage) — see WORLD_BIBLE.md. Each has their own agenda.
- **NPCs** — crew members may have personal quests that function as private missions.

Private contracts pay better than corp work but offer no standing benefit. They're one-off jobs.

### 4. Trustee missions (hidden, rare)

The Trustee occasionally sends missions directly through the AI. These are not posted on the board — the AI whispers them to the captain mid-run.

Trustee missions always advance the dismantling arc. Examples:
- "A T5 clerk is filing insurance claims for conscripts who died. Their office is on [station]. Copy the ledger."
- "A T1 geologist found a hidden deposit. They haven't reported it yet. Get there first."

Trustee missions are rare (1–3 per run) and always involve risk/reward tradeoffs. They may require the blessing to access.

---

## Mission structure

### Mission flow

1. **Accept** — via mission board on ship, dialog with NPC, or AI whisper.
2. **Brief** — over ship comms or in-person. The briefing sets expectations: "Go to [station], deliver [cargo], get paid [credits]." The briefing is intentionally incomplete — it doesn't mention the complication.
3. **Travel** — player navigates to the destination. Random events may occur during travel.
4. **Execute** — at the destination, the mission unfolds. Something unexpected happens. The player makes choices.
5. **Resolve** — mission outcome. Success, failure, or partial success with consequences.
6. **Report** — return to the mission-giver (or not — the player can keep the reward and ghost them, with standing consequences).

### Mission template

Every mission has:

| Field | Description |
|---|---|
| **Giver** | Who offered it (corp, genship, NPC, Trustee) |
| **Objective** | What the briefing says to do |
| **Complication** | What actually happens (not in briefing) |
| **Reward** | Credits, standing, item, information |
| **Dismantling hook** | How this mission can advance the dismantling arc |
| **Risk** | What can go wrong (suspicion, combat, crew loss) |

---

## Mission types

### Mining (T1, T2, independent)

**Surface:** Extract resources from an asteroid or Mars surface.
**Complication examples:**
- The mining site is on a hidden He-3 deposit. Mapping it advances Act 3.
- Conscripts are being abused. The captain can report it (standing with T1 drops, standing with Coalition rises) or look the other way.
- The mining equipment is faulty — sabotage or neglect?

**Dismantling hook:** Mining missions can reveal hidden deposits, expose labor abuses, or provide access to T1 internal communications.

### Combat (all factions, private contracts)

**Surface:** Fight off pirates, escort a convoy, clear a derelict, defend a station.
**Complication examples:**
- The "pirates" are Coalition smugglers. Fighting them hurts the Coalition. Letting them go risks suspicion.
- The convoy is carrying conscript laborers. The captain can free them (standing with corps drops, dismantling progress increases).
- The derelict ship has a survivor — a T4 scientist with genetic-program data.

**Dismantling hook:** Combat missions can capture enemy officers (interrogation = lore), seize Trust documents, or liberate laborers.

### Exploration (T3, T4, private)

**Surface:** Map an uncharted zone, investigate a signal, scout a new station.
**Complication examples:**
- The signal is a distress call from a hidden Coalition settlement. Revealing it to T3 may get it shut down.
- The uncharted zone has a pre-launch artifact — evidence of the sabotage program (Act 2 unlock).
- The new station is controlled by B2-Salvage. They don't want visitors.

**Dismantling hook:** Exploration missions are the primary way to unlock discovery acts and find evidence of the sabotage program.

### Data/Intelligence (T5, T7, Trustee)

**Surface:** Steal records, hack a terminal, intercept a transmission, copy a ledger.
**Complication examples:**
- The records contain conscript mortality data. Publishing it raises suspicion massively but advances the dismantling.
- The terminal is in a high-security area. The blessing can bypass it — but the blessing is one-use.
- The transmission reveals a Trust family conflict (T1 is fractious). Exploiting it may crack the cartel.

**Dismantling hook:** Intelligence missions are the most direct path to dismantling progress. They're also the most dangerous.

### Diplomacy/Social (genships, NPCs)

**Surface:** Negotiate a dispute, mediate between factions, deliver a message, recruit an informant.
**Complication examples:**
- The dispute is between a corp and a genship. Siding with one damages the other.
- The message reveals that a crew member is a Trust informant. The captain must decide what to do.
- The informant wants protection in exchange for data. Can the captain deliver?

**Dismantling hook:** Diplomatic missions build faction relationships that unlock later opportunities. They also surface information about the Trustee's identity.

### Freight/Logistics (T2, T6, AC)

**Surface:** Deliver cargo, repair a station, refuel a ship, transport passengers.
**Complication examples:**
- The cargo is mislabeled — it's actually weapons for a Trust militia. Refusing the job raises suspicion. Accepting it arms the enemy.
- The station being repaired is a T3 habitat station. The repair reveals conscript living conditions.
- The passenger is a defector. T2 wants them back.

**Dismantling hook:** Logistics missions move the captain through the belt and expose them to conditions they wouldn't otherwise see. They're worldbuilding delivery mechanisms.

---

## Dismantling through missions

The dismantling arc is not a separate mission category — it's a **layer that sits on top of every mission type**. Any mission can become a dismantling opportunity if the player chooses to exploit it.

### How it works

Every mission has a **surface objective** (what the briefing says) and a **hidden opportunity** (what the captain can discover or choose). The hidden opportunity is never announced — the player finds it through dialog choices, exploration, or trait-triggered options.

**Example — Mining mission for Helios Extraction (T1):**

| Layer | Content |
|---|---|
| **Briefing** | "Extract 50 tons of ore from asteroid X-7. Payment: 200 credits." |
| **Surface** | Mine the ore. Random event: equipment malfunctions. Repair it. Complete the job. |
| **Hidden opportunity** | While mining, the captain's H-tier or trait triggers: "The ore composition is wrong. This isn't a standard deposit — it's a hidden He-3 vein." |
| **Player choice** | (a) Report it to T1 — standing with T1 increases, no dismantling progress. (b) Map it secretly — dismantling Act 3 advances, suspicion +2 if discovered. (c) Tell the Coalition — standing with Coalition increases, T1 standing drops. |

This layering means the player can play "straight" (just do the job, earn credits) or engage with the dismantling (exploit every opportunity, risk suspicion). Both are valid play styles.

### Dismantling progress triggers

| Discovery Act | How missions unlock it |
|---|---|
| **Act 1: Cartel structure mapped** | Intelligence missions (T5, T5), social missions with NPCs who know the structure |
| **Act 2: Sabotage programs found** | Exploration missions (finding pre-launch artifacts), intelligence missions (T4 genetic-program docs) |
| **Act 3: Hidden deposits mapped** | Mining missions (T1), exploration missions (scouting) |
| **Act 4: Alternative cartography** | Exploration missions (mapping alternative fuel sources), Trustee missions |
| **Act 5: Trustee's final project** | Requires Acts 1–4 + specific Trustee mission chain |

---

## Standing system

Standing tracks the captain's relationship with each faction. It affects:

- **Mission availability** — higher standing = more jobs offered
- **Station access** — some stations require minimum standing with the controlling faction
- **Cover-test difficulty** — high standing with a faction makes cover-tests easier in their territory
- **Prices** — high standing = better prices at faction-controlled stations

Standing ranges: **-5 (hostile) to +5 (trusted)**. Most start at 0.

| Standing | Effect |
|---|---|
| -5 to -3 | Faction actively hostile. Attacked on sight in their territory. |
| -2 to -1 | Unwelcome. No missions. Cover-tests harder. |
| 0 | Neutral. Standard missions available. |
| +1 to +2 | Friendly. Better missions, easier cover-tests. |
| +3 to +4 | Trusted. Restricted missions unlocked, best prices. |
| +5 | Deep cover. Access to internal faction politics. High suspicion risk if discovered. |

**Standing changes are one-directional per mission.** A mission may raise standing with one faction and lower it with another. The player always sees the consequence before committing.

---

## Mission generation

Missions are **procedurally generated** from templates, with variation from:

- **Faction controller** — who offers the job
- **Station type** — mining station offers mining jobs, etc.
- **Current belt state** — a station under siege offers defense jobs
- **Captain's H-tier** — higher H-tier unlocks intelligence missions
- **Captain's standing** — higher standing unlocks better jobs
- **Dismantling progress** — later acts unlock Trustee missions and faction-conflict missions

The mission board refreshes:
- When the captain returns to the ship after a station visit
- When the captain travels to a new sector
- Periodically (every 10 minutes of play)

---

## Dialog missions

Not all missions come from the board. Some are offered through **dialog** when the captain talks to NPCs:

- A crew member says: "I heard T2 is hiring escorts. My cousin works at [station]."
- A station civilian whispers: "If you're looking for off-books work, talk to [NPC] in the back room."
- An AI prompt: "I've intercepted a T5 transmission. They're looking for a captain to handle a... delicate delivery."

Dialog missions are how the player discovers work that isn't publicly posted. They reward exploration and crew conversation.

---

## Credits and economy

Credits are the **in-run currency**. They pay for:

- Fuel
- Repairs
- Ship upgrades (cosmetic + minor functional)
- Station services (medical, supplies)
- Bribes (suspicion reduction)

Credits **do not carry between runs**. Each run starts with a small stake (enough for fuel + one repair). The player earns more through missions.

There is **no meta-currency**. The only cross-run progression is the dismantling arc, cosmetic awards, and ledger entries.

---

## Cross-run mission continuity

Missions are not isolated. The campaign remembers partial progress. Future captains inherit what previous captains started.

### Continuation rules

Any mission can be continued if:
- **High-tier operations** — always salvageable if partially completed. The next captain sees a "CLEANUP JOB" variant with lower standing requirements.
- **Any mission with recoverable gain** — if the captain obtained pass codes, key intel, or damaged critical systems before dying, the next captain inherits that progress.

### Decay

Mission progress decays slowly over runs if nobody continues the work:
- **Rate:** ~5-10% decay per run. Enemies repopulate, fortifications rebuild.
- **Scaling:** Well-resourced Trust factions rebuild faster (~10% per run). Fractured factions rebuild slower (~5% per run).
- **Reset threshold:** If progress decays to 0%, the mission resets to "fresh" status and can be re-accepted from scratch.
- **Notification:** The AI informs the captain of decay when they check the mission board ("The X-7 operation has deteriorated. Progress: 60%.").

### Multi-stage operations

High-tier operations often span multiple runs:

| Stage | Captain | What they did | What carries forward |
|---|---|---|---|
| 1 | Captain 47 | Infiltrated T5 station, obtained pass codes | Pass codes in ledger |
| 2 | Captain 48 | Used pass codes, copied ledger data | Intel on Trust financial structure (Act 1 unlock) |
| 3 | Captain 49 | Defended the data from retaliation | Dismantling Act 1 progress + standing shifts |
| 4 | Captain 50 | Exposed the data to the belt | Act 2 unlock, faction relationship shifts |

Each stage completes a piece and advances the campaign. The next captain sees the current stage and what's been done.

### Emotional framing

This system embodies the game's theme: resistance through sacrifice. The player isn't trying to win in one run. They're trying to contribute. A captain who dies having obtained pass codes has *succeeded* — they moved the campaign forward. The next captain finishes what they started.

The AI references this in dialog:
- "Captain 47 found the deposit. They didn't live to see it mapped. You have their notes."
- "Thirty captains have tried to crack the T5 ledger. Thirty-one if you count Captain 49 who got in but didn't make it out. The door is unlocked. The terminal is still warm."
- "You are not the first. You will not be the last. But you are the one who is here now."

### Death as sacrifice, not failure

Death is not failure. It is a natural part of the resistance. The player is not rewarded for surviving — they are rewarded for **advancing the campaign**. Survival is desirable because it means the player can continue contributing, but dying after a critical breakthrough is still a victory.

The cosmetic awards between runs are **relics** — not rewards for success, but tokens of memory. The next captain finds a nameplate, a note, a photograph. These are what remains of the ones who came before.

---

[End of MISSION BOARD & FACTION MISSIONS v0.1 draft.]
