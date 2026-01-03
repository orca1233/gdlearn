# API Reference - 개발자용 기술 문서

> **팀원 필독**: 이 문서는 프로젝트의 전역 시스템, Autoload, 시그널, 그룹 등을 정리한 개발자용 레퍼런스입니다.

---

## 📌 목차
1. [Autoload 싱글톤](#autoload-싱글톤)
2. [시그널 시스템](#시그널-시스템)
3. [Godot 그룹](#godot-그룹)
4. [Resource 클래스](#resource-클래스)
5. [충돌 레이어](#충돌-레이어)
6. [공통 함수](#공통-함수)

---

## 🌍 Autoload 싱글톤

프로젝트 전역에서 어디서든 접근 가능한 싱글톤입니다.

### 1. vfx_manager

**파일**: `Scripts/vfx_manager.gd`
**용도**: 시각 효과(폭발 등) 중앙 관리

#### 함수

##### `spawn_explosion(pos: Vector2)`
폭발 이펙트를 지정된 위치에 생성합니다.

**파라미터**:
- `pos` (Vector2): 폭발 위치 (global_position)

**사용 예시**:
```gdscript
# 플레이어 위치에 폭발 생성
vfx_manager.spawn_explosion(player.global_position)

# 적 사망 시
vfx_manager.spawn_explosion(global_position)
```

**사용 위치**:
- `player.gd:183` - 플레이어 피격 시
- `boss_1.gd:29` - 보스 사망 시
- `enemy.gd:69` - 적 사망 시

---

### 2. audio_manager

**파일**: `Scripts/audio_manager.gd`
**용도**: BGM/SFX 중앙 관리

#### 전역 변수

```gdscript
var bgm_volume: float = 0.05  # BGM 볼륨 (0.0 ~ 1.0)
var sfx_volume: float = 0.05  # SFX 볼륨 (0.0 ~ 1.0)
```

#### 등록된 사운드

**BGM**:
- `"stage"`: 스테이지 배경음악 (`stage_bgm_001.mp3`)

**SFX**:
- `"playerdead"`: 플레이어 사망음 (`se_pldead00.wav`)
- `"timeout"`: 타임아웃 효과음 (`se_timeout.wav`)
- `"powerup"`: 파워업 효과음 (`se_chargeup.wav`)
- `"damage"`: 피격음 (`se_damage00.wav`)

#### 함수

##### `play_bgm(track_name: String, fade_in: bool = true)`
BGM을 재생합니다. 이미 같은 곡이 재생 중이면 무시합니다.

**파라미터**:
- `track_name` (String): BGM 이름 (예: "stage", "boss")
- `fade_in` (bool): 페이드인 효과 여부 (기본값: true)

**사용 예시**:
```gdscript
# 게임 시작 시 스테이지 BGM 재생
audio_manager.play_bgm("stage")

# 보스전 돌입 시 BGM 전환 (페이드인 효과)
audio_manager.play_bgm("boss", true)

# 타이틀 화면 (페이드인 없이)
audio_manager.play_bgm("title", false)
```

**사용 위치**:
- `game_scene.gd:37` - 스테이지 시작 시

---

##### `stop_bgm(fade_out: bool = true)`
BGM을 정지합니다.

**파라미터**:
- `fade_out` (bool): 페이드아웃 효과 여부 (기본값: true)

**사용 예시**:
```gdscript
# 게임 오버 시 (페이드아웃)
audio_manager.stop_bgm(true)

# 즉시 정지
audio_manager.stop_bgm(false)
```

---

##### `play_sfx(sound_name: String, pitch_scale: float = 1.0)`
효과음을 재생합니다. 동시에 최대 16개까지 재생 가능합니다.

**파라미터**:
- `sound_name` (String): SFX 이름 (예: "playerdead", "damage")
- `pitch_scale` (float): 피치 스케일 (기본값: 1.0)
  - 0.5 = 낮은 음 (느린 재생)
  - 1.0 = 원본
  - 2.0 = 높은 음 (빠른 재생)

**사용 예시**:
```gdscript
# 플레이어 사망음
audio_manager.play_sfx("playerdead")

# 피격음 (피치 랜덤화로 다양성 추가)
audio_manager.play_sfx("damage", randf_range(0.9, 1.1))

# 파워업 (높은 음)
audio_manager.play_sfx("powerup", 1.2)
```

**사용 위치**:
- `player.gd:184` - 플레이어 피격 시 "playerdead" 재생

---

##### `set_bgm_volume(volume: float)`
BGM 볼륨을 조절합니다 (옵션 메뉴용).

**파라미터**:
- `volume` (float): 볼륨 (0.0 ~ 1.0)

**사용 예시**:
```gdscript
# 옵션 메뉴의 슬라이더
func _on_bgm_slider_value_changed(value: float):
    audio_manager.set_bgm_volume(value / 100.0)  # 0~100 → 0.0~1.0
```

---

##### `set_sfx_volume(volume: float)`
SFX 볼륨을 조절합니다 (옵션 메뉴용).

**파라미터**:
- `volume` (float): 볼륨 (0.0 ~ 1.0)

**사용 예시**:
```gdscript
# 옵션 메뉴의 슬라이더
func _on_sfx_slider_value_changed(value: float):
    audio_manager.set_sfx_volume(value / 100.0)
```

---

### 새 사운드 추가 방법

1. **사운드 파일 추가**
   - `Assets/Sound/BGM/` 또는 `Assets/Sound/SFX/`에 파일 복사

2. **audio_manager.gd 수정**
   ```gdscript
   # BGM 추가
   var bgm_tracks = {
       "stage": preload("res://Assets/Sound/BGM/stage_bgm_001.mp3"),
       "boss": preload("res://Assets/Sound/BGM/boss_theme.mp3"),  # 추가
   }

   # SFX 추가
   var sfx_sounds = {
       "playerdead": preload("res://Assets/Sound/SFX/se_pldead00.wav"),
       "explosion": preload("res://Assets/Sound/SFX/explosion.wav"),  # 추가
   }
   ```

3. **코드에서 사용**
   ```gdscript
   audio_manager.play_bgm("boss")
   audio_manager.play_sfx("explosion")
   ```

---

## 📡 시그널 시스템

### Player → GameScene → UI 흐름

```
Player (player.gd)
  ├─ life_changed(new_life: int)
  │    └─> GameScene이 중개
  │         └─> UI Canvas (_on_player_life_changed)
  │
  ├─ bomb_changed(new_bomb: int)
  │    └─> GameScene이 중개
  │         └─> UI Canvas (_on_player_bomb_changed)
  │
  ├─ item_collected(type: int, value: int)
  │    └─> GameScene이 중개
  │         └─> UI Canvas (_on_take_item)
  │
  └─ player_died()
       └─> GameScene이 중개
            └─> UI Canvas (_on_player_died)
```

### 플레이어 시그널

**파일**: `Scripts/player.gd:53-57`

#### 1. `life_changed(new_life: int)`
플레이어 생명이 변경될 때 발신됩니다.

**발신 시점**:
- 피격 시 (`player.gd:181`)
- 리스폰 시 (자동)

**연결 위치**:
- `game_scene.gd:20` → `ui_canvas._on_player_life_changed`

**사용 예시**:
```gdscript
# 외부에서 플레이어 생명 변경 시
player.current_life += 1
player.life_changed.emit(player.current_life)
```

---

#### 2. `bomb_changed(new_bomb: int)`
폭탄 개수가 변경될 때 발신됩니다.

**발신 시점**:
- 폭탄 사용 시 (`player.gd:126`)
- 폭탄 아이템 획득 시 (`player.gd:250`)
- 게임 시작 시 (`player.gd:73`)

**연결 위치**:
- `game_scene.gd:23` → `ui_canvas._on_player_bomb_changed`

---

#### 3. `item_collected(type: int, value: int)`
아이템 획득 시 발신됩니다 (Score 아이템만).

**파라미터**:
- `type` (int): 아이템 타입 (1 = Score)
- `value` (int): 점수 값 (보통 100000)

**발신 시점**:
- Score 아이템 획득 시 (`player.gd:247`)

**연결 위치**:
- `game_scene.gd:26` → `ui_canvas._on_take_item`

---

#### 4. `player_died()`
플레이어가 완전히 사망했을 때 발신됩니다 (생명 0).

**발신 시점**:
- `current_life <= 0`일 때 (`player.gd:192`)

**연결 위치**:
- `game_scene.gd:34` → `ui_canvas._on_player_died`

---

### Enemy/Boss → GameScene → UI 흐름

```
Enemy/Boss
  └─ enemy_died()
       └─> GameScene이 중개 (_on_enemy_spawned에서 connect)
            └─> UI Canvas (_on_object_died)
```

#### `enemy_died()`
적/보스가 사망했을 때 발신됩니다.

**정의 위치**:
- `enemy.gd:18`
- `boss_1.gd:9`

**발신 시점**:
- 적 HP 0 이하 (`enemy.gd:68`)
- 보스 HP 0 이하 (`boss_1.gd:28`)

**연결 방식**:
```gdscript
# game_scene.gd:39-42
func _on_enemy_spawned(enemy_instance) -> void:
    # 동적으로 연결 (스폰 시마다)
    enemy_instance.enemy_died.connect(ui_canvas._on_object_died)
```

---

### EnemySpawner → GameScene 흐름

```
EnemySpawner
  └─ enemy_spawned(enemy_inst: Node)
       └─> GameScene (_on_enemy_spawned)
            └─> enemy.enemy_died를 UI에 연결
```

#### `enemy_spawned(enemy_inst: Node)`
적이 스폰되었을 때 발신됩니다.

**정의 위치**: `enemy_spawner.gd:9`

**파라미터**:
- `enemy_inst` (Node): 생성된 적 인스턴스

**발신 시점**:
- `enemy_spawner.gd:63` - 적 생성 직후

**연결 위치**:
- `game_scene.gd:35` → `_on_enemy_spawned`

---

## 🏷️ Godot 그룹

코드에서 `get_tree().get_first_node_in_group("그룹명")` 또는 `get_tree().get_nodes_in_group("그룹명")`으로 사용됩니다.

### 등록된 그룹

| 그룹명 | 노드 | 용도 | 등록 위치 |
|--------|------|------|-----------|
| **player** | Player (CharacterBody2D) | 플레이어 탐지 (적이 조준할 때) | `player.tscn` |
| **boss** | Boss (Node2D) | 보스 감지 (폭탄 피격 판정) | `boss_1.tscn` |
| **enemy_bullet** | EnemyBullet (Area2D) | 적 탄막 일괄 제거 (폭탄 사용 시) | `enemy_bullet.tscn` |

### 사용 예시

#### 플레이어 찾기
```gdscript
# enemy.gd:52 - 적이 플레이어 조준
var player = get_tree().get_first_node_in_group("player")
if player:
    b.direction = (player.global_position - global_position).normalized()
```

#### 폭탄으로 탄막 제거
```gdscript
# bomb.gd - 폭탄 범위 내 적 탄막 전부 삭제
for bullet in get_tree().get_nodes_in_group("enemy_bullet"):
    if overlaps_area(bullet):
        bullet.queue_free()
```

#### 보스에게 피해
```gdscript
# bomb.gd - 폭탄이 보스에게 데미지
for boss in get_tree().get_nodes_in_group("boss"):
    if overlaps_area(boss):
        boss._take_damage(damage)
```

---

## 📦 Resource 클래스

### 1. BulletPatternData

**파일**: `Scripts/boss_pattern_data.gd`
**용도**: 보스 탄막 패턴 정의

#### Enum

```gdscript
enum ShootType {
    SPIRAL = 0,        # 나선형
    SPREAD = 1,        # 부채꼴
    CIRCLE_BURST = 2   # 원형 파동
}
```

#### 주요 속성

| 속성 | 타입 | 설명 | 기본값 |
|------|------|------|--------|
| `pattern_type` | ShootType | 패턴 종류 | SPIRAL |
| `speed` | float | 총알 속도 | 200.0 |
| `bullet_count` | int | 총알 개수 | 10 |
| `spread_angle` | float | 퍼짐 각도 (도) | 30.0 |
| `is_aimed` | bool | 플레이어 조준 여부 | false |
| `fire_rate` | float | 발사 간격 (초) | 0.1 |
| `rotate_speed` | float | 회전 속도 (SPIRAL) | 0.1 |
| `use_burst` | bool | 버스트 모드 | false |
| `burst_time` | float | 발사 지속 시간 | 2.0 |
| `rest_time` | float | 휴식 시간 | 1.0 |

#### 사용 예시

**Resource 파일 생성** (Godot 에디터):
1. 우클릭 → New Resource → BulletPatternData
2. `Resource/my_pattern.tres`로 저장
3. Inspector에서 속성 설정:
   - `pattern_type`: SPREAD
   - `bullet_count`: 15
   - `spread_angle`: 45.0
   - `is_aimed`: true

**보스에 할당**:
```gdscript
# boss_2.tscn의 BulletPattern 노드
# Inspector → patterns 배열에 my_pattern.tres 추가
```

---

### 2. SpawnEvent

**파일**: `Scripts/spawn_event.gd`
**용도**: 적 스폰 타이밍 정의

#### 주요 속성

| 속성 | 타입 | 설명 |
|------|------|------|
| `spawn_time` | float | 스폰 시간 (초) |
| `enemy_scene` | PackedScene | 적 씬 (enemy.tscn) |
| `enemy_path` | PackedScene | 경로 씬 (enemy_path.tscn) |
| `count` | int | 스폰 개수 |
| `interval` | float | 스폰 간격 (초) |
| `isMirror` | bool | 좌우 대칭 스폰 |

#### 사용 예시

**EnemySpawner에 이벤트 추가**:
1. `game_scene.tscn`의 EnemySpawner 노드 선택
2. Inspector → events 배열 크기 설정 (예: 5)
3. 각 요소 클릭 후 설정:
   ```
   이벤트 0:
     spawn_time: 5.0
     enemy_scene: enemy.tscn
     enemy_path: path_straight.tscn
     count: 3
     interval: 1.0
     isMirror: false

   이벤트 1:
     spawn_time: 10.0
     enemy_scene: enemy.tscn
     enemy_path: path_curve.tscn
     count: 5
     interval: 0.5
     isMirror: true  # 좌우 양쪽에서 10마리 소환
   ```

---

## 🎯 충돌 레이어

**설정 위치**: 프로젝트 설정 → Layer Names → 2D Physics

| Layer | 이름 | 오브젝트 |
|-------|------|----------|
| 1 | 플레이어 | Player (CharacterBody2D) |
| 2 | 플레이어 총알 | PlayerBullet (Area2D) |
| 4 | 적 본체 | Enemy, Boss (Area2D) |
| 12 | 아이템 | Item (Area2D) |
| 16 | 적 총알 | EnemyBullet (Area2D) |

### 충돌 매트릭스

| 오브젝트 | Collision Layer | Collision Mask |
|---------|----------------|----------------|
| Player | 1 | 4, 12, 16 (적, 아이템, 적 총알) |
| PlayerBullet | 2 | 4 (적만) |
| Enemy | 4 | 1, 2 (플레이어, 플레이어 총알) |
| Item | 12 | 1 (플레이어만) |
| EnemyBullet | 16 | 1 (플레이어만) |

---

## 🛠️ 공통 함수

여러 스크립트에서 동일하게 사용되는 함수들입니다.

### `_take_damage(damage: int)`

**정의 위치**:
- `player.gd:174`
- `boss_1.gd:22`
- `enemy.gd:62`

**용도**: 피해를 받고 HP 감소

**파라미터**:
- `damage` (int): 받을 피해량

**동작**:
1. HP 감소
2. HP 0 이하 시 사망 처리
3. 폭발 이펙트 생성 (vfx_manager)

**호출 예시**:
```gdscript
# 플레이어 총알이 적에게 닿았을 때
# player_bullet.gd
if body.has_method("_take_damage"):
    body._take_damage(damage)  # damage = 1
```

**주의**:
- 이 함수는 **공통 인터페이스**로 사용됨
- 새로운 적/보스를 만들 때 반드시 구현 필요
- 향후 BaseEnemy 클래스로 통합 예정

---

## 📝 팀원용 체크리스트

### 새 기능 추가 시

#### BGM/SFX 추가
- [ ] `Assets/Sound/BGM/` 또는 `Assets/Sound/SFX/`에 파일 추가
- [ ] `audio_manager.gd`의 딕셔너리에 등록
- [ ] 이 문서의 "등록된 사운드" 섹션 업데이트

#### 새 시그널 추가
- [ ] 스크립트에 `signal 시그널명(파라미터)` 선언
- [ ] `game_scene.gd`에서 connect
- [ ] 이 문서의 "시그널 시스템" 섹션 업데이트

#### 새 그룹 추가
- [ ] 씬의 노드 → Groups 탭에서 그룹 추가
- [ ] 이 문서의 "Godot 그룹" 섹션 업데이트

#### 새 Resource 클래스 추가
- [ ] `Scripts/`에 `extends Resource` 스크립트 생성
- [ ] `class_name` 선언 (필수)
- [ ] 이 문서의 "Resource 클래스" 섹션 업데이트

---

## 🔄 문서 업데이트 규칙

- **Autoload 추가 시**: 해당 섹션에 함수 목록 추가
- **시그널 추가 시**: 시그널 시스템 섹션에 흐름도 업데이트
- **사운드 추가 시**: audio_manager 섹션의 "등록된 사운드" 업데이트
- **중요 공통 함수 추가 시**: "공통 함수" 섹션에 추가

---

## 📞 질문/문의

이 문서에 없는 내용이나 불명확한 부분은 팀 채팅방에 문의해주세요.

**마지막 업데이트**: 2026-01-03
