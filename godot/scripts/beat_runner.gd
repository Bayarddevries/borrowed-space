extends Node
## beat_runner — Ink-shaped runtime that reads beats from a JSON manifest.
##
## Phase 2g. Public API mirrors ink_runner.gd's contract so consumers stay
## stable when the Ink-bundled version lands later. Reads a manifest at:
##   res://.../run-start-manifest.json   (production path)
## and falls back to the dev-mode repo-root path (see NarrativeData._resolve_dev_path).
##
## In production builds, ink_runner.gd replaces this body's resolve_text/choose
## with calls to inkjs, but the API surface stays the same:
##   - run_beat(beat_id: String) -> Dictionary       # returns {text, choices}
##   - choose(choice_index: int) -> Dictionary      # returns next state
##   - get_current_text() -> String
##   - apply_to_state(record: Dictionary)
##
## Beat manifest schema (see narrative/beats/run-start-manifest.json):
##   {
##     "beats": {
##       "<beat_id>": {
##         "speaker": "narrator" | "captain" | "ai",
##         "text": "...",           // single string with optional {captain_name} interpolation
##         "choices": [
##           { "label": "...", "to": "<next_beat_id>", "delta": { /* patch applied */ } }
##         ]
##       }
##     },
##     "start": "<beat_id>"
##   }
class_name BeatRunner

const MANIFEST_PATH := "/../narrative/beats/run-start-manifest.json"

var _manifest: Dictionary = {}
var _current_beat: String = ""
var _state: Dictionary = {}   # mutable per-run state (captain record + bond deltas)
var _history: Array = []      # visits log for ledger

func _ready() -> void:
	_load_manifest()

## Load a manifest from a custom path relative to the Godot project root.
## Uses the same dev-mode path resolution (globalize_path + manual file walk)
## as _load_manifest. Returns true on success.
func load_manifest_from(manifest_rel_path: String) -> bool:
	var godot_root := ProjectSettings.globalize_path("res://")
	var path := godot_root + manifest_rel_path.lstrip("/")
	return _read_manifest_at(path)

func _load_manifest() -> void:
	# Same dev-mode outside-the-project-root pattern as NarrativeData.
	var godot_root := ProjectSettings.globalize_path("res://")
	var path := godot_root + MANIFEST_PATH.lstrip("/")
	_read_manifest_at(path)

func _read_manifest_at(path: String) -> bool:
	if not FileAccess.file_exists(path):
		push_error("[BeatRunner] manifest not found at %s" % path)
		return false
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("[BeatRunner] open failed: %s" % path)
		return false
	var text := f.get_as_text()
	f.close()
	var data = JSON.parse_string(text)
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[BeatRunner] manifest not a dictionary")
		return false
	_manifest = data
	return true

func is_loaded() -> bool:
	return not _manifest.is_empty()

func bind_state(state: Dictionary) -> void:
	# Host (AI) calls this to seed the per-run state.
	_state = state.duplicate(true)

func run_beat(beat_id: String = "") -> Dictionary:
	if beat_id == "":
		beat_id = _current_beat if _current_beat != "" else _manifest.get("start", "")
	if not _manifest.has("beats") or not _manifest["beats"].has(beat_id):
		push_error("[BeatRunner] unknown beat: %s" % beat_id)
		return {"text": "", "choices": []}
	var beat_obj = _manifest["beats"][beat_id]
	_current_beat = beat_id
	var interpolated := _interpolate(String(beat_obj.get("text", "")))
	var choices: Array = []
	for c in beat_obj.get("choices", []):
		choices.append({
			"label": String(c.get("label", "")),
			"to": String(c.get("to", "")),
			"delta": c.get("delta", {}),
		})
	return {"text": interpolated, "choices": choices, "speaker": String(beat_obj.get("speaker", "narrator"))}

func choose(choice_index: int) -> Dictionary:
	var beat_obj = _manifest["beats"][_current_beat]
	var choices: Array = beat_obj.get("choices", [])
	if choices.is_empty():
		# End-of-run beat — no choices. Return empty, the AI handles end-of-run.
		return {"text": get_current_text(), "choices": [], "speaker": beat_obj.get("speaker", "narrator")}
	if choice_index < 0 or choice_index >= choices.size():
		push_error("[BeatRunner] choice_index out of range: %d" % choice_index)
		return {"text": "", "choices": []}
	var picked = choices[choice_index]
	# Apply delta into _state (deep-merge).
	if picked.has("delta") and not picked["delta"].is_empty():
		_deep_merge(_state, picked["delta"])
	# Log for the ledger.
	_history.append({"beat": _current_beat, "choice": picked["label"]})
	# Move cursor.
	return run_beat(picked["to"])

func get_current_text() -> String:
	if _current_beat == "":
		return ""
	var beat_obj = _manifest["beats"][_current_beat]
	return _interpolate(String(beat_obj.get("text", "")))

func get_current_beat() -> String:
	return _current_beat

func get_state() -> Dictionary:
	return _state.duplicate(true)

func get_history() -> Array:
	return _history.duplicate()

# Apply a record to the in-memory state (called when the run ends).
func apply_to_state(record: Dictionary) -> void:
	_deep_merge(_state, record)

func _interpolate(text: String) -> String:
	# Replace {key} with _state[key] when missing, leaves empty.
	for key in _state.keys():
		text = text.replace("{%s}" % key, str(_state[key]))
	return text

static func _deep_merge(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		var src_val = source[key]
		if target.has(key) and typeof(target[key]) == TYPE_DICTIONARY and typeof(src_val) == TYPE_DICTIONARY:
			_deep_merge(target[key], src_val)
		else:
			target[key] = src_val
