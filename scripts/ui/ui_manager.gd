extends Node
## Autoload singleton (as a scene): owns the persistent UI layer -- HUD,
## journal, dialogue box and the win/lose screen -- and mediates between
## them and the gameplay autoloads. Any NPC or clue can call into this
## directly by its global name, UIManager.

@onready var hud: Control = $CanvasLayer/HUD
@onready var journal_panel: Control = $CanvasLayer/JournalPanel
@onready var dialogue_panel: Control = $CanvasLayer/DialoguePanel
@onready var end_screen: Control = $CanvasLayer/EndScreen

var _journal_open: bool = false


func _ready() -> void:
	journal_panel.visible = false
	dialogue_panel.visible = false
	end_screen.visible = false

	GameManager.infection_updated.connect(hud.update_infection)
	GameManager.day_changed.connect(hud.update_day)
	GameManager.game_won.connect(_on_game_won)
	GameManager.game_lost.connect(_on_game_lost)
	JournalManager.clue_discovered.connect(_on_clue_discovered)

	hud.update_day(GameManager.get_current_day())
	hud.update_infection(GameManager.get_infection_percent())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_journal") and not dialogue_panel.visible and not end_screen.visible:
		_toggle_journal()
	elif event.is_action_pressed("ui_cancel"):
		if dialogue_panel.visible:
			close_dialogue()
		elif journal_panel.visible:
			_toggle_journal()


func _toggle_journal() -> void:
	_journal_open = not _journal_open
	journal_panel.visible = _journal_open
	if _journal_open:
		journal_panel.refresh()
	_update_lock()


func start_dialogue(npc_name: String, tree: Dictionary, npc_ref: Node) -> void:
	dialogue_panel.visible = true
	dialogue_panel.open(npc_name, tree, npc_ref)
	_update_lock()


func close_dialogue() -> void:
	dialogue_panel.visible = false
	dialogue_panel.close()
	_update_lock()


func set_interact_prompt(text: String) -> void:
	hud.set_interact_prompt(text)


func reset_ui() -> void:
	_journal_open = false
	dialogue_panel.visible = false
	journal_panel.visible = false
	end_screen.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.set_input_locked(false)


func _update_lock() -> void:
	var locked := dialogue_panel.visible or journal_panel.visible or end_screen.visible
	GameManager.set_input_locked(locked)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if locked else Input.MOUSE_MODE_CAPTURED


func _on_clue_discovered(clue_id: String) -> void:
	var data := JournalManager.get_clue_data(clue_id)
	hud.show_clue_toast(data.get("title", "New Clue"))


func _on_game_won() -> void:
	_show_end(true)


func _on_game_lost() -> void:
	_show_end(false)


func _show_end(won: bool) -> void:
	dialogue_panel.visible = false
	journal_panel.visible = false
	end_screen.visible = true
	end_screen.show_result(won)
	_update_lock()
