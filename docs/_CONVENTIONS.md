# Borrowed Space — Conventions

**Purpose:** Document the conventions used across all `docs/` Markdown files so Obsidian's graph view, search, and tag panes work cleanly. These conventions apply to *every* markdown file at the project's source-of-truth location.

---

## Folder layout

```
~/projects/borrowed-space/
├── docs/
│   ├── VISION.md                 (one-page project vision + north star)
│   ├── WORLD_BIBLE.md            (the world: genships, factions, history)
│   ├── BELT_CANON_LADDER.md      (what's known, by run)
│   ├── TRAITS.md                 (trait system + cover-test mechanics)
│   ├── NPCS.md                   (recurring NPC archetypes and roles)
│   ├── PERSISTENCE.md            (cross-run state model)
│   ├── TRUSTEE_BACKSTORY.md      (origin + cross-run reveal arc)
│   ├── HE3_INDUSTRY.md           (He-3 cartel + dismantling arc)
│   └── _CONVENTIONS.md           (this file)
├── narrative/
│   └── beats/                    (Ink source, compiled via inkgd or our wrapper)
├── godot/                        (Godot 4.x project root; Phase 2a scaffold later)
└── README.md
```

---

## Frontmatter (YAML) — required on every `.md` except `_CONVENTIONS.md`

```yaml
---
title: Borrowed Space — World Bible
status: draft                # draft | review | locked | archived
last_edited: 2026-06-22       # ISO date
tags:                        # Obsidian tag panes; see tag taxonomy below
  - faction
  - genship
aliases:                     # Obsidian alternative titles for backlinks
  - WB
  - World Bible
phase: 1                      # 1: world, 2: scaffold, 3: art, 4: combat-fill, 5: ship out
related:                     # Obsidian wikilinked files
  - "[[VISION]]"
  - "[[TRAITS]]"
---
```

### Tag taxonomy

All tags are **lowercase-hyphen**, organized hierarchically by domain:

| Domain | Tag roots |
|---|---|
| Project-level | `project`, `phase-1`, `phase-2`, `phase-3`, `phase-4`, `phase-5` |
| Meta | `vision`, `northstar`, `convention`, `roadmap` |
| World | `faction`, `genship`, `coalition`, `first-five`, `belt`, `earth`, `mars`, `luna` |
| People | `npc`, `trustee`, `ai`, `captain-gen` |
| Lore | `disparity`, `he3`, `collapse`, `dismantling-arc`, `sabotage-program` |
| Mechanics | `trait`, `cover-test`, `fold`, `persistence`, `npc-state`, `overship-roll` |
| Story | `crew-bond`, `exposure-arc`, `trustee-arc`, `narrative-template` |
| Pipeline | `obsidian`, `git`, `ink`, `godot`, `art-pipeline` |

Use 2–5 tags per file. Avoid generic tags like `info`.

### Aliases

- Add 1–2 short aliases per file for backlinks (e.g., `WB` for `World Bible`).
- Alias must not collide with another file's title.

### `related` (wikilinks)

- One-way links *as the author wrote them.* Obsidian will show these.
- Use Obsidian wikilink syntax: `[[FILENAME]]` or `[[FILENAME|display text]]`.

---

## Notation conventions inside file body

### Names

**Always** flag placeholder names like `[TBD placeholder]` or `[G1-NorthAmerica PLACEHOLDER]`. The rename pass at end of phase 1 replaces them.

Use `**[bold]**` for narrative-canonical names once locked. Before lock: `[G1-NorthAmerica PLACEHOLDER]`.

### Cross-file references

- Use Obsidian wikilinks *and* include the file path in parenthesis on the first reference. Example: `see the He-3 dossier ([HE3](../HE3_INDUSTRY.md))`.
- Same: `see the Trustee backstory ([TRUSTEE](../TRUSTEE_BACKSTORY.md))`.
- This keeps the docs readable in plain Markdown and Obsidian-ready.

### Inline emphasis rules

- *Italics* for non-canonical terms + clever nicknames.
- **Bold** for canonical names + forced-emotional terms (e.g. **the captain is fragile**).
- `Code` for variable names, IDs, machine-thing-tags.
- `> Block quote` for primary-canon sample text (small quotes, dispatch fragments).

### Lists

- Use `-` for unordered lists.
- Use numbered lists only for sequential operations (e.g., "do this, then this, then this").

---

## Doc status lifecycle

| Status | Meaning |
|---|---|
| `draft` | Work in progress. Content shifts. |
| `review` | Stable contents; redirect-only. |
| `locked` | No longer edited without signature approval. |
| `archived` | Superseded; left in place for reference. |

Visible as YAML frontmatter `status`.

---

## Update hygiene

- **Every edit:** bump `last_edited` (ISO date) in frontmatter.
- **Locking:** change `status: draft` → `status: review` → `status: locked` per the lifecycle.
- **Renaming:** *do not* in-place rename placeholder names. Add replacements during a dedicated `rename pass` at end of phase 1.

---

## Obsidian plugin / extension targets (future)

Topics we may want Obsidian's plugin layer to support:

- **Graph filters** (show only world / only mechanics blocks)
- **Backlinks pane** (default)
- **Tag pane** (defaults to alphabetical; we may want hierarchical)
- **Local graph** per file
- **Canvas** (free-form diagram)
- **Dataview** queries (e.g., "list all [G1-NorthAmerica PLACEHOLDER] references")
- **Templater** (frontmatter templating)

These land in Phase 2 only — they are not in scope for Phase 1 closing.

[End of CONVENTIONS.md.]