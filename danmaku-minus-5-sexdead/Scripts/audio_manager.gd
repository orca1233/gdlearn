# audio_manager.gd
# Autoload 싱글톤으로 등록 (project.godot에 추가 필요)
extends Node

# ============================================
# BGM (배경음악)
# ============================================
@onready var bgm_player = AudioStreamPlayer.new()

# BGM 파일 프리로드 (파일 경로는 실제 사운드 추가 후 수정)
var bgm_tracks = {
	"stage": preload("res://Assets/Sound/BGM/stage_bgm_001.mp3"),
	"title": preload("res://Assets/Sound/BGM/title_bgm_001.mp3")
}

# ============================================
# SFX (효과음)
# ============================================
# SFX용 AudioStreamPlayer 풀 (동시 재생 지원)
var sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS = 16  # 동시 재생 가능한 효과음 개수

# SFX 파일 프리로드
var sfx_sounds = {
	"playerdead": preload("res://Assets/Sound/SFX/se_pldead00.wav"),
	"timeout": preload("res://Assets/Sound/SFX/se_timeout.wav"),
	"powerup": preload("res://Assets/Sound/SFX/se_chargeup.wav"),
	"damage": preload("res://Assets/Sound/SFX/se_damage00.wav")
}

# ============================================
# 볼륨 설정
# ============================================
var bgm_volume: float = 0.05  # 0.0 ~ 1.0
var sfx_volume: float = 0.03 # 0.0 ~ 1.0

# ============================================
# 초기화
# ============================================
func _ready() -> void:
	# BGM 플레이어 설정
	add_child(bgm_player)
	# bgm 사운드들의 통합 관리자 -> music을 낮추면 bgm 전체 소리 줄어듬
	# bgm은 1개밖에 재생 못하도록 할 것이기 때문에 1개만 설정
	bgm_player.bus = "Music"  # Audio Bus 설정 (project.godot에서 생성 필요)
	# 선형적인 숫자 -> 볼륨 데시벨
	bgm_player.volume_db = linear_to_db(bgm_volume)

	# SFX 플레이어 풀 생성
	# 현재는 16번 반복해서 sfx를 태워줄 player를 만듬
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		# sfx 사운드들의 통합 관리자 -> SFX 낮추면 SFX 전체 소리 줄어듬
		player.bus = "SFX"  # Audio Bus 설정
		player.volume_db = linear_to_db(sfx_volume)
		add_child(player)
		sfx_players.append(player)

# ============================================
# BGM 제어
# ============================================

# BGM 재생
func play_bgm(track_name: String, fade_in: bool = true) -> void:
	# track name이 bgm_tracks에 안 실려 있으면 => 에러
	if not bgm_tracks.has(track_name):
		push_error("AudioManager: BGM '%s' 없음!" % track_name)
		return

	# 이미 같은 곡이 재생 중이면 무시
	# stream중인 곡이 bgm_tracks에 있고 // 그게 지금 playing중이면 아무것도 안 함
	if bgm_player.stream == bgm_tracks[track_name] and bgm_player.playing:
		return

	# 페이드 아웃 후 새 BGM 재생
	# 지금 playing중인데 fade_in이 true이면 => fade out
	if bgm_player.playing and fade_in:
		await fade_out_bgm(0.5)  # 0.5초 페이드 아웃

	bgm_player.stream = bgm_tracks[track_name]
	bgm_player.play()

	# fade in이 활성화되어 있으면 fade in (tween)을 해서 -80에서 bgm_volume까지 0.5초 동안 오게 만듬
	# fade_in_bgm(float=duration) 으로 몇 초동안 페이드인할지 결정 가능
		# 페이드 아웃도 같은 원리
	if fade_in:
		fade_in_bgm(0.5)  # 0.5초 페이드 인

# BGM 정지
func stop_bgm(fade_out: bool = true) -> void:
	# fade out 0.5 = 0.5초동안 대기하고 멈춰줌
	if fade_out:
		await fade_out_bgm(0.5)
	else:
		bgm_player.stop()

# BGM 페이드 인
func fade_in_bgm(duration: float) -> void:
	# tween으로 bgm_player의 볼륨_db(사운드 크기)를 선형적으로 bgm_volume 수준만큼 변화시킴
	# 걸리는 시간 초는 fade_in_bgm(float)로 결정 가능
	var tween = create_tween()
	bgm_player.volume_db = -80  # 거의 무음
	tween.tween_property(bgm_player, "volume_db", linear_to_db(bgm_volume), duration)

# BGM 페이드 아웃
func fade_out_bgm(duration: float) -> void:
	# tween으로 bgm_player의 볼륨_db(사운드 크기)를 선형적으로 -80 수준만큼 변화시킴
	# 걸리는 시간 초는 fade_in_bgm(float)로 결정 가능
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80, duration)
	await tween.finished
	# tween이 -80만큼 사운드를 내리면 stop시킴
	bgm_player.stop()

# ============================================
# SFX 제어
# ============================================

# SFX 재생
func play_sfx(sound_name: String, pitch_scale: float = 1.0) -> void:
	# sfx name이 sfx_sounds에 안 실려 있으면 => 에러
	if not sfx_sounds.has(sound_name):
		push_error("AudioManager: SFX '%s' 없음!" % sound_name)
		return

	# 재생 가능한 플레이어 찾기
	var player = _get_available_sfx_player()
	if player:
		# 재생 가능한 player가 있으면 player가 stream하는 건 sfx_sounds[sound_name]
		player.stream = sfx_sounds[sound_name]
		player.pitch_scale = pitch_scale  # 피치 변경으로 다양성 추가 가능
		# 플레이어가 재생
		player.play()
	else:
		# 모든 플레이어가 사용 중이면(=재생 가능한 플레이어가 없으면) 가장 오래된 것 중단하고 재사용
		sfx_players[0].stop()
		sfx_players[0].stream = sfx_sounds[sound_name]
		sfx_players[0].pitch_scale = pitch_scale
		sfx_players[0].play()

# 사용 가능한 SFX 플레이어 찾기
func _get_available_sfx_player() -> AudioStreamPlayer:
	# sfx_players에서 player를 찾는데
	for player in sfx_players:
		# play하고 있지 않으면
		if not player.playing:
			# 그 플레이어를 돌려줌
			return player
	return null

# ============================================
# 볼륨 조절 (옵션 메뉴에서 사용)
# ============================================

func set_bgm_volume(volume: float) -> void:
	bgm_volume = clamp(volume, 0.0, 1.0)
	bgm_player.volume_db = linear_to_db(bgm_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	for player in sfx_players:
		player.volume_db = linear_to_db(sfx_volume)

# dB 변환 헬퍼 (0.0 = -80dB, 1.0 = 0dB)
func linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)
