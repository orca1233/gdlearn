extends Area2D

@export var bullet_scene: PackedScene # 에디터에서 Bullet.tscn을 드래그 앤 드롭
@export var item_scene : PackedScene # 에디터에서 item씬

enum BehaviorState {
    SPAWNING,        # 등장 중
    PATROLLING,      # 이동 중
    ATTACKING,       # 공격 중 (탄막 발사)
    EVADING,         # 회피 중 (플레이어 탄막 회피)
    DYING,           # 사망 중
    SPECIAL          # 특수 행동 (분열, 변신 등)
}

@export var damage : int = 1
@export var max_life = 1
@onready var current_life = max_life

@export_group("Behavior Settings")
@export var initial_state: BehaviorState = BehaviorState.SPAWNING
@export var attack_interval: float = 2.0       # 공격 간격
@export var evade_chance: float = 0.3          # 회피 확률
@export var special_behavior_chance: float = 0.1  # 특수 행동 확률

@export_group("Item Summon")
@export var summon_power_item = 1
@export var summon_score_item = 3
@export var item_score = 100000

signal enemy_died
signal state_changed(old_state: BehaviorState, new_state: BehaviorState)

var current_state: BehaviorState = BehaviorState.SPAWNING
var state_timer: float = 0.0
var player_in_range: bool = false
var is_vulnerable: bool = true

func _ready():
	current_state = initial_state
	# 초기 상태 진입
	_enter_state(current_state)

func _process(delta: float):
	state_timer += delta
	
	# 상태별 업데이트
	match current_state:
		BehaviorState.SPAWNING:
			_update_spawning(delta)
		BehaviorState.PATROLLING:
			_update_patrolling(delta)
		BehaviorState.ATTACKING:
			_update_attacking(delta)
		BehaviorState.EVADING:
			_update_evading(delta)
		BehaviorState.DYING:
			_update_dying(delta)
		BehaviorState.SPECIAL:
			_update_special(delta)
	
	# 플레이어 감지 (간단한 거리 체크)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var distance = global_position.distance_to(players[0].global_position)
		player_in_range = distance < 300  # 300px 내에 있으면 범위 내

# 상태 전환 함수
func change_state(new_state: BehaviorState):
	if new_state == current_state:
		return
	
	var old_state = current_state
	_exit_state(old_state)
	current_state = new_state
	_enter_state(new_state)
	
	state_changed.emit(old_state, new_state)
	state_timer = 0.0

# 상태 진입 처리
func _enter_state(state: BehaviorState):
	match state:
		BehaviorState.SPAWNING:
			is_vulnerable = false  # 등장 중에는 무적
			modulate = Color(0.7, 0.7, 0.7, 0.8)  # 반투명
		
		BehaviorState.PATROLLING:
			is_vulnerable = true
			modulate = Color(1, 1, 1, 1)  # 정상 색상
		
		BehaviorState.ATTACKING:
			is_vulnerable = true
			modulate = Color(1, 0.5, 0.5, 1)  # 약간 붉은색 (공격 표시)
			# 탄막 발사 시작
			if has_node("bullet"):
				$bullet.fire_timer.start()
		
		BehaviorState.EVADING:
			is_vulnerable = false  # 회피 중에는 무적
			modulate = Color(0.5, 0.5, 1, 0.7)  # 파란색 반투명
		
		BehaviorState.DYING:
			is_vulnerable = false
		
		BehaviorState.SPECIAL:
			is_vulnerable = false
			modulate = Color(1, 1, 0.5, 1)  # 노란색 (특수 행동)

# 상태 종료 처리
func _exit_state(state: BehaviorState):
	match state:
		BehaviorState.ATTACKING:
			# 탄막 발사 중지
			if has_node("bullet"):
				$bullet.fire_timer.stop()
		
		BehaviorState.EVADING:
			# 회피 효과 제거
			pass

func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		body._take_damage(damage)

# 플레이어 탄막 감지
func _on_area_entered(area: Area2D):
	if area.is_in_group("player_bullet"):
		# 피격 시 회피 시도
		if current_state != BehaviorState.EVADING and current_state != BehaviorState.DYING:
			if randf() < evade_chance:
				change_state(BehaviorState.EVADING)
			else:
				# 회피 실패 시 데미지 처리
				_take_damage_from_bullet(area)

# 탄막으로부터 데미지 처리
func _take_damage_from_bullet(bullet: Area2D):
	if is_vulnerable:
		# bullet의 damage 속성 사용 (player_bullet.gd 참고)
		var bullet_damage = 1
		if bullet.has_method("get_damage"):
			bullet_damage = bullet.get_damage()
		elif bullet.has_property("damage"):
			bullet_damage = bullet.damage
		
		_take_damage(bullet_damage)

# 보스한테도 적용 가능하게
func _take_damage(damage_amount: int):
	if not is_vulnerable:
		return  # 무적 상태면 데미지 무시
	
	# 피격 이펙트 (깜빡임)
	modulate = Color(1, 0.5, 0.5, 1)  # 붉은색
	get_tree().create_timer(0.1).timeout.connect(func(): 
		if current_state != BehaviorState.DYING:
			modulate = Color(1, 1, 1, 1)
	)
	
	current_life -= damage_amount
	if current_life <= 0:
		change_state(BehaviorState.DYING)
	else:
		# 체력이 낮을수록 회피 확률 증가
		var health_ratio = float(current_life) / max_life
		evade_chance = 0.3 + (0.5 * (1.0 - health_ratio))  # 30%~80% 회피 확률
		
		# 데미지 받으면 공격 중단하고 PATROLLING으로
		if current_state == BehaviorState.ATTACKING:
			change_state(BehaviorState.PATROLLING)
		
func _object_died():
	enemy_died.emit()
	vfx_manager.spawn_explosion(global_position)
	# 죽을 때 아이템 소환
	spawn_items()
	queue_free()

# 상태별 업데이트 함수들
func _update_spawning(delta: float):
	# 등장 애니메이션 (서서히 나타남)
	modulate.a = min(modulate.a + delta, 1.0)
	
	# 1초 후 PATROLLING 상태로 전환
	if state_timer >= 1.0:
		change_state(BehaviorState.PATROLLING)

func _update_patrolling(delta: float):
	# 플레이어가 범위 내에 있고, 공격 간격이 지났으면 공격
	if player_in_range and state_timer >= attack_interval:
		change_state(BehaviorState.ATTACKING)
	
	# 랜덤하게 특수 행동 시도
	if randf() < special_behavior_chance * delta:
		change_state(BehaviorState.SPECIAL)

func _update_attacking(delta: float):
	# 공격 지속 시간 (2초)
	if state_timer >= 2.0:
		# 플레이어가 여전히 범위 내에 있으면 계속 공격
		if player_in_range and randf() < 0.7:  # 70% 확률로 계속 공격
			state_timer = 0.0  # 타이머 리셋하고 계속 공격
		else:
			change_state(BehaviorState.PATROLLING)

func _update_evading(delta: float):
	# 회피 이동 (플레이어 반대 방향으로)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var evade_dir = (global_position - players[0].global_position).normalized()
		position += evade_dir * 100 * delta
	
	# 회피 지속 시간 (1초)
	if state_timer >= 1.0:
		change_state(BehaviorState.PATROLLING)

func _update_dying(delta: float):
	# 사망 애니메이션 (서서히 사라짐)
	modulate.a = max(modulate.a - delta * 2, 0.0)
	
	# 1초 후 실제 제거
	if state_timer >= 1.0:
		_object_died()

func _update_special(delta: float):
	# 특수 행동 (예: 분열, 강화 등)
	# 여기서는 간단히 강화 효과만 구현
	modulate.g = sin(state_timer * 5) * 0.5 + 0.5  # 녹색 깜빡임
	
	# 특수 행동 지속 시간 (3초)
	if state_timer >= 3.0:
		# 강화 효과: 공격 속도 증가
		attack_interval *= 0.8  # 20% 빨라짐
		change_state(BehaviorState.PATROLLING)

func spawn_items():
	# item_scene 없으면 
	if item_scene == null: return
	
	# 1. 파워 아이템 summon_power_item개 생성, 기본값 1
	for i in range(summon_power_item):
		var power_item = item_scene.instantiate()
		# 죽었을 때 위치에 소환
		power_item.global_position = global_position
		# item_scene을 불러왔기 때문에, 그 안의 init_item을 쓸 수 있음 
		# type 0으로 지정해주고, value는 1로 지정해줌 (이러면 poweritem / value = 1이 된다).
			# type 0 / 2는 value를 지정해줄 필요가 없기 때문에 우선은 기본값 1로 해둠.
		power_item.init_item(0, 1) 
		get_tree().current_scene.call_deferred("add_child", power_item)
	
	# 2. 점수 아이템 summon_score_item개 생성, 기본값 3
	for i in range(summon_score_item):
		var score_item = item_scene.instantiate()
		# 위치를 랜덤하게 분산
		var randomizer = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		score_item.global_position = global_position + randomizer
		# item_scene을 불러왔기 때문에, 그 안의 init_item을 쓸 수 있음 
			# type 1 = score item으로 지정해주고, value는 item_score으로 지정해줌.
			# 이러면 item에 값 2개가 전달되고, 다시 item이 player에 닿았을 때 값을 전해주고,
			# player는 최상위인 game_scene에 이 값을 전달해 준 뒤에, game_scene이 ui를 최신화함.
		score_item.init_item(1, item_score)
		get_tree().current_scene.call_deferred("add_child", score_item)
