extends PathFollow2D


@export var speed: float = 200.0

func _process(delta: float):
	# 매 프레임마다 경로를 따라 progress(픽셀 단위)를 증가시킵니다.
	progress += speed * delta
	
	# 만약 경로 끝(ratio 1.0)에 도달하면 잡몹과 경로를 모두 삭제합니다.
	if progress_ratio >= 1.0:
		get_parent().queue_free() # Path2D를 포함해 삭제
		
