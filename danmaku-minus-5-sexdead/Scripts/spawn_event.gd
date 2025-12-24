class_name SpawnEvent
extends Resource

@export var spawn_time : float
# enemy scene을 가져다 붙이는 것. 가능하다면 enemy도 resource 코드 만들고 싶은데... 그럼 PackedScene로 하면 안되나?
@export var enemy_scene : PackedScene
@export var enemy_path : PackedScene # enemy_path + path2D
@export var count : int
@export var interval : float
# 적을 반대편에도 똑같이 복사해서 소환할지 여부 (한쪽만 나오게 하고 싶을 수 있으니)
@export var isMirror : bool
