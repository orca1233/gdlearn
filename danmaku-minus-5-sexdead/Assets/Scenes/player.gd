extends CharacterBody2D

@export var speed: float = 300.0
@export var focus_speed: float = 150.0
@onready var hitbox_sprite = $HitboxSprite # 히트박스 표시용 스프라이트

func _ready() -> void:
	position = Vector2(576, 600)

func _physics_process(_delta):
	# 1. 입력 방향
	var direction = Input.get_vector("left", "right", "up", "down")
	# 디버깅용
	# print(direction)
	
	# 2. 저속 모드 체크
	var current_speed = speed
	if Input.is_action_pressed("shift"):
		current_speed = focus_speed
		hitbox_sprite.visible = true
	else:
		hitbox_sprite.visible = false

	# 3. 이동 적용
	velocity = direction * current_speed
	move_and_slide()
