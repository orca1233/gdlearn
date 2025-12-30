extends Node

signal message_received(message)

func _ready():
    var chat_channel = get_node("/root/ChatChannel")
    chat_channel.connect("message_sent", self, "_on_message_sent")

func _on_message_sent(message):
    emit_signal("message_received", message)
    print("Message received: " + message)