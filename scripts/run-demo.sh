#!/usr/bin/env bash
# scripts/run-demo.sh — run a visible (non-headless) demo of the playable run.
#
# Phase 2g: demonstrates the 7-step playable run in a real Godot window.
# Useful for visual QA, screenshots, and showing the game to others.
#
# Exits 0 when the demo closes cleanly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_PROJECT="${REPO_ROOT}/godot"

GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
  echo "ERR: ${GODOT_BIN} not found on PATH. Set GODOT_BIN to override." >&2
  exit 2
fi

cd "${GODOT_PROJECT}"

echo "Running demo (visible window) in ${GODOT_PROJECT}"
echo "Close the Godot window to exit."

# Note: --headless is intentionally omitted so the player can see the game.
# The demo runs the AI's full_run() and prints results to the console.
"${GODOT_BIN}" --path "${GODOT_PROJECT}" -- \
  -s res://scripts/ai.gd

echo "Demo complete."
