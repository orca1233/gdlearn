# enemy_bullet.gd
extends Area2D

@export var damage : int = 1
var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var original_speed: float = 0.0

# 이동 패턴 관련
var move_type: BulletPatternData.MoveType = BulletPatternData.MoveType.LINEAR
var pattern_data: BulletPatternData = null
var lifetime: float = 0.0  # 생성 후 경과 시간

# CURVE 타입용
var curve_time: float = 0.0
var initial_direction: Vector2 = Vector2.ZERO

# HOMING 타입용
var homing_active: bool = false

# STOP_AND_CHANGE 타입용
var has_stopped: bool = false
var stop_elapsed: float = 0.0
var is_stopped: bool = false

# graze 관련
var is_grazed: bool = false       # 현재 graze 중인지
var has_scored_graze: bool = false  # 이미 graze 점수 획득했는지
const GRAZE_SPEED_MULTIPLIER = 0.85 # 탄속 얼마나 느리게 만드는지
const GRAZE_SCORE_PER_TICK = 1000  # 틱당 점수 (조정 가능)
const GRAZE_SCORE_INTERVAL = 0.1  # 0.1초마다 점수 획득

var graze_timer: float = 0.0  # 총알이 들어와있던 시간에 따라서 graze 점수를 줌

func setup(data: BulletPatternData, dir: Vector2, custom_speed: float):
	# 데이터에서 텍스처와 충돌 영역 설정
	if has_node("Sprite2D"): $Sprite2D.texture = data.texture
	if has_node("CollisionShape2D"): $CollisionShape2D.shape = data.collision_shape
	
	# 이동 관련 설정
	self.pattern_data = data
	self.move_type = data.move_type
	self.direction = dir
	self.initial_direction = dir
	self.speed = custom_speed
	self.rotation = dir.angle() + deg_to_rad(data.sprite_rotation)
	
	original_speed = custom_speed
	
	# HOMING 타입 초기화
	if move_type == BulletPatternData.MoveType.HOMING:
		homing_active = true

func _process(delta):
	lifetime += delta
	
	# 이동 패턴별 처리
	if pattern_data:
		match move_type:
			BulletPatternData.MoveType.LINEAR:
				_move_linear(delta)
			
			BulletPatternData.MoveType.ACCELERATE:
				_move_accelerate(delta)
			
			BulletPatternData.MoveType.CURVE:
				_move_curve(delta)
			
			BulletPatternData.MoveType.HOMING:
				_move_homing(delta)
			
			BulletPatternData.MoveType.STOP_AND_CHANGE:
				_move_stop_and_change(delta)
	else:
		# pattern_data가 없으면 기본 직선 이동
		position += direction * speed * delta
	
	# graze 로직 : 
	# shift를 누른 상태에서 area(총알)이 플레이어 그레이즈 에리어로 들어간 상태에서 (is_grazed = true)
	# graze timer가 0.1초보다 커지면 graze timer를 초기화하고 점수를 줌
	if is_grazed:
		graze_timer += delta
		# 0.1초마다 점수 지급
		if graze_timer >= GRAZE_SCORE_INTERVAL:
			_give_graze_score()
			graze_timer = 0.0  # 타이머 리셋

## 이동 패턴 함수들 ##

# LINEAR: 기본 직선 이동
func _move_linear(delta: float):
	position += direction * speed * delta

# ACCELERATE: 가속/감속 이동
func _move_accelerate(delta: float):
	speed += pattern_data.acceleration * delta
	# 속도가 음수가 되지 않도록 제한
	speed = max(speed, 0.0)
	position += direction * speed * delta

# CURVE: 사인파 곡선 이동
func _move_curve(delta: float):
	curve_time += delta
	
	# 전진 방향으로 이동
	position += initial_direction * speed * delta
	
	# 수직 방향으로 사인파 진동 추가
	var perpendicular = initial_direction.rotated(PI / 2)
	var offset = sin(curve_time * pattern_data.curve_frequency) * pattern_data.curve_amplitude * delta
	position += perpendicular * offset

# HOMING: 플레이어 추적 유도탄
func _move_homing(delta: float):
	if homing_active and lifetime < pattern_data.homing_duration:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var target_dir = (players[0].global_position - global_position).normalized()
			# 현재 방향과 목표 방향을 부드럽게 보간
			direction = direction.lerp(target_dir, pattern_data.homing_strength * delta / 100.0)
			direction = direction.normalized()
			
			# 회전도 업데이트
			rotation = direction.angle()
	else:
		# 유도 시간이 끝나면 일반 직선 이동
		homing_active = false
	
	position += direction * speed * delta

# STOP_AND_CHANGE: 정지 후 방향 전환
func _move_stop_and_change(delta: float):
	if not has_stopped:
		# 정지 트리거 시간 전까지는 일반 이동
		if lifetime < pattern_data.stop_trigger_time:
			position += direction * speed * delta
		else:
			# 정지 시작
			has_stopped = true
			is_stopped = true
	else:
		if is_stopped:
			# 정지 중
			stop_elapsed += delta
			if stop_elapsed >= pattern_data.stop_time:
				# 정지 종료, 방향 전환
				is_stopped = false
				direction = direction.rotated(deg_to_rad(pattern_data.change_angle))
				rotation = direction.angle()
		else:
			# 방향 전환 후 이동
			position += direction * speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		## TODO take_damage 메소드 -> 라이프 -1, 라이프 = 0이면 queue_free해주고 사망 연출 instantiate
		## _take_damage로는 int 전달함. 데미지 바꾸고 싶으면 player_bullet에서
		body._take_damage(damage)
		return_to_pool()

func _on_visible_on_screen_notifier_2d_screen_exited():
	return_to_pool()

func _add_graze():
	if not is_grazed: # graze 상태가 아니면
		is_grazed = true # ture로 만들어주고 
		speed = original_speed * GRAZE_SPEED_MULTIPLIER # speed에 0.85 곱해서 느리게 만들기
		graze_timer = 0.0  # 타이머 초기화
		modulate = Color(0.45, 0, 0) # 색깔 빨갛게 변경
		
# 반대 로직인 remove도 만듬
func _remove_graze() -> void:
	if is_grazed:
		is_grazed = false # graze 꺼주기
		speed = original_speed # 속도 초기화
		graze_timer = 0.0 # graze 타이머 초기화
		modulate = Color(1.0, 1.0, 1.0)

func _give_graze_score():
	var player = get_tree().get_first_node_in_group("player") # player를 가져옴
	if player and player.has_signal("graze_scored"): # 플레이어가 있고(오류방지용), 플레이어에게 해당 시그널 있으면
		player.graze_scored.emit(GRAZE_SCORE_PER_TICK) # 점수 발송(int)

# Pooling 관련 함수들
func return_to_pool():
	# 상태 초기화
	reset_bullet_state()
	
	# BulletPool에 반환
	BulletPool.return_bullet_to_pool(self)

func reset_bullet_state():
	# 모든 상태 변수 초기화
	direction = Vector2.ZERO
	speed = 0.0
	original_speed = 0.0
	move_type = BulletPatternData.MoveType.LINEAR
	pattern_data = null
	lifetime = 0.0
	curve_time = 0.0
	initial_direction = Vector2.ZERO
	homing_active = false
	has_stopped = false
	stop_elapsed = 0.0
	is_stopped = false
	is_grazed = false
	has_scored_graze = false
	graze_timer = 0.0
	
	# 그래픽 상태 초기화
	modulate = Color(1.0, 1.0, 1.0)
