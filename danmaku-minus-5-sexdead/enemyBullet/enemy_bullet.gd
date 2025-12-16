extends Node2D

var speed = 600
var player_pos
var can_shoot = true
var move_to
@onready var player = get_tree().get_first_node_in_group("player") # player 가져오기

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
