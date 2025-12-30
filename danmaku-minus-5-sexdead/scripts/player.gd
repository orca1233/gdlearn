extends Node

# 속성을 정의합니다.
var health: int = 100
var speed: float = 200.0

# 노드가 준비되면 호출됩니다.
func _ready():
    pass

# 사용자 입력을 처리하는 함수입니다.
func _process(delta: float) -> void:
    if Input.is_action_pressed('ui_right'):
        position.x += speed * delta
    if Input.is_action_pressed('ui_left'):
        position.x -= speed * delta

# 수정본 추가해줘 (디스코드 메시지)