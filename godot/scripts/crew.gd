extends Node
## Crew — procedurally-generated crew member for the current run.
##
## Phase 2g. Bound to one NPC archetype variant per crew slot.
## Reads npc-archetypes.json via NarrativeData; rolls variant + trait pool.
##
## State Vector (per NPCS.md §state-vector, except where per-run-only):
## - archetype_id, variant_id       — fixed per slot
## - name                            — procedural (placeholder fragments; no lore)
## - bond_score                      — start at 0; per-run only
## - held_trust                      — variant default; persisted cross-run
## - memory_log                      — empty at first meeting
##
## API:
##   - generate(archetype_id: String) -> Dictionary   # returns a crew record
##   - to_record() -> Dictionary                       # already-generated record
class_name Crew

const _NAME_FRAGMENTS := {
	"NPC1": ["Thea", "Esther", "Marcell", "Yusra", "Halia", "Ovela", "Danial", "Pell"],
	"NPC2": ["Idris", "Sera", "Huo", "Vetch", "Auriga", "Quince", "Nileh"],
	"NPC3": ["André", "Mara", "Vargas", "Tomás", "Séverine", "Olusola", "Yuki"],
}

var archetype_id: String
var variant_id: String
var crew_name: String       # Node.name is a built-in, can't shadow
var bond_score: int = 0
var held_trust: int = 0
var memory_log: Array = []

# Pick a variant at random given an archetype's variant list.
# Returns a fresh Crew record as a Dictionary; the host can wrap it if needed.
static func generate(archetype_id: String) -> Dictionary:
	var archs = NarrativeData.npc_archetypes()
	if archs == null:
		push_error("[Crew] cannot read npc-archetypes.json")
		return {}
	for arch in archs["archetypes"]:
		if arch["archetype_id"] == archetype_id:
			var variants: Array = arch["variants"]
			var v = variants[Dice.roll(variants.size()) - 1]
			var names: Array = _NAME_FRAGMENTS.get(archetype_id, ["[NAME] PLACEHOLDER"])
			var name_frag: String = names[Dice.roll(names.size()) - 1]
			return {
				"archetype_id": archetype_id,
				"variant_id": v["variant_id"],
				"name": name_frag,
				"bond_score": 0,
				"held_trust": v["trust_seed"],
				"memory_log": [],
				"voice_fragments": v["voice_fragments"],
			}
	push_error("[Crew] archetype not found: %s" % archetype_id)
	return {}
