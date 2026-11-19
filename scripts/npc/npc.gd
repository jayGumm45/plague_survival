extends StaticBody3D
## A villager the player can talk to. Set npc_id to match a key in
## DialogueDatabase, and flip is_doctor to true on exactly one NPC instance
## in the level -- that is the villager an "accuse" dialogue choice will
## actually cure the player against.

@export var npc_id: String = ""
@export var display_name: String = "Villager"
@export var is_doctor: bool = false


func _ready() -> void:
	add_to_group("interactable")


func get_interact_prompt() -> String:
	return "Talk to %s" % display_name


func interact(_player: Node) -> void:
	var tree := DialogueDatabase.get_tree(npc_id)
	if tree.is_empty():
		push_warning("NPC '%s' has no dialogue tree for npc_id '%s'" % [display_name, npc_id])
		return
	UIManager.start_dialogue(display_name, tree, self)
