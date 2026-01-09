extends Node2D

# 나중에 구조 바뀌어도 gamescene 주소만 바꾸면 되도록 세팅
@onready var player = $Gameplaycontainer/Player
@onready var ui_canvas = $UIcanvas
@onready var enemy_spawner = $Gameplaycontainer/EnemySpawner
@onready var bullet_container = $Gameplaycontainer/Bulletcontainer
@onready var enemy_container = $Gameplaycontainer/Enemycontainer
#@onready var enemy = $Gameplaycontainer/EnemySpawner/enemy
@onready var stage_timer = $StageTimer
@onready var background = $Parrallax2D
@onready var option_panel = $UIcanvas/OptionPanel

# 스테이지 지속 시간
@export var stage_duration : float

func _ready() -> void:
	stage_timer.wait_time = stage_duration
	stage_timer.start()
	# player랑 ui canvas가 있으면
	if player and ui_canvas:
		# life 변한 것 uicanvas한테 알려줄 수 있게 connect
		player.life_changed.connect(ui_canvas._on_player_life_changed)
		
		# 폭탄 변한 것 uicanvas한테 알려줄 수 있게 connect
		player.bomb_changed.connect(ui_canvas._on_player_bomb_changed)
		
		# score item 먹으면 알려주기
		player.item_collected.connect(ui_canvas._on_take_item)

		# Player의 _ready()가 GameScene보다 먼저 실행되면 current life 발신을 놓칠 수도 있어서
		# 귀찮지만 한번 더 수동 갱신
		ui_canvas._on_player_life_changed(player.current_life)
		ui_canvas._on_player_bomb_changed(player.current_bomb)

		# 사망 연결용
		player.player_died.connect(ui_canvas._on_player_died)
		enemy_spawner.enemy_spawned.connect(_on_enemy_spawned)
		
		audio_manager.play_bgm("stage")
	
	if option_panel:
		option_panel.closed.connect(_on_option_panel_closed)

func _on_enemy_spawned(enemy_instance) -> void:
	# 생성된 적의 'enemy_died' 신호를 UI의 '_on_object_died' 함수에 연결
	# 이렇게 하면 적 -> GameScene(중재) -> UI 로 연결됩니다.
	enemy_instance.enemy_died.connect(ui_canvas._on_object_died)

# 배경 멈추기
func _on_stage_timer_timeout() -> void:
	var background_tween = create_tween()
	# tween 써서 position을 respawn_position까지 1.5초동안 옮긴다
	background_tween.tween_property(background, "autoscroll", Vector2.ZERO, 0.45)
	
func _input(event):
	# ESC 키로 일시정지
	if event.is_action_pressed("esc"):
		# 이미 paused된 상태에 esc 누른 거라면 -> resume 하고 option 패널 끄기
		if get_tree().paused:
			resume_game()
			option_panel._close()
		# paused되지 않은 거라면 pause하고 옵션패널 켜기
		else:
			pause_game()

func resume_game():
	get_tree().paused = false
	option_panel._close()
	
func pause_game():
	get_tree().paused = true
	option_panel._open()

# closed 신호를 받아서 func 발동
# closed 신호는 option_panel의 닫기 버튼에서 쏴줌
func _on_option_panel_closed():
	resume_game()
	
