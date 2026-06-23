# Borrowed Space

**Project status:** Phase 1 in progress. World bible in review.

A 2.5D roguelike space RPG about *being promoted into uncertainty*. Defector-oligarch-funded captains sail the asteroid belt, slowly dismantling the He-3 monopoly that oligarchs engineered 80+ years ago. The ship's AI holds memory across runs.

**North star:** A being-promoted-into-uncertainty roguelike with a multi-run dismantling arc, set in a He-3 monopoly estate built by oligarch-founded sabotage; the AI remembers; each captain is a single increment of dismantling; defiant oligarch defectors, conscripts-as-protagonists, and stations that endure.

## Quick links

- [VISION.md](docs/VISION.md) — what we're making and why
- [WORLD_BIBLE.md](docs/WORLD_BIBLE.md) — the setting
- [TRUSTEE_BACKSTORY.md](docs/TRUSTEE_BACKSTORY.md) — the antagonist's origin
- [HE3_INDUSTRY.md](docs/HE3_INDUSTRY.md) — the dismantling arc
- [NPCS.md](docs/NPCS.md) — recurring characters
- [TRAITS.md](docs/TRAITS.md) — captain generation
- [PERSISTENCE.md](docs/PERSISTENCE.md) — what carries across runs
- [BELT_CANON_LADDER.md](docs/BELT_CANON_LADDER.md) — knowledge bands
- [BIAS_GUARDRAILS.md](docs/BIAS_GUARDRAILS.md) — anti-stereotype watch list
- [ROADMAP.md](docs/ROADMAP.md) — phase boundaries and current plans
- [_CONVENTIONS.md](docs/_CONVENTIONS.md) — file conventions

## Project layout

```
borrowed-space/
├── README.md
├── docs/
└── narrative/
    └── beats/
```

## Obsidian

This is Obsidian-compatible. To view as a vault:

```bash
mkdir -p ~/obsidian-vaults/borrowed-space
ln -s ~/projects/borrowed-space/* ~/obsidian-vaults/borrowed-space/
open ~/obsidian-vaults/borrowed-space  # on macOS
```

Or in Obsidian: "Open vault as folder" → point to `~/projects/borrowed-space/`.

## Tech stack (planned)

- **Engine:** Godot 4.x — Phase 2
- **Narrative:** Ink + a thin Godot wrapper — Phase 2
- **Art:** Hand-drawn paper-pipeline (Krita → PNG) — Phase 3
- **Persistence:** JSON / YAML — Phase 2

## License

TBD.
