extends Node2D

enum PathType { 
    BEZIER,          # 기존 베지어 곡선 이동
    CIRCLE,          # 원형 순회
    SINE_WAVE,       # 사인파 이동
    HOMING,          # 플레이어 추적
    RANDOM_WALK,     # 랜덤 이동
    STOP_AND_SHOOT,  # 정지 후 발사
    CUSTOM_POINTS    # 좌표 기반 경로
}

enum StartPosition {
    LEFT_TOP,       # 좌측 상단
    LEFT_CENTER,    # 좌측 중앙
    LEFT_BOTTOM,    # 좌측 하단
    RIGHT_TOP,      # 우측 상단
    RIGHT_CENTER,   # 우측 중앙
    RIGHT_BOTTOM,   # 우측 하단
    CUSTOM          # 직접 좌표
}

enum EndPosition {
    CENTER_TOP,     # 중앙 상단
    CENTER,         # 중앙
    CENTER_BOTTOM,  # 중앙 하단
    CUSTOM          # 직접 좌표
}

enum CurveType {
    LINEAR,         # 직선 보간
    BEZIER,         # 베지어 곡선
    SPLINE          # 스플라인 곡선
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

@export_group("Custom Points Path")
@export var custom_points: Array[Vector2] = []  # 경로 지점들
@export var point_durations: Array[float] = []  # 각 지점 도착 시간 (초)
@export var curve_type: CurveType = CurveType.LINEAR  # 보간 방식
@export var start_position_type: StartPosition = StartPosition.LEFT_TOP
@export var end_position_type: EndPosition = EndPosition.CENTER_TOP
@export var custom_start_position: Vector2 = Vector2.ZERO  # CUSTOM 선택 시 사용
@export var custom_end_position: Vector2 = Vector2.ZERO   # CUSTOM 선택 시 사용

var start_pos: Vector2
var elapsed_time: float = 0.0
var is_mirrored: bool = false  # 미러 플래그
var reached_end: bool = false  # 목표점 도착 여부
var path_phase: float = 0.0    # 경로 위상 (Circle/Sine용)
var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0
var stop_phase: float = 0.0  # 0: 이동, 1: 정지, 2: 퇴장
var current_segment: int = 0  # 현재 이동 중인 경로 세그먼트
var segment_start_time: float = 0.0  # 현재 세그먼트 시작 시간

func _ready():
	start_pos = global_position
	
	# 커스텀 포인트 경로 초기화
	if path_type == PathType.CUSTOM_POINTS:
		_init_custom_points()

# 커스텀 포인트 경로 초기화
func _init_custom_points():
	if custom_points.size() == 0:
		# 기본 경로 생성
		_generate_default_path()
	
	# point_durations 배열이 비어있으면 기본값 설정
	if point_durations.size() == 0:
		for i in range(custom_points.size()):
			point_durations.append(move_duration / custom_points.size())
	
	# 현재 세그먼트 초기화
	current_segment = 0
	segment_start_time = 0.0
	
	# 시작 위치 설정
	if custom_points.size() > 0:
		global_position = custom_points[0]

# 기본 커스텀 경로 생성
func _generate_default_path():
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 시작 위치 계산
	match start_position_type:
		StartPosition.LEFT_TOP:
			custom_start_position = Vector2(0, 0)
		StartPosition.LEFT_CENTER:
			custom_start_position = Vector2(0, viewport_size.y / 2)
		StartPosition.LEFT_BOTTOM:
			custom_start_position = Vector2(0, viewport_size.y)
		StartPosition.RIGHT_TOP:
			custom_start_position = Vector2(viewport_size.x, 0)
		StartPosition.RIGHT_CENTER:
			custom_start_position = Vector2(viewport_size.x, viewport_size.y / 2)
		StartPosition.RIGHT_BOTTOM:
			custom_start_position = Vector2(viewport_size.x, viewport_size.y)
	
	# 종료 위치 계산
	match end_position_type:
		EndPosition.CENTER_TOP:
			custom_end_position = Vector2(viewport_size.x / 2, 0)
		EndPosition.CENTER:
			custom_end_position = Vector2(viewport_size.x / 2, viewport_size.y / 2)
		EndPosition.CENTER_BOTTOM:
			custom_end_position = Vector2(viewport_size.x / 2, viewport_size.y)
	
	# 미러링 처리
	if is_mirrored:
		custom_start_position.x = viewport_size.x - custom_start_position.x
	
	# 경로 포인트 생성
	custom_points = [
		custom_start_position,
		custom_end_position,
		Vector2(custom_end_position.x, -100)  # 화면 밖으로 퇴장
	]
	
	# 각 세그먼트 시간 설정
	point_durations = [
		move_duration * 0.7,  # 시작점 → 종료점
		move_duration * 0.3   # 종료점 → 화면 밖
	]

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
		PathType.CUSTOM_POINTS:
			_process_custom_points(delta)

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

# CUSTOM_POINTS: 좌표 기반 경로 이동
func _process_custom_points(delta: float):
	if custom_points.size() == 0:
		return
	
	# 현재 세그먼트가 마지막 세그먼트를 넘어서면 퇴장
	if current_segment >= custom_points.size() - 1:
		global_position.y -= exit_speed * delta
		_check_screen_exit()
		return
	
	# 현재 세그먼트의 시작점과 종료점
	var start_point = custom_points[current_segment]
	var end_point = custom_points[current_segment + 1]
	
	# 현재 세그먼트 진행 시간 계산
	var segment_elapsed = elapsed_time - segment_start_time
	var segment_duration = point_durations[current_segment] if current_segment < point_durations.size() else move_duration / custom_points.size()
	
	# 세그먼트 진행률 (0~1)
	var segment_progress = min(segment_elapsed / segment_duration, 1.0)
	
	# 보간 방식에 따른 위치 계산
	match curve_type:
		CurveType.LINEAR:
			# 선형 보간
			global_position = start_point.lerp(end_point, segment_progress)
		
		CurveType.BEZIER:
			# 3점 베지어 곡선 (중간 제어점은 두 점의 중점에서 살짝 위로)
			if current_segment + 2 < custom_points.size():
				var control_point = (start_point + end_point) * 0.5 + Vector2(0, -50)
				global_position = _bezier_interpolate(start_point, control_point, end_point, segment_progress)
			else:
				global_position = start_point.lerp(end_point, segment_progress)
		
		CurveType.SPLINE:
			# 카트먼-롬 스플라인 (간단한 구현)
			if custom_points.size() >= 4 and current_segment + 3 < custom_points.size():
				var p0 = custom_points[max(current_segment - 1, 0)]
				var p1 = start_point
				var p2 = end_point
				var p3 = custom_points[min(current_segment + 2, custom_points.size() - 1)]
				global_position = _catmull_rom_interpolate(p0, p1, p2, p3, segment_progress)
			else:
				global_position = start_point.lerp(end_point, segment_progress)
	
	# 세그먼트 완료 체크
	if segment_progress >= 1.0:
		current_segment += 1
		segment_start_time = elapsed_time
	
	_check_screen_exit()

# 베지어 곡선 보간
func _bezier_interpolate(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	return q0.lerp(q1, t)

# 카트먼-롬 스플라인 보간
func _catmull_rom_interpolate(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var t2 = t * t
	var t3 = t2 * t
	
	return 0.5 * (
		(2 * p1) +
		(-p0 + p2) * t +
		(2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
		(-p0 + 3 * p1 - 3 * p2 + p3) * t3
	)
