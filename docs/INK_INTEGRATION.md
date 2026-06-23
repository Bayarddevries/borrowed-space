---
title: Borrowed Space — Ink Integration
status: review
last_edited: 2026-06-22
tags:
  - ink
  - integration
  - narrative
  - decision
aliases:
  - INK_INTEGRATION
phase: 2
related:
  - "[[_CONVENTIONS]]"
  - "[[ROADMAP]]"
  - "[[NPCS]]"
  - "[[TRAITS]]"
  - "[[PERSISTENCE]]"
---

# Ink Integration (Phase 2c) — *Borrowed Space*

**Status:** Decision locked. Path A (inkjs via JS bridge) primary; Path C (native GDScript player) as fallback.

---

## Goals

1. The Ink layer is a *runtime concern* — it should not dominate the codebase.
2. The narrative layer talks to a small Godot wrapper, not to inkjs directly.
3. The wrapper is small enough to read in 5 minutes.
4. The wrapper can be swapped wholesale if Path A breaks.

---

## Path A vs Path C — the decision

### Path A — inkjs via JS bridge (primary)

**How it works:**

- `.ink` files compile to `ink.json` ahead of time using `inklecate` (Ink's official compiler).
- The compiled JSON is loaded into a tiny JavaScript runtime that *also runs Ink's runtime engine.*
- The Godot side talks to the JS side via bridge; the JS side returns JSON or strings.
- The Godot wrapper (`ink_runner.gd`) is ~150 lines of glue.

**Pros:**

- InkJS is the official JavaScript implementation of Ink; it gets Ink-feature parity.
- Bugs we find are upstream bugs to file.
- Future-proof: if Inkle updates Ink or inkjs, our upgrade is a JS engine swap.

**Cons:**

- Cross-language bridge has *some* complexity.
- Headless tests need a JS engine (we use quickjs or one of the bundled engines).
- Export to web makes this trivial (Path A is the natural fit for web); export to desktop means bundling the JS engine.

### Path C — native GDScript player (fallback)

**How it works:**

- Compile `.ink` ahead-of-time to `ink.json` (same as Path A).
- A custom GDScript player *reads* `ink.json` and walks the story thread.
- No JS bridge, no engine to embed; the player uses Map<int, StoryNode> as its data structure.

**Pros:**

- Pure GDScript, no bridge.
- Works identically in Godot editor + headless + web + desktop.
- No engine size penalty.

**Cons:**

- We've never built one. Risks: story-state serialization, choice mechanics, knots/stitches/threads of Ink, knots with arguments.
- Ink has minor features that wouldn't make Path C first-cut: gather/surprise, lists, threads.
- Path C is *only* safer in the long run if we maintain it. Otherwise the engine fork is the issue.

### Decision

Path A first, Path C as documented fallback. We don't switch to C unless Path A *concretely breaks.*

Reasons:

- InkJS is the canonical Ink runtime. It's the Inkle-blessed path.
- We are *narrative-first*. We want the Ink's full feature set authored freely.
- The bridge complexity is manageable in a ~150-line API; if it becomes unmanageable, we'll have noted pitfalls in AGENTS.md before we'd have to bail.

---

## Wrapper API

```gdscript
# godot/scripts/ink_runner.gd — singleton, ~150 lines, public API

extends Node

# === STATE ===
var story_runtime = null           # the JS engine instance (set after load_story)
var current_text: String = ""
var available_choices: Array = []
var variables: Dictionary = {}

# === LIFECYCLE ===

func bind_external(state: Dictionary, ledger: Dictionary) -> void:
    # Push variables from persistence into Ink's runtime state.
    # Not part of the main API; called by ai.gd after load_story.
    pass

func load_story(ink_json_path: String) -> bool:
    # Loads a compiled ink.json from a Godot resource path (res://...).
    # Returns true on success.
    # (Phase 2c implements this against a stub backend;
    #  Phase 2g wires it to the actual JS engine.)
    pass

# === ENGINE EVENTS ===

func continue_story() -> String:
    # Advance the Ink story to the next line(s).
    # Returns the text on screen.
    pass

func choose(choice_index: int) -> bool:
    # Make a choice by index. Returns ok/fail.
    pass

func get_current_text() -> String:
    return current_text

func get_choices() -> Array:
    return available_choices

# === STATE SYNC ===

func apply_to_state(captain_obj) -> void:
    # Apply Ink runtime variables to a Captain instance (a GDScript object).
    pass

func get_variable(name: String) -> Variant:
    return variables.get(name, null)
```

That's the *whole* API. Anything that needs *more* goes into the design doc and is treated as a phase-2g or phase-2f concern.

---

## What 2c delivers

1. `godot/scripts/ink_runner.gd` rewritten from placeholder to a *real* singleton with the API defined above.
2. **Stub backing store** — for phase 2c the wrapper is *not* wired to inkjs. It uses an in-memory dictionary-backed stub. This way, phase 2c is mostly contract + tests; the JS bridge comes in phase 2f/2g.
3. `godot/scripts/ink_runner_stub.gd` — the backing store.
4. Smoke-test (`test/test_ink_runner.gd`): asserts `load_story("res://narrative/build/prologue.json")` returns false (no build dir yet), and that the API surface is reachable.
5. This INK_INTEGRATION.md.

What's *not* in 2c:

- The JS engine embedding (Path A).
- The Ink compilation step (Phase 2g).
- Web export integration (Phase 5).

---

## Pitfalls to log as we find them

Pitfalls discovered in phase 2c get logged in `AGENTS.md` so the next agent knows what's wrong with inkjs.

[End of INK_INTEGRATION.md]
