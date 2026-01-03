extends PathFollow2D

@export var speed: float = 200.0
@onready var curve = Curve2D.new()

func _ready():
    var viewport_size = get_viewport_rect().size
    
    # 점들을 절대 값이 아닌 화면 비율로 설정
    curve.add_point(Vector2(0.0, 0.0) * viewport_size)        # 시작점: 왼쪽 하단
    curve.add_point(Vector2(0.5, 0.5) * viewport_size)        # 중앙: 중앙 정점
    curve.add_point(Vector2(1.0, 0.0) * viewport_size)        # 끝점: 오른쪽 하단
    set_curve(curve)

func _process(delta: float):
    # 매 프레임마다 경로를 따라 progress(픽셀 단위)를 증가시킵니다.
    progress += speed * delta
    
    # 만약 경로 끝(ratio 1.0)에 도달하면 잡몹과 경로를 모두 삭제합니다.
    if progress_ratio >= 1.0:
        get_parent().queue_free() # Path2D를 포함해 삭제
        print("화면 밖 삭제")