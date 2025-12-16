extends Control

# CSV의 ID가 1부터 시작하므로 1로 초기화
var current_index = 1 

func _ready():
	# 게임 시작 시 첫 번째 대사(ID: 1) 출력
	show_dialogue(current_index)

func show_dialogue(index):
	# [안전장치] 해당 ID의 대사가 없으면 함수 종료 (엔딩이거나 에러 방지)
	if not DataManager.scenario_data.has(index):
		print("대사 종료 또는 잘못된 인덱스입니다: ", index)
		return

	# 1. 시나리오 데이터 가져오기 (딕셔너리 형태)
	var dialogue = DataManager.scenario_data[index]
	
	# [수정] 배열 인덱스([1])가 아니라 키("CharacterID")로 가져와야 함
	var char_id = int(dialogue["CharacterID"]) 
	
	# 2. 캐릭터 데이터 가져오기
	var char_info = DataManager.character_data[char_id]
	
	# 3. UI 업데이트
	# [수정] DataManager에서 저장한 Key 이름("CharacterName")과 정확히 일치해야 함
	$DialoguePanel/MarginContainer/NameLabel.text = char_info["CharacterName"]
	$DialoguePanel/MarginContainer/NameLabel.modulate = Color(char_info["ColorCode"])
	
	# [수정] "Dialogue" 키 사용
	$DialoguePanel/TextLabel.text = dialogue["Dialogue"] 
	
	# 4. 이미지 및 위치 설정
	# [수정] "PortraitPath" 키 사용
	var texture_path = char_info["PortraitPath"]
	$CharacterLayer/ActivePortrait.texture = load(texture_path)
	
	# [수정] "CharacterPos" 키 사용
	if dialogue["CharacterPos"] == "L":
		$CharacterLayer/ActivePortrait.position = $CharacterLayer/LeftPos.position
		$CharacterLayer/ActivePortrait.flip_h = true
	else:
		$CharacterLayer/ActivePortrait.position = $CharacterLayer/RightPos.position
		$CharacterLayer/ActivePortrait.flip_h = false 

# (추가 팁) 다음 대사로 넘어가는 함수 예시
func _input(event):
	if event.is_action_pressed("ui_accept"): # 스페이스바나 클릭 등
		current_index += 1
		show_dialogue(current_index)
