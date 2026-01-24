extends Area2D

# 탄막 발사 패턴 (에디터에서 BulletPatternController 설정)
@export var bullet_scene: PackedScene

# 아이템 드랍 설정
@export_group("Item Summon")
@export var item_scene : PackedScene
@export var summon_power_item = 1
@export var summon_score_item = 3
@export var item_score = 100000

# 적 기본 속성
@export var damage : int = 1
@export var max_life = 1

signal enemy_died

var current_life: int

func _ready():
	current_life = max_life
	
	# 탄막 발사 패턴 시작 (bullet 노드가 있으면)
	if has_node("bullet"):
		var bullet_node = $bullet
		if bullet_node.has_method("load_pattern"):
			# 첫 번째 패턴으로 시작
			bullet_node.load_pattern(0)

func _on_body_entered(body: Node2D) -> void:
	## 플레이어에게 데미지 주기
	if body.has_method("_take_damage"):
		body._take_damage(damage)

func _on_area_entered(area: Area2D):
	# 플레이어 탄막에 맞았을 때
	if area.is_in_group("player_bullet"):
		_take_damage_from_bullet(area)

func _take_damage_from_bullet(bullet: Area2D):
	# bullet의 damage 속성 사용
	var bullet_damage = 1
	if bullet.has_method("get_damage"):
		bullet_damage = bullet.get_damage()
	elif bullet.has_property("damage"):
		bullet_damage = bullet.damage
	
	_take_damage(bullet_damage)

func _take_damage(damage_amount: int):
	current_life -= damage_amount
	
	# 피격 시 잠시 깜빡임 효과 (옵션)
	modulate = Color(1, 0.5, 0.5, 1)  # 붉은색
	get_tree().create_timer(0.1).timeout.connect(func(): 
		modulate = Color(1, 1, 1, 1)
	)
	
	if current_life <= 0:
		_object_died()

func _object_died():
	enemy_died.emit()
	
	# 폭발 이펙트 생성
	vfx_manager.spawn_explosion(global_position)
	
	# 아이템 생성
	spawn_items()
	
	# 즉시 제거
	queue_free()

func spawn_items():
	# item_scene 없으면 리턴
	if item_scene == null: 
		return
	
	# 1. 파워 아이템 summon_power_item개 생성
	for i in range(summon_power_item):
		var power_item = item_scene.instantiate()
		power_item.global_position = global_position
		power_item.init_item(0, 1)  # type 0 = 파워 아이템, value = 1
		get_tree().current_scene.call_deferred("add_child", power_item)
	
	# 2. 점수 아이템 summon_score_item개 생성
	for i in range(summon_score_item):
		var score_item = item_scene.instantiate()
		var randomizer = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		score_item.global_position = global_position + randomizer
		score_item.init_item(1, item_score)  # type 1 = 점수 아이템
		get_tree().current_scene.call_deferred("add_child", score_item)