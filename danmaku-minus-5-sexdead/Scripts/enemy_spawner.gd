extends Node2D

# 1. 아까 만든 'EnemyPath.tscn' 파일을 인스펙터에서 드래그해서 넣어주세요
@export var enemy_path_scene: PackedScene 

signal enemy_spawned(enemy_instance)

func _ready():
	# 게임 시작 1초 뒤에 공격 시작
	await get_tree().create_timer(1.0).timeout
	start_pincer_attack()
	print("나 소환됨! 위치: ", global_position)

func start_pincer_attack():
	# 5마리 소환 루프
	for i in range(5):
		# 왼쪽 소환
		spawn_enemy(false)
		# 오른쪽 소환
		spawn_enemy(true)
		
		# 0.5초 쉬고 다음 마리 소환
		await get_tree().create_timer(0.5).timeout

func spawn_enemy(is_right: bool):
	if enemy_path_scene == null: return
	
	var path_inst = enemy_path_scene.instantiate()
	# 메인 씬에 추가하여 전체 화면 좌표계를 사용합니다.
	get_tree().current_scene.add_child(path_inst)
	
	# 적 소환했다는 신호 보내기
	var enemy = path_inst.get_node("PathFollow2D/enemy")
	enemy_spawned.emit(enemy)
	
	var screen_width = get_viewport_rect().size.x
	
	if is_right:
		# 1. 오른쪽 팀 설정
		# scale.x = -1은 지도를 세로축 기준으로 거울처럼 뒤집습니다.
		path_inst.scale.x = -1
		
		# 2. 위치 설정
		# 지도의 원점을 화면 오른쪽 끝(screen_width)에 배치합니다.
		path_inst.global_position = Vector2(screen_width, 0)
	else:
		# 3. 왼쪽 팀 설정
		# 지도의 원점을 화면 왼쪽 끝(0,0)에 배치합니다.
		path_inst.global_position = Vector2.ZERO
