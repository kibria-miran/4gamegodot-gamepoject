extends Node3D

const MAP_DATA = {
    "width": 8,
    "height": 8,
    "tiles": [
        "WW", "WW", "WW", "WW", "WW", "WW", "WW", "WW",
        "WW", "S",  "  ", "C",  "G1", "WW", "WW", "WW",
        "WW", "S",  "WW", "  ", "  ", "  ", "WW", "WW",
        "WW", "  ", "WW", "WW", "C",  "G2", "WW", "WW",
        "WW", "  ", "  ", "OBJ","  ", "  ", "  ", "WW",
        "WW", "WW", "  ", "WW", "C",  "  ", "WW", "WW",
        "WW", "  ", "  ", "  ", "  ", "  ", "G3", "WW",
        "WW", "WW", "X",  "WW", "WW", "WW", "WW", "WW"
    ]
}

const GUARD_DATA = [
    {"id": "G1", "tile": Vector2i(4, 1), "facing": Vector2i(0, 1)},
    {"id": "G2", "tile": Vector2i(5, 3), "facing": Vector2i(-1, 0)},
    {"id": "G3", "tile": Vector2i(6, 6), "facing": Vector2i(0, -1)}
]

var grid: Array = []
var operatives: Array = []
var guards: Array = []
var current_op_index: int = 0
var turn_phase: String = "PLAYER"
var objective_secured: bool = false
var selected_op = null
var splash_label: Label = null
var splash_timer: float = 0.0

func _ready():
    AudioManager.play("amb_tactical", -10.0)
    _build_map()
    _spawn_guards()
    _spawn_operatives()
    _create_hud()
    _next_player_turn()

func _build_map():
    grid = []
    for y in range(MAP_DATA.height):
        for x in range(MAP_DATA.width):
            var idx = y * MAP_DATA.width + x
            var tile_char = MAP_DATA.tiles[idx]
            var tile_type = TILE_TYPE.FLOOR
            match tile_char:
                "WW": tile_type = TILE_TYPE.WALL
                "S": tile_type = TILE_TYPE.START
                "C": tile_type = TILE_TYPE.HALF_COVER
                "OBJ": tile_type = TILE_TYPE.OBJECTIVE
                "X": tile_type = TILE_TYPE.EXTRACTION
                "G1", "G2", "G3": tile_type = TILE_TYPE.FLOOR
            grid.append(tile_type)
            var cube = BoxMesh.new()
            cube.size = Vector3(3.8, 0.2, 3.8)
            var mat = StandardMaterial3D.new()
            match tile_type:
                TILE_TYPE.WALL:
                    cube.size = Vector3(3.8, 3.0, 3.8)
                    mat.albedo_color = Color(0.15, 0.15, 0.15)
                TILE_TYPE.HALF_COVER:
                    cube.size = Vector3(3.8, 1.0, 3.8)
                    mat.albedo_color = Color(0.3, 0.35, 0.25)
                TILE_TYPE.OBJECTIVE:
                    mat.albedo_color = Color(0.9, 0.7, 0.1)
                TILE_TYPE.EXTRACTION:
                    mat.albedo_color = Color(0.1, 0.8, 0.1)
                _:
                    mat.albedo_color = Color(0.25, 0.25, 0.28)
            var mi = MeshInstance3D.new()
            mi.mesh = cube
            mi.material_override = mat
            mi.position = Vector3(x * 4.0, 0, y * 4.0)
            $Map.add_child(mi)

func _spawn_guards():
    for g in GUARD_DATA:
        var guard = GuardAI.new()
        guard.id = g.id
        guard.tile_position = g.tile
        guard.facing = g.facing
        guard.alert_meter = 0
        guard.hp = 50
        guard.max_hp = 50
        guard.combat = 5
        guard.state = GuardAI.GUARD_STATE.UNAWARE
        guards.append(guard)
        var cube = BoxMesh.new()
        cube.size = Vector3(2.0, 2.5, 2.0)
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color(0.7, 0.15, 0.15)
        var mi = MeshInstance3D.new()
        mi.mesh = cube
        mi.material_override = mat
        mi.position = Vector3(g.tile.x * 4.0, 1.25, g.tile.y * 4.0)
        mi.set_meta("guard_id", g.id)
        $Enemies.add_child(mi)

func _spawn_operatives():
    var start_tiles = []
    for y in range(MAP_DATA.height):
        for x in range(MAP_DATA.width):
            var idx = y * MAP_DATA.width + x
            if MAP_DATA.tiles[idx] == "S":
                start_tiles.append(Vector2i(x, y))
    var op_idx = 0
    for op in OperativeManager.operatives:
        if op.status == OperativeManager.OP_STATUS.MISSION and op_idx < start_tiles.size():
            op.tile_position = start_tiles[op_idx]
            op.reached_extraction = false
            op.is_downed = false
            op.ap = 2
            operatives.append(op)
            var cube = BoxMesh.new()
            cube.size = Vector3(1.8, 2.0, 1.8)
            var mat = StandardMaterial3D.new()
            mat.albedo_color = Color(0.2, 0.4, 0.8)
            var mi = MeshInstance3D.new()
            mi.mesh = cube
            mi.material_override = mat
            mi.position = Vector3(op.tile_position.x * 4.0, 1.0, op.tile_position.y * 4.0)
            mi.set_meta("op_id", op.id)
            $Operatives.add_child(mi)
            op_idx += 1
    if operatives.size() > 0:
        selected_op = operatives[0]
        _update_selection_highlight()

func _create_hud():
    splash_label = Label.new()
    splash_label.theme_override_font_sizes/font_size = 48
    splash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    splash_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    splash_label.size = Vector2(400, 100)
    splash_label.position = Vector2(200, 200)
    splash_label.visible = false
    var canvas = CanvasLayer.new()
    canvas.add_child(splash_label)
    add_child(canvas)

    var ap_label = Label.new()
    ap_label.name = "APLabel"
    ap_label.position = Vector2(10, 10)
    ap_label.theme_override_font_sizes/font_size = 20
    canvas.add_child(ap_label)

    var end_turn = Button.new()
    end_turn.name = "EndTurnBtn"
    end_turn.text = "End Turn"
    end_turn.position = Vector2(10, 500)
    end_turn.pressed.connect(_end_player_turn_early)
    canvas.add_child(end_turn)

    var save_warning = Button.new()
    save_warning.name = "SaveBtn"
    save_warning.text = "Save (ends mission)"
    save_warning.position = Vector2(10, 540)
    save_warning.pressed.connect(_mid_mission_save)
    canvas.add_child(save_warning)

func _process(delta):
    if splash_label and splash_label.visible:
        splash_timer -= delta
        if splash_timer <= 0:
            splash_label.visible = false
    _update_ap_label()

func _update_ap_label():
    var canvas = null
    for c in get_children():
        if c is CanvasLayer:
            canvas = c
            break
    if not canvas: return
    var ap_label = canvas.get_node("APLabel")
    if not ap_label: return
    var text = ""
    for op in operatives:
        if op == selected_op:
            text += ">> " + op.name + " -- AP: " + str(op.ap) + "\n"
        elif not op.is_downed:
            text += "   " + op.name + " -- AP: " + str(op.ap) + "\n"
    ap_label.text = text

func _show_splash(text: String, duration: float = 1.5):
    if splash_label:
        splash_label.text = text
        splash_label.visible = true
        splash_timer = duration
    print(text)

func _input(event):
    if event.is_action_pressed("debug_skip_enemy") and turn_phase == "ENEMY":
        _show_splash("DEBUG: Skipping enemy phase", 0.5)
        _next_player_turn()
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _handle_click(event)

func _handle_click(event: InputEventMouseButton):
    if turn_phase != "PLAYER": return
    var space = get_viewport().get_camera_3d()
    if not space: return
    var from = space.project_ray_origin(event.position)
    var dir = space.project_ray_normal(event.position)
    var plane = Plane(Vector3(0, 1, 0), 0)
    var intersect = plane.intersects_ray(from, dir)
    if intersect == null: return
    var x = floori(intersect.x / 4.0 + 0.5)
    var z = floori(intersect.z / 4.0 + 0.5)
    var target = Vector2i(x, z)
    if target.x < 0 or target.x >= MAP_DATA.width or target.y < 0 or target.y >= MAP_DATA.height:
        return
    if not selected_op or selected_op.is_downed or selected_op.ap <= 0:
        return
    if not _is_walkable(target):
        return
    var idx = target.y * MAP_DATA.width + target.x
    var dist = abs(target.x - selected_op.tile_position.x) + abs(target.y - selected_op.tile_position.y)
    if dist > 2:
        _show_splash("Too far! Max 2 tiles per move.")
        return
    if dist == 0:
        return
    if selected_op.ap < dist: return
    _move_operative(selected_op, target)

func _move_operative(op, target_tile: Vector2i):
    var tiles = abs(target_tile.x - op.tile_position.x) + abs(target_tile.y - op.tile_position.y)
    op.tile_position = target_tile
    op.ap -= tiles
    _update_op_visual(op)
    CameraManager.smooth_pan_to(target_tile, 0.3)
    _emit_noise(op.tile_position, 2)
    var idx = target_tile.y * MAP_DATA.width + target_tile.x
    if grid[idx] == TILE_TYPE.EXTRACTION and objective_secured:
        op.reached_extraction = true
        _show_splash(op.name + " extracted!", 2.0)
        _check_mission_end()
        return
    if grid[idx] == TILE_TYPE.OBJECTIVE and not objective_secured:
        objective_secured = true
        EventBus.emit_signal("objective_secured")
        ResourceManager.add("intel", 5)
        _show_splash("Intel objective secured!", 2.0)
    _update_guard_alertness(op)
    _check_turn_end()

func attack_operative(op, guard):
    if op.ap < 2:
        _show_splash("Not enough AP!")
        return false
    var hit_chance = 0.75 + (op.combat - 5) * 0.05
    if guard.state == GuardAI.GUARD_STATE.UNAWARE:
        hit_chance += 0.25
    var roll = randf()
    if roll <= hit_chance:
        var damage = randi_range(20, 30)
        guard.hp -= damage
        _show_splash("Hit! " + str(damage) + " damage to " + guard.id, 1.0)
        if guard.hp <= 0:
            _remove_guard(guard)
    else:
        _show_splash("Missed!", 1.0)
    op.ap -= 2
    guard.state = GuardAI.GUARD_STATE.COMBAT
    _emit_noise(op.tile_position, 8)

func _is_walkable(tile: Vector2i) -> bool:
    if tile.x < 0 or tile.x >= MAP_DATA.width or tile.y < 0 or tile.y >= MAP_DATA.height:
        return false
    var idx = tile.y * MAP_DATA.width + tile.x
    if grid[idx] == TILE_TYPE.WALL: return false
    for op in operatives:
        if op.tile_position == tile and not op.is_downed: return false
    for guard in guards:
        if guard.tile_position == tile and guard.hp > 0: return false
    return true

func _update_op_visual(op):
    for child in $Operatives.get_children():
        if child.get_meta("op_id", "") == op.id:
            child.position = Vector3(op.tile_position.x * 4.0, 1.0, op.tile_position.y * 4.0)

func _update_selection_highlight():
    for child in $Operatives.get_children():
        var mi = child as MeshInstance3D
        if not mi or not mi.material_override: continue
        var mat = mi.material_override.duplicate()
        if mi.get_meta("op_id", "") == selected_op.id:
            mat.albedo_color = Color(0.4, 0.8, 1.0)
        else:
            mat.albedo_color = Color(0.2, 0.4, 0.8)
        mi.material_override = mat

func _emit_noise(source: Vector2i, radius: int):
    for guard in guards:
        if guard.hp <= 0: continue
        var dist = abs(source.x - guard.tile_position.x) + abs(source.y - guard.tile_position.y)
        if dist <= radius:
            guard.alert_meter = min(100, guard.alert_meter + (radius - dist) * 5)

func _update_guard_alertness(op):
    for guard in guards:
        if guard.hp <= 0: continue
        if _is_in_vision_cone(op.tile_position, guard):
            guard.alert_meter = min(100, guard.alert_meter + 15)

func _is_in_vision_cone(target: Vector2i, guard) -> bool:
    var dist = abs(target.x - guard.tile_position.x) + abs(target.y - guard.tile_position.y)
    if dist > 6: return false
    var dx = target.x - guard.tile_position.x
    var dy = target.y - guard.tile_position.y
    var dot = dx * guard.facing.x + dy * guard.facing.y
    var len = sqrt(dx*dx + dy*dy)
    if len == 0: return false
    var cos_angle = dot / len
    return cos_angle >= cos(deg_to_rad(45))

func _remove_guard(guard):
    guard.hp = 0
    for child in $Enemies.get_children():
        if child.get_meta("guard_id", "") == guard.id:
            child.queue_free()

func _next_player_turn():
    turn_phase = "PLAYER"
    for op in operatives:
        if not op.is_downed:
            op.ap = 2
    current_op_index = 0
    _select_next_operative()

func _select_next_operative():
    while current_op_index < operatives.size():
        var op = operatives[current_op_index]
        if not op.is_downed and op.ap > 0:
            selected_op = op
            _update_selection_highlight()
            _show_splash("PLAYER TURN -- " + op.name, 1.0)
            CameraManager.smooth_pan_to(op.tile_position, 0.3)
            return
        current_op_index += 1
    _start_enemy_phase()

func _start_enemy_phase():
    turn_phase = "ENEMY"
    selected_op = null
    _update_selection_highlight()
    _show_splash("ENEMY TURN", 1.5)
    for guard in guards:
        if guard.hp <= 0: continue
        _process_guard_ai(guard)
    _next_player_turn()

func _process_guard_ai(guard):
    if guard.alert_meter <= 30:
        guard.state = GuardAI.GUARD_STATE.UNAWARE
    elif guard.alert_meter <= 60:
        guard.state = GuardAI.GUARD_STATE.SUSPICIOUS
    elif guard.alert_meter <= 90:
        guard.state = GuardAI.GUARD_STATE.ALERTED
    else:
        guard.state = GuardAI.GUARD_STATE.COMBAT
    guard.alert_meter = max(0, guard.alert_meter - 5)
    if guard.state == GuardAI.GUARD_STATE.COMBAT:
        _guard_attack(guard)

func _end_player_turn_early():
    if turn_phase == "PLAYER":
        _start_enemy_phase()

func _check_turn_end():
    var all_done = true
    for op in operatives:
        if not op.is_downed and op.ap > 0:
            all_done = false
            break
    if all_done:
        _start_enemy_phase()

func _check_mission_end():
    var extracted = 0
    var downed = 0
    var on_map = 0
    for op in operatives:
        if op.reached_extraction: extracted += 1
        elif op.is_downed: downed += 1
        else: on_map += 1
    if extracted == operatives.size() or (extracted > 0 and on_map == 0):
        _end_mission("success")
    elif downed == operatives.size():
        GameState.trigger_game_over("Squad Wipe -- All operatives lost in combat")
    elif downed + on_map == 0 and extracted == 0:
        _end_mission("failure")

func _guard_attack(guard):
    var closest = null
    var min_dist = 999
    for op in operatives:
        if op.is_downed: continue
        var d = abs(op.tile_position.x - guard.tile_position.x) + abs(op.tile_position.y - guard.tile_position.y)
        if d <= 8 and d < min_dist:
            min_dist = d
            closest = op
    if not closest: return
    var hit_chance = 0.75 + (guard.combat - 5) * 0.05
    var range_penalty = max(0, min_dist - 3) * 0.05
    hit_chance -= range_penalty
    if randf() <= hit_chance:
        var damage = randi_range(10, 20)
        closest.hp -= damage
        _show_splash(guard.id + " hits " + closest.name + " for " + str(damage), 1.0)
        if closest.hp <= 0:
            closest.is_downed = true
            closest.hp = 0
            _place_downed_marker(closest.tile_position)
            _show_splash(closest.name + " is DOWNED!", 2.0)
    _check_mission_end()

func _place_downed_marker(tile: Vector2i):
    var marker = BoxMesh.new()
    marker.size = Vector3(1.5, 0.3, 1.5)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(1.0, 0.0, 0.0)
    var mi = MeshInstance3D.new()
    mi.mesh = marker
    mi.material_override = mat
    mi.position = Vector3(tile.x * 4.0, 0.15, tile.y * 4.0)
    mi.set_meta("downed", true)
    $Map.add_child(mi)

func _end_mission(outcome: String):
    var result = {"outcome": outcome, "intel_secured": objective_secured}
    EventBus.emit_signal("mission_completed", outcome == "success", result)
    GameState.transition_to(GameState.State.DEBRIEF)
    get_tree().change_scene_to_file("res://scenes/ui/DebriefScreen.tscn")

func _mid_mission_save():
    var warning = AcceptDialog.new()
    warning.title = "Save Game"
    warning.dialog_text = "Saving returns you to base. Mission progress will be lost."
    warning.ok_button_text = "Save and Return"
    warning.confirmed.connect(func():
        SaveManager.save_game()
        for op in operatives:
            op.status = OperativeManager.OP_STATUS.ACTIVE
        GameState.transition_to(GameState.State.BASE_PHASE)
        get_tree().change_scene_to_file("res://scenes/base/BaseView.tscn")
    )
    add_child(warning)
    warning.popup_centered()

enum TILE_TYPE { FLOOR, WALL, START, HALF_COVER, OBJECTIVE, EXTRACTION }
