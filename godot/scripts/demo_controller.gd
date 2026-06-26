extends Node
## demo_controller — moves 1-5 of the Day-1 demo loop.
##
## Attached to run_start.tscn. Owns the click-through that exercises
## Captain.generate() → Crew meeting → Travel.transit() → LedgerWriter.
##
## Phase 3 day-1 wiring only. No new content, no loader changes.

class_name DemoController

const ORIGINS_WITH_FRAGMENT := [
	{"genship_id": "SAA", "label": "Seeding (Coalition)", "fragment_id": "SAA-coalition"},
	{"genship_id": "ME",  "label": "Threshold",          "fragment_id": "ME-urban"},
	{"genship_id": "NAC", "label": "Declaration",        "fragment_id": "NAC-charter"},
]

@onready var _brief_label: RichTextLabel = $BriefLabel
@onready var _trace_label: RichTextLabel = $TraceLabel
@onready var _ledger_sidebar: RichTextLabel = $LedgerSidebar

var ai: Node = null
var captain: Dictionary = {}
var crew: Array = []
var transit_result: Dictionary = {}
var ledger_result: Dictionary = {}

func _ready() -> void:
	# Resolve dependencies lazily so the script works whether autoload is
	# "Persist" (production) or stubbed in test.
	_refresh_view()
	_persist_message()

func _persist_message() -> void:
	var s := "Persist autoload: "
	if has_node("/root/Persist"):
		s += "ready"
	else:
		s += "MISSING"
	_trace_label.text = s

func _refresh_view() -> void:
	var msg := "[b]Borrowed Space — Day-1 Demo[/b]\n\n"
	msg += "Click [b]Pick Origin[/b] to start.\n\n"
	msg += "Trivia so far: captain=%s, crew=%d, transit=%s, ledger=%s" % [
		str(captain.get("name", "?")),
		crew.size(),
		_str_of(transit_result),
		_str_of(ledger_result),
	]
	_brief_label.text = msg
	_render_ledger()

func _render_ledger() -> void:
	var line := "Ledger (sidebar)\n"
	if ledger_result.is_empty():
		line += "  (none yet)\n"
	else:
		line += "  captain_n=%s\n  genship=%s\n  records=%d\n" % [
			str(ledger_result.get("captain_n", "?")),
			str(ledger_result.get("genship_id", "?")),
			ledger_result.get("crew_count", 0),
		]
	_ledger_sidebar.text = line

func _str_of(d: Dictionary) -> String:
	if d.is_empty():
		return "{}"
	return "{ok=%s, kind=%s}" % [
		str(d.get("ok", "?")),
		str(d.get("arrival_kind", "?")),
	]

# ── Move 1: Pick Origin ─────────────────────────────────────────
# Pressing the button runs Captain.generate() through the AI orchestrator
# and surfaces the origin label so the user sees something change.
func _on_pick_origin_pressed() -> void:
	if not has_node("/root/Persist"):
		_trace_label.text = "Persist autoload missing — cannot run."
		return
	# Hardcoded reps match ORIGINS_WITH_FRAGMENT[0]. Move 2 swaps them
	# behind an OptionButton.
	var pick: Dictionary = ORIGINS_WITH_FRAGMENT[0]
	var AI_Script: GDScript = load("res://scripts/ai.gd")
	ai = AI_Script.new()
	add_child(ai)
	# One frame so AI._ready fires (BeatRunner + LedgerWriter autoload).
	await get_tree().process_frame
	captain = ai.step_1_pick_origin(pick["genship_id"], pick["fragment_id"])
	if captain.is_empty():
		_trace_label.text = "step_1_pick_origin returned empty."
		return
	ai.step_2_pick_archetype("A")
	ai.step_3_ai_briefing("Captain-Day1")
	var origin_label := str(captain.get("origin", {}).get("genship_label", "?"))
	_brief_label.text = "[b]Origin: %s[/b] (%s / %s)\nship_class=%s, h_tier=%d\n\nClick [b]Meet Crew[/b] to roll two procedurally-generated crew." % [
		origin_label,
		pick["genship_id"],
		pick["fragment_id"],
		captain.get("ship_class", "?"),
		int(captain.get("h_tier_peak", 0)),
	]

# ── Move 4: Ledger write on encounter return ─────────────────────
# Called from overworld.tscn via a scene-switch handler after the
# transit completes. Builds a ledger row from captain + crew.
func write_ledger_after_encounter(transit: Dictionary, in_crew: Array) -> void:
	transit_result = transit
	crew = in_crew
	var LW: GDScript = load("res://scripts/ledger_writer.gd")
	var lw = LW.new()
	add_child(lw)
	var fake_state := {
		"outcome": "ledger-closed",
		"discoveries_caught": ["ink_first_arrival"],
	}
	# Match ai.gd pattern: feed beat state + captain + crew into finalise.
	var captain_n: int = lw.finalise_run(fake_state, captain, crew, ["ink_first_arrival"])
	ledger_result = {
		"captain_n": captain_n,
		"genship_id": captain.get("genship_id", "?"),
		"crew_count": crew.size(),
	}
	_render_ledger()
	print("[demo] Ledger entry written: captain_n=%d, kind=%s" % [
		captain_n,
		transit.get("arrival_kind", "?"),
	])
