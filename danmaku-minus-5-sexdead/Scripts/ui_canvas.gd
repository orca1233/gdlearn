extends CanvasLayer

# 더 좋은 이미지 있으면 변경
@onready var score_timer = $score_timer
var lifeimage = load("res://Assets/Portrait/icon.svg")
# 폭탄 아이콘은 일단 같은거 쓰거나, 색만 다르게 해서 쓰세요. 나중에 변경 가능.
var bombimage = load("res://Assets/Portrait/icon.svg") 

var time_elapsed : int
var kill_score : int
var total_score : int
var item_score : int

func _ready() -> void:

	# Life 컨테이너 설정 (우측 상단 고정)
	if has_node("Life"):
		var life = $Life
		# 1. 앵커를 우측 상단'으로 강제 설정
		life.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		# 2. 성장 방향 왼쪽으로
		life.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		# 3. 정렬: 오른쪽 끝
		life.alignment = BoxContainer.ALIGNMENT_END
		
	# Bomb 컨테이너 설정 (우측 하단 고정)
	if has_node("Bomb"):
		var bomb = $Bomb
		# 1. 앵커를 '우측 하단'으로
		bomb.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		# 2. 성장 방향
		bomb.grow_horizontal = Control.GROW_DIRECTION_BEGIN
		# 3. 정렬
		bomb.alignment = BoxContainer.ALIGNMENT_END

func _on_player_life_changed(new_life: int) -> void:
	# 1. 기존에 그려진 하트들을 모두 삭제
	if has_node("Life"):
		for child in $Life.get_children():
			child.queue_free()
		
		# 2. 현재 체력만큼 하트를 새로 그림
		for i in range(new_life):
			var text_rect = TextureRect.new()
			text_rect.texture = lifeimage
			text_rect.stretch_mode = TextureRect.STRETCH_KEEP
			# 크기 조절 필요하면 여기서
			text_rect.custom_minimum_size = Vector2(32, 32) 
			text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			$Life.add_child(text_rect)

# 폭탄 UI 업데이트 (Life와 같은 방식)
func _on_player_bomb_changed(new_bomb: int) -> void:
	# Bomb 컨테이너가 씬에 있어야 합니다! (HBoxContainer 추천)
	if has_node("Bomb"): 
		for child in $Bomb.get_children():
			child.queue_free()
			
		for i in range(new_bomb):
			var text_rect = TextureRect.new()
			text_rect.texture = bombimage # 폭탄 이미지
			text_rect.stretch_mode = TextureRect.STRETCH_KEEP
			text_rect.modulate = Color(0, 1, 0) # 구분 위해 초록색 틴트 적용 (이미지 있으면 빼세요)
			text_rect.custom_minimum_size = Vector2(32, 32)
			text_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			$Bomb.add_child(text_rect)

# 죽으면 게임오버씬 띄우기
func _on_player_died() -> void:
	# 스코어 타이머 멈춤
	score_timer.stop()
	# 게임 오버 패널에 띄울 스코어 계산
	$Gameoverpanel/CenterContainer/VBoxContainer/Label2.text = $Gameoverpanel/CenterContainer/VBoxContainer/Label2.text + $Score.text
	$Gameoverpanel.visible = true
	
# 게임 오버 상태일 때만 다시 불러오는 용도의 attack으로 기능하게끔
func _input(event):
	if $Gameoverpanel.visible:
		if Input.is_action_just_pressed("attack"):
		#gamescene 다시 불러오기
			$Gameoverpanel.visible = false
			get_tree().reload_current_scene()

# 스코어 판 갱신해주는 함수
func _update_score_display() -> void:
	# 시간 점수 + 처치 점수
	total_score = (time_elapsed * 1000) + kill_score + item_score
	$Score.text = "Score : " + str(total_score)

# 1초마다 실행되는 타이머
func _on_score_timer_timeout() -> void:
	time_elapsed += 1
	_update_score_display() # 시간 늘었으니 점수 갱신

# 적이 죽었을 때 실행되는 함수
func _on_object_died() -> void:
	kill_score += 100000 # 적 점수 저장소에 추가
	_update_score_display() # 적 죽었으니 점수 갱신
	
# 아이템 먹었을 때 실행되는 함수
func _on_take_item(type, value) -> void:
	# type = 1 = score 면 value 만큼 더해줌
	if type == 1:
		item_score += value # 아이템 점수 저장소에 추가
		_update_score_display() # 아이템 먹었으니 점수 갱신
