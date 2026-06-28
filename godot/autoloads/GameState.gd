extends Node

enum State {
	MAIN_MENU,
	BASE_PHASE,
	MISSION_BRIEFING,
	TACTICAL_MISSION,
	DEBRIEF,
	GAME_OVER,
	VICTORY
}

var current_state: int = State.MAIN_MENU setget _set_state

func _ready():
	EventBus.game_over.connect(_on_game_over)

func trigger_game_over(reason: String):
	EventBus.game_over.emit(reason)
	current_state = State.GAME_OVER

func transition_to(new_state: int):
	_set_state(new_state)

func is_state(state: int) -> bool:
	return current_state == state

func _set_state(new_state: int):
	var previous = current_state
	current_state = new_state
	print("GameState: ", State.keys()[previous], " -> ", State.keys()[new_state])

func _on_game_over(reason: String):
	print("Game Over! Reason: ", reason)
	current_state = State.GAME_OVER
	get_tree().change_scene_to_file("res://scenes/ui/GameOverScreen.tscn")
