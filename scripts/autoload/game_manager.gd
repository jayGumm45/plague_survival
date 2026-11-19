extends Node
## Autoload singleton: tracks the three-day countdown, infection progress,
## and the overall win/lose state of the current playthrough.

signal day_changed(day: int)
signal infection_updated(percent: float)
signal game_won
signal game_lost

enum State { PLAYING, WON, LOST }

## How many in-game days the player survives before the plague kills them.
const TOTAL_DAYS: int = 3
## Real-world seconds per in-game day. Tune this to make the mystery
## longer or shorter; 480.0 (8 minutes) gives ~24 minutes total.
const SECONDS_PER_DAY: float = 480.0
const TOTAL_SECONDS: float = SECONDS_PER_DAY * TOTAL_DAYS

var state: State = State.PLAYING
var elapsed_time: float = 0.0
## Set true while a menu/dialogue/journal is open so gameplay input stops.
var input_locked: bool = false
var is_cured: bool = false

var _last_day: int = 1


func _process(delta: float) -> void:
	if state != State.PLAYING:
		return
	elapsed_time += delta
	var day := get_current_day()
	if day != _last_day:
		_last_day = day
		day_changed.emit(day)
	infection_updated.emit(get_infection_percent())
	if elapsed_time >= TOTAL_SECONDS:
		lose_game()


## Current in-game day, 1-indexed, clamped so it never reports past TOTAL_DAYS.
func get_current_day() -> int:
	return mini(int(elapsed_time / SECONDS_PER_DAY) + 1, TOTAL_DAYS)


## 0-100. Reaching 100 means the plague has killed the player.
func get_infection_percent() -> float:
	return clampf(elapsed_time / TOTAL_SECONDS, 0.0, 1.0) * 100.0


## Called when the player successfully accuses the real plague doctor.
func cure_player() -> void:
	if state != State.PLAYING:
		return
	is_cured = true
	state = State.WON
	game_won.emit()


## Called when the countdown runs out before the player is cured.
func lose_game() -> void:
	if state != State.PLAYING:
		return
	state = State.LOST
	game_lost.emit()


func set_input_locked(locked: bool) -> void:
	input_locked = locked


## Restores a fresh run. The level itself still needs to be reloaded by
## whoever calls this (see EndScreen.gd).
func reset() -> void:
	state = State.PLAYING
	elapsed_time = 0.0
	is_cured = false
	input_locked = false
	_last_day = 1
