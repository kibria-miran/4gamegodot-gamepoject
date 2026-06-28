extends Node

var current_day: int = 1
var phase: String = "MORNING"

func _ready():
    EventBus.day_started.emit(current_day)

func advance_phase():
    match phase:
        "MORNING":
            phase = "BASE"
        "BASE":
            phase = "MISSION"
        "MISSION":
            phase = "DEBRIEF"
        "DEBRIEF":
            phase = "END_OF_DAY"
        "END_OF_DAY":
            current_day += 1
            phase = "MORNING"
            EventBus.day_started.emit(current_day)
    EventBus.phase_changed.emit(phase)
    _apply_daily_resources()
    _check_lose_conditions()

func _apply_daily_resources():
    var total_power_production = 0
    var total_power_consumption = 0
    var total_oxygen_consumption = 0
    var total_security = 0
    var total_morale = 0
    var budget_cap_bonus = 0

    for room in FacilityManager.get_all_rooms():
        total_power_production += room.get("power_production", 0)
        total_power_consumption += room.get("power_consumption", 0)
        total_oxygen_consumption += room.get("oxygen_consumption", 0)
        total_security += room.get("security_modifier", 0)
        total_morale += room.get("morale_modifier", 0)
        budget_cap_bonus += room.get("budget_cap_bonus", 0)

    if budget_cap_bonus > 0:
        var current_cap = ResourceManager.get_cap("budget")
        ResourceManager.set_cap("budget", current_cap + budget_cap_bonus)

    var net_power = total_power_production - total_power_consumption
    ResourceManager.add("power", net_power)

    var oxygen_cost = total_oxygen_consumption
    ResourceManager.spend("oxygen", oxygen_cost)

    MoralTracker.shift(total_morale, "daily_morale_from_rooms")
    ResourceManager.add("security", total_security)

    ResourceManager.add("budget", 500)
    if FacilityManager.has_room("command_center"):
        ResourceManager.add("intel", 5)

    _check_resource_shortfall()

func _check_resource_shortfall():
    var oxygen = ResourceManager.get_value("oxygen")
    if oxygen <= 0:
        OperativeManager.apply_oxygen_damage(abs(oxygen))

    var power = ResourceManager.get_value("power")
    if power < 0:
        FacilityManager.trigger_power_outage(abs(power))

func _check_lose_conditions():
    var sec = ResourceManager.get_value("security")
    if sec <= 0:
        GameState.trigger_game_over("Base Exposure -- Facility compromised")

    var trust = ResourceManager.get_value("control_trust")
    if trust <= 0:
        GameState.trigger_game_over("Control Termination -- Cleanup team dispatched")

    var all_dead = true
    for op in OperativeManager.operatives:
        if op.hp > 0:
            all_dead = false
            break
    if all_dead and OperativeManager.operatives.size() > 0:
        GameState.trigger_game_over("Squad Wipe -- All operatives lost")

    if DetaineeManager.get_interrogatable().size() > 0:
        for d in DetaineeManager.get_interrogatable():
            if d.threat_level >= 5:
                GameState.trigger_game_over("Detainee Breach -- High-value asset escaped with intel")
