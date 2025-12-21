extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0

func setup(data: BulletPatternData, dir: Vector2):
	if not is_inside_tree():
		await ready
		
	# 1. 수치 데이터는 즉시 저장
	self.speed = data.speed
	self.direction = dir
	self.rotation = dir.angle()
	
	if has_node("Sprite2D"):
		$Sprite2D.texture = data.texture
		#print("텍스처 적용 완료: ", data.texture.resource_path)
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.shape = data.collision_shape
		
func _process(delta):
	position += direction * speed * delta
	
# 화면 밖으로 나가면 삭제
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
