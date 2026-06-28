extends CanvasLayer

func _ready():
    EventBus.resource_changed.connect(_on_resource_changed)
    EventBus.day_started.connect(_on_day_started)
    EventBus.phase_changed.connect(_on_phase_changed)
    _update_all()
    $Panel/Controls/EndDayBtn.pressed.connect(_on_end_day_pressed)
    $Panel/Controls/BuildBtn.pressed.connect(_on_build_pressed)
    $Panel/Controls/SaveBtn.pressed.connect(_on_save_pressed)
    $Panel/Controls/PersonnelBtn.pressed.connect(_on_personnel_pressed)
    $Panel/Controls/DetaineeBtn.pressed.connect(_on_detainee_pressed)
    $Panel/Controls/LoadBtn.pressed.connect(_on_load_pressed)
    EventBus.room_built.connect(_on_room_built)

func _on_resource_changed(type: String, value: float):
    match type:
        "budget": $Panel/Resources/BudgetLabel.text = "Budget: $" + str(int(value))
        "intel": $Panel/Resources/IntelLabel.text = "Intel: " + str(int(value))
        "power": $Panel/Resources/PowerLabel.text = "Power: " + str(int(value))
        "oxygen": $Panel/Resources/OxygenLabel.text = "O2: " + str(int(value))
        "security": $Panel/Resources/SecurityLabel.text = "Security: " + str(int(value))
        "control_trust": $Panel/Resources/ControlTrustLabel.text = "Trust: " + str(int(value))

func _on_day_started(day: int):
    $Panel/Resources/DayLabel.text = "Day: " + str(day)

func _on_phase_changed(phase: String):
    $Panel/PhaseLabel.text = "Phase: " + phase

func _update_all():
    var r = ResourceManager.resources
    $Panel/Resources/DayLabel.text = "Day: " + str(DayCycle.current_day)
    $Panel/Resources/BudgetLabel.text = "Budget: $" + str(int(r.budget))
    $Panel/Resources/IntelLabel.text = "Intel: " + str(int(r.intel))
    $Panel/Resources/PowerLabel.text = "Power: " + str(int(r.power))
    $Panel/Resources/OxygenLabel.text = "O2: " + str(int(r.oxygen))
    $Panel/Resources/SecurityLabel.text = "Security: " + str(int(r.security))
    $Panel/Resources/ControlTrustLabel.text = "Trust: " + str(int(r.control_trust))
    $Panel/PhaseLabel.text = "Phase: " + DayCycle.phase
    _update_detainee_count()

func _on_end_day_pressed():
    var base_view = get_parent()
    if base_view.has_method("end_day"):
        base_view.end_day()

func _on_build_pressed():
    var base_view = get_parent()
    if base_view.has_method("open_build_menu"):
        base_view.open_build_menu()

func _on_save_pressed():
    SaveManager.save_game()

func _on_personnel_pressed():
    var base_view = get_parent()
    if base_view.has_method("open_personnel"):
        base_view.open_personnel()

func _on_detainee_pressed():
    var base_view = get_parent()
    if base_view.has_method("open_interrogation"):
        base_view.open_interrogation()

func _on_room_built(room_id: String, tile: Vector2i):
    if room_id == "containment_cell":
        _update_detainee_count()

func _update_detainee_count():
    var active = DetaineeManager.get_interrogatable().size()
    var max = DetaineeManager.get_max_slots()
    $Panel/DetaineeCount.text = "Detainees: " + str(active) + "/" + str(max)

func _on_load_pressed():
    SaveManager.load_game()
