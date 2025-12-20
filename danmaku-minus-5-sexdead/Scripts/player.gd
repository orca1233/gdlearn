extends CharacterBody2D

# Inspector에서 조정 가능하게 export
@export_group("Movement")
@export var speed: float = 300.0
@export var focus_speed: float = 150.0

@export_group("Combat")
# 목숨
@export var max_life: int = 3
# 탄막 불러오기(굳이 export일 필요는 없는데 일단) & 연사시간 조정
@export var bullet_scene: PackedScene = preload("res://Scenes/player_bullet.tscn")
@export var fire_rate: float = 0.08 # 연사 속도

# 플레이어가 가지는 변수
var current_life: int
var can_shoot: bool = true

@onready var hitbox_sprite = $HitboxSprite
@onready var shoot_timer = $shoot_timer

# 플레이어가 쏘는 시그널(데미지 입었다 / 죽었다)
signal life_changed(new_life: int)
signal player_died

func _ready() -> void:
	# 목숨 수 초기화
	current_life = max_life
	# 시작 위치 초기화, 임의값이라 나중에 수정
	position = Vector2(576,600)
	
	# 타이머=연사속도 설정
	shoot_timer.wait_time = fire_rate
	# 꽉찬 하트 그릴 수 있게 신호 발신
	life_changed.emit(current_life)


# 충돌이나 slide 어쩌고 할때는 _physics process 쓰는게 좋다는 글을 봄
func _physics_process(_delta: float) -> void:

	# 1. 이동 처리 (WASD 및 화살표)
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var current_move_speed = speed
	
	# 저속 모드 (Shift)
	if Input.is_action_pressed("shift"):
		current_move_speed = focus_speed
		hitbox_sprite.visible = true
	else:
		hitbox_sprite.visible = false

	velocity = input_dir * current_move_speed
	move_and_slide()
	
	# 화면 밖으로 나가지 않게 제한하기 위해 clamp 사용
	# clamp(a,b,c) = 특정 값 a가 b, c 사이의 값만 반환하도록 고정하는 것
		# 즉 여기서는 x, y가 16 ~ 1152-16, 648-16 사이에서만 움직일 수 있게 됨
	var view_rect = get_viewport_rect()
	# 플레이어 크기 고려하여 여백 둠
	var padding = 16.0
	position.x = clamp(position.x, padding, view_rect.size.x - padding)
	position.y = clamp(position.y, padding, view_rect.size.y - padding)

	# 2. 공격 처리
	# Z키 또는 /키 (WASD 조작은 / , 화살표 조작은 z)
	if Input.is_action_pressed("attack"):
		shoot()

# 총알 쏘는(소환하는) 로직
	# level에서 안 하는 이유 -> 스테이지 많이 만들건데 그때마다 총알 로직 level에서 구현해주기 귀찮아서 플레이어에 박음
func shoot() -> void:
	if not can_shoot or not bullet_scene:
		return
	
	# 총알 생성
	var bullet = bullet_scene.instantiate()
	# 총알은 플레이어 앞 marker 위치에서 소환
	bullet.position = $BulletPos.global_position
	# 총알을 불렛컨테이너에 추가
		# 를 위해서 Player의 부모인 Gameplaycontainer의 node인 bulletcontainer를 가져옴
	var bullet_container = get_parent().get_node("Bulletcontainer")
	bullet_container.add_child(bullet)
	
	# 쿨타임 도입, 수동 재시작 -> shoot timer 자동 시작 꺼놔야함
	can_shoot = false
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	
func _take_damage(damage):
	# 이미 죽었으면 무시

	if current_life <= 0:
		return
	current_life -= damage

	# 체력 변화 신호 발신 (UI 업데이트용)
	life_changed.emit(current_life)
		
	if current_life <= 0:
		game_over()

func game_over() -> void:
	# 사망 신호 발신
	player_died.emit()
	
	# 조작권 뺏기
	set_physics_process(false)
	
	# (선택) 플레이어 숨기기 or 폭발 이펙트 재생 등
	# visible = false
