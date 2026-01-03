extends Node2D

@export var hold_time: float = 1.75  # 대기 시간
@onready var tween = $Tween  # Tween 노드
@onready var viewport_size = get_viewport().size

func _ready() -> void:
    var start_position = Vector2(-50, -50)  # 화면 좌측 상단 밖
    var target_position = viewport_size * 0.15  # 도착 위치

    # Curve2D 설정
    var curve = Curve2D.new()
    curve.add_point(start_position)
    curve.add_point(target_position)

    # Tween 설정
    tween.tween_property(self, "position", target_position, 1.0, Tween.TRANS_QUINT, Tween.EASE_OUT)

    # 대기 후 복귀
    tween.connect("tween_completed", self, "_on_tween_completed")

    # 즉시 위치를 시작점으로 설정
    position = start_position

func _on_tween_completed(tween_name):
    if tween_name == "position":  # Tween 완료 시
        yield(get_tree().create_timer(hold_time), "timeout")  # 대기
        tween.tween_property(self, "position", Vector2(-50, -50), 1.0, Tween.TRANS_QUINT, Tween.EASE_IN)  # 복귀
    