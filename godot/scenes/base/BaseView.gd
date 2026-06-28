extends Node3D

var grid_system: Node3D = null

func _ready():
    AudioManager.play("amb_base_idle", -10.0)
    print("Base phase started -- Day " + str(DayCycle.current_day))
    grid_system = preload("res://scenes/base/GridSystem.gd").new()
    add_child(grid_system)
    var hud = preload("res://scenes/ui/HUD.tscn").instantiate()
    add_child(hud)
    if DayCycle.current_day == 1 and DetaineeManager.get_interrogatable().is_empty():
        DetaineeManager.intake_detainee()
    if DayCycle.phase == "MORNING":
        var event = EventSystem.select_event("morning_phase")
        if not event.is_empty():
            EventBus.emit_signal("event_fired", event)
    if DayCycle.phase == "END_OF_DAY":
        var event = EventSystem.select_event("end_of_day")
        if not event.is_empty():
            EventBus.emit_signal("event_fired", event)
    if DayCycle.current_day == 1 and TutorialManager.tutorial_active:
        _show_tutorial()

func _show_tutorial():
    var step = TutorialManager.get_current_step()
    if not step.is_empty():
        var popup = AcceptDialog.new()
        popup.title = "Tutorial -- Day " + str(DayCycle.current_day)
        popup.dialog_text = step.text
        popup.ok_button_text = "Next"
        popup.confirmed.connect(_on_tutorial_next)
        add_child(popup)
        popup.popup_centered()

func _on_tutorial_next():
    TutorialManager.advance_step()
    var step = TutorialManager.get_current_step()
    if not step.is_empty() and TutorialManager.tutorial_active:
        var popup = AcceptDialog.new()
        popup.title = "Tutorial"
        popup.dialog_text = step.text
        popup.ok_button_text = "Next"
        popup.confirmed.connect(_on_tutorial_next)
        add_child(popup)
        popup.popup_centered()

func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if grid_system and grid_system.has_method("get_tile_from_mouse"):
            var tile = grid_system.get_tile_from_mouse(event)
            if tile.x >= 0 and _pending_room_id != "":
                if grid_system.place_room(_pending_room_id, tile):
                    AudioManager.play("room_build")
                    _pending_room_id = ""
                else:
                    AudioManager.play("ui_deny")

var _pending_room_id: String = ""

func open_build_menu():
    var build_menu = preload("res://scenes/ui/BuildMenu.tscn").instantiate()
    build_menu.connect("room_selected", _on_room_selected)
    add_child(build_menu)

func _on_room_selected(room_id: String):
    _pending_room_id = room_id

func open_interrogation():
    var screen = preload("res://scenes/ui/InterrogationScreen.tscn").instantiate()
    add_child(screen)

func open_personnel():
    var screen = preload("res://scenes/ui/PersonnelScreen.tscn").instantiate()
    add_child(screen)

func end_day():
    DayCycle.advance_phase()
    if DayCycle.phase == "END_OF_DAY":
        var event = EventSystem.select_event("end_of_day")
        if not event.is_empty():
            EventBus.emit_signal("event_fired", event)
    SaveManager.save_game()
    if DayCycle.phase == "MISSION":
        get_tree().change_scene_to_file("res://scenes/ui/MissionBriefing.tscn")
    elif DayCycle.phase == "MORNING":
        var event = EventSystem.select_event("morning_phase")
        if not event.is_empty():
            EventBus.emit_signal("event_fired", event)

func save_game():
    SaveManager.save_game()

func load_game():
    SaveManager.load_game()
