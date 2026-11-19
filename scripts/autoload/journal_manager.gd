extends Node
## Autoload singleton: the player's journal. Holds every clue in the game,
## which ones have been discovered, and a running suspicion score per
## villager built entirely from the clues the player has found.
##
## To add a new clue: add an entry to CLUE_DB, then call
## JournalManager.add_clue("your_id") from a dialogue tree (see
## DialogueDatabase) or from a ClueItem placed in the level.

signal clue_discovered(clue_id: String)

## clue_id -> { title, text, weights: { suspect_id: int } }
## "weights" nudge how suspicious each named villager looks; they are
## flavour/guidance only -- the actual plague doctor is whichever NPC
## instance has is_doctor = true in the level.
const CLUE_DB: Dictionary = {
	"letter_physician_mask": {
		"title": "A Half-Burned Letter",
		"text": "\"...the physician must wear the mask when the moon is low, lest they be known...\" The rest is ash.",
		"weights": {"edgar": 2, "aldric": 1},
	},
	"aldric_sermon_note": {
		"title": "Father Aldric's Sermon Notes",
		"text": "\"Beware the quack physicians who hide among decent folk, preying on the dying for coin.\"",
		"weights": {"aldric": 1},
	},
	"beatrice_ring": {
		"title": "A Signet Ring",
		"text": "A small ring stamped with a serpent coiled around a staff -- a physician's mark -- dropped near the well before dawn.",
		"weights": {"edgar": 2},
	},
	"ledger_herbs": {
		"title": "A Torn Ledger Page",
		"text": "An unusually large order of nightshade and foxglove, paid for under the name 'E. Vance.'",
		"weights": {"edgar": 3},
	},
	"mira_about_edgar": {
		"title": "Mira's Admission",
		"text": "A quiet man borrowed Mira's rarest herbs, \"for a cough,\" he said -- though she never once heard him cough.",
		"weights": {"edgar": 2, "mira": -1},
	},
	"tomas_death_records": {
		"title": "The Gravedigger's Count",
		"text": "Burials slowed strangely once a stranger took the old apothecary house at the village's edge.",
		"weights": {"edgar": 2, "tomas": -1},
	},
	"tomas_night_visitor": {
		"title": "A Late Visitor",
		"text": "A cloaked figure was seen slipping toward the quarantine house well past curfew, moving like someone who knew exactly where to step.",
		"weights": {"edgar": 2},
	},
	"beatrice_gossip_lights": {
		"title": "Candlelight After Curfew",
		"text": "The apothecary's window burns candlelight long after curfew, every single night.",
		"weights": {"edgar": 2},
	},
	"edgar_slip": {
		"title": "A Physician's Slip",
		"text": "Pressed about dosages, Edgar answered with a precision no mere apothecary should have -- then caught himself, too late.",
		"weights": {"edgar": 3},
	},
}

const SUSPECT_NAMES: Dictionary = {
	"aldric": "Father Aldric",
	"mira": "Mira the Herbalist",
	"tomas": "Old Tomas",
	"beatrice": "Beatrice the Baker",
	"edgar": "Edgar the Apothecary",
}

var discovered: Array[String] = []
var suspicion: Dictionary = {
	"aldric": 0,
	"mira": 0,
	"tomas": 0,
	"beatrice": 0,
	"edgar": 0,
}


## Adds a clue if it isn't already known. Returns true if it was newly added.
func add_clue(clue_id: String) -> bool:
	if not CLUE_DB.has(clue_id):
		push_warning("JournalManager: unknown clue id '%s'" % clue_id)
		return false
	if discovered.has(clue_id):
		return false
	discovered.append(clue_id)
	var weights: Dictionary = CLUE_DB[clue_id].get("weights", {})
	for suspect_id in weights.keys():
		if suspicion.has(suspect_id):
			suspicion[suspect_id] += int(weights[suspect_id])
	clue_discovered.emit(clue_id)
	return true


func has_clue(clue_id: String) -> bool:
	return discovered.has(clue_id)


func get_discovered_clue_ids() -> Array[String]:
	return discovered.duplicate()


func get_clue_data(clue_id: String) -> Dictionary:
	return CLUE_DB.get(clue_id, {})


func get_suspicion(suspect_id: String) -> int:
	return int(suspicion.get(suspect_id, 0))


## A short, flavourful readout of how suspicious each villager seems so far,
## ranked highest to lowest. Shown in the journal UI.
func get_suspicion_summary() -> String:
	var entries: Array = []
	for suspect_id in suspicion.keys():
		entries.append([suspect_id, suspicion[suspect_id]])
	entries.sort_custom(func(a, b): return a[1] > b[1])
	var result := "Your suspicions:"
	for entry in entries:
		result += "\n%s -- %s" % [SUSPECT_NAMES.get(entry[0], entry[0]), _suspicion_word(entry[1])]
	return result


func _suspicion_word(value: int) -> String:
	if value <= 0:
		return "no real suspicion"
	elif value <= 2:
		return "a little suspicious"
	elif value <= 4:
		return "quite suspicious"
	else:
		return "very suspicious"


func reset() -> void:
	discovered.clear()
	for suspect_id in suspicion.keys():
		suspicion[suspect_id] = 0
