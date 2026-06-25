# Combat — Plan Lock (Session 2026-06-24)

## Goals

Build the **CQB grid layer** as the first playable combat module. Skip space combat (defer to Phase 3f). Build CQB because:

1. It's where crew deaths happen — the core roguelike emotional beat (Wildermyth's "*I remember that character*").
2. Ledger persistence already supports casualty writes (Phase 2).
3. The fold mechanic + trait-driven dialog already point at it.
4. Space combat is "2-3 decisions / resolved quickly" per VISION.md — deferring it means we avoid designing two systems at once.

This is a **plan-only session**. No code before Bayard signs off.

---

## Scope of this phase (Phase 3e)

1. **CQB grid runtime.** 5×5 (or 6×6) grid, ~2-3 crew vs. 2-4 enemies, cover tiles, line-of-sight, action economy.
2. **Damage / casualty pipeline.** Crew HP → 0 = casualty. Casualty writes a ledger entry (`died_at_run`, `died_in_battle`, tribute cite).
3. **Outcome → narrative bridge.** Combat result (won/lost/fled/casualty) returns to Ink beat with state vars (`cqb_outcome`, `casualty_count`, `cqb_turns`).
4. **Cover-test dialog layer.** The "passes the gate without escalation" pre-combat check. Failure routes into CQB or detention.
5. **Trait/fold integration.** T-traits fold mid-combat if suspicion > 3 (the trickiest piece — needs design sign-off).

**Not in scope (deferred):**
- Space combat (Phase 3f)
- Soldier class progression
- Skill tree / leveling mid-run
- AI personalities per enemy archetype
- Multi-floor station assaults (out for v0)

---

## Design Decisions to Lock

### D1. Grid shape

**Proposal: 5×5 axial-ish grid.** Two reasons:
- 5×5 = 25 tiles, fits one screen on a 720p viewport without scrolling.
- CQB fights are **2-3 crew vs 2-4 aliens** — fewer than 6 actors. 5×5 is plenty.
- XCOM Squad-size is 4 vs 4 — *wider* grid. We want Wildermyth's tighter "scarce-tiles" feeling where positioning *matters*. 5×5 forces cover to matter.

Open: **5×5 vs 6×6 vs 7×5?** Tile count ~25 vs 36 vs 35. The "sweet spot" where every cover tile has a meaningful choice is what we want.

### D2. Action economy

**Proposal: 2 AP per crew per turn. Standard move = 1 AP. Standard attack = 1 AP. Cover-grant or reload = free.**

Why 2-AP:
- Wildermyth has per-action movement + per-action attack.
- XCOM has 2 actions per turn (move / shoot / move+1-move-or-shoot).
- 2-AP gives the player real decision-making ("shoot twice, or move-shoot-reposition?") without bloating turns.

Open: **add a "dash" / passive cost of 1 AP for double-step?** Lower priority — can ship without.

### D3. Cover semantics

**Proposal: half cover (±2 evasion), full cover (±4 evasion), flanked = full cover waived.**

- Half cover: sandbags, crates, low consoles.
- Full cover: walls, blast doors, behind-console.
- Flanked: enemy on opposite tile-edges of the cover tile → cover ignored.
- Height advantage: +1 attack tile for elevated shots. Stacks with cover.

Why: this is the XCOM cover mechanic, which is well-understood. We don't reinvent it.

Open: **destructible cover?** XCOM does. I think **no for v0** — adds bookkeeping without much depth at 2-3 crew scale.

### D4. Enemy AI

**Proposal: simple priority queue.** Enemies act on a fixed tick (e.g., player turn 1 → enemy turn 1 → player turn 2). Each enemy's AI is a `Behavior` script with one decision:

- **Aggro behavior:** move toward closest crew, attack if in range.
- **Guard behavior:** stay near an objective tile, attack if crew within X tiles.
- **Coward behavior:** flee if HP < 30%, otherwise guard.

Each enemy carries 1 behavior. Designed in JSON, picked at encounter spawn.

Open: **Bah, the cheap version is "all enemies aggro, just with different stats". Is that too cheap?** I think it's fine for the first ship — variety comes from archetypes, not behaviors, until Phase 4 add-on.

### D5. Damage and casualty

**Proposal: 8-12 HP per crew. 1d6 damage per weapon (light) / 2d4 (heavy). Crew at 0 HP = casualty.**

- Casualty writes to ledger with:
  - `died_at_run: <run_id>`
  - `died_in_battle: <battle_id>`
  - `bond_score_at_death: <number>`
  - `held_trust_at_death: <number>`
  - `tribute_cite: <short, e.g. "Marcell fell at the Corvallo gate">`
  - `archetype_id`, `variant_id`, `name` (so next-run ghosts can re-cite)

**Why this matters:** the roguelike persistence — the whole game leans on characters *dying* and being remembered. Without this pipeline, the "Wild West-Myth feel" is hollowed out.

Open: **"dying in CQB always carries an Ink tribute" — should we ship that as a v0 requirement, or as a Phase 4 stretch?** My vote: **v0 requirement**. Tributes *are* the loop.

### D6. Tie-back to Ink and ledger

**Proposal:**

```
AI.step_X_meet_aliens:
  var cover = CoverTest.roll(captain.l_status, crew_picked.best_held_trust)
  if cover.tier == "pass-clean":
    # Ink beat: pass through gate
    InkRunner.run("beats/station_pass_through", {outcome: "clean"})
    return
  elif cover.tier == "rough":
    # Ink beat: rough passage, no combat
    InkRunner.run("beats/station_pass_through", {outcome: "rough"})
    return
  else:
    # CQB starts
    var result = CQB.run(crew_picked, alien_archetype)
    CQB.write_casualties_to_ledger(result, captain)
    CQB.write_bond_shifts_to_ledger(result, captain)
    InkRunner.run("beats/post_cqb", {outcome: result.outcome,
                                       casualty_count: len(result.casualties),
                                       cqb_turns: result.turn_count})
```

- `CQB.run` is the actual grid loop.
- `CoverTest.roll` reads captain stats + best crew stat, returns `{tier, …}`.
- Result is captured as plain-dict then handed to Ink + Persist + Ledger.

### D7. The fold mechanic

**Proposal: fold triggers *during* CQB if suspicion > 3.** Specifically:

- At combat start: check `captain.suspicion > 3`. If yes, fold all T-traits.
- Folded T-traits (✕) **give -1 to all CQB rolls for that crew**. The "fear betrays" mechanic.
- Folded T-trait ships to ledger as: `t_slots`: `["t-P-K", "t-P-C", "t-P-C✕"]`. Two unlocked-and-still-good, one folded.
- If a folded T-trait block shows up in the post-CQB Ink beat, the dialog changes.

**Why this design:** suspicion has to *hurt* mechanically. Otherwise it doesn't bind to combat.

Open: **does the fold manifest *only* as a CQB malus, or also as auto-aggression on enemies?** I'm open. I lean **CQB malus only** — keeps the design simple. Auto-aggression would teach the player that "suspicion means everyone turns on you" — maybe future work.

### D8. UI direction

**Proposal: 2.5D paper-cutout grid.** Hand-painted backdrop (station asset per station kind), shaped paper character tokens (crew + aliens), top-down camera. Camera does *not* tilt (we're 2.5D, not 3D). Movement is click-to-tile or arrow-key-with-tile-cursor; attacks are click-on-enemy.

- **No projectile animations.** Bland. Damage is a damage-number pop.
- **No particle FX.** Just the token sliding and the number bouncing.
- **Big stylistic fonts** for HP / damage numbers (paper RPG vibe).

Why: matches the existing MetisTrailV2 / borrowed-space paper-cutout / grit direction.

Open: **avoid art-direction risk** — Phase 3f should ship before Phase 3e goes visual. We can ship CQB as **ASCII / colored-rect grid first** (1-2 hour build) for gut-check of the math, then layer visuals once DirectionPage is set.

---

## Tasks once approved (Phase 3e plan)

1. **Issue #13** — design lock (this doc).
2. **Issue #14 — open** — `CqbGrid.gd` runtime module (the math + AP + state mutation).
3. **Issue #15 — open** — `CoverTest.gd` (the dialog gate-check, returns `tier`).
4. **Issue #16 — open** — `casualty_pipeline.gd` (writes to ledger, formats tributes).
5. **Issue #17 — open** — `cqb_ai.gd` (enemy behavior logic JSON-driven).
6. **Issue #18 — open** — 4 Ink beats: `station_pass_through_clean`, `station_pass_through_rough`, `station_cqb_enter`, `station_cqb_end_<outcome>`.
7. **Issue #19 — open** — GUT test suite for CQB (`test_cqb.gd`, ~8-10 tests).

**The deferred design happens once Phase 3e ships:**
- **Issue #20 — open** — visual layer (2.5D paper cutout + tokens). Holds until Phase 3f direction page lands.

---

## Risks

| Risk | Mitigation |
|---|---|
| CQB math gets gnarly (line-of-sight, flanking detection) | Cap as 5×5, axial; reuse `hex.gd` math where possible |
| Fold mechanic creates runaway suspicion loops | Caps: suspicion clamps at 6, fold is per-trait not global |
| Enemy AI tuned wrong (too easy / too hard) | Ship difficulty knob in `cqb_ai.json` per encounter archetype |
| Casualties make ledger too long | Tribute cite is a single string; no transcript upload |
| Ink ↔ combat state mismatch (vars not passed correctly) | Round-trip with `ink_runner.gd` from Phase 2c — already supports vars |

---

## Open questions for Bayard

1. **D1**: 5×5 OK, or 6×6? (I prefer 5×5 for "scarce tile" pressure.)
2. **D2**: 2-AP — agree?
3. **D4**: AI behaviors — is "all aggro" good enough for v0?
4. **D5**: In-Combat Ink tribute — v0 must-have, or Phase 4 stretch?
5. **D7**: Fold mechanic as CQB malus only, or also adds enemy aggression?
6. **D8**: Ship CQB as ASCII prototype first (cheap), or jump straight to paper-cutout?

Once these are answered, I'll lock `docs/COMBAT.md`, open Issues #14–#19, and start `CqbGrid.gd`.
