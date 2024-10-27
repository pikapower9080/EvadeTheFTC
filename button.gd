extends Button

@onready var Title = get_parent().get_node("Title")
@onready var Deluxe = get_parent().get_node("Deluxe")
@onready var Background = get_parent().get_parent().get_node("Background")
@onready var Jimmy = get_parent().get_parent().get_node("Jimmy")

signal game_started

var started = false

func _on_pressed():
	if (started): return
	started = true
	Deluxe.get_node("AnimationPlayer").active = false
	var tween = create_tween()
	tween.tween_property(Title, "position", Vector2(Title.position.x, -Title.size.y), 1.5).set_trans(Tween.TRANS_QUINT)
	tween.parallel().tween_property(Deluxe, "scale", Vector2(0, 0), 1.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position", Vector2(position.x, 400 + size.y), 1).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_g, "game_speed", 50, 1.8)
	tween.parallel().tween_property(Jimmy, "position", Vector2(Jimmy.position.x, 0), 1.8)
	tween.tween_callback(func():
		Deluxe.queue_free()
		game_started.emit()
		)
