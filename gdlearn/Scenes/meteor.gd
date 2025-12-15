extends Area2D
var rng := RandomNumberGenerator.new()
# 속도 랜덤
var speed : int
var rotationspeed : int
var direction_x : float
var circleradius : float

signal collision

func _ready() -> void:
	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width) # 1280
	var random_y = rng.randi_range(-150, -50) # 720
	var random_imgnum := rng.randi_range(1,6)
	position = Vector2(random_x, random_y)

	# 속도 / 로테이션 / 방향 설정
	speed = rng.randi_range(100, 500)
	direction_x = rng.randf_range(-1, 1)
	rotationspeed = rng.randi_range(40, 100)
	
	var path: String = "res://kenney_space-shooter-redux/PNG/Meteors/" + str(random_imgnum) + ".png"
	$MeteorImage.texture = load(path)
	var circleradius : int
	circleradius = 9.5 * random_imgnum
	# [중요] 모양(Shape)을 복제해서 이 메테오만의 고유한 것으로 만듭니다. 
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate()
	$CollisionShape2D.shape.radius = circleradius
	

func _process(delta: float) -> void:
	position += Vector2(direction_x, 1.0) * speed * delta
	rotation_degrees += rotationspeed * delta

# 유저용
func _on_body_entered(_body: Node2D) -> void:
	# body = user
	collision.emit()
	
func _on_area_entered(area: Area2D) -> void:
	#운석하고 충돌할 수 있는 area는 레이저밖에 없다
	# 레이저 큐프리 해주고, 메테오도 비프리 해주고
	area.queue_free()
	queue_free()
