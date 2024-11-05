extends Button

@onready var Title = get_parent().get_node("Title")
@onready var Deluxe = get_parent().get_node("Deluxe")
@onready var Background = get_parent().get_parent().get_node("Background")
@onready var Jimmy = get_parent().get_parent().get_node("Jimmy")
@onready var Story = get_parent().get_parent().get_node("Control/Story")
@onready var MenuMusic = get_parent().get_parent().get_node("MenuMusic")
@onready var StoryMusic = get_parent().get_parent().get_node("StoryMusic")

signal game_started

var started = false
var sound_stone_slide = [load("res://Sounds/stone-sliding.wav"), load("res://Sounds/stone-sliding-2.wav")]
var sound_slip = load("res://Sounds/cartoon-slipping.mp3")
var sound_button = load("res://Sounds/select.wav")

func _on_pressed():
	if (started): return
	started = true
	_g.play_sound(sound_button, -5)
	Deluxe.get_node("AnimationPlayer").active = false
	var tween = create_tween()
	tween.tween_property(Title, "position", Vector2(Title.position.x, -Title.size.y), 1.5).set_trans(Tween.TRANS_QUINT)
	tween.parallel().tween_property(Deluxe, "scale", Vector2(0, 0), 1.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "position", Vector2(position.x, 800 + size.y), 2.21).set_trans(Tween.TRANS_BACK)
	tween.tween_property(_g, "game_speed", 100, 1.8)
	tween.parallel().tween_property(MenuMusic, "volume_db", -45, 1)
	tween.parallel().tween_property(Jimmy, "position", Vector2(Jimmy.position.x, 530), 1.305)
	tween.parallel().tween_callback(func():
		_g.play_sound(sound_stone_slide[0])
		)
	tween.tween_property(Story, "position", Vector2(0, 0), 1.250)
	tween.parallel().tween_callback(func():
		_g.play_sound(sound_stone_slide[1])
		StoryMusic.playing = true
		)
	tween.parallel().tween_property(StoryMusic, "volume_db", 0, 1)
	tween.tween_callback(func():
		MenuMusic.playing = false
		Deluxe.queue_free()
		game_started.emit()
		)
