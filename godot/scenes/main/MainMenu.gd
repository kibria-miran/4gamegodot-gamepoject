extends Control

func _ready():
    $Continue.disabled = not SaveManager.save_exists()

func _on_new_game_pressed():
    GameState.transition_to(GameState.State.BASE_PHASE)
    get_tree().change_scene_to_file("res://scenes/base/BaseView.tscn")

func _on_continue_pressed():
    if SaveManager.load_game():
        GameState.transition_to(GameState.State.BASE_PHASE)
        get_tree().change_scene_to_file("res://scenes/base/BaseView.tscn")

func _on_quit_pressed():
    get_tree().quit()
