extends Area2D

var direction = Vector2.ZERO
@export var speed = 400.0

func set_direction(dir: Vector2):
	direction = dir
	# 총알 이미지의 방향을 이동 방향에 맞게 회전 (선택 사항)
	rotation = dir.angle()

func _process(delta):
	print("내 방향은: ", direction)
	position += direction * speed * delta

# 화면 밖으로 나가면 삭제 (VisibleOnScreenNotifier2D 시그널 연결)
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
