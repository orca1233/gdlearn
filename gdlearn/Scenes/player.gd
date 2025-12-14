extends CharacterBody2D
@export var speed:= 500.0
@export var laser_scene : PackedScene
@onready var shoot_timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(100, 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()

# 타이머의 Timeout 시그널을 이 함수에 연결하세요.
func _on_timer_timeout() -> void:
	spawn_laser()

func spawn_laser():
	if laser_scene == null:
		return
	var laser = laser_scene.instantiate()
	laser.global_position = global_position
	get_tree().current_scene.add_child(laser)
