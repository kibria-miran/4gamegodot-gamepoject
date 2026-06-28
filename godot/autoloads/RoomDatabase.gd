extends Node

var _rooms: Dictionary = {}

func _ready():
	_load_all()

func get(id: String) -> Dictionary:
	return _rooms.get(id, {})

func get_all() -> Array:
	return _rooms.values()

func _load_all():
	var dir = DirAccess.open("res://resources/rooms/")
	if not dir:
		return
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".tres"):
			var path = "res://resources/rooms/" + file
			var res = load(path)
			if res:
				_rooms[res.id] = {
					"id": res.id,
					"display_name": res.display_name,
					"cost": res.cost,
					"power_production": res.power_production,
					"power_consumption": res.power_consumption,
					"oxygen_consumption": res.oxygen_consumption,
					"tier": res.tier,
					"security_modifier": res.security_modifier,
					"morale_modifier": res.morale_modifier,
					"budget_cap_bonus": res.budget_cap_bonus
				}
		file = dir.get_next()
