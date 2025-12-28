extends Area2D

# 0: Power, 1: Score, 2:Bomb
enum ItemType { POWER = 0, SCORE = 1, BOMB = 2 }

var type: ItemType = ItemType.POWER
var value: int = 0
var speed: float = 150.0

@export_group("ItemImage")
@export var powerimage : AtlasTexture
@export var scoreimage : AtlasTexture
@export var bombimage : AtlasTexture

# 외부(enemy) 호출해서 값 정해주도록 함
# init_item(1, 1000) 을 하면 scoreitem / 1000점짜리 를 만든다는 것이 됨
func init_item(_type: ItemType, _value: int):
	type = _type
	value = _value
	
	# 외부에서 값 받아올 때 이미지도 설정 가능하도록
	if type == ItemType.POWER:
		$Sprite2D.texture = powerimage
	elif type == ItemType.SCORE:
		$Sprite2D.texture = scoreimage
	elif type == ItemType.BOMB:
		$Sprite2D.texture = bombimage

func _physics_process(delta: float) -> void:
	var current_speed = speed
	# Shift 누르면 감속
	if Input.is_action_pressed("shift"):
		current_speed = speed * 0.5
		
	position.y += current_speed * delta

# 플레이어에게 닿으면 획득하도록 로직 
func _on_body_entered(body: Node2D) -> void:
	# 메서드가 있는지 확인하고 아이템 먹으라고 지시
	if body.has_method("get_item"):
		body.get_item(type, value)
		queue_free()

# 화면 밖으로 나가면 없애기
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
