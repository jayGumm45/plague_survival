extends Control

@onready var list_box: VBoxContainer = $Center/Panel/Margin/VBox/Scroll/ListBox
@onready var hint_label: Label = $Center/Panel/Margin/VBox/HintLabel


func refresh() -> void:
	for child in list_box.get_children():
		child.queue_free()

	var ids := JournalManager.get_discovered_clue_ids()
	if ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No clues discovered yet. Explore the village and talk to its people."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		list_box.add_child(empty_label)
	else:
		for id in ids:
			var data := JournalManager.get_clue_data(id)
			var entry := Label.new()
			entry.text = "- %s\n   %s" % [data.get("title", id), data.get("text", "")]
			entry.autowrap_mode = TextServer.AUTOWRAP_WORD
			list_box.add_child(entry)

	hint_label.text = JournalManager.get_suspicion_summary()
