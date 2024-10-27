extends TextureRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position -= Vector2(_g.game_speed * delta, 0)
	if (position.x <= -400):
		position = Vector2(0, 0)
