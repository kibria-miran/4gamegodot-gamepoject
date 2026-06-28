extends Node

func _ready():
    print("Blacksite Command v1.0 -- Phase 1")
    print("ResourceManager initialized / RoomDatabase loaded / EventBus ready / DayCycle ready / GameState ready: MAIN_MENU")
    GameState.transition_to(GameState.State.MAIN_MENU)
    get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
