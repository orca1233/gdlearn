# boss_1.gd
extends Node2D

@export var hp: float = 100.0
@onready var pattern_node = $BulletPattern # 자식 노드로 붙인 패턴 컨트롤러

func _process(_delta):
	# 예: 피가 50 이하로 떨어지면 2번째 패턴(index 1)으로 변경
	if hp <= 50 and pattern_node.current_index == 0:
		pattern_node.next_pattern()
	
	if hp <= 0:
		queue_free()
