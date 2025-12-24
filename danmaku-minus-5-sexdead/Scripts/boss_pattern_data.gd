# boss_pattern_data.gd
extends Resource
class_name BulletPatternData

enum ShootType { SPIRAL, SPREAD, CIRCLE_BURST }

@export_group("Base Info")
@export var pattern_type: ShootType = ShootType.SPIRAL
@export var texture: Texture2D
@export var collision_shape: Shape2D

@export_group("Movement")
@export var speed: float = 300.0
@export var speed_variance: float = 0.0 # 산탄용: 총알마다 속도가 얼마나 다를지 (0~100 등)

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
