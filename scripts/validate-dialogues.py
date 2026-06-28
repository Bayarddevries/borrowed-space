#!/usr/bin/env python3
"""validate-dialogues.py — checks dialogue beat files for structural issues."""
import json, os, sys, glob

PROJECT = "/home/bayard_devries/projects/borrowed-space"
DIALOGUES = os.path.join(PROJECT, "narrative/dialogues")
ROGUES = os.path.join(PROJECT, "narrative/data/npc-rogues-gallery.json")

errors = 0
warnings = 0

# Load NPC rogues gallery for speaker validation
npcs = {}
if os.path.exists(ROGUES):
    with open(ROGUES) as f:
        rg = json.load(f)
    npcs = rg.get("npcs", {})

# Find all dialogue files
files = glob.glob(os.path.join(DIALOGUES, "*.json"))
print(f"Checking {len(files)} dialogue file(s)...\n")

for fp in sorted(files):
    fname = os.path.basename(fp)
    try:
        with open(fp) as f:
            data = json.load(f)
    except json.JSONDecodeError as e:
        print(f"  ❌ {fname}: JSON parse error — {e}")
        errors += 1
        continue

    if not isinstance(data, dict):
        print(f"  ❌ {fname}: top-level is not a dict")
        errors += 1
        continue

    scene_count = 0
    for scene_id, scene in data.items():
        if scene_id == "_meta":
            continue
        scene_count += 1
        if not isinstance(scene, dict):
            print(f"  ⚠️  {fname}/{scene_id}: not a dict")
            warnings += 1
            continue

        lines = scene.get("lines", [])
        if not lines:
            print(f"  ⚠️  {fname}/{scene_id}: no lines")
            warnings += 1
            continue

        for i, line in enumerate(lines):
            speaker = line.get("speaker", "")
            if speaker and speaker != "player" and speaker != "narrator":
                if speaker not in npcs:
                    print(f"  ⚠️  {fname}/{scene_id}: line {i} unknown speaker '{speaker}'")
                    warnings += 1
            choices = line.get("choices", [])
            if choices:
                for j, c in enumerate(choices):
                    if not c.get("label", ""):
                        print(f"  ⚠️  {fname}/{scene_id}: line {i} choice {j} missing label")
                        warnings += 1
                    nxt = c.get("next", "")
                    if nxt and nxt not in data:
                        print(f"  ⚠️  {fname}/{scene_id}: choice '{c.get('label','?')}' next '{nxt}' not found in file")
                        warnings += 1
                    cond = c.get("condition", {})
                    if cond:
                        fact = cond.get("fact", "")
                        op = cond.get("op", "")
                        if not fact or not op:
                            print(f"  ⚠️  {fname}/{scene_id}: choice {j} incomplete condition")
                            warnings += 1

    print(f"  ✓ {fname} — {scene_count} scene(s)")

print(f"\n{'='*50}")
print(f"Results: {errors} errors, {warnings} warnings")
if errors:
    sys.exit(1)
if warnings:
    print("⚠️  Fix warnings before committing narrative content.")
print("✅ Dialogue validation complete.")
