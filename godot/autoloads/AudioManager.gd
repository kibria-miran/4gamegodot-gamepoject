extends Node

var _streams: Dictionary = {}
var _audio_player: AudioStreamPlayer

func _ready():
    _audio_player = AudioStreamPlayer.new()
    add_child(_audio_player)
    _load_all("res://assets/audio/sfx/")
    _wire_eventbus()

func _wire_eventbus():
    EventBus.room_built.connect(func(rid, tile): play("room_build"))
    EventBus.resource_changed.connect(func(type, val):
        if type == "power" and val < 10: play("power_low")
        if type == "security" and val < 15: play("security_low")
    )
    EventBus.day_started.connect(func(day): play("day_end"))
    EventBus.event_fired.connect(func(event): play("event_popup"))
    EventBus.mission_started.connect(func(mid): play("mission_deploy"))
    EventBus.mission_completed.connect(func(success, result):
        play("mission_success" if success else "mission_fail")
    )
    EventBus.game_over.connect(func(reason): play("game_over"))

func play(sound_id: String, volume_db: float = 0.0):
    if not _streams.has(sound_id):
        return
    _audio_player.stream = _streams[sound_id]
    _audio_player.volume_db = volume_db
    _audio_player.play()

func stop():
    _audio_player.stop()

func set_volume(volume_db: float):
    _audio_player.volume_db = volume_db

func _load_all(path: String):
    var dir = DirAccess.open(path)
    if not dir:
        return
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        var extension = file.get_extension().to_lower()
        if extension in ["ogg", "mp3", "wav"]:
            var sound_path = path.path_join(file)
            var stream = load(sound_path)
            if stream:
                var sound_id = file.get_basename()
                _streams[sound_id] = stream
        file = dir.get_next()
