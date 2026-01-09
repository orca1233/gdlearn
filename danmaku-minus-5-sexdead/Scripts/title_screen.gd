extends Control

@onready var option_panel = $OptionPanel
@export var start_scene: PackedScene

func _ready() -> void:
	# 초기에는 옵션 패널 숨김
	option_panel.visible = false
	# bgm 틀어주기
	audio_manager.play_bgm("title")
	
#========================================
#             시작 패널
#========================================

# 시작 버튼
func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_scene)
	
# 옵션 버튼
func _on_option_button_pressed() -> void:
	option_panel._open()
	
# 나가기 버튼
func _on_quit_button_pressed() -> void:
	get_tree().quit()
