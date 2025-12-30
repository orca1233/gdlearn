extends Node

# Enemy class for managing enemy behavior

var health: int = 100
var speed: float = 200.0

func _ready():
    # Initialize enemy properties
    pass

func _process(delta: float):
    # Update enemy position
    move_enemy(delta)

func move_enemy(delta: float):
    # Logic to move the enemy
    position += Vector2(speed * delta, 0)

func take_damage(amount: int):
    health -= amount
    if health <= 0:
        die()

func die():
    # Logic for enemy death
    queue_free()