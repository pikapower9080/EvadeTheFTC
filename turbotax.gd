extends Area2D

@onready var Sprite = $Sprite2D
@export var type = "TURBOTAX"

func _process(delta):
	position += Vector2(-_g.game_speed * delta, 0)
	if (position.x < -180):
		queue_free()
