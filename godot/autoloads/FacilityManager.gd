extends Node

var built_rooms: Array[Dictionary] = []

func build_room(room_id: String, tile: Vector2i, floor: int) -> bool:
	var room_data = RoomDatabase.get(room_id)
	if room_data.is_empty():
		return false
	var cost = room_data.get("cost", 0)
	if not ResourceManager.spend("budget", cost):
		return false
	var room = {
		"room_id": room_id,
		"tile": tile,
		"floor": floor,
		"cost": cost,
		"display_name": room_data.get("display_name", ""),
		"power_production": room_data.get("power_production", 0),
		"power_consumption": room_data.get("power_consumption", 0),
		"oxygen_consumption": room_data.get("oxygen_consumption", 0),
		"security_modifier": room_data.get("security_modifier", 0),
		"morale_modifier": room_data.get("morale_modifier", 0),
		"budget_cap_bonus": room_data.get("budget_cap_bonus", 0)
	}
	built_rooms.append(room)
	EventBus.room_built.emit(room_id, tile)
	return true

func demolish_room(tile: Vector2i):
	var idx = -1
	for i in built_rooms.size():
		if built_rooms[i].get("tile") == tile:
			idx = i
			break
	if idx == -1:
		return
	var room = built_rooms[idx]
	var refund = room.get("cost", 0) * 0.5
	ResourceManager.add("budget", refund)
	built_rooms.remove_at(idx)
	EventBus.room_demolished.emit(tile)

func has_room(room_id: String) -> bool:
	for room in built_rooms:
		if room.get("room_id") == room_id:
			return true
	return false

func get_all_rooms() -> Array:
	return built_rooms.duplicate()

func trigger_power_outage(deficit: float):
	print("Power outage triggered with deficit: ", deficit)
