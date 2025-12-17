extends Node2D

var speed = 300
var direction = Vector2.RIGHT
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
