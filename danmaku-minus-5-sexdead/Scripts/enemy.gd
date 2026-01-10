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
