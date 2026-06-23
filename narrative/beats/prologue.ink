// Borrowed Space — Prologue.ink (sample beat draft v0)
// Purpose: Demonstrate the storytelling layer end-to-end.
//   - Reads captain traits from external state.
//   - References the ledger (past-run crew names).
//   - Runs a cover-test.
//   - Forks into three branches based on the roll.
//
// This is a STRUCTURAL DEMO. Names are PLACEHOLDERS.
// Variable names use snake_case for Godot/Ink interop.
//
// Place this file in: narrative/beats/prologue.ink

// === TARGET: a passing-station encounter. ===

-> start

=== start ===
# speaker: narrator
~ count = 0
The transit station {station_name} is the kind of place you see on a deck log—#+atmosphere: station_transit_hum +.
* Thea Salt ({crew_name_one}) trims a corridor sweep of debris as she passes.

- -> encounter_1

=== encounter_1 ===
# speaker: narrator
A station deputy in {faction_name_a} livery steps into your path. He reads your invoice-code twice.
* "Captain. We haven't had a {genship_brief} passenger this cycle. Anything to declare?"

# speaker: captain
~ has_band2_lexicon = (captain_archetype == "coalition_heir" || captain_archetype == "ff_ward")
The captain's response folds at the threshold of {has_band2_lexicon ? "operator idioms" : "msc-mode linguist measures"}.

// Branch selection: the cover-test.
- (cover_test)

=== cover_test ===
// Cover-test result determines which branch the captain enters.
// Each branch has a different consequence.
~ cover_test_threshold = 7
~ roll = LOWEST_TRAIT + (suspicion_meter * -1) + hidden_factor

{
- roll >= cover_test_threshold + 2:
    -> branch_pass_clean
- roll >= cover_test_threshold - 1:
    -> branch_pass_rough
- roll >= cover_test_threshold - 2:
    -> branch_fail_soft
- else:
    -> branch_fail_hard
}

=== branch_pass_clean ===
~ suspicion_meter = suspicion_meter
~ ledger_clean_pass = ledger_clean_pass + 1
~ station_renown = station_renown + 1
The invoice-code is accepted. The deputy moves on.
* {crew_name_two} murmurs on deck log: "That went well."
-> END

=== branch_pass_rough ===
~ suspicion_meter = suspicion_meter + 1
~ ledger_clean_pass = ledger_clean_pass
* The deputy's hand lingers on the clipboard.
~ ({dynamic_npc} at the deputy desk logs your invoice against rule.)
-> END

=== branch_fail_soft ===
~ suspicion_meter = suspicion_meter + 2
~ ledger_clean_pass = 0
The deputy pauses. "Captain. We're going to need to step inside a moment."
* {crew_name_one} straightens from the cabinet beside you. The crowd shifts.
-> defensive_response

=== defensive_response ===
{
- has_band2_lexicon || LOWEST_TRAIT > 4:
    -> defensive_pass
- else:
    -> defensive_break
}

=== defensive_pass ===
You produce a station-clearance counterweight. The deputy's posture changes.
* "Apologies, Captain. Welcome to {station_name}."
~ ledger_clean_pass = 1
-> END

=== defensive_break ===
"You can wait on your crew while we verify." The deputy's tone sinks.
* A name surfaces from your {genship_brief} archive: someone on this station knew your fiction once.
~ suspicion_meter = suspicion_meter + 2
-> END

=== branch_fail_hard ===
~ suspicion_meter = suspicion_meter + 4
~ ledger_clean_pass = 0
The deputy leans on a comm-key. Within thirty seconds, two more show.
* {crew_name_three} appears from a side corridor. The crowd's attention is the captain's.
-> hard_break_response

=== hard_break_response ===
{
- captain_archetype == "substitute_body":
    -> hard_break_substitute
- captain_archetype == "coalition_heir":
    -> hard_break_coalition
- else:
    -> hard_break_ward
}

=== hard_break_substitute ===
You return to the room. The crew assembled under audit; the deputy reads a name aloud.
* The captain does not recognize it. The crew does.
~ suspicion_meter = suspicion_meter + 2
~ arC_reveal_band4 = true
-> END

=== hard_break_coalition ===
A second deputy steps forward with a {hand_signal_a} — {G3_exposition}.
* The crew sees the moment. They question the captain in your ear. You can't answer them not here.
~ suspicion_meter = suspicion_meter + 2
-> END

=== hard_break_ward ===
* {crew_name_one} pulls her deck log toward her. The crowd settles.
A {F1_name} lieutenant makes the call.
~ ledger_audit_filed = true
-> END

// === END ===
