extends Area2D

@export var bullet_scene: PackedScene # 에디터에서 Bullet.tscn을 드래그 앤 드롭
@export var item_scene : PackedScene # 에디터에서 item씬

@export var damage : int = 1
var can_shoot = false
var shoot_timer = 0.0
@export var shoot_interval = 0.04 # 발사 간격
@export var max_life = 1
@onready var current_life = max_life

@export_group("Item Summon")
@export var summon_power_item = 1
@export var summon_score_item = 3
@export var item_score = 100000

signal enemy_died

func _process(delta):
	# PathFollow2D가 부모라고 가정 (path를 따라가는 적)
	if get_parent() is PathFollow2D:
		var progress = get_parent().progress_ratio
		
		# 중간(30%)부터 60%까지 공격
		if progress >= 0.3 and progress <= 0.6:
			shoot_timer += delta
			if shoot_timer >= shoot_interval:
				shoot_at_player()
				shoot_timer = 0.0
	else:
		# 부모가 PathFollow2D가 아니면 그냥 공격 (이게 없어서 shoot을 안하는 경우가 있었음)
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_at_player()
			shoot_timer = 0.0

func shoot_at_player():
	if bullet_scene == null:
		return
		
	# 1. 총알 복사 (메모리에 생성)
	var b = bullet_scene.instantiate()
	
	# 2. 화면에 추가 (이게 global_position 설정보다 먼저 와야 합니다!)
	# get_tree().current_scene.add_child(b)
	# BulletContainer에 추가
	get_tree().current_scene.bullet_container.add_child(b)
	
	# 3. 위치 설정 (이제 화면에 존재하므로 위치를 잡을 수 있습니다)
	b.global_position = global_position
	
	# 4. 방향 설정
	var player = get_tree().get_first_node_in_group("player")
	if player:
		b.direction = (player.global_position - global_position).normalized()

func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		body._take_damage(damage)

# 보스한테도 적용 가능하게
func _take_damage(damage):
	current_life -= damage
	if current_life <= 0:
		_object_died()
		
func _object_died():
	enemy_died.emit()
	vfx_manager.spawn_explosion(global_position)
	# 죽을 때 아이템 소환
	spawn_items()
	queue_free()

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
