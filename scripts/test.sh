#!/usr/bin/env bash
# scripts/test.sh — run all GUT tests for borrowed-space.
#
# Phase 2f: Phase 2's only "test harness" deliverable.
# Wraps `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test ...`.
#
# Exits 0 only when GUT itself reports success.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_PROJECT="${REPO_ROOT}/godot"
mkdir -p "${REPO_ROOT}/scripts"

# Allow override; default to godot on PATH.
GODOT_BIN="${GODOT_BIN:-godot}"

if ! command -v "${GODOT_BIN}" >/dev/null 2>&1; then
  echo "ERR: ${GODOT_BIN} not found on PATH. Set GODOT_BIN to override." >&2
  exit 2
fi

cd "${GODOT_PROJECT}"

echo "Running GUT tests in ${GODOT_PROJECT}"
"${GODOT_BIN}" --headless -s res://addons/gut/gut_cmdln.gd \
  -gdir=res://test \
  -gexit \
  -gprefix=test_ \
  "$@"
echo "Done."
