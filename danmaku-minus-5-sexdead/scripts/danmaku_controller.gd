extends Node

# 사용자의 요청을 처리하는 함수
func _on_message_received(message):
    if message.begins_with("!"):
        var command = message.substr(1)
        handle_command(command)

func handle_command(command: String):
    match command:
        "코드":
            # 코드 요청 처리 로직 추가
            pass
        _:
            print("알 수 없는 명령어!")