extends Control

@onready var day_label: Label = $TopMargin/TopBox/DayLabel
@onready var infection_label: Label = $TopMargin/TopBox/InfectionLabel
@onready var infection_bar: ProgressBar = $TopMargin/TopBox/InfectionBar
@onready var interact_label: Label = $InteractLabel
@onready var toast_label: Label = $ToastLabel
@onready var overlay: ColorRect = $InfectionOverlay
@onready var toast_timer: Timer = $ToastTimer


func _ready() -> void:
	toast_label.visible = false
	interact_label.text = ""
	interact_label.visible = false
	toast_timer.timeout.connect(_on_toast_timer_timeout)


func update_day(day: int) -> void:
	day_label.text = "Day %d of %d" % [day, GameManager.TOTAL_DAYS]


func update_infection(percent: float) -> void:
	infection_bar.value = percent
	infection_label.text = "Infection: %d%%" % int(percent)
	overlay.color = Color(0.5, 0.0, 0.0, clampf(percent / 100.0, 0.0, 1.0) * 0.55)


func set_interact_prompt(text: String) -> void:
	interact_label.text = text
	interact_label.visible = text != ""


func show_clue_toast(title: String) -> void:
	toast_label.text = "New clue: %s" % title
	toast_label.visible = true
	toast_timer.start()


func _on_toast_timer_timeout() -> void:
	toast_label.visible = false
