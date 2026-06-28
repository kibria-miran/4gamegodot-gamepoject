extends Node

var _events: Array[Dictionary] = []
var _last_fired: Dictionary = {}
var current_day: int = 1

func _ready():
	_load_events()

func has_active_event(event_id: String) -> bool:
	return _events.any(func(e): return e.get("id") == event_id)

func select_event(phase: String) -> Dictionary:
	var candidates = []
	for event in _events:
		if event.trigger != phase:
			continue
		if event.has("cooldown_days") and _last_fired.get(event.id, -999) > current_day - event.cooldown_days:
			continue
		candidates.append(event)
	if candidates.is_empty():
		return {}
	var total_weight = 0
	for e in candidates:
		total_weight += e.weight
	var roll = randf_range(0, total_weight)
	var accumulator = 0.0
	for e in candidates:
		accumulator += e.weight
		if roll <= accumulator:
			_last_fired[e.id] = current_day
			return e
	return candidates.back()

func _load_events():
	var file = FileAccess.open("res://data/events.json", FileAccess.READ)
	if not file:
		return
	var json = JSON.parse_string(file.get_as_text())
	if json is Array:
		_events = json
