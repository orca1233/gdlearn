extends Node2D
class_name EnemyBulletPatternController

@export var bullet_node: PackedScene
@export var patterns: Array[BulletPatternData]

var current_index: int = 0
var current_data: BulletPatternData
var theta: float = 0.0

@onready var fire_timer = Timer.new()   # 총알 발사기
@onready var burst_timer = Timer.new()  # 주기 관리자

func _ready():
	add_child(fire_timer)
	add_child(burst_timer)
	fire_timer.timeout.connect(_on_fire_timeout)
	burst_timer.timeout.connect(_on_burst_timeout)
	
	if patterns.size() > 0:
		load_pattern(0)

func load_pattern(index: int):
	if index >= patterns.size(): return
	
	current_index = index
	current_data = patterns[index] # 여기서 데이터를 한 번만 할당!
	theta = 0.0
	
	# 1. 발사 타이머 설정
	fire_timer.wait_time = current_data.fire_rate
	fire_timer.start()
	
	# 2. 주기(Burst) 모드 설정
	if current_data.use_burst:
		burst_timer.wait_time = current_data.burst_time
		burst_timer.one_shot = true
		burst_timer.start()
	else:
		burst_timer.stop()

func _on_burst_timeout():
	if fire_timer.is_stopped():
		fire_timer.start()
		burst_timer.start(current_data.burst_time)
	else:
		fire_timer.stop()
		burst_timer.start(current_data.rest_time)

func _on_fire_timeout():
	var base_angle = 0.0
	
	# 플레이어 조준 각도 계산
	if current_data.is_aimed:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var spawn_pos = global_position + current_data.spawn_offset.rotated(global_rotation)
			base_angle = (players[0].global_position - spawn_pos).angle()

	match current_data.pattern_type:
		current_data.ShootType.SPIRAL:
			theta += current_data.rotate_speed
			shoot(base_angle + theta)
			
		current_data.ShootType.SPREAD:
			# 부채꼴 산탄 (중심 각도를 기준으로 퍼짐)
			var start_angle = base_angle - deg_to_rad(current_data.spread_angle) / 2
			var step = 0.0
			if current_data.bullet_count > 1:
				step = deg_to_rad(current_data.spread_angle) / (current_data.bullet_count - 1)
			
			for i in range(current_data.bullet_count):
				shoot(start_angle + (step * i))
				
		current_data.ShootType.CIRCLE_BURST:
			# 원형 파동 (360도 전체 발사)
			var step = (PI * 2) / current_data.bullet_count
			for i in range(current_data.bullet_count):
				shoot(base_angle + (step * i))

func shoot(angle: float):
	var bullet = null
	
	# BulletPool 사용 여부 확인
	if BulletPool.instance != null:
		# Pool에서 bullet 가져오기
		bullet = BulletPool.get_bullet_from_pool()
		
		# Pool에 bullet_scene이 설정되어 있지 않으면 초기화
		if BulletPool.instance.bullet_scene == null:
			BulletPool.instance.bullet_scene = bullet_node
	else:
		# Pool이 없으면 기존 방식으로 생성
		bullet = bullet_node.instantiate()
	
	if bullet == null:
		# Emergency fallback
		bullet = bullet_node.instantiate()
		print("Bullet creation failed, using fallback instantiate")
	
	# BulletContainer에 추가
	get_tree().current_scene.bullet_container.add_child(bullet)
	
	# 오프셋 및 방향 보정 적용
	var final_pos = global_position + current_data.spawn_offset.rotated(global_rotation)
	var final_speed = current_data.speed + randf_range(-current_data.speed_variance, current_data.speed_variance)
	var final_dir = Vector2.RIGHT.rotated(angle + deg_to_rad(current_data.alpha))
	
	if bullet.has_method("setup"):
		bullet.setup(current_data, final_dir, final_speed)
	bullet.global_position = final_pos
