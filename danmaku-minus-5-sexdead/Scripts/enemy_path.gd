extends Node2D

enum PathType { 
    BEZIER,          # 기존 베지어 곡선 이동
    CIRCLE,          # 원형 순회
    SINE_WAVE,       # 사인파 이동
    HOMING,          # 플레이어 추적
    RANDOM_WALK,     # 랜덤 이동
    STOP_AND_SHOOT   # 정지 후 발사
}

@export_group("Basic Settings")
@export var path_type: PathType = PathType.BEZIER
@export var move_duration: float = 3.0  # 도착 예상 시간 (초)
@export var exit_speed: float = 200.0  # 화면 밖으로 나갈 속도

@export_group("Circle Path")
@export var circle_radius: float = 100.0  # 원 반경
@export var circle_speed: float = 1.0     # 원 주회 속도

@export_group("Sine Wave Path") 
@export var wave_amplitude: float = 50.0  # 파동 진폭
@export var wave_frequency: float = 2.0   # 파동 주파수

@export_group("Homing Path")
@export var homing_strength: float = 100.0  # 유도 강도
@export var homing_start_time: float = 1.0  # 유도 시작 시간

@export_group("Random Walk")
@export var random_change_interval: float = 0.5  # 방향 변경 간격
@export var random_speed_variance: float = 50.0  # 속도 변동 범위

@export_group("Stop and Shoot")
@export var stop_time: float = 2.0          # 정지 시간
@export var stop_position: Vector2 = Vector2(320, 240)  # 정지 위치

var start_pos: Vector2
var elapsed_time: float = 0.0
var is_mirrored: bool = false  # 미러 플래그
var reached_end: bool = false  # 목표점 도착 여부
var path_phase: float = 0.0    # 경로 위상 (Circle/Sine용)
var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0
var stop_phase: float = 0.0  # 0: 이동, 1: 정지, 2: 퇴장

func _ready():
	start_pos = global_position

func _process(delta: float):
	elapsed_time += delta
	
	match path_type:
		PathType.BEZIER:
			_process_bezier(delta)
		PathType.CIRCLE:
			_process_circle(delta)
		PathType.SINE_WAVE:
			_process_sine_wave(delta)
		PathType.HOMING:
			_process_homing(delta)
		PathType.RANDOM_WALK:
			_process_random_walk(delta)
		PathType.STOP_AND_SHOOT:
			_process_stop_and_shoot(delta)

# 화면 밖으로 나갔는지 체크 및 제거
func _check_screen_exit():
	if global_position.y < -100 or global_position.y > get_viewport().get_visible_rect().size.y + 100 \
		or global_position.x < -100 or global_position.x > get_viewport().get_visible_rect().size.x + 100:
		queue_free()

# BEZIER: 기존 베지어 곡선 이동
func _process_bezier(delta: float):
	var progress = min(elapsed_time / move_duration, 1.0)
	
	# 화면 정보
	var viewport_size = get_viewport().get_visible_rect().size
	var screen_center_x = viewport_size.x / 2
	
	# 미러링 상태에 따라 경로 조정
	var point1: Vector2
	var point2: Vector2
	
	if is_mirrored:
		# 오른쪽 경로: (viewport_width - 100, 100) → (screen_center_x, -100)
		point1 = Vector2(viewport_size.x - 100, 100)
		point2 = Vector2(screen_center_x, -100)
	else:
		# 왼쪽 경로: (100, 100) → (screen_center_x, -100)
		point1 = Vector2(100, 100)
		point2 = Vector2(screen_center_x, -100)
	
	# 구간 1: 시작점 → point1 (0.0 ~ 0.5)
	# 구간 2: point1 → point2 (0.5 ~ 1.0)
	if progress <= 0.5:
		var local_progress = progress / 0.5
		global_position = lerp(start_pos, point1, local_progress)
	elif progress < 1.0:
		var local_progress = (progress - 0.5) / 0.5
		global_position = lerp(point1, point2, local_progress)
	else:
		# 목표점 도착 후, 계속 위쪽으로 이동
		if not reached_end:
			reached_end = true
		global_position.y -= exit_speed * delta
	
	_check_screen_exit()

# CIRCLE: 원형 순회
func _process_circle(delta: float):
	path_phase += delta * circle_speed
	
	# 화면 정보
	var viewport_size = get_viewport().get_visible_rect().size
	var center_x = viewport_size.x / 2
	var center_y = viewport_size.y / 3  # 화면 상단 1/3 지점
	
	# 원형 이동 계산
	var circle_x = center_x + cos(path_phase) * circle_radius
	var circle_y = center_y + sin(path_phase) * circle_radius
	
	global_position = Vector2(circle_x, circle_y)
	
	# 일정 시간 후 퇴장
	if elapsed_time >= move_duration:
		global_position.y -= exit_speed * delta
	
	_check_screen_exit()

# SINE_WAVE: 사인파 이동
func _process_sine_wave(delta: float):
	path_phase += delta * wave_frequency
	
	# 화면 정보
	var viewport_size = get_viewport().get_visible_rect().size
	var start_x = 100 if not is_mirrored else viewport_size.x - 100
	var end_x = viewport_size.x / 2
	
	# 진행도 계산
	var progress = min(elapsed_time / move_duration, 1.0)
	
	# X축 이동 (왼쪽/오른쪽 → 중앙)
	var target_x = lerp(start_x, end_x, progress)
	
	# Y축 사인파 진동
	var wave_offset = sin(path_phase) * wave_amplitude
	var base_y = 100 + progress * 200  # 기본 Y축 이동
	var target_y = base_y + wave_offset
	
	global_position = Vector2(target_x, target_y)
	
	# 목표점 도착 후 퇴장
	if progress >= 1.0:
		global_position.y -= exit_speed * delta
	
	_check_screen_exit()

# HOMING: 플레이어 추적
func _process_homing(delta: float):
	# 화면 정보
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 초기 이동 (화면 안으로 들어오기)
	if elapsed_time < homing_start_time:
		var progress = elapsed_time / homing_start_time
		var start_x = 100 if not is_mirrored else viewport_size.x - 100
		var target_x = viewport_size.x / 2
		var target_y = 150
		
		global_position.x = lerp(start_x, target_x, progress)
		global_position.y = lerp(-50, target_y, progress)
	else:
		# 플레이어 추적
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var target_dir = (players[0].global_position - global_position).normalized()
			global_position += target_dir * homing_strength * delta
	
	# 일정 시간 후 퇴장
	if elapsed_time >= move_duration:
		global_position.y -= exit_speed * delta
	
	_check_screen_exit()

# RANDOM_WALK: 랜덤 이동
func _process_random_walk(delta: float):
	random_timer += delta
	
	# 주기적으로 방향 변경
	if random_timer >= random_change_interval or random_dir == Vector2.ZERO:
		random_timer = 0.0
		random_dir = Vector2(randf_range(-1, 1), randf_range(-0.5, 0.5)).normalized()
		
		# 속도 변동 적용
		var current_speed = exit_speed + randf_range(-random_speed_variance, random_speed_variance)
		random_dir *= current_speed
	
	# 랜덤 이동
	global_position += random_dir * delta
	
	# 화면 경계 처리
	var viewport_rect = get_viewport().get_visible_rect()
	viewport_rect = viewport_rect.grow(-50)  # 경계선 안쪽으로 50px 여유
	
	if global_position.x < viewport_rect.position.x:
		random_dir.x = abs(random_dir.x)
	elif global_position.x > viewport_rect.end.x:
		random_dir.x = -abs(random_dir.x)
	
	if global_position.y < viewport_rect.position.y:
		random_dir.y = abs(random_dir.y)
	elif global_position.y > viewport_rect.end.y:
		random_dir.y = -abs(random_dir.y)
	
	# 일정 시간 후 퇴장
	if elapsed_time >= move_duration:
		global_position.y -= exit_speed * delta
	
	_check_screen_exit()

# STOP_AND_SHOOT: 정지 후 발사
func _process_stop_and_shoot(delta: float):
	match stop_phase:
		0:  # 이동 단계
			var progress = min(elapsed_time / (move_duration * 0.5), 1.0)
			global_position = lerp(start_pos, stop_position, progress)
			
			if progress >= 1.0:
				stop_phase = 1
				elapsed_time = 0.0  # 정지 타이머 초기화
		
		1:  # 정지 단계
			elapsed_time += delta
			if elapsed_time >= stop_time:
				stop_phase = 2
				elapsed_time = 0.0  # 퇴장 타이머 초기화
		
		2:  # 퇴장 단계
			global_position.y -= exit_speed * delta
	
	_check_screen_exit()
