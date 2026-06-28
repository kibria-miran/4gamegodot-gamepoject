extends Node

enum Threshold { LOW, NORMAL, HIGH }

var current_moral: float = 0.0
var _last_threshold: int = Threshold.NORMAL

func _ready():
	EventBus.resource_changed.connect(_on_resource_changed)

func _on_resource_changed(type: String, value: float):
	if type == "moral_alignment":
		current_moral = value
		_check_thresholds()

func shift(amount: float, reason: String):
	ResourceManager.add("moral_alignment", amount)
	if amount != 0:
		print("Moral shifted by ", amount, " due to: ", reason)

func _check_thresholds():
	var moral = ResourceManager.get_value("moral_alignment")
	var new_threshold = Threshold.NORMAL
	if moral >= 75:
		new_threshold = Threshold.HIGH
	elif moral <= -50:
		new_threshold = Threshold.LOW
	if new_threshold != _last_threshold:
		_last_threshold = new_threshold
		var label = ""
		match new_threshold:
			Threshold.HIGH:
				label = "high"
			Threshold.LOW:
				label = "low"
			_:
				label = "normal"
		EventBus.moral_threshold_crossed.emit(label)

func get_threshold() -> int:
	return _last_threshold
