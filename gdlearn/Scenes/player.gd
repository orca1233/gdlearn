extends CharacterBody2D
@export var speed:= 500.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(100, 100)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
