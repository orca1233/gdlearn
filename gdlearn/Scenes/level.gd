extends Node2D

# 1 load the scene
var meteor_scene : PackedScene = load("res://Scenes/meteor.tscn")
var laser_scene : PackedScene = load("res://Scenes/laser.tscn")

# HEALTH
var health : int = 3

func _ready() -> void:
	get_tree().call_group('ui', 'set_health', health)
	var size := get_viewport().get_visible_rect().size
	var rng := RandomNumberGenerator.new()
	for star in $Stars.get_children():
		#포지션바꾸기
		var random_x = rng.randi_range(0, int(size.x))
		var random_y = rng.randi_range(0, int(size.y))
		star.position = Vector2(random_x, random_y)
		# 스케일 바꾸기
		var random_scale = rng.randf_range(1, 2)
		star.scale = Vector2(random_scale,random_scale)
		
		# 스피드스케일
		star.speed_scale = rng.randf_range(1, 3)

func _on_meteor_timer_timeout() -> void:
	var meteor = meteor_scene.instantiate()
	$Meteors.add_child(meteor)
	
	# 시그널 연결
	meteor.connect("collision", _on_meteor_collision)

func _on_meteor_collision():
	health -= 1
	get_tree().call_group('ui', 'set_health', health)
	if health <= 0:
		# 게임 오버 방식이 두 개 이상이면 인스턴스화? gemini한테 물어보기
		# 왜 packed가 있는지?
		get_tree().change_scene_to_file("res://Scenes/gameover.tscn")

# 1. 씬 프리로드 
# 2. 인스턴스화
# 3. 추가할 씬 밑에 차일드로 추가

func _on_player_laser(pos) -> void:
	var laser = laser_scene.instantiate()
	$Lasers.add_child(laser)
	laser.position = pos
