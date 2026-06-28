extends Node

enum OP_STATUS { ACTIVE, MISSION, INFIRMARY, MIA, DEAD }

class Operative:
	var id: String
	var name: String
	var combat: int
	var stealth: int
	var tech: int
	var endurance: int
	var loyalty: int
	var stress: int
	var hp: int
	var max_hp: int
	var xp: int
	var status: int
	var recovery_days: int
	var reached_extraction: bool
	var is_downed: bool
	var tile_position: Vector2i
	var ap: int

	func _init(data: Dictionary):
		id = data.get("id", "")
		name = data.get("name", "Operative")
		combat = data.get("combat", 5)
		stealth = data.get("stealth", 5)
		tech = data.get("tech", 5)
		endurance = data.get("endurance", 5)
		loyalty = data.get("loyalty", 80)
		stress = data.get("stress", 0)
		hp = data.get("hp", 100)
		max_hp = 100
		xp = data.get("xp", 0)
		status = OP_STATUS.ACTIVE
		recovery_days = 0
		reached_extraction = false
		is_downed = false
		tile_position = Vector2i.ZERO

var operatives: Array[Operative] = []

func _ready():
	_create_phase1_operatives()

func _create_phase1_operatives():
	var data = [
		{"id": "op_001", "name": "Vance", "combat": 7, "stealth": 4, "tech": 3, "endurance": 6, "loyalty": 80, "hp": 90},
		{"id": "op_002", "name": "Keller", "combat": 5, "stealth": 8, "tech": 6, "endurance": 5, "loyalty": 75, "hp": 80},
		{"id": "op_003", "name": "Reed", "combat": 6, "stealth": 3, "tech": 7, "endurance": 7, "loyalty": 85, "hp": 100},
		{"id": "op_004", "name": "Moss", "combat": 8, "stealth": 6, "tech": 4, "endurance": 4, "loyalty": 70, "hp": 85}
	]
	for d in data:
		operatives.append(Operative.new(d))

func get_active() -> Array:
	return operatives.filter(func(o): return o.status == OP_STATUS.ACTIVE)

func apply_oxygen_damage(deficit: float):
	var dmg_per_op = ceil(deficit / 10.0) * 5
	for op in operatives:
		if op.status == OP_STATUS.ACTIVE:
			op.hp = max(0, op.hp - dmg_per_op)

func get_operative(id: String) -> Operative:
	for op in operatives:
		if op.id == id:
			return op
	return null
