extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/Label2.text = $CenterContainer/VBoxContainer/Label2.text # + str($Score.text)

func _input(event):
	if event.is_action_pressed("attack"):
		get_tree().change_scene_to_file("res://Scenes/game_scene.tscn")
