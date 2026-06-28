#!/usr/bin/env bash
# bundle-narrative.sh — copy narrative JSON files into the Godot project
# for production builds. Run before `godot --export-release`.
#
# Copies:
#   narrative/data/*.json  →  godot/assets/data/
#   narrative/beats/*.json →  godot/assets/data/beats/
#
# After running, narrative_data.gd will load from res://assets/data/
# instead of walking up from the project root (dev-mode).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_ASSETS="${REPO_ROOT}/godot/assets/data"

mkdir -p "${GODOT_ASSETS}/beats"

echo "=== Bundling narrative data for production ==="

# Copy data files
for f in "${REPO_ROOT}"/narrative/data/*.json; do
  cp "$f" "${GODOT_ASSETS}/"
  echo "  data/$(basename "$f")"
done

# Copy beat files
for f in "${REPO_ROOT}"/narrative/beats/*.json; do
  cp "$f" "${GODOT_ASSETS}/beats/"
  echo "  beats/$(basename "$f")"
done

echo ""
echo "Done. ${GODOT_ASSETS} now has production-ready narrative data."
echo "Run 'godot --headless --path ${REPO_ROOT}/godot --import' to refresh."
