{
  "_meta": {
    "schema": "C",
    "version": "0.1",
    "description": "Dialogue beat schema (Schema C). Multi-line, per-speaker dialogue with conditional branching. Drop-in replacement for the prose+choice format.",
    "instructions": "To add a dialogue scene: create a .json file in narrative/dialogues/ with one or more dialogue scenes. Each scene has an id, metadata, and a lines array. Each line has a speaker, text, and optional choices. Choices can have conditions, deltas, and next targets."
  },
  "example_dialogue": {
    "id": "t1_inspector_first_contact",
    "metadata": {
      "mode": "overlay",
      "bg": "res://assets/sprites/bg_briefing.png",
      "npc": "t1_inspector_vos"
    },
    "lines": [
      {
        "speaker": "t1_inspector_vos",
        "text": "Your transponder's clean. I know. This is theatre.",
        "choices": null
      },
      {
        "speaker": "t1_inspector_vos",
        "text": "Someone filed a priority override on your route. Normally that means a Trust audit. But the override came from a genship code. Not a Trust code.",
        "choices": null
      },
      {
        "speaker": "t1_inspector_vos",
        "text": "I'm supposed to detain you while they verify. I'm not going to do that.",
        "choices": null
      },
      {
        "speaker": "player",
        "text": "",
        "choices": [
          {
            "label": "\"Why not?\"",
            "next": "t1_vos_why_not"
          },
          {
            "label": "\"Who filed the override?\"",
            "condition": {
              "fact": "captain.genship",
              "op": "==",
              "value": "NAC"
            },
            "next": "t1_vos_override"
          },
          {
            "label": "Stay silent. Let them fill the space.",
            "delta": {
              "suspicion_delta": 1
            },
            "next": "t1_vos_silence"
          }
        ]
      }
    ]
  }
}
