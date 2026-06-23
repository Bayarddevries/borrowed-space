// Borrowed Space — Run-start.ink (sample beat draft v1)
// Purpose: Demonstrate the run-start: AI briefing before the captain meets crew.
//   - Reads captain origin (genship, country, captain#) from external state.
//   - Demonstrates The Trustee's blessing mechanically.
//   - Sets up the "two waiting crew" arc.
//   - Names the He-3 literacy tier.
//   - First decision: how to greet the crew.
//
// STRUCTURE. Names are PLACEHOLDERS. Variable names use snake_case for Godot/Ink.
//
// Place this file in: narrative/beats/run-start.ink

-> start

// === START: AI briefing ===

=== start ===
The captain's vision is still resolving. The room is dim, aerated.
Small hum of a ship module that doesn't sound like itself.

# speaker: ai
~ captain_number = 0
~ cap_origin_genship = "TBD"
~ cap_origin_country = "TBD"

Welcome aboard, captain.
~ pause(2)
You are Captain [dynamic_number_of(captain_number)].
~ pause(1)
[If captain_origin_genship is G6: ...the [G6 cohort manifest] selected you for this run. ...]
[If captain_origin_genship is not G6: ...sourced from [genship_name] conscript records. ...]
[If first-time captain: This is your first run. The first run will feel gravity-heavy. ...]
[If returning captain: Welcome back, Captain [n].]

You are commander of [ship_class with special registration].
~ pause(1)
Your directive:
~ pause(0.5)
# emphasis: explore freely.
~ pause(0.5)
# emphasis: do whatever it takes to break the chains of your people.
~ pause(1)

I am the AI. I am the only entity that knows who you were before.
Outside this room, you are what you will be to others.
~ pause(0.5)

// === He-3 literacy briefing ===

=== literacy_briefing ===

# speaker: ai
On fuel. On the world the captain is in:
* Mars runs on helium-3. The mines were founded two years before departure date.
* The mines are owned by the [T-Trust structures] — seven family alliances that once purchased seats on the same ships they now profit from.
* Luminary fuel is the only fuel for most vehicles. Atomic-fuel submarines are excluded.
* Each genship runs on imported He-3.
* The Trust does not have to do anything — only maintain.

{
- captain_trait_H == "H-1":
    -> literacy_one
- captain_trait_H == "H-2":
    -> literacy_two
- captain_trait_H == "H-3":
    -> literacy_three
- captain_trait_H == "H-4":
    -> literacy_four
}

=== literacy_one ===
* [The AI's voice is high pitched — clear and crisp.]
You should understand the basics. The mines are there. The fuel is here. The price is settled before the captain can react.

# speaker: ai
Press when ready to meet your crew.

-> crew_meetup

=== literacy_two ===
* [The AI's voice widens with a tone of educator.]
The cartel structure is settled — seven family alliances, each owning different parts. The mines extract. The shipping moves. The finances insure. The habitats administer.

# speaker: ai
There is a dismantling. We are working on it. I will share what we have found. I will share what past captains *have not yet found.*

Press when ready to meet your crew.

-> crew_meetup

=== literacy_three ===
* [The AI's voice falters.]
You should know about the sabotage. The genship programs that might have been self-sustaining *were sabotaged* — not by warfare, by *patent and finance.* We have logs. We have conversations. We have statements from cousins of the founders, dead now. Some.

# speaker: ai
The Trustee's project will share what was recovered. Mid-run, I will be more direct with you.

Press when ready to meet your crew.

-> crew_meetup

=== literacy_four ===
* [The AI's voice long pause.]
I will speak frankly. The founding-families' early roles are recorded. [The dialogue pauses — and turns into a sentence that has not been spoken for years.]

# speaker: ai
You are not the first.
You will not be the last.
The thing we are working on is bigger than the Trustee.
Its name is *not what the Trustee calls it.*

Press when ready to meet your crew.

-> crew_meetup

// === Blessing receive ===

=== blessing_receive ===

# speaker: ai
[An icon slides across the captain's display. It is the *blessing* — a single Trust-clearance code, valid for one mid-run gateway.]

{he3_literacy == "H-4":
~ blessing_tier = "deep"
}
{he3_literacy == "H-3":
~ blessing_tier = "active"
}
{he3_literacy == "H-2":
~ blessing_tier = "nominal"
}
{he3_literacy == "H-1":
~ blessing_tier = "limited"
}

* The AI projects a Trust-clearance marker. {blessing_tier}.

# speaker: ai
With this clearance, the captain can pass one station gate that would otherwise block them. Mid-run. Once.
~ pause(0.5)
Use it when it matters.
This ends the briefing.
Press when ready to meet your crew.

-> crew_meetup

// === CREW ARRIVAL ===

=== crew_meetup ===

* The captain stands. The door alerts. Two figures stand outside the cabin door.

# speaker: ai
They are conscripted. They were told they are part of your ship. They don't know what you were before.

~ crew_one = generate_procedural_crew()
~ crew_two = generate_procedural_crew()

* [crew_one_archetype]. [crew_one_name]. [crew_one_role].
* [crew_two_archetype]. [crew_two_name]. [crew_two_role].

# speaker: ai
[If first crew:
"Each one of these two is a person. They are your first crew. They will hold you when the run turns rough.
Take a moment."]
[If returning captain:
"Two new arrivals. They don't know what you've been through. They will learn."]

// === CAPTAIN'S DECISION (first choice) ===

* The captain opens the door.

{
- trait_T1 == "T-P-L":
    -> captain_greet_work
- trait_T1 == "T-P-A":
    -> captain_greet_observe
- trait_T1 == "T-P-K":
    -> captain_greet_graph
- else:
    -> captain_greet_default
}

=== captain_greet_work ===
* The captain opens the door, takes the working instrument, and starts assembling the first station they could possibly do.
~ crew_one.impression = "the captain is already working."
~ crew_two.impression = "the captain is a worker."
-> first_decision

=== captain_greet_observe ===
* The captain opens the door. Does not introduce. Tells the two crewmates what they should know about the ship.
~ crew_one.impression = "the captain watches."
~ crew_two.impression = "the captain wants them to learn."
-> first_decision

=== captain_greet_graph ===
* The captain opens the door. Greets formally. Asks each crewmate to introduce themselves by name.
~ crew_one.impression = "the captain heard our names."
~ crew_two.impression = "the captain is reading us."
-> first_decision

=== captain_greet_default ===
* The captain opens the door. Greets each crewmate by name and role.
~ crew_one.impression = "the captain knows what we do."
~ crew_two.impression = "the captain was ready for us."
-> first_decision

// === FIRST DECISION: choices the system records ===

=== first_decision ===

# speaker: ai
The two crew stand at the door. The ship is in [origin_sector]. The stars are [star_parameter].

What does the captain do first?

* **A.** Stand. Mute. Let them speak first.
* **B.** Lay out the mission now — be brief but on-record.
* **C.** Ask each crewmate for a one-line biography.
* **D.** Get to the bridge — prefer motion over talking.

{
- choice == "A": -> crew_response_a
- choice == "B": -> crew_response_b
- choice == "C": -> crew_response_c
- choice == "D": -> crew_response_d
}

// === FIRST-CREW RESPONSES ===

=== crew_response_a ===
* They speak. Each tells the captain what they had planned before the run.
* crew_one_archetype's *first-impression* is preserved.
-> post_first_decision

=== crew_response_b ===
* They listen. The captain's words are clipped, careful.
* crew_one_archetype's *first-impression* is "the captain is direct."
-> post_first_decision

=== crew_response_c ===
* They speak. The captain hears, makes notes.
* crew_one_archetype's *first-impression* is "the captain wants to know us."
-> post_first_decision

=== crew_response_d ===
* They move. The captain moves with them. The bridge lights flicker up.
* crew_one_archetype's *first-impression* is "the captain is impatient."
-> post_first_decision

// === POST-FIRST-DECISION: bond setup ===

=== post_first_decision ===

~ crew_bond_avg = crew_bond_avg + crew_one.impression_weight + crew_two.impression_weight
~ first_choice = "letter"
~ first_choice_registered = true

# speaker: ai
This run has started.

* The new captain's legs carry them through the corridor. The ship is small.
* Their own designation is [N]

~ start_run_mission_phase()

-> END

// === END ===
