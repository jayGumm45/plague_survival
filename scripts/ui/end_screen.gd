extends Control

@onready var title_label: Label = $Center/Panel/Margin/VBox/TitleLabel
@onready var subtitle_label: Label = $Center/Panel/Margin/VBox/SubtitleLabel
@onready var restart_button: Button = $Center/Panel/Margin/VBox/RestartButton


func _ready() -> void:
	restart_button.pressed.connect(_on_restart_pressed)


func show_result(won: bool) -> void:
	if won:
		title_label.text = "Cured"
		subtitle_label.text = "Edgar presses a small vial into your hands. By morning the fever has broken. You found the plague doctor in time."
	else:
		title_label.text = "The Plague Claims You"
		subtitle_label.text = "Three days have passed. You never found the doctor in time."


func _on_restart_pressed() -> void:
	GameManager.reset()
	JournalManager.reset()
	UIManager.reset_ui()
	get_tree().reload_current_scene()
