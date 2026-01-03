extends Area2D

enum State { ENTERING, CHASING }
var state: State = State.ENTERING
@export var speed: float = 100.0
@onready var tween = $Tween

func _ready() -> void:
    # 시작 위치를 화면 좌측 상단 밖으로 설정
    position = Vector2(-100, -100)
    # 도착점으로 이동하는 Tween 설정
    var target_position = get_viewport().size * 0.2
    tween.tween_property(self, "position", target_position, 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
    # Tween이 끝나면 상태를 CHASING으로 변경
    tween.connect("tween_completed", self, "_on_tween_completed")

func _on_tween_completed(object: Object, key: String) -> void:
    if object == tween:
        state = State.CHASING

func _physics_process(delta: float) -> void:
    if state == State.CHASING:
        var player = get_tree().get_first_node_in_group("player")
        if player:
            # 플레이어를 바라보고 천천히 이동
            look_at(player.global_position)
            position = position.move_toward(player.global_position, speed * delta)