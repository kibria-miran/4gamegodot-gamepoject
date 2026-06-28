extends Node

const SAVE_PATH: String = "user://savegame.sav"
const SAVE_VERSION: int = 1

func save_game():
	var data = _collect_state()
	data["_version"] = SAVE_VERSION
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("SaveManager: Failed to open save file for writing.")
		return
	file.store_string(JSON.stringify(data, "\t"))
	print("SaveManager: Game saved.")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("SaveManager: No save file found.")
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("SaveManager: Failed to open save file for reading.")
		return false
	var text = file.get_as_text()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		print("SaveManager: Save file is corrupted.")
		return false
	_migrate(parsed)
	_apply_state(parsed)
	print("SaveManager: Game loaded.")
	return true

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func delete_save():
	if save_exists():
		DirAccess.remove_absolute(SAVE_PATH)
		print("SaveManager: Save file deleted.")

func _migrate(data: Dictionary):
	var version = data.get("_version", 0)
	if version < 1:
		data["moral_tracker"] = data.get("moral_tracker", {})
		data["_version"] = 1

func _collect_state() -> Dictionary:
	var operative_data = []
	for op in OperativeManager.operatives:
		operative_data.append({
			"id": op.id,
			"name": op.name,
			"combat": op.combat,
			"stealth": op.stealth,
			"tech": op.tech,
			"endurance": op.endurance,
			"loyalty": op.loyalty,
			"stress": op.stress,
			"hp": op.hp,
			"max_hp": op.max_hp,
			"xp": op.xp,
			"status": op.status,
			"recovery_days": op.recovery_days,
			"reached_extraction": op.reached_extraction,
			"is_downed": op.is_downed,
			"tile_position_x": op.tile_position.x,
			"tile_position_y": op.tile_position.y
		})
	var detainee_data = []
	for d in DetaineeManager.detainees:
		detainee_data.append({
			"id": d.id, "name": d.name, "backstory": d.backstory,
			"intel_value": d.intel_value, "resistance": d.resistance,
			"willpower": d.willpower, "max_willpower": d.max_willpower,
			"health": d.health, "max_health": d.max_health,
			"threat_level": d.threat_level, "faction": d.faction,
			"trait": d.trait, "is_asset": d.is_asset, "is_dead": d.is_dead
		})
	return {
		"resources": {
			"budget": ResourceManager.get_value("budget"),
			"intel": ResourceManager.get_value("intel"),
			"power": ResourceManager.get_value("power"),
			"oxygen": ResourceManager.get_value("oxygen"),
			"security": ResourceManager.get_value("security"),
			"moral_alignment": ResourceManager.get_value("moral_alignment"),
			"control_trust": ResourceManager.get_value("control_trust"),
			"black_market_rep": ResourceManager.get_value("black_market_rep")
		},
		"facilities": FacilityManager.get_all_rooms(),
		"operatives": operative_data,
		"detainees": detainee_data,
		"day_cycle": {
			"current_day": DayCycle.current_day,
			"phase": DayCycle.phase
		},
		"event_system": {
			"current_day": EventSystem.current_day,
			"last_fired": EventSystem._last_fired.duplicate()
		},
		"moral_tracker": {
			"current_moral": MoralTracker.current_moral,
			"last_threshold": MoralTracker._last_threshold
		},
		"tutorial": {
			"tutorial_active": TutorialManager.tutorial_active,
			"current_step": TutorialManager.current_step
		}
	}

func _apply_state(data: Dictionary):
	var res = data.get("resources", {})
	for key in res:
		ResourceManager._resources[key] = res[key]

	var facilities = data.get("facilities", [])
	FacilityManager.built_rooms = facilities.duplicate()

	var operatives = data.get("operatives", [])
	OperativeManager.operatives.clear()
	for op_data in operatives:
		var op = OperativeManager.Operative.new(op_data)
		op.status = op_data.get("status", OperativeManager.OP_STATUS.ACTIVE)
		op.recovery_days = op_data.get("recovery_days", 0)
		op.reached_extraction = op_data.get("reached_extraction", false)
		op.is_downed = op_data.get("is_downed", false)
		op.tile_position = Vector2i(op_data.get("tile_position_x", 0), op_data.get("tile_position_y", 0))
		OperativeManager.operatives.append(op)

	var detainees = data.get("detainees", [])
	DetaineeManager.detainees.clear()
	for det_data in detainees:
		var d = DetaineeManager.Detainee.new(det_data)
		d.willpower = det_data.get("willpower", d.willpower)
		d.max_willpower = det_data.get("max_willpower", d.max_willpower)
		d.health = det_data.get("health", d.health)
		d.max_health = det_data.get("max_health", d.max_health)
		d.is_asset = det_data.get("is_asset", false)
		d.is_dead = det_data.get("is_dead", false)
		DetaineeManager.detainees.append(d)

	var day_cycle = data.get("day_cycle", {})
	DayCycle.current_day = day_cycle.get("current_day", 1)
	DayCycle.phase = day_cycle.get("phase", "MORNING")

	var event_sys = data.get("event_system", {})
	EventSystem.current_day = event_sys.get("current_day", 1)
	EventSystem._last_fired = event_sys.get("last_fired", {}).duplicate()

	var moral_tracker = data.get("moral_tracker", {})
	MoralTracker.current_moral = moral_tracker.get("current_moral", 0.0)
	MoralTracker._last_threshold = moral_tracker.get("last_threshold", 1)

	var tutorial = data.get("tutorial", {})
	TutorialManager.tutorial_active = tutorial.get("tutorial_active", true)
	TutorialManager.current_step = tutorial.get("current_step", 0)
