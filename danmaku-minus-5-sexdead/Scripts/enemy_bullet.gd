extends Node2D
# area2D로 하는게 더 좋을듯 node2D는 충돌 계산해서 성능 안좋다고함
# 둘이 만났을때 바로 트리거되는건 area2D가 더 유리하다고함
var speed = 300
var direction = Vector2.RIGHT
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
