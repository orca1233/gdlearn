# boss_1.gd
extends Node2D

@onready var pattern_node = $BulletPattern # 자식 노드로 붙인 패턴 컨트롤러
@export var damage : int = 1
@export var max_life = 100
@onready var current_life = max_life

signal enemy_died

func _process(_delta):
	# 예: 피가 50 이하로 떨어지면 2번째 패턴(index 1)으로 변경
	if current_life <= 50 and pattern_node.current_index == 0:
		pattern_node.next_pattern()
		
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
	queue_free()

func _on_enemy_died() -> void:
	pass # Replace with function body.
