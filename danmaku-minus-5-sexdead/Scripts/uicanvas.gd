extends CanvasLayer

# 더 좋은 이미지 있으면 변경
@onready var score_timer = $score_timer
var lifeimage = load("res://Assets/Portrait/icon.svg")
var time_elapsed : int
var score : int

func _on_player_life_changed(new_life: int) -> void:
	# 1. 기존에 그려진 하트들을 모두 삭제
	for child in $Life.get_children():
		child.queue_free()
	
	# 2. 현재 체력만큼 하트를 새로 그림
	for i in range(new_life):
		var text_rect = TextureRect.new()
		text_rect.texture = lifeimage
		# 이미지 비율 유지 설정
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		$Life.add_child(text_rect)

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

# 점수 타이머
func _on_score_timer_timeout() -> void:
	time_elapsed += 1
	score = time_elapsed * 1000 
	$Score.text = "Score : " + str(score)
