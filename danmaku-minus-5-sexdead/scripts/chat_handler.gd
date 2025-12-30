extends Node

# 디스코드 메시지 핸들러

func _ready():
    pass

func on_message_received(message):
    if message.startswith('!코드 '):
        var code = message.substr(6)
        send_code_response(code)

func send_code_response(code):
    # 코드 응답 처리 로직
    print('코드:', code)