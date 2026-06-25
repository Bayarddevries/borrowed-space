extends Node
## CasualtyPipeline — ledger writes + journal + Ink tribute on HP=0.
class_name CasualtyPipeline

# ── API ──────────────────────────────────────────────────────────
static func process(casualties: Array) -> Dictionary:
    var result := {"casualties": [], "tributes": [], "journal_entries": []}
    for entry in casualties:
        if not entry is Dictionary:
            continue
        var actor_id: String = str(entry.get("actor_id", ""))
        var faction: String = str(entry.get("faction", ""))
        if actor_id == "" or faction == "":
            continue
        var record := {"actor_id": actor_id, "faction": faction}
        if faction == "crew":
            var tribute := _resolve_tribute(actor_id)
            record["tribute_cite"] = tribute
            record["died_at_run"] = _current_run_id()
            result["tributes"].append(tribute)
            _journal_append(actor_id, tribute)
            result["journal_entries"].append({"actor_id": actor_id, "tribute": tribute})
        result["casualties"].append(record)
    return result

static func _resolve_tribute(actor_id: String) -> String:
    var frags = NarrativeData.voice_fragments()
    if frags == null or not frags is Dictionary:
        return ""
    var pool: Array = frags.get("die_in_throes", [])
    if pool.is_empty():
        return ""
    return str(pool[int(randi() % pool.size())])

static func _journal_append(actor_id: String, tribute: String) -> void:
    if not has_node("/root/CaptainsJournal"):
        return
    var cj: Object = get_node("/root/CaptainsJournal")
    var actor_data = _get_actor_meta(actor_id)
    var captain_id: String = actor_data.get("captain_id", "unknown")
    var day: int = actor_data.get("day_index", 0)
    cj.append(captain_id, actor_id, day, tribute)

static func _current_run_id() -> String:
    return Time.get_datetime_string_from_system().replace(" ", "T")

static func _get_actor_meta(actor_id: String) -> Dictionary:
    var st = Persist.get_state()
    var ledger = st.get("ledger", {})
    var captains = ledger.get("captains", {})
    for cid in captains:
        var crew_block = captains[cid].get("crew", {})
        if crew_block.has(actor_id):
            var meta = crew_block[actor_id].duplicate(true)
            meta["captain_id"] = cid
            return meta
    return {}

static func set_captain_for_run(captain_id: String, day_index: int) -> void:
    _current_captain_id = captain_id
    _current_day_index = day_index
