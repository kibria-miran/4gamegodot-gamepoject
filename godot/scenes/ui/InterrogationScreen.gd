extends Control

var selected_detainee = null
var detainee_buttons: Array = []

func _ready():
    $Panel/CloseBtn.pressed.connect(_close)
    $Panel/InfoPanel/Actions/PsychBtn.pressed.connect(_interrogate.bind(DetaineeManager.INTERROGATION_TYPE.PSYCHOLOGICAL))
    $Panel/InfoPanel/Actions/ChemBtn.pressed.connect(_interrogate.bind(DetaineeManager.INTERROGATION_TYPE.CHEMICAL))
    $Panel/InfoPanel/Actions/PhysBtn.pressed.connect(_interrogate.bind(DetaineeManager.INTERROGATION_TYPE.PHYSICAL))
    $Panel/InfoPanel/PostActions/ReleaseBtn.pressed.connect(_release)
    $Panel/InfoPanel/PostActions/EliminateBtn.pressed.connect(_eliminate)
    _populate_detainee_list()
    _hide_info()

func _populate_detainee_list():
    for child in $Panel/DetaineeList.get_children():
        child.queue_free()
    detainee_buttons.clear()
    for d in DetaineeManager.get_interrogatable():
        var btn = Button.new()
        btn.text = d.name + " (WP: " + str(d.willpower) + "/" + str(d.max_willpower) + ")"
        btn.pressed.connect(_select_detainee.bind(d, btn))
        $Panel/DetaineeList.add_child(btn)
        detainee_buttons.append(btn)

func _select_detainee(d, btn):
    selected_detainee = d
    _show_info(d)
    for b in detainee_buttons:
        b.disabled = false
    btn.disabled = true

func _show_info(d):
    $Panel/InfoPanel/NameLabel.text = "Name: " + d.name
    $Panel/InfoPanel/IntelLabel.text = "Intel Value: " + str(d.intel_value)
    $Panel/InfoPanel/WillpowerLabel.text = "Willpower: " + str(d.willpower) + "/" + str(d.max_willpower)
    $Panel/InfoPanel/HealthLabel.text = "Health: " + str(d.health) + "/100"
    $Panel/InfoPanel/TraitLabel.text = "Trait: " + d.trait
    $Panel/InfoPanel/FactionLabel.text = "Faction: " + d.faction
    $Panel/InfoPanel/ResultLabel.text = ""
    $Panel/InfoPanel/Actions.visible = true
    $Panel/InfoPanel/PostActions.visible = true

func _hide_info():
    selected_detainee = null
    $Panel/InfoPanel/NameLabel.text = "Name: "
    $Panel/InfoPanel/IntelLabel.text = "Intel Value: "
    $Panel/InfoPanel/WillpowerLabel.text = "Willpower: "
    $Panel/InfoPanel/HealthLabel.text = "Health: "
    $Panel/InfoPanel/TraitLabel.text = "Trait: "
    $Panel/InfoPanel/FactionLabel.text = "Faction: "
    $Panel/InfoPanel/ResultLabel.text = ""
    $Panel/InfoPanel/Actions.visible = false
    $Panel/InfoPanel/PostActions.visible = false

func _interrogate(method: int):
    if not selected_detainee: return
    var result = DetaineeManager.interrogate(selected_detainee, method)
    var text = "Willpower: -" + str(result.willpower_damage) + "\n"
    text += "Intel gained: " + str(result.intel_gained) + "\n"
    if result.health_damage > 0:
        text += "Health: -" + str(result.health_damage) + "\n"
    if selected_detainee.willpower <= 0:
        text += "DETAINEE BROKEN — all remaining intel extracted!\n"
    if selected_detainee.health <= 0:
        text += "DETAINEE DIED during interrogation.\n"
    text += "Moral penalty: " + str(result.moral_penalty)
    $Panel/InfoPanel/ResultLabel.text = text
    _populate_detainee_list()

func _release():
    if not selected_detainee: return
    DetaineeManager.release(selected_detainee)
    selected_detainee = null
    _hide_info()
    _populate_detainee_list()

func _eliminate():
    if not selected_detainee: return
    DetaineeManager.eliminate(selected_detainee)
    selected_detainee = null
    _hide_info()
    _populate_detainee_list()

func _close():
    queue_free()
