# 🎮 탄막 패턴 가이드

## 📦 생성된 테스트 리소스

### 기본 패턴

#### 1. `pattern_accelerate.tres` - 가속 패턴
- **이동 타입**: ACCELERATE
- **특징**: 천천히 시작해서 빠르게 가속
- **패턴**: 원형 8방향 발사
- **용도**: 예측하기 어려운 속도 변화 탄막

```gdscript
# 주요 파라미터
speed = 100.0           # 시작 속도
acceleration = 150.0    # 가속도
bullet_count = 8        # 8개 발사
spread_angle = 360.0    # 전방향
```

---

#### 2. `pattern_curve.tres` - 곡선 패턴
- **이동 타입**: CURVE
- **특징**: 뱀처럼 구불구불 이동
- **패턴**: 플레이어 조준 5방향 산탄
- **용도**: 회피하기 어려운 곡선 탄막

```gdscript
# 주요 파라미터
speed = 180.0           # 이동 속도
curve_amplitude = 80.0  # 곡선 진폭
curve_frequency = 3.0   # 곡선 주파수
is_aimed = true         # 플레이어 조준
```

---

#### 3. `pattern_homing.tres` - 유도탄 패턴
- **이동 타입**: HOMING
- **특징**: 2.5초간 플레이어 추적
- **패턴**: 3방향 산탄
- **용도**: 압박감 있는 추적 탄막

```gdscript
# 주요 파라미터
speed = 150.0           # 이동 속도
homing_strength = 80.0  # 유도 강도
homing_duration = 2.5   # 유도 지속 시간
bullet_count = 3        # 3개 발사
```

---

#### 4. `pattern_stop_and_change.tres` - 정지 후 반전 패턴
- **이동 타입**: STOP_AND_CHANGE
- **특징**: 0.8초 후 정지, 0.5초간 멈춘 뒤 180도 반전
- **패턴**: 원형 16방향 발사
- **용도**: 예상 밖의 방향 전환으로 혼란 유발

```gdscript
# 주요 파라미터
speed = 200.0               # 이동 속도
stop_trigger_time = 0.8     # 정지 트리거 시간
stop_time = 0.5             # 정지 지속 시간
change_angle = 180.0        # 방향 전환 각도
bullet_count = 16           # 16개 발사
```

---

### 복합 패턴

#### 5. `pattern_spiral_accelerate.tres` - 가속 나선 패턴
- **발사 타입**: SPIRAL (나선)
- **이동 타입**: ACCELERATE (가속)
- **특징**: 나선으로 회전하면서 가속
- **용도**: 화려하고 강력한 보스 패턴

```gdscript
# 주요 파라미터
pattern_type = 0        # SPIRAL
move_type = 1           # ACCELERATE
speed = 80.0            # 시작 속도
acceleration = 200.0    # 강한 가속
rotate_speed = 0.15     # 나선 회전 속도
fire_rate = 0.05        # 빠른 연사
```

---

#### 6. `pattern_aimed_curve.tres` - 조준 곡선 패턴
- **발사 타입**: SPREAD (산탄)
- **이동 타입**: CURVE (곡선)
- **특징**: 플레이어 방향으로 산탄을 쏘되 곡선으로 이동
- **용도**: 회피 난이도가 높은 중급 패턴

```gdscript
# 주요 파라미터
pattern_type = 1        # SPREAD
move_type = 2           # CURVE
speed = 160.0           # 이동 속도
curve_amplitude = 120.0 # 큰 진폭
curve_frequency = 4.0   # 빠른 진동
is_aimed = true         # 플레이어 조준
bullet_count = 7        # 7개 산탄
```

---

## 🎯 사용 방법

### 1. Godot 에디터에서 사용

1. Enemy 씬 열기 (`Scenes/Enemy/enemy.tscn`)
2. `bullet` 노드 선택
3. Inspector에서 `Patterns` 배열 확장
4. 기존 패턴 제거 후 새 패턴 추가
5. `Resource/pattern_*.tres` 파일 드래그 앤 드롭

### 2. 코드로 동적 변경

```gdscript
# enemy_bullet_pattern_controller.gd
var accelerate_pattern = preload("res://Resource/pattern_accelerate.tres")
var homing_pattern = preload("res://Resource/pattern_homing.tres")

patterns = [accelerate_pattern, homing_pattern]
load_pattern(0)
```

---

## 🔧 커스텀 패턴 만들기

### Step 1: 리소스 복사
기존 `.tres` 파일을 복사해서 새 이름으로 저장

### Step 2: 파라미터 조정
Godot 에디터에서 리소스 열기:
- **Movement 그룹**: 이동 타입 선택
- **각 타입별 파라미터 조정**:
  - ACCELERATE: `acceleration` 값 변경
  - CURVE: `curve_amplitude`, `curve_frequency` 조정
  - HOMING: `homing_strength`, `homing_duration` 조정
  - STOP_AND_CHANGE: `stop_time`, `change_angle` 조정

### Step 3: 발사 패턴 조합
- **pattern_type**:
  - `0` = SPIRAL (나선)
  - `1` = SPREAD (산탄)
  - `2` = CIRCLE_BURST (원형 파동)
- **move_type**:
  - `0` = LINEAR (직선)
  - `1` = ACCELERATE (가속)
  - `2` = CURVE (곡선)
  - `3` = HOMING (유도)
  - `4` = STOP_AND_CHANGE (정지 후 방향 전환)

---

## 💡 패턴 조합 아이디어

### 쉬운 난이도
- LINEAR + SPREAD: 기본 직선 산탄
- ACCELERATE + CIRCLE_BURST: 느리게 시작하는 원형 파동

### 중간 난이도
- CURVE + SPREAD: 곡선 산탄
- HOMING + SPIRAL: 추적하는 나선

### 어려운 난이도
- STOP_AND_CHANGE + CIRCLE_BURST: 반전하는 원형 파동
- ACCELERATE + HOMING: 가속하며 추적

---

## 🐛 트러블슈팅

### 탄막이 안 나와요
- Enemy 씬의 `bullet` 노드에 패턴이 할당되어 있는지 확인
- `bullet_node` 필드에 `enemy_bullet.tscn`이 할당되어 있는지 확인

### 이동 패턴이 작동 안 해요
- 리소스 파일의 `move_type` 값이 올바른지 확인
- Godot 에디터를 재시작해서 리소스 리로드

### 성능이 느려요
- `fire_rate` 값을 높여서 발사 빈도 줄이기
- `bullet_count` 값을 줄이기
- Object Pooling 구현 고려

---

## 📚 추가 개선 계획

- [ ] 탄막 패턴 추가 (RANDOM, LASER 등)
- [ ] Object Pooling으로 성능 최적화
- [ ] 패턴 시퀀스 시스템 (보스 스펠카드)
- [ ] 탄막 색상/크기 변화 효과
- [ ] 탄막 파티클 이펙트

---

**작성일**: 2026-01-21  
**버전**: 1.0.0
