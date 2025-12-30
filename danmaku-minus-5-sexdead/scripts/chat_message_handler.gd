extends Node

func _ready():
    print("Chat message handler ready")

func handle_message(message: String):
    if message.starts_with("!"):
        var cmd = message.substr(1, message.length())
        print("Command received: " + cmd)
        # 추가 명령어 처리 로직을 여기에 삽입