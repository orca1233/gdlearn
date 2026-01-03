extends Area2D

@export var bullet_scene: PackedScene # 에디터에서 Bullet.tscn을 드래그 앤 드롭
@export var damage : int = 1
var can_shoot = false
var shoot_timer = 0.0
@export var shoot_interval = 0.04 # 발사 간격
@export var max_life = 1
@onready var current_life = max_life

signal enemy_died

func _process(delta):
	var progress = get_parent().progress_ratio

	# 1. 중간(40%)부터 거의 끝(90%)까지 공격
	if progress >= 0.3 and progress <= 0.6:
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_at_player()
			shoot_timer = 0.0
			# 추가 공격 패턴 (예: 1회의 공격 후, 넓게 총알 발사)
		if shoot_timer >= shoot_interval * 2:
			spread_shoot()
			shoot_timer = 0.0

func shoot_at_player():
	if bullet_scene == null:
		return
	
	# 1. 총알 복사 (메모리에 생성)
	var b = bullet_scene.instantiate()
	
	# 2. 화면에 추가 (이게 global_position 설정보다 먼저 와야 합니다!)
	get_tree().current_scene.add_child(b)
	
	# 3. 위치 설정 (이제 화면에 존재하므로 위치를 잡을 수 있습니다)
	b.global_position = global_position
	
	# 4. 방향 설정
	var player = get_tree().get_first_node_in_group("player")
	if player:
		b.direction = (player.global_position - global_position).normalized()

func spread_shoot():
	if bullet_scene == null:
		return
	
	# 여러 개의 총알 발사
	var spread_count = 5
	var angle_step = 15 # 각도 간격
	var start_angle = -((spread_count - 1) / 2) * angle_step
	
	for i in range(spread_count):
		var b = bullet_scene.instantiate()
		get_tree().current_scene.add_child(b)
		b.global_position = global_position
		var angle = start_angle + i * angle_step
		b.direction = get_vector(angle) # 방향 설정

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("_take_damage"):
		body._take_damage(damage)

func _take_damage(damage):
	current_life -= damage
	if current_life <= 0:
		_object_died()
		queue_free()

func _object_died():
	enemy_died.emit()