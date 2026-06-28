extends Node

enum INTERROGATION_TYPE { PSYCHOLOGICAL, CHEMICAL, PHYSICAL }

class Detainee:
    var id: String
    var name: String
    var backstory: String
    var intel_value: int
    var resistance: int
    var willpower: int
    var max_willpower: int
    var health: int
    var max_health: int
    var threat_level: int
    var faction: String
    var trait: String
    var is_asset: bool
    var is_dead: bool

    func _init(data: Dictionary):
        id = data.get("id", "det_unknown")
        name = data.get("name", "Unknown Subject")
        backstory = data.get("backstory", "No file.")
        intel_value = data.get("intel_value", randi_range(1, 20))
        resistance = data.get("resistance", randi_range(1, 10))
        willpower = data.get("willpower", randi_range(40, 100))
        max_willpower = willpower
        health = data.get("health", 100)
        max_health = 100
        threat_level = data.get("threat_level", randi_range(1, 5))
        faction = data.get("faction", "Unaffiliated")
        trait = data.get("trait", "None")
        is_asset = false
        is_dead = false

var detainees: Array[Detainee] = []

const NAMES = ["Viktor", "Alexei", "Dmitri", "Sergei", "Yuri", "Boris", "Ivan", "Mikhail", "Nikolai", "Oleg"]
const BACKSTORIES = [
    "Former GRU signals officer. Picked up near Norilsk.",
    "Civilian translator caught in a raid. Claims innocence.",
    "Mid-level Network broker. Knows trade routes.",
    "Deserted Crimson Brigade soldier. Fearful but useful.",
    "Journalist investigating Site Omega rumors.",
    "Weapons smuggler with ties to eastern cell.",
    "Low-level informant. Desperate to talk.",
    "Trained saboteur. Resistance is high.",
    "Double agent candidate. Volatile but valuable.",
    "Unidentified subject. No records found."
]
const FACTIONS = ["GRU", "The Network", "Crimson Brigades", "Initiative", "Unaffiliated"]
const TRAITS = ["Innocent", "Career Intel", "Trained", "Fanatic", "Coward", "Loyal", "Deceptive"]

func _ready():
    pass

func get_active() -> Array:
    return detainees.filter(func(d): return not d.is_dead)

func get_interrogatable() -> Array:
    return detainees.filter(func(d): return not d.is_dead and d.health > 0)

func intake_detainee(data: Dictionary = {}):
    if data.is_empty():
        data = _generate_random()
    if detainees.size() >= get_max_slots():
        print("DetaineeManager: No available slots!")
        return null
    var d = Detainee.new(data)
    detainees.append(d)
    print("DetaineeManager: " + d.name + " processed.")
    return d

func get_max_slots() -> int:
    return 1 + FacilityManager.built_rooms.filter(func(r): return r.get("room_id") == "containment_cell").size()

func interrogate(detainee: Detainee, method: int) -> Dictionary:
    var result = {
        "willpower_damage": 0,
        "intel_gained": 0,
        "health_damage": 0,
        "moral_penalty": 0
    }
    match method:
        INTERROGATION_TYPE.PSYCHOLOGICAL:
            result.willpower_damage = randi_range(5, 15)
            result.intel_gained = randi_range(1, 3)
            result.moral_penalty = 2
        INTERROGATION_TYPE.CHEMICAL:
            result.willpower_damage = randi_range(15, 30)
            result.intel_gained = randi_range(3, 8)
            result.health_damage = randi_range(5, 15)
            result.moral_penalty = 8
        INTERROGATION_TYPE.PHYSICAL:
            result.willpower_damage = randi_range(30, 50)
            result.intel_gained = randi_range(5, 12)
            result.health_damage = randi_range(15, 40)
            result.moral_penalty = 15

    if detainee.trait == "Innocent":
        if method != INTERROGATION_TYPE.PSYCHOLOGICAL:
            result.moral_penalty *= 2
    if detainee.trait == "Trained":
        result.willpower_damage = max(1, result.willpower_damage - 5)

    detainee.willpower = max(0, detainee.willpower - result.willpower_damage)
    detainee.health = max(0, detainee.health - result.health_damage)

    if detainee.willpower <= 0:
        result.intel_gained += detainee.intel_value
        detainee.intel_value = 0

    if detainee.health <= 0:
        detainee.is_dead = true
        result.intel_gained = 0
        MoralTracker.shift(-15, "detainee_died_during_interrogation")

    if result.intel_gained > 0:
        ResourceManager.add("intel", result.intel_gained)

    MoralTracker.shift(-result.moral_penalty, "interrogation_" + str(method))
    AudioManager.play("interrogation_start")
    return result

func release(detainee: Detainee):
    detainee.is_dead = true
    MoralTracker.shift(8, "released_detainee")
    detainees.erase(detainee)
    AudioManager.play("ui_confirm")

func eliminate(detainee: Detainee):
    detainee.is_dead = true
    MoralTracker.shift(-10, "eliminated_detainee")
    detainees.erase(detainee)
    AudioManager.play("ui_confirm")

func turn_asset(detainee: Detainee) -> bool:
    if not FacilityManager.has_room("command_center"):
        return false
    detainee.is_asset = true
    MoralTracker.shift(-5, "turned_asset")
    return true

func _generate_random() -> Dictionary:
    var idx = randi() % NAMES.size()
    return {
        "id": "det_" + str(DetaineeManager.detainees.size() + 1).pad_zeros(3),
        "name": NAMES[idx],
        "backstory": BACKSTORIES[idx],
        "intel_value": randi_range(1, 20),
        "resistance": randi_range(1, 10),
        "willpower": randi_range(40, 100),
        "health": 100,
        "threat_level": randi_range(1, 3),
        "faction": FACTIONS[randi() % FACTIONS.size()],
        "trait": TRAITS[randi() % TRAITS.size()]
    }
