extends Node2D

# 나중에 구조 바뀌어도 gamescene 주소만 바꾸면 되도록 세팅
@onready var player = $Gameplaycontainer/Player
@onready var ui_canvas = $UIcanvas

func _ready() -> void:
	# player랑 ui canvas가 있으면
	if player and ui_canvas:
		# life 변한 것 uicanvas한테 알려줄 수 있게 connect
		player.life_changed.connect(ui_canvas._on_player_life_changed)
		# Player의 _ready()가 GameScene보다 먼저 실행되면 current life 발신을 놓칠 수도 있어서
		# 귀찮지만 한번 더 수동 갱신
		ui_canvas._on_player_life_changed(player.current_life)

		# 사망 연결용
		player.player_died.connect(ui_canvas._on_player_died)
