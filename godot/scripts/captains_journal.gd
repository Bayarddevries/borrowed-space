extends Node
## CaptainsJournal — in-memory append-only journal per captain.
##
## Contract:
##   CaptainsJournal.append(captain_id, fragment_id, day_index)
##   CaptainsJournal.get_entries(captain_id) -> Array[Dictionary]
##   CaptainsJournal.clear(captain_id)
##
## Persistence is handled via Persist.patch(state). Every call to
## append() writes the new entry into state.ledger.captains[captain_id].journal.
## In-memory cache mirrors what's on disk so reads are cheap.
class_name CaptainsJournal

# Structure: { captain_id: { name: String, journal: Array[Dictionary] } }
var _store: Dictionary = {}

func _init() -> void:
    refresh_from_persist()

func refresh_from_persist() -> void:
    ## Best-effort re-sync when the singleton is created.
    ## If Persist is not yet loaded (rare), skip.
    if not has_node("/root/Persist"):
        return
    var state: Dictionary = Persist.get_state()
    var captains: Dictionary = state.get("ledger", {}).get("captains", {})
    for cid in captains:
        var entry: Dictionary = captains[cid]
        if not _store.has(cid):
            _store[cid] = {"name": entry.get("name", ""), "journal": []}
        # Merge existing on-disk journal into cache (append semantics).
        var disk_journal: Array = entry.get("journal", [])
        var cached: Array = _store[cid]["journal"]
        # Deduplicate by fragment_id+day so refresh doesn't double entries.
        var seen: Dictionary = {}
        for j in disk_journal:
            seen["%s_%d" % [str(j.get("fragment_id", "")), int(j.get("day", -1))]] = j
        for j in cached:
            seen["%s_%d" % [str(j.get("fragment_id", "")), int(j.get("day", -1))]] = j
        _store[cid]["journal"] = seen.values()

func append(captain_id: String, fragment_id: String, day_index: int, text: String = "") -> void:
    ## Append a journal entry. Writes through Persist immediately.
    ##
    ## Args
    ##   captain_id: key in state.ledger.captains (e.g. "captain_01")
    ##   fragment_id: the fragment id from voice_fragments.json
    ##                (e.g. "captain_journal_017")
    ##   day_index: run day (0 = first day of this captain's tenure)
    ##   text: full text string; optional because the caller may
    ##         already have resolved it from the corpus.
    if not _store.has(captain_id):
        _store[captain_id] = {"name": "", "journal": []}
    var entry: Dictionary = {
        "day": day_index,
        "fragment_id": fragment_id,
        "text": text,
    }
    _store[captain_id]["journal"].append(entry)
    _persist_journal(captain_id)

func get_entries(captain_id: String) -> Array:
    ## Return a copy so callers can inspect but not mutate directly.
    if not _store.has(captain_id):
        return []
    return _store[captain_id]["journal"].duplicate(true)

func set_captain_name(captain_id: String, name: String) -> void:
    if not _store.has(captain_id):
        _store[captain_id] = {"name": name, "journal": []}
    else:
        _store[captain_id]["name"] = name
    _persist_journal(captain_id)

func get_captain_name(captain_id: String) -> String:
    if not _store.has(captain_id):
        return ""
    return _store[captain_id].get("name", "")

func clear(captain_id: String) -> void:
    ## Reset journal for a captain (e.g. on new run rotation).
    if _store.has(captain_id):
        _store[captain_id]["journal"] = []
    _persist_journal(captain_id)

func _persist_journal(captain_id: String) -> void:
    ## Flush the cached journal for one captain into Persist.
    ## Structure matches docs/PERSISTENCE.md §3 captain schema.
    if not has_node("/root/Persist"):
        push_warning("[CaptainsJournal] Persist not found; journal not persisted.")
        return
    var patch: Dictionary = {
        "ledger": {
            "captains": {
                captain_id: {
                    "journal": _store[captain_id]["journal"]
                }
            }
        }
    }
    var ok := Persist.patch(patch)
    if ok:
        Persist.save()
    else:
        push_error("[CaptainsJournal] Persist.patch failed for captain %s" % captain_id)
