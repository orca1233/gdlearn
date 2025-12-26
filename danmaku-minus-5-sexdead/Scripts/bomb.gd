extends Area2D

# 폭탄 데미지 설정
@export var damage: int = 250
# 폭탄 지속 시간 (커지는 데 걸리는 시간)
@export var duration: float = 1.5
# 폭탄이 커질 최대 크기 배율
@export var max_scale: float = 15.0 

func _ready() -> void:
	# 1. 시작은 아주 작게 (거의 안 보이는 수준에서 시작)
	scale = Vector2(0.1, 0.1)
	
	# 2. Tween 생성
	var tween = create_tween()
	
	# 3. 그래프 모양 설정: 
	# TRANS_EXPO: 변화가 아주 급격함 (화악! 하는 느낌)
	# EASE_IN_OUT: 시작과 끝은 느리게, 중간은 빠르게
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 4. duration 동안 scale을 max_scale까지 키움
	tween.tween_property(self, "scale", Vector2(max_scale, max_scale), duration)
	
	# 5. 애니메이션 끝나면 삭제
	await tween.finished
	queue_free()

# 영역(Area)이 들어왔을 때 -> 적 총알 제거
func _on_area_entered(area: Area2D) -> void:
	# 적 총알 그룹인지 확인 (사용자가 그룹 설정을 해야 함)
	if area.is_in_group("enemy_bullet"):
		area.queue_free()
	elif area.is_in_group("enemy"):
		area._object_died()

# body(보스)가 들어왔을 때 -> 보스 데미지
func _on_body_entered(body: Node2D) -> void:
	# 적 그룹인 경우
	if body.is_in_group("boss"):
		# _take_damage 함수가 있으면 호출 (일반 적은 보통 즉사급 데미지)
		if body.has_method("_take_damage"):
			body._take_damage(damage)
