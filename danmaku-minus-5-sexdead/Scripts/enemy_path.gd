extends Node2D


@export var move_duration: float = 3.0  # 도착 예상 시간 (초)
@export var exit_speed: float = 200.0  # 화면 밖으로 나갈 속도

var start_pos: Vector2
var elapsed_time: float = 0.0
var is_mirrored: bool = false  # 미러 플래그
var reached_end: bool = false  # 목표점 도착 여부

func _ready():
	start_pos = global_position

func _process(delta: float):
	elapsed_time += delta
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
	
	# 화면 밖으로 충분히 나가면 삭제
	if global_position.y < -100:
		queue_free()
		
