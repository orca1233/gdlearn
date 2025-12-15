extends CanvasLayer

static var image = load("res://kenney_space-shooter-redux/PNG/UI/playerLife1_red.png")
var time_elapsed : int
# var time_elapsed := 0 위 아래는 똑같은 코드

func set_health(amount):
	# 모든 자식 노드를 삭제 <- 왜? :: 매 어택을 받을 때마다 texture rect를 삭제하고 다시 만들어줘야 하니까.
	for child in $MarginContainer2/HBoxContainer.get_children():
		child.queue_free()
	
	# textrect을 다시 만들어주는 걸 짜자
	for i in amount:
		var text_rect = TextureRect.new()
	#	text_rect = load("res://kenney_space-shooter-redux/PNG/UI/playerLife1_red.png")
	#	↑ 매 루프마다 이미지 다시 생성해서 비효율
		text_rect.texture = image
		text_rect.stretch_mode = TextureRect.STRETCH_KEEP
		$MarginContainer2/HBoxContainer.add_child(text_rect)
		


func _on_score_timer_timeout() -> void:
	time_elapsed += 1
	Global.score = time_elapsed
	$MarginContainer/Label.text = str(time_elapsed)
