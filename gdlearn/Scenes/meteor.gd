extends Area2D
var rng := RandomNumberGenerator.new()
# 속도 랜덤
var speed : int
var rotationspeed : int
var direction_x : float

signal collision

func _ready() -> void:
	var width = get_viewport().get_visible_rect().size[0]
	var random_x = rng.randi_range(0, width) # 1280
	var random_y = rng.randi_range(-150, -50) # 720
	position = Vector2(random_x, random_y)
	
	# 속도 / 로테이션 / 방향 설정
	speed = rng.randi_range(100, 500)
	direction_x = rng.randf_range(-1, 1)
	rotationspeed = rng.randi_range(40, 100)
	
	var path: String = "res://kenney_space-shooter-redux/PNG/Meteors/" + str(rng.randi_range(1,6)) + ".png"
	$MeteorImage.texture = load(path)

func _process(delta: float) -> void:
	position += Vector2(direction_x, 1.0) * speed * delta
	rotation_degrees += rotationspeed * delta

func _on_body_entered(body: Node2D) -> void:
	collision.emit()
