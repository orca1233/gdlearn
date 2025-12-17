extends Node2D

var theta: float = 0.0 # 총알 각도
@export_range(0,2*PI) var alpha: float = 0.0 # 각도 슬라이더

@export var bullet_node: PackedScene

func get_vector(angle):
	theta = angle + alpha 
	return Vector2(cos(theta),sin(theta)) # 삼각 함수 모르겠으면 수학책 펴

func shoot(angle):
	var bullet = bullet_node.instantiate()
	get_tree().current_scene.call_deferred("add_child", bullet)
	
	bullet.position = global_position # 총알이 보스에 따라 움직이면 안되니
	bullet.direction = get_vector(angle)

# get_tree().currnet_scene = 지금 실행 중인 게임의 바탕이 되는 씬을 가져오고
# call_defered("add_child", bullet) = 신호나 물리 연산뒤에 총알 생성
# 그냥 안하는 이유는 검색 ㄱ

func _on_timer_timeout() -> void:
	shoot(theta)
