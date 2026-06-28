extends Control

func _ready():
    $Panel/CloseBtn.pressed.connect(_close)
    _populate()

func _populate():
    var status_names = ["ACTIVE", "MISSION", "INFIRMARY", "MIA", "DEAD"]
    for op in OperativeManager.operatives:
        var frame = Panel.new()
        frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        var vbox = VBoxContainer.new()
        vbox.add_child(_make_label("Name: " + op.name, 18))
        vbox.add_child(_make_label("Status: " + status_names[op.status], 14))
        vbox.add_child(_make_label("Combat: " + str(op.combat) + "  Stealth: " + str(op.stealth), 14))
        vbox.add_child(_make_label("Tech: " + str(op.tech) + "  Endurance: " + str(op.endurance), 14))
        vbox.add_child(_make_label("HP: " + str(op.hp) + "/" + str(op.max_hp), 14))
        vbox.add_child(_make_label("Loyalty: " + str(op.loyalty) + "  Stress: " + str(op.stress), 14))
        vbox.add_child(_make_label("XP: " + str(op.xp), 14))
        if op.status == OperativeManager.OP_STATUS.INFIRMARY:
            vbox.add_child(_make_label("Recovery: " + str(op.recovery_days) + " days", 12))
        frame.add_child(vbox)
        $Panel/Operatives.add_child(frame)

func _make_label(text: String, size: int) -> Label:
    var l = Label.new()
    l.text = text
    l.theme_override_font_sizes/font_size = size
    return l

func _close():
    queue_free()
