extends Control

@onready var name_label: Label = $Center/Panel/Margin/VBox/NameLabel
@onready var text_label: Label = $Center/Panel/Margin/VBox/TextLabel
@onready var choices_box: VBoxContainer = $Center/Panel/Margin/VBox/ChoicesBox

var _tree: Dictionary = {}
var _npc_ref: Node = null
var _npc_display_name: String = ""


func open(npc_name: String, tree: Dictionary, npc_ref: Node) -> void:
	_tree = tree
	_npc_ref = npc_ref
	_npc_display_name = npc_name
	_show_node("start")


func close() -> void:
	_tree = {}
	_npc_ref = null
	for child in choices_box.get_children():
		child.queue_free()


func _show_node(node_id: String) -> void:
	if not _tree.has(node_id):
		UIManager.close_dialogue()
		return

	var node_data: Dictionary = _tree[node_id]
	name_label.text = node_data.get("speaker", _npc_display_name)
	text_label.text = node_data.get("text", "")

	for child in choices_box.get_children():
		child.queue_free()

	var choices: Array = node_data.get("choices", [])
	var shown_any := false
	for choice in choices:
		if not _choice_available(choice):
			continue
		shown_any = true
		var button := Button.new()
		button.text = choice.get("text", "...")
		button.pressed.connect(_on_choice_selected.bind(choice))
		choices_box.add_child(button)

	if not shown_any:
		var close_button := Button.new()
		close_button.text = "End conversation"
		close_button.pressed.connect(UIManager.close_dialogue)
		choices_box.add_child(close_button)


func _choice_available(choice: Dictionary) -> bool:
	if choice.has("requires_clue"):
		var req = choice["requires_clue"]
		if req is String:
			if not JournalManager.has_clue(req):
				return false
		elif req is Array:
			for id in req:
				if not JournalManager.has_clue(id):
					return false
	if choice.has("requires_min_suspicion"):
		var reqs: Dictionary = choice["requires_min_suspicion"]
		for suspect_id in reqs.keys():
			if JournalManager.get_suspicion(suspect_id) < int(reqs[suspect_id]):
				return false
	return true


func _on_choice_selected(choice: Dictionary) -> void:
	if choice.has("give_clue"):
		JournalManager.add_clue(choice["give_clue"])

	var action: String = choice.get("action", "")
	match action:
		"end":
			UIManager.close_dialogue()
			return
		"accuse":
			_handle_accusation()
			return

	var next_id: String = choice.get("next", "")
	if next_id == "":
		UIManager.close_dialogue()
	else:
		_show_node(next_id)


func _handle_accusation() -> void:
	if _npc_ref != null and _npc_ref.is_doctor:
		GameManager.cure_player()
	else:
		_show_node("accuse_fail")
