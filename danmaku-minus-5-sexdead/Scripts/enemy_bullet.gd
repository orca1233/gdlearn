# enemy_bullet.gd
extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0

func setup(data: BulletPatternData, dir: Vector2, custom_speed: float):
	# 데이터에서 텍스처와 충돌 영역 설정
	if has_node("Sprite2D"): $Sprite2D.texture = data.texture
	if has_node("CollisionShape2D"): $CollisionShape2D.shape = data.collision_shape
	
	# 이동 관련 설정
	self.direction = dir
	self.speed = custom_speed
	self.rotation = dir.angle() + deg_to_rad(data.sprite_rotation)
	

func _process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		## TODO take_damage 메소드 -> 라이프 -1, 라이프 = 0이면 queue_free해주고 사망 연출 instantiate
		## _take_damage로는 int 전달함. 데미지 바꾸고 싶으면 player_bullet에서
		body._take_damage(damage)
		queue_free()
