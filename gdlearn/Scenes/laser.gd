extends Area2D
@export var speed:= 10
# 유형 이름과 일치

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2.UP * speed * delta
	
	if global_position.y < -50:
		queue_free()
