# enemy_bullet.gd
extends Area2D

@export var damage : int = 1
var direction: Vector2 = Vector2.ZERO
var speed: float = 0.0
var original_speed: float = 0.0

# graze 관련
var is_grazed: bool = false       # 현재 graze 중인지
var has_scored_graze: bool = false  # 이미 graze 점수 획득했는지
const GRAZE_SPEED_MULTIPLIER = 0.85 # 탄속 얼마나 느리게 만드는지
const GRAZE_SCORE_PER_TICK = 1000  # 틱당 점수 (조정 가능)
const GRAZE_SCORE_INTERVAL = 0.1  # 0.1초마다 점수 획득

var graze_timer: float = 0.0  # 총알이 들어와있던 시간에 따라서 graze 점수를 줌

func setup(data: BulletPatternData, dir: Vector2, custom_speed: float):
	# 데이터에서 텍스처와 충돌 영역 설정
	if has_node("Sprite2D"): $Sprite2D.texture = data.texture
	if has_node("CollisionShape2D"): $CollisionShape2D.shape = data.collision_shape
	
	# 이동 관련 설정
	self.direction = dir
	self.speed = custom_speed
	self.rotation = dir.angle() + deg_to_rad(data.sprite_rotation)
	
	original_speed = custom_speed

func _process(delta):
	position += direction * speed * delta

# graze 로직 : 
	# shift를 누른 상태에서 area(총알)이 플레이어 그레이즈 에리어로 들어간 상태에서 (is_grazed = true)
	# graze timer가 0.1초보다 커지면 graze timer를 초기화하고 점수를 줌
	if is_grazed:
		graze_timer += delta
		# 0.1초마다 점수 지급
		if graze_timer >= GRAZE_SCORE_INTERVAL:
			_give_graze_score()
			graze_timer = 0.0  # 타이머 리셋
	
func _on_body_entered(body: Node2D) -> void:
	## 적이 CharacterBody2D면 이거 쓰고
	if body.has_method("_take_damage"):
		## TODO take_damage 메소드 -> 라이프 -1, 라이프 = 0이면 queue_free해주고 사망 연출 instantiate
		## _take_damage로는 int 전달함. 데미지 바꾸고 싶으면 player_bullet에서
		body._take_damage(damage)
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _add_graze():
	if not is_grazed: # graze 상태가 아니면
		is_grazed = true # ture로 만들어주고 
		speed = original_speed * GRAZE_SPEED_MULTIPLIER # speed에 0.85 곱해서 느리게 만들기
		graze_timer = 0.0  # 타이머 초기화
		modulate = Color(0.45, 0, 0) # 색깔 빨갛게 변경
		
# 반대 로직인 remove도 만듬
func _remove_graze() -> void:
	if is_grazed:
		is_grazed = false # graze 꺼주기
		speed = original_speed # 속도 초기화
		graze_timer = 0.0 # graze 타이머 초기화
		modulate = Color(1.0, 1.0, 1.0)

func _give_graze_score():
	var player = get_tree().get_first_node_in_group("player") # player를 가져옴
	if player and player.has_signal("graze_scored"): # 플레이어가 있고(오류방지용), 플레이어에게 해당 시그널 있으면
		player.graze_scored.emit(GRAZE_SCORE_PER_TICK) # 점수 발송(int)
	
	
