extends Node2D

# 1 load the scene
var meteor_scene : PackedScene = load("res://Scenes/meteor.tscn")

func _on_meteor_timer_timeout() -> void:
	var meteor = meteor_scene.instantiate()
	$Meteors.add_child(meteor)

# 1. 씬 프리로드 
# 2. 인스턴스화
# 3. 추가할 씬 밑에 차일드로 추가
