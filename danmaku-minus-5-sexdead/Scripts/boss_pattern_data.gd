extends Resource
class_name BulletPatternData

@export var texture: Texture2D
@export var collision_shape: Shape2D
@export var speed: float = 300.0
@export var fire_rate: float = 0.1   # 발사 속도
@export var rotate_speed: float = 0.1# 회전 속도
@export_range(0, 2*PI) var alpha: float = 0.0 # 시작 보정 각도
