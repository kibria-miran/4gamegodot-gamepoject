extends Node

const INF: float = INF

var _resources: Dictionary = {}
var _caps: Dictionary = {}

func _ready():
	_resources = {
		"budget": 5000.0,
		"intel": 0.0,
		"power": 0.0,
		"oxygen": 100.0,
		"security": 50.0,
		"moral_alignment": 0.0,
		"control_trust": 80.0,
		"black_market_rep": 0.0
	}
	_caps = {
		"budget": 10000.0,
		"intel": INF,
		"power": INF,
		"oxygen": 100.0,
		"security": 100.0,
		"moral_alignment": INF,
		"control_trust": 100.0,
		"black_market_rep": 100.0
	}

func get_value(type: String) -> float:
	return _resources.get(type, 0.0)

func get_cap(type: String) -> float:
	return _caps.get(type, INF)

func has(type: String, amount: float) -> bool:
	return _resources.get(type, 0.0) >= amount

func add(type: String, amount: float):
	if not _resources.has(type):
		return
	var new_val = _resources[type] + amount
	var cap = _caps[type]
	if type == "moral_alignment":
		new_val = clampf(new_val, -100.0, 100.0)
	elif cap != INF:
		new_val = min(new_val, cap)
	var old_val = _resources[type]
	_resources[type] = new_val
	if not is_equal_approx(old_val, new_val):
		EventBus.resource_changed.emit(type, new_val)

func spend(type: String, amount: float) -> bool:
	if not _resources.has(type):
		return false
	if _resources[type] < amount:
		return false
	_resources[type] -= amount
	EventBus.resource_changed.emit(type, _resources[type])
	return true

func set_cap(type: String, value: float):
	if _caps.has(type):
		_caps[type] = value
