extends StaticBody3D
## A hidden document / physical clue lying in the world. On interact it is
## added to the journal (see JournalManager) and then hides itself.

@export var clue_id: String = ""

var _collected: bool = false


func _ready() -> void:
	add_to_group("interactable")
	if JournalManager.has_clue(clue_id):
		_mark_collected()


func get_interact_prompt() -> String:
	if _collected:
		return ""
	return "Pick up document"


func interact(_player: Node) -> void:
	if _collected:
		return
	if JournalManager.add_clue(clue_id):
		_mark_collected()


func _mark_collected() -> void:
	_collected = true
	visible = false
	collision_layer = 0
	remove_from_group("interactable")
