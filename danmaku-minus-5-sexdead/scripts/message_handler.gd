extends Node

func _ready():
    print("Discord message listener ready!")

func on_message_received(message : String):
    print("Received message: " + message)
