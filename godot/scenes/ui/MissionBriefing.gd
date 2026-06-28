extends Control

var selected_operatives: Array = []

var _armory_bonus: bool = false

func _ready():
    $Panel/DeployBtn.pressed.connect(_deploy)
    $Panel/BackBtn.pressed.connect(_back_to_base)
    _armory_bonus = FacilityManager.has_room("armory")
    if _armory_bonus:
        $Panel/Description.text += "\n\n[ARMORY ONLINE -- +1 Combat to all operatives]"
    _populate_operative_list()

func _populate_operative_list():
    for op in OperativeManager.operatives:
        if op.status == OperativeManager.OP_STATUS.ACTIVE:
            var btn = CheckButton.new()
            btn.text = op.name + " (Combat: " + str(op.combat) + ", HP: " + str(op.hp) + ")"
            btn.toggled.connect(_on_op_toggled.bind(op))
            $Panel/SquadList.add_child(btn)

func _on_op_toggled(toggled_on: bool, op):
    if toggled_on:
        selected_operatives.append(op)
    else:
        selected_operatives.erase(op)
    $Panel/DeployBtn.disabled = selected_operatives.size() < 2 or selected_operatives.size() > 4

func _deploy():
    if selected_operatives.size() < 2: return
    for op in selected_operatives:
        op.status = OperativeManager.OP_STATUS.MISSION
        if _armory_bonus:
            op.combat += 1
    EventBus.emit_signal("mission_started", "coldburn")
    GameState.transition_to(GameState.State.TACTICAL_MISSION)
    get_tree().change_scene_to_file("res://scenes/tactical/TacticalView.tscn")

func _back_to_base():
    GameState.transition_to(GameState.State.BASE_PHASE)
    get_tree().change_scene_to_file("res://scenes/base/BaseView.tscn")
