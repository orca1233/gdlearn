extends Node

func _ready():
    pass

func handle_message(message: String):
    if message == "!코드 새로운 파일 생성해줘":
        create_new_file()  

func create_new_file():
    var file = File.new()
    file.open("res://danmaku-minus-5-sexdead/scripts/new_script.gd", File.WRITE)
    file.store_line("extends Node\n\nfunc _ready():\n    pass")
    file.close()