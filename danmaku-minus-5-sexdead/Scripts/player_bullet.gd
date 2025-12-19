extends Area2D

# 총알 데미지랑 속도 설정 가능하게 함
@export var speed: float = 800.0
@export var damage: int = 1
# 상하좌우 결정 가능하게, 나중에 좌우탄도 있을법하니까
@export var direction:= Vector2.UP

# 쓸변수
@onready var notifier = $VisibleOnScreenNotifier2D

func _physics_process(delta: float) -> void:
	# 총알은 방향 따라서
	position += direction * speed * delta

# 화면 밖으로 나갔는지 체크하고 삭제
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	# 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		# TODO take_damage 메소드 -> 라이프 -1, 라이프 = 0이면 queue_free해주고 사망 연출 instantiate
		# _take_damage로는 int 전달함. 데미지 바꾸고 싶으면 player_bullet에서
		body._take_damage(damage)
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# 적이 Area2D면 이거
	if area.has_method("_take_damage"):
		area._take_damage(damage)
		queue_free()
