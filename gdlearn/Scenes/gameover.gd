extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/Label2.text = $CenterContainer/VBoxContainer/Label2.text + str(Global.score)

func _input(event):
	if event.is_action_pressed("shoot"):
		get_tree().change_scene_to_file("res://Scenes/level.tscn")
