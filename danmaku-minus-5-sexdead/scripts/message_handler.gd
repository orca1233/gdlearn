extends Node

func _ready():
    print("디스코드 메시지 요청을 처리합니다.")

func handle_message(message):
    if message.begins_with("!코드 "):
        var code_request = message.substr(6)
        print("사용자 요청된 코드: " + code_request)
        # 코드 처리 로직 추가