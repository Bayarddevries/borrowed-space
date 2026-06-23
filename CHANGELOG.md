---
title: Borrowed Space — Changelog
status: review
last_edited: 2026-06-22
tags:
  - workflow
  - changelog
  - history
aliases:
  - CHANGELOG
phase: 2
related:
  - "[[ROADMAP]]"
  - "[[AGENTS]]"
---

# CHANGELOG.md

This file lists notable commits for human-reviewed history. Detailed diffs are in git history.

Format follows [Keep a Changelog](https://keepachangelog.com/) but adapted for solo-dev / agent workflows. Compatible with the commit-message convention in `AGENTS.md`.

---

## [Unreleased] — Phase 1 + 2a

### Phase 2a — scaffold conventions (commit `e525942`)
- ROADMAP.md drafted
- Cross-links to BIAS_GUARDRAILS and ROADMAP in every world-building doc
- GitHub Labels: `phase-2`, `phase-3`, `phase-4`, `phase-5`

### Phase 2a — agent workflow convention (commit `pending`)
- AGENTS.md drafted
- Pre-session reading list: VISION + ROADMAP + HANDOFF → issue → relevant docs
- Commit-message convention: Metis Trail V2 base + `Closes #N` and `Phase: X` footers

### Phase 1 — world bible v1 (commit `f0426c9`)
- 9 docs drafted: VISION, WORLD_BIBLE, BELT_CANON_LADDER, TRAITS, NPCS, PERSISTENCE, TRUSTEE_BACKSTORY, HE3_INDUSTRY, BIAS_GUARDRAILS, _CONVENTIONS
- Two sample Ink beats: prologue.ink, run-start.ink
- Initial git push to private GitHub repo
- Naming: PLACEHOLDERS until rename pass

---

## How to use this file

**Add a dated entry** for each phase. Example pattern:

```
### Phase 2b — Godot 4 project layout (commit <hash>)
- project.godot scaffold laid
- scenes/run_start.tscn, overworld.tscn, station.tscn placeholders
- assets/sprites/, assets/data/ structure solve

Closes #2
Phase: 2b
```

[End of CHANGELOG.md]
