# 🎮 Borrowed Space — Day-1 Demo Run Book

> **What this is:** Click-by-click guide to run the project and see the demo loop.
>
> **What you'll see:** Origin pick → crew meet → overworld → travel → encounter → ledger write → return to briefing.
>
> **Requirements:** Godot 4.6.2.stable installed, repo cloned, `main` branch checked out.

---

## Step 1 — Open the project

1. Open **Godot 4.6.2.stable**
2. Click **Import** → navigate to `~/projects/borrowed-space/godot/` → select `project.godot` → **Import & Edit**

---

## Step 2 — Run the demo

3. In the **FileSystem** dock (bottom-left), double-click `scenes/run_start.tscn`
4. Press **F5** (or click **Run Current Scene** in the top toolbar)

You should see a window titled "Borrowed Space — Day-1 Demo" with 3 buttons, a dropdown, and text areas.

---

## Step 3 — Click through the loop

| Step | Click | What happens |
|---|---|---|
| **5** | **Pick Origin** button | The BriefLabel shows your origin's `chain_summary`. Persist autoload status shown above the button. |
| **6** | **Origin dropdown** next to Pick Origin | Select between **Seeding (Coalition)**, **Threshold**, or **Declaration**. Each maps to SAA, ME, or NAC genship. |
| **7** | **Meet Crew** button | Two procedurally generated crew members appear in CrewLabel with their archetype, variant, and held_trust score. |
| **8** | **Launch → Overworld** button | Scene switches to `overworld.tscn`. You see a hex label, encounter status, station dropdown, and action buttons. |
| **9** | Pick a station from the dropdown | Stations from `cartography.json` are loaded (10 stations across 6 factions). |
| **10** | Click **Transit** | Travel.transit() is called. The result (hex moved to, fuel cost, time elapsed, encounter rolled) appears in HexLabel/EncounterLabel. |
| **11** | If an encounter fires: click **Proceed** | The encounter runs through the pool → if combat triggers, the CQB grid fires. Outcome writes to ledger. |
| **12** | Click **End Run** | Scene returns to `run_start.tscn`. The LedgerSidebar now shows "Captains so far: 1" with the run's stats. |

---

## What the buttons actually do (under the hood)

| Button | Script call | System exercised |
|---|---|---|
| Pick Origin | `Captain.new_run(genship_id, fragment_id)` | Captain generation, origin matrix, narrative_data.gd |
| Meet Crew | `Crew.generate(archetype_id)` for 2 slots | NPC archetype variants, trait pool, bond seeding |
| Launch | `get_tree().change_scene_to_file("res://scenes/overworld.tscn")` | DemoSession autoload, scene transition |
| Transit | `Travel.transit(ship, to_q, to_r, stations)` | Hex math, cartography, fuel/suspicion clock, encounter pool |
| Proceed | Route through `EncounterPool.roll()` → optional CQB | Encounter beats, CQB grid, casualty pipeline, ledger |
| End Run | `LedgerWriter.finalise_run()` → return to `run_start.tscn` | Ledger persistence, cross-run state |

---

## What's NOT in this demo yet

- **CQB combat won't always fire** — it depends on encounter pool rolls. You may see a non-combat encounter (trade, social, discovery) instead.
- **No art** — everything is placeholder text/ASCII. Phase 4 adds the paper-craft visual layer.
- **No permanent save** — closing the window loses the run. Persist.json is written to `user://` data directory but the scene doesn't offer a "resume" button yet.

---

## Verify it worked

After clicking through steps 5-12, check the ledger file:

```bash
# Linux: persist.json lives in Godot's user data directory
ls ~/.local/share/godot/app_userdata/Borrowed\ Space/persist.json
cat ~/.local/share/godot/app_userdata/Borrowed\ Space/persist.json | python3 -m json.tool
```

You should see a `"captains"` block with one entry containing your selected origin, generated crew, and any discoveries from the encounter.

---

## If something breaks

| Symptom | Likely cause | Fix |
|---|---|---|
| Scene doesn't open | Autoload conflict | Run `cd ~/projects/borrowed-space/godot && godot --headless --import` to refresh cache |
| Buttons don't respond | DemoSession autoload missing | Open `Project → Project Settings → Autoload` → confirm `DemoSession="*res://scripts/demo_session.gd"` |
| Ledger empty | Persist not initialized | Console will show "Persist: no save file, starting fresh" — normal first-run behaviour |

---

[End of RUN_BOOK.md]
