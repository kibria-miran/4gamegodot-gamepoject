extends Node

var tutorial_active: bool = true
var current_step: int = 0
var steps: Array[Dictionary] = []

func _ready():
	steps = [
		{"text": "Build a Generator Room to provide power.", "action": "build_generator"},
		{"text": "Build a Command Center to unlock missions and intel.", "action": "build_command_center"},
		{"text": "End the day to advance to the next phase.", "action": "end_day"}
	]

func get_current_step() -> Dictionary:
	if current_step < steps.size():
		return steps[current_step]
	return {}

func advance_step():
	current_step += 1
	if current_step >= steps.size():
		tutorial_active = false

func reset():
	current_step = 0
	tutorial_active = true
