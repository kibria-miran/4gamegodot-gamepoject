extends Control

func _ready():
    $Panel/ContinueBtn.pressed.connect(_continue)
    _populate()

func _populate():
    var mission_success = true
    var result_text = "Full Success"
    var details = ""
    var extracted = 0
    var total = 0

    for op in OperativeManager.operatives:
        if op.status == OperativeManager.OP_STATUS.MISSION:
            total += 1
            if op.reached_extraction:
                extracted += 1
                op.status = OperativeManager.OP_STATUS.ACTIVE
                op.xp += 10
                op.stress = min(100, op.stress + 15)
                details += op.name + ": Extracted. XP +10, Stress +15\n"
            elif op.is_downed:
                op.status = OperativeManager.OP_STATUS.INFIRMARY
                op.recovery_days = 14
                details += op.name + ": Downed. Infirmary (14 days)\n"
                mission_success = false
            else:
                op.status = OperativeManager.OP_STATUS.MIA
                details += op.name + ": MIA\n"
                mission_success = false

    if extracted > 0 and mission_success:
        result_text = "Full Success"
        details += "\nIntel package secured. Mission accomplished."
        ResourceManager.add("intel", 5)
    elif extracted > 0 and not mission_success:
        result_text = "Partial Success"
        details += "\nOperatives extracted, but intel was lost. Control Trust -5"
        ResourceManager.add("control_trust", -5)
    else:
        result_text = "Total Failure"
        details += "\nNo operatives extracted. Mission failed completely."

    $Panel/ResultLabel.text = "Result: " + result_text
    $Panel/Details.text = details

func _continue():
    DayCycle.advance_phase()
    GameState.transition_to(GameState.State.BASE_PHASE)
    get_tree().change_scene_to_file("res://scenes/base/BaseView.tscn")
