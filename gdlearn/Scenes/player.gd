extends CharacterBody2D
@export var speed:= 500.0
var can_shoot:= true

signal laser(pos)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(100, 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("shoot") and can_shoot :
		laser.emit($LaserStartPos.global_position)
		can_shoot = false
		# 고돗에서 자식 노드는 부모 노드의 위치에 상대적이라서 부모 노드 위치가 변해도 거기에 붙은 자식 노드 좌표는 안변함
		# 그래서 글로벌 위치로 지정해줘야 위치가 변함
		$LaserTimer.start()

# 스페이스바를 누른다 -> 발사 -> 0.5초 동안 쿭타임이 시작된다 -> 0.5초가 지난 후에 다시 총을 쏠 수 있다 [0.5초 쿨타임을 만든다]

func _on_laser_timer_timeout() -> void:
	can_shoot = true
