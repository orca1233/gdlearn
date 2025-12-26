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

@export_group("Bomb")
@export var max_bomb: int = 3
@export var bomb_scene: PackedScene # 폭탄 씬 (Bomb.tscn)을 여기에 할당해야 함
var current_bomb: int
var is_bombing: bool = false # 현재 폭탄 사용 중인지

@export_group("Respawn")
@export var invincible_time : float = 1.5
@export var respawn_time : float = 1.0
@export var respawn_position : Vector2 = Vector2(576,600)

# 플레이어가 가지는 변수
var current_life: int
var can_shoot: bool = true
var is_invincible: bool = false # 무적 상태 확인

@onready var hitbox_sprite = $HitboxSprite
@onready var shoot_timer = $shoot_timer

# 플레이어가 쏘는 시그널
signal life_changed(new_life: int)
signal bomb_changed(new_bomb: int) # 폭탄 개수 변화 신호 추가
signal player_died

func _ready() -> void:
	# 목숨 수 초기화
	current_life = max_life
	# 폭탄 수 초기화
	current_bomb = max_bomb
	
	# 시작 위치 초기화, 임의값이라 나중에 수정
	position = respawn_position
	
	# 타이머=연사속도 설정
	shoot_timer.wait_time = fire_rate
	
	# UI 초기화를 위해 신호 발신
	life_changed.emit(current_life)
	bomb_changed.emit(current_bomb)


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
	var view_rect = get_viewport_rect()
	# 플레이어 크기 고려하여 여백 둠
	var padding = 16.0
	position.x = clamp(position.x, padding, view_rect.size.x - padding)
	position.y = clamp(position.y, padding, view_rect.size.y - padding)

	# 2. 공격 처리
	# Z키 또는 /키 (WASD 조작은 / , 화살표 조작은 z)
	if Input.is_action_pressed("attack"):
		shoot()
	
	# 폭탄
	if Input.is_action_just_pressed("bomb"):
		use_bomb()

# 폭탄 사용 로직
func use_bomb() -> void:
	# 폭탄 없거나, 사용중이거나, 죽은 상태일 경우 예외처리
	if current_bomb <= 0 or is_bombing or current_life <= 0:
		return
	
	# bomb 씬 안넣었을 때 대비
	if bomb_scene == null:
		print("bomb 씬 안넣음")
		return

	# 개수 차감
	current_bomb -= 1
	# UI 캔버스 갱신용 신호
	bomb_changed.emit(current_bomb)
	# 사용중에는 또 사용 못하게
	is_bombing = true
	
	# 폭탄 소환
	var bomb = bomb_scene.instantiate()
	# 플레이어 중심 위치에서 발동
	bomb.global_position = global_position
	get_parent().add_child(bomb)
	
	# 무적 시간 부여 (폭탄 위기 탈출용) - 필요 시 조정
	is_invincible = true
	
	# 폭탄 쿨타임/지속시간. await로 2초동안 기다려줌 (필요시 조정 가능)
	await get_tree().create_timer(2.0).timeout
	
	# 기다려준 후에 무적이랑 쿨타임 제거
	is_bombing = false
	is_invincible = false

# 총알 쏘는 로직
func shoot() -> void:
	if not can_shoot or not bullet_scene:
		return
	
	# 총알 생성
	var bullet = bullet_scene.instantiate()
	# 총알은 플레이어 앞 marker 위치에서 소환
	bullet.position = $BulletPos.global_position
	# 총알을 불렛컨테이너에 추가
	var bullet_container = get_parent().get_node("Bulletcontainer")
	bullet_container.add_child(bullet)
	
	# 쿨타임 도입, 수동 재시작 -> shoot timer 자동 시작 꺼놔야함
	can_shoot = false
	shoot_timer.start()


func _on_shoot_timer_timeout() -> void:
	can_shoot = true
	
func _take_damage(damage):
	# 이미 죽었으면 // 아니면 무적 상태면 무시
	if current_life <= 0 or is_invincible == true:
		return
	current_life -= damage

	# 체력 변화 신호 발신 (UI 업데이트용)
	life_changed.emit(current_life)
	# 폭발 이펙트 재생
	vfx_manager.spawn_explosion(global_position)
	
	if current_life <= 0:
		game_over()
	else:
		respawn()

func game_over() -> void:
	# 사망 신호 발신
	player_died.emit()
	
	# 조작권 뺏기
	set_physics_process(false)

func respawn() -> void:
	# 1. 조작권 뺏고 / visible 끄고 / invincible 설정
	set_physics_process(false)
	visible = false
	is_invincible = true
	
	# 죽었을 때 폭탄 개수를 다시 채워줄지(리스셋) 여부는 기획에 따라 다름. 여기선 일단 유지.
	# current_bomb = max_bomb # 만약 죽으면 폭탄 채워주려면 주석 해제
	# bomb_changed.emit(current_bomb)
	
	var view_rect = get_viewport_rect()
	position = Vector2(respawn_position.x, view_rect.size.y + 100)
	# 2. 살짝 대기 (1초)
	await get_tree().create_timer(respawn_time).timeout
	
	# 3. 화면 아래쪽에서 등장 준비
	visible = true
	
	# 4. 슬라이딩 연출 (Tween 사용)
	var respawn_tween = create_tween()
	respawn_tween.set_trans(Tween.TRANS_CUBIC)
	respawn_tween.set_ease(Tween.EASE_OUT)
	# tween 써서 position을 respawn_position까지 1.5초동안 옮긴다
	respawn_tween.tween_property(self, "position", respawn_position, 1.5)
	
	await respawn_tween.finished
	
	# 5. 조작 가능하게 설정해주기
	position = respawn_position
	visible = true
	set_physics_process(true)
	
	# 4.5. 무적시간 주기
	var blink_tween = create_tween()
	blink_tween.set_loops() # 무한 반복 설정
	blink_tween.tween_property(self, "modulate:a", 0.5, 0.1) # 반투명
	blink_tween.tween_property(self, "modulate:a", 1.0, 0.1) # 불투명
	await get_tree().create_timer(invincible_time).timeout # 1.5초 끝날 때까지 대기
	
	# 5. 무적 해제
	if blink_tween:
		blink_tween.kill() # blink tween 있으면 죽이고 / alpha 값 1.0으로 만들기
		modulate.a = 1.0
	is_invincible = false # 그 후에 무적 해제
