extends Area2D

var direction = Vector2.ZERO
@export var speed = 400.0
@export var damage = 1

func set_direction(dir: Vector2):
	direction = dir
	# 총알 이미지의 방향을 이동 방향에 맞게 회전 (선택 사항)
	rotation = dir.angle()

func _process(delta):
	position += direction * speed * delta

# 화면 밖으로 나가면 삭제 (VisibleOnScreenNotifier2D 시그널 연결)
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		## TODO take_damage 메소드 -> 라이프 -1, 라이프 = 0이면 queue_free해주고 사망 연출 instantiate
		## _take_damage로는 int 전달함. 데미지 바꾸고 싶으면 player_bullet에서
		body._take_damage(damage)
		queue_free()
