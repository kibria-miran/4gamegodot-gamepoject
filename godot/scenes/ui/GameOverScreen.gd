extends Control

func _ready():
    $Panel/MainMenuBtn.pressed.connect(_main_menu)
    EventBus.game_over.connect(_on_game_over)

func _on_game_over(reason: String):
    $Panel/ReasonLabel.text = "Reason: " + reason
    AudioManager.play("game_over")

func _main_menu():
    GameState.transition_to(GameState.State.MAIN_MENU)
    get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
