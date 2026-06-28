---
title: Borrowed Space — Phase 4 Plan
status: draft
last_edited: 2026-06-28
tags:
  - roadmap
  - phase-4
  - planning
aliases:
  - PHASE4_PLAN
phase: 4
related:
  - "[[ROADMAP]]"
  - "[[VISION]]"
  - "[[HANDOFF]]"
---

# Borrowed Space — Phase 4 Plan: The Visual Game

**Date:** 2026-06-28
**Based on:** Current Phase 3 codebase (112 tests, full narrative loop) + conversation with Bayard

## The North Star (updated from your words)

> Wildermyth in space. Paper cutout 2.5D aesthetic — cartoonish but gritty. Isometric hex map, ship travels tile-by-tile with encounters en route. Character-driven dialogue with recurring NPCs that remember you. Stations as hubs with bars, stores, missions. CQB combat and space combat as tactical layers on top. The AI remembers. The dismantling accumulates.

---

## 1. Art Spec Sheet — What You Draw & What Size

All sizes assume you're drawing on iPad in Fresco at **2× resolution** (around 300+ DPI). I'll scale them down for in-game use. The paper aesthetic should come through naturally in your style.

| Asset | Drawing Canvas (px) | In-Game Size (px) | Qty | Notes |
|---|---|---|---|---|
| **Hex tile** | 240×280 | 120×140 | 1 (tileable) | Isometric diamond. Can tint or overlay different colours for hex kinds (lane, deep_belt, derelict, anomaly, station). Paper texture, subtle crater/grit |
| **Ship sprite** (on map) | 192×128 | 96×64 | 1 | Isometric view. Corvette profile visible at map scale. Engine glow optional (can be particles in code) |
| **Character portrait** | 240×320 | 120×160 | ~15+ | Shoulders + head. Expressive face. Paper cutout with rough edges. NPCs: bartender, shopkeeper, T1 inspector, crew archetypes, etc. Player captain: same format |
| **Station hub BG** | 1400×800 | 1400×800 | 10 | Full-screen. Each station has a unique hub scene (interior/ exterior). Paper diorama style |
| **Station bar BG** | 1400×800 | 1400×800 | 2–3 | Reusable bar interiors. Warm lighting, paper textures |
| **Station store BG** | 1400×800 | 1400×800 | 2–3 | Reusable store interiors. Industrial, dim |
| **Encounter BG** | 1400×800 | 1400×800 | 3–5 | Space scenes for important encounters (bridge of a T1 cruiser, derelict interior, etc.) |
| **Travel space BG** | 1400×800 | 1400×800 | 1 | Starfield with streaks for fast-travel overlay |
| **UI dialogue panel** | — | — | 1 | Paper-textured bordered box, lower third of screen. I'll build this in Godot |

**What to draw first (my recommendation):**
1. Ship sprite — small, fast, validates the style
2. One hex tile — get the isometric angle right
3. One character portrait — test the cutout look
4. One station hub BG (pick your favourite station from the JSON: Kashner Iceworks, Corvallo Station, Coral...)

---

## 2. Phase 4 Build Order

### Phase 4a — Visual Hex Map (current)
*Replaces the ASCII hex with real tiles and ship movement.*

- [ ] Isometric hex rendering in Godot (`TileMapLayer` or individual `Sprite2D` nodes with hexagonal layout math)
- [ ] Pan/drag camera over the belt (Godot `Camera2D` with drag + zoom)
- [ ] Place station markers as clickable pins on their hexes
- [ ] Ship sprite appears on current hex
- [ ] Click a station → calculate path (A* or hex-line) → animate ship hex-by-hex toward destination
- [ ] **Per-hop encounter roll** — each hex crossed can fire an encounter from the pool
- [ ] **Crew dialogue during travel** — smaller encounters (crew chat, minor events, flavour text) that fire between major encounter checks
- [ ] Seamless return to existing encounter/choice UI when something triggers

### Phase 4b — Station Hub Screens
*Replaces the station.tscn placeholder with a real hub.*

- [ ] Docking → switch to station hub scene (station-specific BG)
- [ ] Hub buttons: Bar, Store, Missions, Depart
- [ ] **Bar** → bar BG + bartender portrait + dialogue tree (rumours, crew morale options, faction gossip)
- [ ] **Store** → shop BG + shopkeeper portrait + trade interface (buy/sell supplies, fuel, gear)
- [ ] **Missions** → mission board overlay (already exists as text, restyle for the hub)
- [ ] **Depart** → return to hex map at that station hex
- [ ] Each sub-screen: BG swaps, dialogue panel slides up

### Phase 4c — Dialogue System
*Replaces the prose+button encounter format with proper character dialogue.*

- [ ] **Dialogue panel** — slides up from bottom, takes lower ~40% of screen
  - Left: NPC portrait + name
  - Right: current NPC dialogue text (typewriter-style)
  - Bottom: player choices (conditionally shown)
  - Player portrait in bottom-left when it's our turn to speak
- [ ] **Full-screen takeover** mode — for important encounters, the dialogue panel expands to cover the whole screen, BG becomes the encounter location
- [ ] **Conditional branches** — options can check `captain.genship`, `suspicion`, `crew bond scores`, `standing[FACTION_ID]`, `visited_stations`, etc.
- [ ] **Dialogue beat format** — new JSON schema (separate from current encounter-prose format) with per-line speaker attribution, branching, conditions, and delta triggers

### Phase 4d — Recurring NPCs + Relationships
*Characters that persist across runs.*

- [ ] **Legend NPC table** in Persist: hardcoded NPCs (bartender at Coral, mechanic at Kashner, etc.) with per-run state (mood, relationship score, dialogue flags)
- [ ] **Crew survivors** — if crew survive a run, they can appear as hireable NPCs next run
- [ ] **Relationship tracking** — each NPC has a `score` (-10 to +10) that affects dialogue options, prices, mission offers
- [ ] **Memory system** — NPCs reference past interactions ("You again. Last time you left without paying.")

### Phase 4e — Crew Morale + Stats
*Systems layer for crew management.*

- [ ] **Morale stat** per crew member (0-100), affected by choices, rest, pay
- [ ] **Crew events en route** — dialogue encounters specific to crew composition
- [ ] **Consequences** — low morale → reduced combat effectiveness, desertion, mutiny chance

---

## 3. Dialogue System — Proposed Format

```json
{
  "id": "dialogue_kashner_bartender_first",
  "speaker": "bartender_kashner",
  "portrait": "portrait_bartender_kashner",
  "lines": [
    {
      "speaker": "bartender_kashner",
      "text": "New face. That's unusual. Most captains who dock here already know the tab.",
      "choices": [
        {"label": "\"What tab?\"", "next": "kashner_bar_explain"},
        {"label": "\"I'm just passing through. One drink.\"", "next": "kashner_bar_drink", "delta": {"fuel_delta": -3, "morale": 5}},
        {"label": "Ignore them and look at the mission board.", "next": "kashner_bar_ignore", "condition": {"captain.suspicion": {"<": 3}}}
      ]
    }
  ]
}
```

---

## 4. Hex Map — Technical Spec

- **Grid:** Axial (cube) hex coordinates, same system already in `hex.gd`
- **Tile size:** 120×140 px per isometric hex (tileable, colour-tinted by hex kind)
- **Viewport:** 1400×800 window, shows ~8–10 hexes visible at any zoom level
- **Sectors:** The belt divides into loose sectors. Each sector has modified encounter weights — deep belt has more discovery, lanes have more patrol, derelict zones have more combat encounters
- **Travel animation:** Ship sprite lerps along hex-path at ~0.5s per hex. Each hex arrival fires a chance roll for encounter/crew dialogue/nothing
- **Station pins:** Static `Sprite2D` on the station's hex, labelled with station name

---

## 5. What's unchanged (Phase 3 systems that survive as-is)

- Captain generation (6 genship origins)
- Crew procedural generation
- Encounter pool (44 entries, weighted selection)
- CQB combat (6×6 grid, cover, AI, casualty pipeline)
- Mission board (offer generation, standing-gated)
- Running summary / ledger
- Persist singleton

---

## 6. What we should build first

You said: *"If we had to ship tomorrow the space travel system, missions and dialogue systems would need to be working perfectly to create a text-based adventure."*

My recommended **first actionable step**: Phase 4a — Visual Hex Map. Here's why:
- It's the most visible "this is a game now" change
- You'll see your ship moving across paper hexes immediately
- Encounters + crew dialogue en route use the existing beat system
- Once the visual map exists, every other system (stations, dialogue, combat) has a *context* to plug into

But I'll build whatever you want to prioritize. Your call.
