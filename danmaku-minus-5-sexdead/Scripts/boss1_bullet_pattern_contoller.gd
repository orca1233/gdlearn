# boss1_bullet_pattern_contoller.gd
extends Node2D
class_name PatternController

@export var bullet_node: PackedScene
@export var patterns: Array[BulletPatternData]

var current_index: int = 0
var theta: float = 0.0
@onready var timer = Timer.new()

func _ready():
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	if patterns.size() > 0:
		load_pattern(0)

func load_pattern(index: int):
	if index >= patterns.size(): return
	current_index = index
	timer.wait_time = patterns[current_index].fire_rate
	timer.start()

func _on_timer_timeout():
	var data = patterns[current_index]
	
	# 1. 기준 각도 결정
	var base_angle = theta # 기본은 누적된 회전각
	if data.is_aimed:
		# 플레이어 방향을 기준 각도로 사용
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var spawn_pos = global_position + data.spawn_offset.rotated(rotation)
			base_angle = (players[0].global_position - spawn_pos).angle()
	
	# 2. 패턴 타입별 발사 로직
	match data.pattern_type:
		data.ShootType.SPIRAL:
			theta += data.rotate_speed
			shoot(base_angle + theta, data)
			
		data.ShootType.SPREAD:
			# 기준 각도(base_angle)를 중심으로 부채꼴 발사
			var start_angle = base_angle - deg_to_rad(data.spread_angle) / 2
			var angle_step = 0.0
			if data.bullet_count > 1:
				angle_step = deg_to_rad(data.spread_angle) / (data.bullet_count - 1)
				
			for i in range(data.bullet_count):
				var angle = start_angle + (angle_step * i)
				shoot(angle, data)
				
		data.ShootType.CIRCLE_BURST:
			for i in range(data.bullet_count):
				var angle = (PI * 2 / data.bullet_count) * i
				shoot(base_angle + angle, data)

func shoot(angle: float, data: BulletPatternData):
	var bullet = bullet_node.instantiate()
	get_tree().current_scene.add_child(bullet)

	# 생성 위치에 Resource에서 정한 offset 적용
	bullet.global_position = self.global_position + data.spawn_offset.rotated(self.rotation)
	
	# 산탄용: 총알마다 속도를 다르게 설정
	var final_speed = data.speed + randf_range(-data.speed_variance, data.speed_variance)
	
	var dir = Vector2.RIGHT.rotated(angle + data.alpha)
	
	if bullet.has_method("setup"):
		bullet.setup(data, dir)
		bullet.speed = final_speed # setup 이후에 개별 속도 덮어쓰기
