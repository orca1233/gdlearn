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
	var data = patterns[current_index]
	timer.wait_time = data.fire_rate
	timer.start()

func next_pattern():
	current_index += 1
	if current_index < patterns.size():
		load_pattern(current_index)
	else:
		timer.stop()

func _on_timer_timeout():
	var data = patterns[current_index]
	# theta는 매 발사 시 rotate_speed만큼 누적되어 회전함
	theta += data.rotate_speed
	shoot(theta, data)

func shoot(angle: float, data: BulletPatternData):
	var bullet = bullet_node.instantiate()

	# 1. 먼저 씬에 추가 (이렇게 해야 Bullet의 _ready가 실행될 준비를 함)
	get_tree().current_scene.add_child(bullet)

	# 2. 그 다음 위치와 데이터를 설정
	bullet.global_position = self.global_position
	var dir = Vector2.RIGHT.rotated(angle + data.alpha)

	if bullet.has_method("setup"):
		bullet.setup(data, dir)
