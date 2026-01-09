extends Panel
# 꺼지고 켜지는거 signal
signal closed

@onready var master_slider = $CenterContainer/VBoxContainer/MasterVolumeContainer/MasterVolumeSlider
@onready var music_slider = $CenterContainer/VBoxContainer/MusicVolumeContainer/MusicVolumeSlider
@onready var audio_slider = $CenterContainer/VBoxContainer/AudioVolumeContainer/AudioVolumeSlider

func _ready() -> void:
	visible = false
	
	# 기본 value들 정해주기
	master_slider.value = 100 # 기본 100%
	music_slider.value = 50 # 기본 50%
	audio_slider.value = 50 # 기본 50%

# 켜졌을 때
func _open():
	visible = true

# 옵션 끄기
func _on_option_quit_button_pressed() -> void:
	_close()
	closed.emit()

# 꺼질 때
func _close():
	visible = false

#========================================
#               옵션 패널
#========================================

#========================================
#              사운드 패널
#========================================
	# 0~100까지의 밸류를 float로 받아서 -> audio의 bus(음성 채널)을 조절해줌
# 1. 마스터 볼륨
func _on_master_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_slider.value / 100))
	$CenterContainer/VBoxContainer/MasterVolumeContainer/ValueLabel.text = str(int(master_slider.value)) + "%"
	
# 2. 뮤직 볼륨
func _on_music_volume_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_slider.value / 100))
	$CenterContainer/VBoxContainer/MusicVolumeContainer/ValueLabel.text = str(int(music_slider.value)) + "%"
	
# 3. SFX 볼륨
func _on_audio_volume_slider_value_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(audio_slider.value / 100))
	$CenterContainer/VBoxContainer/AudioVolumeContainer/ValueLabel.text = str(int(audio_slider.value)) + "%"

#========================================
#        해상도/fps 패널 (옵션버튼)
#========================================
func _on_relosution_option_button_item_selected(index: int) -> void:
	match index:
		0:
			set_windowed_mode()
		1:
			set_fullscreen_mode()

# 창 모드로 설정
func set_windowed_mode():
	# Project 세팅 -> window mode 바꿔주고, 해상도 int vector2로 설정
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	get_window().size = Vector2i(1280, 720)
	
	# 현재 모니터 스크린의 사이즈를 구함
	var screen_size = DisplayServer.screen_get_size()
	# 현재 게임 창 사이즈를 구함
	var window_size = DisplayServer.window_get_size()
	# 모니터의 사이즈에서 스크린의 사이즈를 뺀 여백 = 1920 - 1280 =.
	# 768을 나누기 2 해준 뒤에, 그 값으로 position을 넣으면 항상 화면이 중앙에 오는 것처럼 됨
	get_window().position = (screen_size - window_size) / 2
	
# 풀스크린 모드로 설정
func set_fullscreen_mode():
# Project 세팅 -> FULLSCREEN mode 바꿔주고, 해상도 int vector2로 설정
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_window().size = Vector2i(1920, 1080)

# 프레임 30 / 60 / 무제한으로 바꾸기
func _on_fps_option_button_item_selected(index: int) -> void:
	match index:
		0:
			set_30fps_mode()
		1:
			set_60fps_mode()
		2:
			set_limitless_mode()

func set_30fps_mode():
	Engine.max_fps = 30
func set_60fps_mode():
	Engine.max_fps = 60
func set_limitless_mode():
	Engine.max_fps = 0

# 초기 설정으로 되돌리기
