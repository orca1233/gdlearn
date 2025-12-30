extends Node

func _ready():
    pass

func handle_discord_message(message: String):
    if message.begins_with("!코드 "):
        var code = message.substr(5)
        print("Code received: " + code)
        // Handle the code execution or storage here
