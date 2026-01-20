# boss_pattern_data.gd
extends Resource
class_name BulletPatternData

enum ShootType { SPIRAL, SPREAD, CIRCLE_BURST }
enum MoveType { LINEAR, ACCELERATE, CURVE, HOMING, STOP_AND_CHANGE }

@export_group("Base Info")
@export var pattern_type: ShootType = ShootType.SPIRAL
@export var texture: Texture2D
@export var collision_shape: Shape2D
@export var sprite_rotation: float = 0.0

@export_group("Movement")
@export var move_type: MoveType = MoveType.LINEAR
@export var speed: float = 300.0
@export var speed_variance: float = 0.0 # 산탄용: 총알마다 속도가 얼마나 다를지 (0~100 등)

## ACCELERATE 타입용
@export var acceleration: float = 50.0  # 가속도 (양수: 가속, 음수: 감속)

## CURVE 타입용
@export var curve_amplitude: float = 50.0  # 곡선 진폭 (얼마나 휘는지)
@export var curve_frequency: float = 2.0   # 곡선 주파수 (얼마나 자주 휘는지)

## HOMING 타입용
@export var homing_strength: float = 100.0  # 유도 강도
@export var homing_duration: float = 2.0    # 유도 지속 시간 (초)

## STOP_AND_CHANGE 타입용
@export var stop_time: float = 0.5          # 정지 시간 (초)
@export var stop_trigger_time: float = 1.0  # 몇 초 후에 정지할지
@export var change_angle: float = 180.0     # 방향 전환 각도 (도)

@export_group("Firing")
@export var fire_rate: float = 0.1
@export var bullet_count: int = 1      # 한 번에 쏘는 발수
@export var spread_angle: float = 45.0 # 산탄/원형의 각도 범위
@export var is_aimed: bool = false

@export_group("Rotation")
@export var rotate_speed: float = 0.1
@export var alpha: float = 0.0        # 시작 보정 각도

@export_group("Position")
@export var spawn_offset: Vector2 = Vector2.ZERO # 보스 기준 생성 위치 (예: 오른쪽은 50, 0)

@export_group("Burst Settings")
@export var burst_time: float = 3.0 # 몇 초 동안 발사
@export var rest_time: float = 2.0  # 몇 초 동안 휴식
@export var use_burst: bool = false # 이 기능을 쓸지 말지 결정
