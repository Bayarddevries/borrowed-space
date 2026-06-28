extends ColorRect
## DialogueEngine — drives the dialogue panel scene.

signal dialogue_ended(next_beat_id: String)
signal advance_requested()  # for the overworld controller to process next

# ── Node references ───────────────────────────────────────────────
@onready var _encounter_bg: TextureRect    = $EncounterBg
@onready var _overlay_bg: ColorRect        = $OverlayBg
@onready var _card: ColorRect              = $Card
@onready var _npc_portrait: TextureRect    = $Card/NpcPortrait
@onready var _npc_name: Label              = $Card/NpcPortrait/NpcName
@onready var _player_portrait: TextureRect = $Card/PlayerPortrait
@onready var _dialogue_text: RichTextLabel = $Card/DialogueText
@onready var _choice_btns: Array[Button]   = [$Card/Choice1, $Card/Choice2, $Card/Choice3]

# ── State ─────────────────────────────────────────────────────────
var _beat: Dictionary = {}
var _lines: Array = []
var _line_index: int = 0
var _state: Dictionary = {}
var _pending_deltas: Array = []
var _typewriter_tween: Tween = null
var _in_fullscreen: bool = false
var _default_npc_portrait: Texture2D = null
var _default_player_portrait: Texture2D = null

func _ready() -> void:
	visible = false
	# Load default portraits
	_default_npc_portrait = preload("res://assets/sprites/captain_placeholder.png")
	_default_player_portrait = preload("res://assets/sprites/crew_placeholder.png")


# ── Public API ────────────────────────────────────────────────────

## Start a dialogue beat.
## `beat`: the dialogue beat Dictionary (Schema C).
## `state`: lookup state for conditions (captain, crew, ship, session, persist).
## `npc_portraits`: optional dict mapping npc_id -> Texture2D.
func start_dialogue(beat: Dictionary, state: Dictionary, npc_portraits: Dictionary = {}) -> void:
	_beat = beat
	_lines = beat.get("lines", [])
	_line_index = 0
	_state = state

	# Configure mode
	var meta: Dictionary = beat.get("metadata", {})
	_in_fullscreen = meta.get("mode", "overlay") == "fullscreen"
	_configure_mode(meta)

	# Load encounter BG if specified
	var bg_path: String = meta.get("bg", "")
	if bg_path != "":
		var tex: Texture2D = load(bg_path)
		if tex != null:
			_encounter_bg.texture = tex

	# Cache NPC portraits
	for npc_id: String in npc_portraits.keys():
		pass  # stored for lookup in _show_line

	# Start
	visible = true
	_show_current_line()

	# Connect choice buttons (lazy — children may not be ready at _ready())
	for i in 3:
		if _choice_btns[i] != null and not _choice_btns[i].pressed.is_connected(_on_choice):
			_choice_btns[i].pressed.connect(_on_choice.bind(i))


## Advance to the next line (used after a non-choice line auto-advances).
func advance() -> void:
	_line_index += 1
	if _line_index < _lines.size():
		_show_current_line()
	else:
		_end_dialogue()


## Check if the dialogue is currently visible.
func is_active() -> bool:
	return visible


## Get the current speaker name for the displayed line.
func get_current_speaker() -> String:
	if _line_index < _lines.size():
		return _lines[_line_index].get("speaker", "")
	return ""


# ── Private ───────────────────────────────────────────────────────

func _show_current_line() -> void:
	if _line_index >= _lines.size():
		_end_dialogue()
		return

	var line: Dictionary = _lines[_line_index]
	var speaker: String = line.get("speaker", "narrator")
	var text: String = line.get("text", "")
	var choices: Array = line.get("choices", [])

	# Set speaker visual
	_set_speaker(speaker)

	# Typewriter text
	_show_text(text)

	# Handle choices
	if choices.size() > 0:
		_show_choices(choices)
	else:
		_hide_choices()
		# Auto-advance after a short delay for non-choice lines
		_auto_advance_timer(text)


func _set_speaker(speaker: String) -> void:
	if speaker == "player":
		# Show player portrait, hide NPC portrait
		_npc_portrait.hide()
		_player_portrait.show()
		_npc_name.text = ""
	else:
		_npc_portrait.show()
		_player_portrait.hide()
		# Look up NPC name from rogues-gallery or use speaker ID
		var display_name: String = _resolve_npc_name(speaker)
		_npc_name.text = display_name

	# Apply any portrait overrides
	var override_portrait: Texture2D = _state.get("_portraits", {}).get(speaker, null)
	if override_portrait != null:
		if speaker == "player":
			_player_portrait.texture = override_portrait
		else:
			_npc_portrait.texture = override_portrait


func _resolve_npc_name(speaker_id: String) -> String:
	# Try NPC lookup from rogues-gallery
	var rogues: Dictionary = _state.get("_npcs", {})
	if rogues.has(speaker_id):
		var npc: Dictionary = rogues[speaker_id]
		var name_str: String = npc.get("name", speaker_id)
		var title: String = npc.get("title", "")
		if title != "":
			return "%s, %s" % [name_str, title]
		return name_str

	# Fallback: clean up the ID
	return speaker_id.replace("_", " ").capitalize()


func _show_text(text: String) -> void:
	_dialogue_text.text = ""
	if text == "":
		return

	# Typewriter effect
	if _typewriter_tween != null and _typewriter_tween.is_running():
		_typewriter_tween.kill()

	_typewriter_tween = create_tween()
	_typewriter_tween.set_trans(Tween.TRANS_LINEAR)

	var full_text: String = text
	var current_text: String = ""
	var char_count: int = full_text.length()

	for i in range(char_count):
		current_text += full_text[i]
		_typewriter_tween.tween_callback(_set_text_partial.bind(current_text))
		_typewriter_tween.tween_interval(0.03)  # ~33 chars/sec


func _set_text_partial(partial: String) -> void:
	_dialogue_text.text = partial


func _show_choices(choices: Array) -> void:
	_hide_auto_advance()

	# Filter by conditions
	var eligible: Array = []
	for c in choices:
		var cond: Dictionary = c.get("condition", {})
		if cond.is_empty() or _evaluate_condition(cond):
			eligible.append(c)

	# Show buttons
	for i in range(3):
		if i < eligible.size():
			var c: Dictionary = eligible[i]
			_choice_btns[i].text = c.get("label", "Continue")
			_choice_btns[i].visible = true
		else:
			_choice_btns[i].visible = false


func _hide_choices() -> void:
	for b in _choice_btns:
		b.visible = false


func _auto_advance_timer(text: String) -> void:
	# Auto-advance non-choice lines after reading time (~0.3s per word + base delay)
	if text == "":
		advance.call_deferred()
		return
	var word_count: int = text.split(" ", false).size()
	var delay: float = 1.0 + float(word_count) * 0.15
	get_tree().create_timer(delay).timeout.connect(_on_auto_advance)


func _hide_auto_advance() -> void:
	# No-op: auto-advance timer will fire but _show_choices has already been called
	pass


func _on_auto_advance() -> void:
	if not visible:
		return
	# Only auto-advance if no choices are showing
	if _choice_btns[0].visible or _choice_btns[1].visible or _choice_btns[2].visible:
		return
	if _line_index < _lines.size() - 1:
		advance()


func _on_choice(index: int) -> void:
	if _line_index >= _lines.size():
		return

	var line: Dictionary = _lines[_line_index]
	var choices: Array = line.get("choices", [])

	# Filter again to match what's displayed
	var eligible: Array = []
	for c in choices:
		var cond: Dictionary = c.get("condition", {})
		if cond.is_empty() or _evaluate_condition(cond):
			eligible.append(c)

	if index >= eligible.size():
		return

	var picked: Dictionary = eligible[index]
	_pending_deltas = picked.get("delta", [])

	# Apply deltas immediately
	for d in _pending_deltas:
		_apply_delta(d)

	# Branch
	var next_id: String = picked.get("next", "")
	if next_id != "":
		# Check if next is a line within this beat or a new beat
		var next_target: String = next_id
		_end_dialogue(next_target)
	else:
		# No next — end dialogue
		_end_dialogue("")


func _apply_delta(delta: Dictionary) -> void:
	# Apply to Persist if available
	if has_node("/root/Persist"):
		Persist.patch(delta)

	# Also apply to local state
	for key in delta.keys():
		_state[key] = delta[key]


func _evaluate_condition(cond: Dictionary) -> bool:
	var fact: String = cond.get("fact", "")
	var op: String = cond.get("op", "==")
	var value = cond.get("value", null)

	var actual = _resolve_fact(fact)
	match op:
		"==":
			return str(actual) == str(value)
		"!=":
			return str(actual) != str(value)
		">":
			return float(actual) > float(value)
		"<":
			return float(actual) < float(value)
		">=":
			return float(actual) >= float(value)
		"<=":
			return float(actual) <= float(value)
		"has":
			if actual is Array:
				return value in actual
			return false
		"exists":
			return actual != null and actual != ""
	return true


func _resolve_fact(fact: String):
	# Dot-notation path: "captain.genship", "suspicion", "visited_stations.STATION_01"
	if fact == "":
		return null

	var parts: Array = fact.split(".")
	var current = _state

	# Special case: single-word facts check state directly
	if parts.size() == 1:
		if current.has(fact):
			return current[fact]
		return null

	# Walk the path
	for i in range(parts.size()):
		var key: String = parts[i]
		if current is Dictionary and current.has(key):
			current = current[key]
		else:
			return null

	return current


func _configure_mode(meta: Dictionary) -> void:
	var mode: String = meta.get("mode", "overlay")
	if mode == "fullscreen":
		_in_fullscreen = true
		_encounter_bg.visible = true
		_overlay_bg.visible = false
		# Card expands to full screen
		_card.offset_top = 0
		_card.offset_bottom = 800
		_card.offset_left = 0
		_card.offset_right = 1400
		_card.color = Color(0, 0, 0, 0)
		# Move text up
		_card.get_node("DialogueText").offset_top = 500
		_card.get_node("DialogueText").offset_bottom = 650
		for i in 3:
			var btn = _card.get_node("Choice%d" % (i+1))
			if btn:
				btn.offset_top = 660 + i * 38
				btn.offset_bottom = 690 + i * 38
	else:
		_in_fullscreen = false
		_encounter_bg.visible = false
		_overlay_bg.visible = true
		_card.offset_top = 440
		_card.offset_bottom = 760
		_card.offset_left = 80
		_card.offset_right = 1320
		_card.color = Color(0.08, 0.07, 0.10, 0.92)


func _end_dialogue(next_id: String = "") -> void:
	visible = false
	_typewriter_tween = null
	emit_signal("dialogue_ended", next_id)
