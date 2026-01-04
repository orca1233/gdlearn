extends PathFollow2D

@export var speed: float = 200.0

func _ready():
	# 1. 커브(길) 객체를 새로 만듭니다.
	var curve = Curve2D.new()
	
	# 2. 화면 크기 가져오기
	var viewport_size = get_viewport_rect().size
	
	# 3. 경로 점 찍기 (그림의 경로 구현)
	# 화면 비율을 사용합니다 (0.0 ~ 1.0)
	
	# 시작점: 왼쪽 하단 (화면 약간 안쪽으로 설정)
	# Vector2(0.1, 1.0)은 x=화면너비의 10%, y=화면높이의 100%(맨 아래) 지점입니다.
	curve.add_point(Vector2(0.1, 1.0) * viewport_size)

	# 중간 제어점: 곡선을 만들기 위한 점 (화면 중앙 왼쪽 부근)
	# 이 점을 지나가면서 완만한 곡선이 만들어집니다.
	curve.add_point(Vector2(0.2, 0.3) * viewport_size)
	
	# 끝점: 상단 중앙 약간 오른쪽 (화면 약간 안쪽으로 설정)
	# Vector2(0.6, 0.1)은 x=화면너비의 60%, y=화면높이 밖 10%(맨 위 근처) 지점입니다.
	curve.add_point(Vector2(0.5, -0.1) * viewport_size)
	
	# 4. 나(PathFollow2D) 말고, 부모(Path2D)에게 커브를 줍니다.
	if get_parent() is Path2D:
		get_parent().curve = curve

func _process(delta: float):
	# 매 프레임마다 경로를 따라 이동
	progress += speed * delta
	
	# 끝까지 가면 삭제
	if progress_ratio >= 1.0:
		get_parent().queue_free()
