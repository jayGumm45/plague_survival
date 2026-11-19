extends RefCounted
class_name DialogueDatabase
## Static data store for every NPC's dialogue tree. Not an autoload --
## referenced directly as DialogueDatabase.get_tree(npc_id) from anywhere,
## since class_name scripts are globally available in Godot 4.
##
## Tree format:
## {
##   "node_id": {
##       "speaker": "Display Name",       # optional, falls back to the NPC's name
##       "text": "What they say.",
##       "choices": [
##           {
##               "text": "Player-facing choice text",
##               "next": "other_node_id",            # optional: jump to this node
##               "action": "end" | "accuse",          # optional special behaviour
##               "give_clue": "clue_id",              # optional: grants a clue
##               "requires_clue": "clue_id" or [...],  # optional: hide choice until found
##               "requires_min_suspicion": {"edgar": 6}, # optional: hide until suspicious enough
##           },
##           ...
##       ],
##   },
##   ...
## }
##
## A node with no choices (or none currently available) automatically gets
## an "End conversation" button from DialoguePanel.
## "accuse" is handled generically: if the NPC's is_doctor flag is true the
## player is cured, otherwise the "accuse_fail" node (if present) is shown.

static func get_tree(npc_id: String) -> Dictionary:
	return _TREES.get(npc_id, {})


const _TREES: Dictionary = {
	"aldric": {
		"start": {
			"speaker": "Father Aldric",
			"text": "Bless you, child. These are dark days -- the pestilence spares no one. What troubles you?",
			"choices": [
				{"text": "Have you heard talk of an undercover physician in the village?", "next": "doctor_talk"},
				{"text": "Where might I find the chapel's old records?", "next": "records"},
				{"text": "Accuse him of being the plague doctor", "action": "accuse"},
				{"text": "Leave", "action": "end"},
			],
		},
		"doctor_talk": {
			"speaker": "Father Aldric",
			"text": "A physician, hiding among us? I have heard whispers. Some say a healer walks these streets in secret, afraid of the mobs who'd demand miracles -- or blame them for the deaths.",
			"choices": [
				{"text": "Do you suspect anyone in particular?", "next": "suspicion"},
				{"text": "Back", "next": "start"},
			],
		},
		"suspicion": {
			"speaker": "Father Aldric",
			"text": "I keep my suspicions for God's ears, not idle gossip. Though... the old apothecary house at the village's edge has been shuttered oddly often of late.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
		"records": {
			"speaker": "Father Aldric",
			"text": "The parish records are open to any troubled soul. There, among the pews -- mind the dust.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
		"accuse_fail": {
			"speaker": "Father Aldric",
			"text": "Me? A physician? I bury the dead, child, I do not heal them. You are mistaken -- and your time is short. Look elsewhere.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
	},
	"mira": {
		"start": {
			"speaker": "Mira",
			"text": "Herbs for your fever? I have little left -- everyone wants a cure these days, and I can't make miracles.",
			"choices": [
				{"text": "Has anyone bought unusual amounts of herbs lately?", "next": "herbs"},
				{"text": "Accuse her of being the plague doctor", "action": "accuse"},
				{"text": "Leave", "action": "end"},
			],
		},
		"herbs": {
			"speaker": "Mira",
			"text": "Now that you mention it... a quiet man came by more than once, always alone, always at dusk. Took my rarest nightshade and foxglove, said it was 'for a cough.' I never once heard him cough.",
			"choices": [
				{"text": "Who was he?", "next": "reveal"},
				{"text": "Back", "next": "start"},
			],
		},
		"reveal": {
			"speaker": "Mira",
			"text": "Edgar. The apothecary at the edge of town. Odd fellow -- keeps to himself, keeps his shutters closed.",
			"choices": [
				{"text": "(Note this down)", "give_clue": "mira_about_edgar", "next": "start"},
			],
		},
		"accuse_fail": {
			"speaker": "Mira",
			"text": "Me, the doctor? I sell dried thyme and hope, nothing more. Whoever you're looking for, it isn't me -- and you're wasting precious hours.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
	},
	"tomas": {
		"start": {
			"speaker": "Old Tomas",
			"text": "Digging graves is honest work, even in plague years. What do you want, another count of the dead?",
			"choices": [
				{"text": "Has the dying slowed at all?", "next": "death_count"},
				{"text": "Accuse him of being the plague doctor", "action": "accuse"},
				{"text": "Leave", "action": "end"},
			],
		},
		"death_count": {
			"speaker": "Old Tomas",
			"text": "Funny thing -- the burials slowed, not long after that stranger took the old apothecary house on the edge of town. Can't say if it's coincidence.",
			"choices": [
				{"text": "(Note this down)", "give_clue": "tomas_death_records", "next": "visitor_prompt"},
			],
		},
		"visitor_prompt": {
			"speaker": "Old Tomas",
			"text": "Something else bother you, or are you still digging for gossip?",
			"choices": [
				{"text": "Have you seen anyone sneaking around at night?", "next": "visitor", "requires_clue": "tomas_death_records"},
				{"text": "Back", "next": "start"},
			],
		},
		"visitor": {
			"speaker": "Old Tomas",
			"text": "Once. A cloaked figure, well past curfew, slipping toward the quarantine house like he'd walked that path a hundred times. Moved too sure-footed for a frightened villager.",
			"choices": [
				{"text": "(Note this down)", "give_clue": "tomas_night_visitor", "next": "start"},
			],
		},
		"accuse_fail": {
			"speaker": "Old Tomas",
			"text": "Ha! I bury folk, I don't save them. Look to the living, not the gravedigger.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
	},
	"beatrice": {
		"start": {
			"speaker": "Beatrice",
			"text": "Bread's thin these days, but I've still got an ear for every bit of gossip in this village.",
			"choices": [
				{"text": "Heard anything strange lately?", "next": "gossip"},
				{"text": "Accuse her of being the plague doctor", "action": "accuse"},
				{"text": "Leave", "action": "end"},
			],
		},
		"gossip": {
			"speaker": "Beatrice",
			"text": "Only that the apothecary's window burns candlelight long after curfew, every single night. A man alone doesn't need that much light unless he's hiding something.",
			"choices": [
				{"text": "(Note this down)", "give_clue": "beatrice_gossip_lights", "next": "ring_prompt"},
			],
		},
		"ring_prompt": {
			"speaker": "Beatrice",
			"text": "Oh -- and someone lost a ring by the well. I left it lying there; didn't want trouble over another's trinket.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
		"accuse_fail": {
			"speaker": "Beatrice",
			"text": "Me, a physician? I can barely keep flour in the bin! Try the apothecary, if you ask me -- but don't quote me on it.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
	},
	"edgar": {
		"start": {
			"speaker": "Edgar",
			"text": "Another sick soul at my door. I sell remedies, nothing more -- I can't cure the pestilence, if that's what you've come for.",
			"choices": [
				{"text": "Ask about the undercover physician", "next": "deflect"},
				{"text": "Press him about his herb purchases", "next": "slip", "requires_min_suspicion": {"edgar": 6}},
				{"text": "Accuse him of being the plague doctor", "action": "accuse"},
				{"text": "Leave", "action": "end"},
			],
		},
		"deflect": {
			"speaker": "Edgar",
			"text": "A physician in hiding? I wouldn't know. If I were him, I'd hide too -- this village burns healers as readily as it thanks them.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
		"slip": {
			"speaker": "Edgar",
			"text": "You want to know about dosages? Nightshade in careful measure slows the fever, foxglove steadies a failing heart, and--",
			"choices": [
				{"text": "(He catches himself too late)", "give_clue": "edgar_slip", "next": "slip_caught"},
			],
		},
		"slip_caught": {
			"speaker": "Edgar",
			"text": "...that is, so I've heard apothecaries say. Forget I spoke.",
			"choices": [
				{"text": "Accuse him of being the plague doctor", "action": "accuse"},
				{"text": "Back", "next": "start"},
			],
		},
		"accuse_fail": {
			"speaker": "Edgar",
			"text": "You're mistaken. I only sell what little comfort I can. Go, before the fever takes your wits as well as your strength.",
			"choices": [
				{"text": "Back", "next": "start"},
			],
		},
	},
}
