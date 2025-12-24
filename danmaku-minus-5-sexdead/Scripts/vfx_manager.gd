extends Node

# 미리 로드
var explosion_scene = preload("res://Scenes/explosion.tscn")

# 폭발 이펙트 생성 함수
func spawn_explosion(pos: Vector2):
	if explosion_scene:
		var effect = explosion_scene.instantiate()
		effect.global_position = pos
		# 씬에 추가해야 적이 큐 프리해도 이펙트가 남음
		get_tree().current_scene.add_child(effect)
