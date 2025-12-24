extends Node2D

# 이벤트 단위로 스폰을 해줌.
# 시간 초에 따라서 적 소환해주기 위한 것. SpawnEvent를 넣으면 됨.
# 크기를 int로 지정하고, SpawnEvent를 지정해서 넣은 후 그것을 클릭하면 
 # n초에 적 x를 y마리 path z를 따라서 소환할 수 있음
@export var events: Array[SpawnEvent]

signal enemy_spawned(enemy_inst)
var current_time : float
var next_event_index: int = 0

func _ready() -> void:
	# 배열이 spawn_time 순서대로 되어 있지 않으면 로직이 꼬일 수 있어서 a<b 순서로 return
	events.sort_custom(func(a, b): return a.spawn_time < b.spawn_time)

func _process(delta: float) -> void:
	current_time += delta
# 아직 처리할 이벤트가 남았는지 확인
 # 이벤트 배열 사이즈가 next_event_index보다 크면, 배열에서 next_event_index번째 이벤트로 설정
	if next_event_index < events.size():
		var event = events[next_event_index]
		# 현재 시간이 이벤트 설정 시간보다 커지면 스폰
		if current_time >= event.spawn_time:
			start_spawn_routine(event)
			next_event_index += 1

# count 만큼 순차 소환
func start_spawn_routine(event: SpawnEvent) -> void:
	for i in range(event.count): # event의 count 수만큼 대기
		spawn_single_enemy(event, false)
		# 거울 모드 체크되어 있으면 두 번 소환
		if event.isMirror:
			spawn_single_enemy(event, true)
		# 다음 마리 소환 전 대기
		if i < event.count - 1:
			await get_tree().create_timer(event.interval).timeout

func spawn_single_enemy(event: SpawnEvent, is_mirrored: bool = false) -> void:
	# event에서 path_scene을 가져와서 인스턴스화하고 path_inst에 저장
	var path_inst = event.enemy_path.instantiate()
	get_tree().current_scene.add_child(path_inst)
	
	# 만약 is_mirrored가 체크되어 있으면(TRUE)
	if is_mirrored:
		# Path를 -1(반대편)으로 보냄
		path_inst.scale.x = -1
		# 화면 오른쪽 끝으로 이동
		path_inst.position.x = get_viewport_rect().size.x
		
	# Enemy도 똑같이 저장
	var enemy_inst = event.enemy_scene.instantiate()
	
	# enemy를 PathFollow2D에 추가해주기 위해 찾기
	# 이름이 PathFollow2D라서 거기에 추가
	var path_follow = path_inst.get_node("PathFollow2D")
	if path_follow:
		# 적을 PathFollow의 자식으로 붙임 (그래야 따라감)
		path_follow.add_child(enemy_inst)
		# 적 위치를 초기화해서 path의 첫 시작점에 있게 해야함
		enemy_inst.position = Vector2.ZERO
		
	enemy_spawned.emit(enemy_inst)

	
