extends Node

var character_data = {} 
var scenario_data = {}

func _ready():
	load_character_table()
	load_dialogue_table()

func load_character_table():
	# 파일이 실제로 존재하는지 확인 (안전장치)
	if not FileAccess.file_exists("res://Assets/Datasheets/CharacterTable.csv"):
		print("오류: 캐릭터 테이블 파일을 찾을 수 없습니다.")
		return

	var file = FileAccess.open("res://Assets/Datasheets/CharacterTable.csv", FileAccess.READ)
	file.get_csv_line() # 헤더 건너뛰기
	
	while !file.eof_reached():
		var csv = file.get_csv_line()
		
		# [수정 1] 데이터가 4개 미만이면(정보가 부족하면) 무시 (Index Error 방지)
		if csv.size() < 4:
			continue 
		
		var CharacterID = int(csv[0])
		character_data[CharacterID] = {
			"CharacterName": csv[1],
			"PortraitPath": csv[2],
			"ColorCode": csv[3]
		}
	print("캐릭터 데이터 로드 완료")

func load_dialogue_table():
	if not FileAccess.file_exists("res://Assets/Datasheets/DialogueTable.csv"):
		print("오류: 다이얼로그 테이블 파일을 찾을 수 없습니다.")
		return

	var file = FileAccess.open("res://Assets/Datasheets/DialogueTable.csv", FileAccess.READ)
	file.get_csv_line() # 헤더 건너뛰기
	
	while !file.eof_reached():
		var csv = file.get_csv_line()
		
		# [수정 2] 핵심 해결책! 
		# 다이얼로그 테이블은 컬럼이 5개이므로, 5개 미만인 줄은 건너뜁니다.
		# 엑셀 마지막에 빈 엔터가 들어가 있으면 csv.size()가 1이 되어 에러가 납니다.
		if csv.size() < 5:
			continue 
		
		var ScenarioID = int(csv[0])
		scenario_data[ScenarioID] = {
			"CharacterID": csv[1],
			"CharacterPos": csv[2],
			"CharacterExpression": csv[3], # [수정 3] 오타 수정 (CharacterExpression)
			"Dialogue": csv[4]
		}
	print("시나리오 데이터 로드 완료")
