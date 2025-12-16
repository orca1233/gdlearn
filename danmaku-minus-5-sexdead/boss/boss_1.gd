extends Node2D

var bullet_scene = load("res://enemyBullet/enemyBullet.tscn")

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var b = bullet_scene.instantiate()
	b.poistion.x += 100
	add_child(b)
