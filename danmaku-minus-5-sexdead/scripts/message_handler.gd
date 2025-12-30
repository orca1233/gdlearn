extends Node

func _on_message_received(message):
    if message.startswith('!코드'):
        var code_request = message.substr(6)
        # 요청된 코드에 대한 처리 로직 추가
        pass
