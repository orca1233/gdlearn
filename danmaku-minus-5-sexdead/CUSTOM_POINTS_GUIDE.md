# 📍 커스텀 좌표 기반 이동 패턴 가이드

## 🎯 새로운 기능: CUSTOM_POINTS PathType

`enemy_path.gd`에 **좌표 기반 세밀한 이동 패턴** 시스템이 추가되었습니다.

### 🚀 빠른 시작

#### **방법 1: 사전 정의된 위치 사용 (간단)**
```
1. `enemy_path.tscn` 열기
2. `PathFollow2D` 노드 선택
3. Inspector에서 `path_type`을 `CUSTOM_POINTS`로 변경
4. `start_position_type` 선택 (예: LEFT_TOP)
5. `end_position_type` 선택 (예: CENTER_TOP)
6. `curve_type` 선택 (LINEAR/BEZIER/SPLINE)
7. 게임 실행!
```

#### **방법 2: 직접 좌표 입력 (정밀)**
```
1. `path_type`을 `CUSTOM_POINTS`로 설정
2. `custom_points` 배열에 Vector2 좌표 추가
3. `point_durations`에 각 지점 도착 시간 설정
4. `curve_type`으로 보간 방식 선택
```

---

## 📋 사용 예제

### **예제 1: 좌측 상단 → 중앙 상단 (직선)**
```gdscript
# 에디터에서 설정:
path_type = CUSTOM_POINTS
start_position_type = LEFT_TOP
end_position_type = CENTER_TOP
curve_type = LINEAR
move_duration = 3.0
```

**결과**: `(0,0) → (320,0) → (320,-100)` 경로로 직선 이동

### **예제 2: U자형 경로 (곡선)**
```gdscript
custom_points = [
    Vector2(100, 100),      # 시작점
    Vector2(160, 50),       # 곡선 정점
    Vector2(220, 100),      # 종료점
    Vector2(220, -100)      # 퇴장
]
point_durations = [1.0, 2.0, 1.0]
curve_type = BEZIER
```

### **예제 3: S자형 경로 (스플라인)**
```gdscript
custom_points = [
    Vector2(50, 200),      # 좌측 하단
    Vector2(160, 100),     # 중앙
    Vector2(270, 200),     # 우측 하단
    Vector2(160, 300),     # 중앙 하단
    Vector2(160, -100)     # 퇴장
]
curve_type = SPLINE
```

---

## 🔧 파라미터 설명

### **Core Parameters**
| 파라미터 | 설명 | 기본값 |
|---------|------|--------|
| `custom_points` | 이동할 좌표 지점들 | `[]` |
| `point_durations` | 각 지점 도착 시간 | `[]` |
| `curve_type` | 보간 방식 | `LINEAR` |

### **Preset Positions**
| 시작 위치 | 좌표 (1280x720 기준) |
|----------|-------------------|
| `LEFT_TOP` | `(0, 0)` |
| `LEFT_CENTER` | `(0, 360)` |
| `LEFT_BOTTOM` | `(0, 720)` |
| `RIGHT_TOP` | `(1280, 0)` |
| `RIGHT_CENTER` | `(1280, 360)` |
| `RIGHT_BOTTOM` | `(1280, 720)` |

| 종료 위치 | 좌표 (1280x720 기준) |
|----------|-------------------|
| `CENTER_TOP` | `(640, 0)` |
| `CENTER` | `(640, 360)` |
| `CENTER_BOTTOM` | `(640, 720)` |

### **Curve Types**
| 타입 | 설명 | 용도 |
|------|------|------|
| `LINEAR` | 직선 보간 | 단순한 직선 이동 |
| `BEZIER` | 부드러운 곡선 | 자연스러운 곡선 경로 |
| `SPLINE` | 스플라인 곡선 | 복잡한 곡선 경로 |

---

## 🎮 실전 예제 패턴

### **패턴 A: 대각선 하강 (좌상 → 우하)**
```gdscript
start_position_type = LEFT_TOP
end_position_type = RIGHT_BOTTOM
curve_type = BEZIER
move_duration = 4.0
```

### **패턴 B: 정지 후 퇴장**
```gdscript
custom_points = [
    Vector2(100, 150),     # 시작점
    Vector2(320, 150),     # 정지점
    Vector2(320, 150),     # 동일 위치 (정지)
    Vector2(320, -100)     # 퇴장
]
point_durations = [1.0, 0.0, 2.0, 1.0]  # 2초간 정지
```

### **패턴 C: 원형 순회 (수동)**
```gdscript
custom_points = []
# 원형 좌표 자동 생성
for i in range(8):
    var angle = i * (PI * 2 / 8)
    var x = 320 + cos(angle) * 100
    var y = 240 + sin(angle) * 100
    custom_points.append(Vector2(x, y))
curve_type = SPLINE
```

---

## 🛠️ 코드로 동적 설정

```gdscript
# 런타임에서 동적 경로 설정
func setup_custom_path():
    var path_follow = get_node("PathFollow2D")
    
    # 커스텀 포인트 설정
    path_follow.custom_points = [
        Vector2(100, 100),
        Vector2(320, 200),
        Vector2(540, 100),
        Vector2(540, -100)
    ]
    
    # 시간 설정
    path_follow.point_durations = [1.5, 2.0, 1.0]
    
    # 곡선 타입
    path_follow.curve_type = path_follow.CurveType.BEZIER
    
    # PathType 변경
    path_follow.path_type = path_follow.PathType.CUSTOM_POINTS
    
    # 초기화 강제 실행
    path_follow._init_custom_points()
```

---

## 🔍 디버깅 팁

### **1. 좌표 확인**
```gdscript
# 경로 지점 출력
func _ready():
    if path_type == PathType.CUSTOM_POINTS:
        print("Custom Points:")
        for i in range(custom_points.size()):
            print("  [%d] %s" % [i, custom_points[i]])
```

### **2. 시간 설정 자동화**
```gdscript
# 총 이동 시간을 기준으로 자동 시간 분배
func auto_set_durations(total_time: float):
    point_durations = []
    var segment_count = custom_points.size() - 1
    for i in range(segment_count):
        point_durations.append(total_time / segment_count)
```

### **3. 화면 크기 기준 좌표**
```gdscript
# 화면 비율에 따른 좌표 계산
func get_screen_ratio_position(x_ratio: float, y_ratio: float) -> Vector2:
    var viewport_size = get_viewport().get_visible_rect().size
    return Vector2(viewport_size.x * x_ratio, viewport_size.y * y_ratio)

# 사용 예: 화면 왼쪽 25%, 위에서 30% 위치
var pos = get_screen_ratio_position(0.25, 0.30)
```

---

## 📊 패턴 조합 아이디어

### **탄막 게임용 기본 패턴**
1. **좌측 라인**: `LEFT_TOP → CENTER_TOP → RIGHT_TOP`
2. **우측 라인**: `RIGHT_TOP → CENTER → LEFT_BOTTOM`
3. **중앙 집중**: `LEFT_CENTER → CENTER → RIGHT_CENTER`
4. **위협 패턴**: `LEFT_TOP → CENTER (정지) → 퇴장`

### **난이도별 추천**
- **쉬움**: LINEAR + 2-3개 포인트
- **보통**: BEZIER + 3-4개 포인트  
- **어려움**: SPLINE + 4-5개 포인트 + 정지 구간

---

## ⚠️ 주의사항

### **1. 배열 크기 일치**
```gdscript
# 좋은 예: 포인트와 시간 배열 크기 일치
custom_points = [p1, p2, p3]
point_durations = [1.0, 2.0, 1.0]  # 3개

# 나쁜 예: 크기가 다름
custom_points = [p1, p2, p3]
point_durations = [1.0, 2.0]  # 2개만 있음 → 오류 발생
```

### **2. 시간 합계**
```gdscript
# 전체 이동 시간 확인
var total_duration = 0.0
for duration in point_durations:
    total_duration += duration
    
print("총 이동 시간: ", total_duration, "초")
```

### **3. 좌표 범위**
- 화면 좌표: `(0,0)` ~ `(1280,720)` (기준 해상도)
- 퇴장 좌표: Y축 `-100` 이하 권장
- 시작 좌표: Y축 `-50` 이상 권장

---

## 🔄 마이그레이션 가이드

### **기존 사용자**
1. 기존 `enemy_path.tscn` 파일은 그대로 사용 가능
2. 새로운 `CUSTOM_POINTS` 타입만 추가됨
3. 기존 6가지 PathType은 변경 없음

### **새로운 씬 생성**
```gdscript
# 새로운 커스텀 경로 씬 생성
1. `enemy_path.tscn` 복사 → `enemy_path_custom.tscn`
2. PathFollow2D 설정 변경
3. 새 이름으로 저장 후 사용
```

---

## 🎯 성능 최적화

### **1. 포인트 수 제한**
- 권장: 3-5개 포인트
- 최대: 10개 포인트 (성능 저하 가능)

### **2. 곡선 타입 선택**
- `LINEAR`: 가장 가볍고 빠름
- `BEZIER`: 중간 성능
- `SPLINE`: 가장 무거움 (많은 포인트 시 성능 저하)

### **3. 시간 계산 최적화**
```gdscript
# 비효율적: 매 프레임 계산
var progress = elapsed_time / move_duration

# 효율적: 캐싱 사용
var segment_duration = point_durations[current_segment]  # 한 번만 계산
```

---

## 📞 문제 해결

### **Q1. 적이 움직이지 않아요**
- `path_type`이 `CUSTOM_POINTS`로 설정되었는지 확인
- `custom_points` 배열이 비어있지 않은지 확인
- `move_duration`이 0보다 큰지 확인

### **Q2. 좌표가 이상해요**
- 화면 해상도 기준 좌표 확인 (기본: 1280x720)
- `is_mirrored` 플래그 확인 (좌우 반전)
- 퇴장 좌표가 `-100` 이하인지 확인

### **Q3. 곡선이 매끄럽지 않아요**
- `curve_type`을 `BEZIER`나 `SPLINE`으로 변경
- 더 많은 포인트 추가
- `point_durations` 시간 조정

---

**작성일**: 2026-01-25  
**버전**: 1.0.0  
**호환성**: Godot 4.x, 기존 시스템과 완전 호환