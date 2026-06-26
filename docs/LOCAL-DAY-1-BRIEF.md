# 💻 Local Agent Brief — Day-1 Demo Loop

> **Audience:** Local integration agent on the same machine as coordinator.
>
> **Repo path:** `~/projects/borrowed-space`
>
> **Branch:** create `phase/day-1-demo-loop` from `main`. Push to remote. Open PR when done.
>
> **Coordinator:** same machine — desk-check works via terminal. Relay progress through session_search/chat.

---

## What you are building

A visible, clickable end-to-end demo: Bayard runs `run_start.tscn`, picks an origin, sees crew, walks the overworld once, encounters something, ledger row appears. Loops back to briefing.

**No content writing.** No new JSON beats, no new Ink. Just scene glue.

## ⚠️ Blockers discovered this morning (read first)

1. **`narrative/data/voice_fragments.json` does NOT exist on disk.** Casualty pipeline (`_resolve_tribute`) and CaptainsJournal both read it. They'll silently no-op. **Recommendation:** add defensive fallbacks first (return "" + log warning) so demo runs even before Remote's 3g lands. They're working on this in parallel.
2. **HANDOFF/CHANGELOG/ISSUES had a small drift on Phase 3 sub-phase numbering (#11/#12 swapped labels)** — already reconciled by coordinator. Trust the Roadmap + HANDOFF docs, not older CHANGELOG entries.

## Read in this order (mandatory)

1. `HANDOFF.md` — current state (just-updated)
2. `docs/ROADMAP.md` — Phase 3 split
3. `godot/scripts/ai.gd` — orchestrator to understand what to wire
4. `godot/scenes/run_start.tscn` — currently a placeholder
5. `godot/scenes/overworld.tscn` — currently a placeholder
6. `godot/scripts/persist.gd` — autoload usage

## Done = (one sentence)

Bayard runs `godot --path godot`, presses Play on `run_start.tscn`, sees a captain briefing, picks an origin, sees their core stat readout, clicks "launch", sees the overworld, picks a hex to travel to, sees the encounter, and a ledger row appears in `~/.local/share/godot/app_userdata/Borrowed Space/persist.json`.

## Visible moves (in order of priority)

### Move 1: `run_start.tscn` actually shows
- A `RichTextLabel` node with placeholder text
- A button that calls `Captain.generate()` and shows `captain["origin"]["chain_summary"]`
- Persist via `Persist.get_state()` to verify captain record was written
- **Acceptance:** Scene opens, click button, see origin name in label.

### Move 2: Add an origin-pick step
- Three OptionButton entries with NAC, ME, Coalition (start with three, expand later)
- Selected origin → Captain.generate() with that genship
- Visible crew list (already works in crew.gd) shown below

### Move 3: Hook overworld.tscn
- A simple ASCII-style hex display (cosmetic)
- A TextEdit showing the encounter pool from JSON (load fresh on enter)
- One button that triggers `Travel.transit(ship, hex_q=-1, hex_r=0)` and shows the result

### Move 4: Encounter → ledger write
- When Travel returns an encounter, call `LedgerWriter.write_row()` (or equivalent — verify name in `ledger_writer.gd`)
- Show the new ledger row in a sidebar
- Print "Ledger entry written" to console

### Move 5: Return to briefing
- Button to "End run" → returns control to run_start.tscn
- Briefing now shows "Captains so far: 1 (you, captain_01)" using data from persist

## Constraints

- **Do NOT write any new content.** No new JSON beats, no new Ink. Just wiring.
- **Do NOT modify the loaders** in `narrative_data.gd` — that's a separate ownership question. Use them read-only.
- **If voice_fragments.json is missing when casualty_pipeline reads it, defensive fallback.** Don't crash. Return "" for tribute, log warning. The casualty pipeline already has a null-check, but verify it works.
- **One scene file at a time.** Commit with `feat(scenes): wire origin pick to run_start.tscn` style. Small commits.

## Pitfalls (from HANDOFF §pitfalls)

- **`class_name` registration in Godot 4.6:** if you create new scripts with `class_name Foo`, run `godot --headless --path godot --import` to refresh global cache before tests.
- **`extends GutTest` script names not matching `test_*` prefix are silently filtered.** Use `test_*.gd` naming.
- **Variant-inference warnings are ERRORS in 4.6.** Use explicit `var x: Type = ...` not `:=`.
- **narrative/ lives outside Godot project root.** Load paths via `_resolve_dev_path()` in `narrative_data.gd` — don't bypass it.
- **GDScript `load()` conflicts with `ResourceLoader.load()`. ** Use `_resolve_*_path()` patterns from existing scripts.

## Verification primitive

After every commit:
```bash
godot --headless --path godot --import  # refresh class cache
godot --headless --path godot -s res://addons/gut/gut_cmdln.gd -gtest=res://test/test_demo_visible_run.gd -gexit
```

If the test still passes (currently 64/64), your wiring didn't break the world.

After all 5 moves, write a **screenshot run-book** at `docs/RUN_BOOK.md`:
- Step-by-step: open Godot → run scene → click button A → see B
- 5-7 steps, ASCII
- Designed so Bayard can follow it without knowing anything about Godot internals

## Expected commit messages (one per move)

```
feat(scenes): wire origin pick to run_start.tscn
feat(scenes): add crew readout below origin pick
feat(scenes): hook overworld.tscn for visible Travel.transit() call
feat(scripts): ledger write on encounter return, with sidebar display
feat(scenes): return-to-briefing routine from overworld
docs(runbook): add RUN_BOOK.md — Bayard's "click here then here" guide
```

## Pitfall note to coordinator (back-channel)

If you hit hard blockers (e.g., Persist autoload missing in scene, scene not loading), call out to coordinator. Coordinator will check for stale doc claims, not bad code.

## Report back format

```
demo: move N done
  • file: <changed path>
  • tests: <X>/<total> GUT pass
  • blocks: <none | specific>
  • next: <move N+1 | demo-runs>
```

If you block:
```
demo: blocker at move N
  • step: <what you tried>
  • reason: <what's stuck>
  • ask: <what you need from coordinator or Remote>
```
