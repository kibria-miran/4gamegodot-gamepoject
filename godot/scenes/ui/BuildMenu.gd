extends Control

signal room_selected(room_id: String)

func _ready():
    $Panel/CloseBtn.pressed.connect(_close)
    _populate_room_list()

func _populate_room_list():
    var rooms = RoomDatabase.get_all()
    for room in rooms:
        var btn = Button.new()
        btn.text = room.display_name + " ($" + str(room.cost) + ")"
        btn.pressed.connect(_select_room.bind(room.id))
        $Panel/RoomList.add_child(btn)

func _select_room(room_id: String):
    var room = RoomDatabase.get(room_id)
    if room.is_empty(): return
    var cost = room.get("cost", 0)
    if not ResourceManager.has("budget", cost):
        AudioManager.play("ui_deny")
        return
    room_selected.emit(room_id)
    $Panel/Title.text = "Click a tile to place " + room.display_name
    AudioManager.play("ui_confirm")

func _close():
    queue_free()
