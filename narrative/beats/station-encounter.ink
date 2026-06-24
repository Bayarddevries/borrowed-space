// Borrowed Space — Station Encounter Beats (Phase 3a.1)
// Purpose: Three destination types from the overworld choice, each with
//   meaningful choices that produce deltas the travel system and ledger read.
//   These beats slot into the TransitResult hook: when arrival_kind ==
//   "station_hex", the AI routes here based on the destination_picked delta.
//
// STRUCTURE. Names are PLACEHOLDER. Variable names use snake_case.
// The JSON manifest (run-start-manifest.json) is the runtime source;
// this .ink file is the canonical narrative source for when inkjs lands.
//
// Place this file in: narrative/beats/station-encounter.ink

-> station_arrival_refuel

// === REFUELING OUTPOST ===
// Conservative destination. Low risk, steady reward.
// TransitResult: arrival_kind = "station_hex", destination_picked = "refueling"

=== station_arrival_refuel ===
# speaker: narrator
The outpost is a tethered cluster of fuel bladders and a single loading arm. A tech in patched coveralls waves you to the pump bay without looking up. The hum is steady. Nothing here surprises anyone.

* Refuel and pay standard rate.
    -> station_refuel_standard
* Ask the tech if she runs credit.
    -> station_refuel_credit
* Skip refuel — you have enough.
    -> end_of_run_1

=== station_refuel_standard ===
# speaker: ai
Fuel +25. The ledger logs the outpost as visited. {crew_name_one} checks the moorings. The tech moves on to her next job before you thank her.

-> end_of_run_1

=== station_refuel_credit ===
# speaker: narrator
The tech finally looks up. "Credit runs through the {genship_id} ledger — you'll settle at quarter-end." She taps a slate. Fuel flows. The rate is the same. The debt is now institutional.

* Accept the terms.
    -> end_of_run_1
* Refuse — pay upfront.
    -> station_refuel_standard

// === SALVAGE DERELICT ===
// Risky destination. Higher stakes, discovery potential.
// TransitResult: arrival_kind = "station_hex", destination_picked = "derelict"

=== station_arrival_derelict ===
# speaker: narrator
The derelict hangs in a slow tumble. Hull breach on the port side — someone cut it open and welded it shut again, badly. Your docking clamp catches. {crew_name_two} runs a sniff test. The air reads stale but breathable.

* Send {crew_name_two} in alone.
    -> station_derelict_solo
* Breach together.
    -> station_derelict_group
* Log it and move on.
    -> end_of_run_1

=== station_derelict_solo ===
# speaker: crew
"Captain. I found something. A cargo manifest — the {genship_id} seal, but the date is wrong. Three years before the program started." {crew_name_two} holds out the slate. The handwriting is neat. The numbers don't add up.

* Stash the manifest. Tell no one.
    -> end_of_run_1
* Share it with the crew now.
    -> end_of_run_1

=== station_derelict_group ===
# speaker: narrator
You enter together. The corridor walls are scorched — someone ran a cutting torch along the seams, looking for something. {crew_name_one} finds a sealed locker. Inside: a Trust-clearance code, expired. But the cipher family is current.

* Take the code to the AI for analysis.
    -> end_of_run_1
* Pocket it. The AI doesn't need everything.
    -> end_of_run_1

// === CORAL TRANSIT ===
// Political destination. Social stakes, information, suspicion tradeoffs.
// TransitResult: arrival_kind = "station_hex", destination_picked = "coral"

=== station_arrival_coral ===
# speaker: narrator
Coral station is a wheel of union halls and transit authority offices. The belt's only place where genship crews mix without a handler. Your invoice-code gets you through the gate. The crowd reads it and knows what you are.

* Head to the union hall. Listen first.
    -> station_coral_hall
* Find a handler. You need work, not politics.
    -> station_coral_handler
* Avoid the crowd. Use the side docks.
    -> station_coral_silent

=== station_coral_hall ===
# speaker: narrator
The hall is loud. Three crews at a table. A {genship_id} patch on one shoulder — your genship, but a crew you've never met. They're talking about the last captain. Your predecessor. They stop when you sit down.

* "I'm the new captain. Tell me what happened to them."
    -> end_of_run_1
* Say nothing. Listen and leave.
    -> end_of_run_1

=== station_coral_handler ===
# speaker: narrator
The handler is a woman with a tablet and a tired smile. "{genship_id}. You're the new one. I've got a run — low-risk, good pay. But it goes through derelict space. Your call."

* Take the job.
    -> end_of_run_1
* Decline. You're not ready for derelict runs.
    -> end_of_run_1

=== station_coral_silent ===
# speaker: ai
You dock at the side arm. No one sees. {crew_name_one} doesn't ask why. The fuel line is unmarked — you siphon what you need. The ledger won't record this stop. But someone on the dock watched you leave.

* Log the fuel and move on.
    -> end_of_run_1

// === END-OF-RUN ===

=== end_of_run_1 ===
# speaker: ai
Run complete. Your discoveries land in the ledger. The next captain's brief will reference you.

-> END
