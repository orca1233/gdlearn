extends Area2D
@export var speed = 200

func _process(delta: float) -> void:
	position.y -= speed * delta
