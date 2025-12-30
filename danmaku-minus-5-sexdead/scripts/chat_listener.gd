extends Node

# Chat Listener script

func _ready():
    print("Chat listener is ready!")

func _on_chat_message_received(message):
    print("Message received: " + message)

# 수정본