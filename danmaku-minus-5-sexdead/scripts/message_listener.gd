extends Node

# 디스코드 메시지를 수신하고 처리하는 기능

func _ready():
    # 초기화 코드
    pass

func on_message_received(message: String):
    # 메시지 처리 로직
    print('Received message: ' + message)
