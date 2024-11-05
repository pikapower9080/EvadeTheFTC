extends Node2D

@onready var Jimmy = $Jimmy

var ftc = preload("res://ftc.tscn")
var turbotax = preload("res://turbotax.tscn")

var jump_power = 300
var gravity = 280

var sounds_welcome = [load("res://Sounds/character_jimmy_howdy_how_ya_doin_1.mp3"), load("res://Sounds/character_jimmy_greetings_friend_1.mp3")]
var sounds_jump = [load("res://Sounds/character_jimmy_jump_2.mp3"), load("res://Sounds/character_jimmy_woah_1.mp3")]
var sounds_collect = [load("res://Sounds/character_jimmy_awesome_1.mp3"), load("res://Sounds/character_jimmy_i_like_cheese_1.mp3"), load("res://Sounds/character_jimmy_i_like_cheese_2.mp3")]
var sounds_hit = [load("res://Sounds/character_jimmy_no_2.mp3"), load("res://Sounds/character_jimmy_what_1.mp3")]
var sound_gameover = load("res://Sounds/Spongebob-Fail-Sound-Effect-.mp3")
var sound_okska = load("res://Sounds/okska.mp3")

enum {
	IDLE,
	RUNNING,
	JUMPING,
	FALLING
}
enum {
	STORY,
	TUTORIAL
}

var state = IDLE
var introState = STORY


func random_from(array):
	return array[randi_range(0, array.size() - 1)]

func spawn_enemy():
	var enemy = ftc.instantiate()
	enemy.position = Vector2(900, 569)
	add_child(enemy)

func spawn_pickup():
	var pickup = turbotax.instantiate()
	pickup.position = Vector2(900, randi_range(200, 400))
	add_child(pickup)

func start_game():
	print("Game started")
	_g.play_sound(sounds_welcome[randi_range(0, sounds_welcome.size() - 1)])
	state = RUNNING
	spawn_pickup()
	await get_tree().create_timer(randi_range(4, 5)).timeout
	spawn_enemy()
	create_tween().tween_property(_g, "game_speed", 330, 1000)
	while (true):
		await get_tree().create_timer(randi_range(4, 5), false).timeout
		var roll = randf()
		if (roll >= 0.5):
			spawn_enemy()
		else:
			spawn_pickup()

func _on_button_game_started():
	$Control/Story.visible = true

func _process(delta):
	if (Input.is_action_just_pressed("jump") and state == RUNNING):
		state = JUMPING
		_g.play_sound(sounds_jump[randi_range(0, sounds_jump.size() - 1)])
		await get_tree().create_timer(1.3, false).timeout
		state = FALLING
	match state:
		JUMPING:
			Jimmy.position -= Vector2(0, jump_power * delta)
		FALLING:
			Jimmy.position += Vector2(0, gravity * delta)
			if (Jimmy.position.y >= 530):
				Jimmy.position = Vector2(Jimmy.position.x, 530)
				state = RUNNING

func _on_jimmy_area_entered(area):
	match area.type:
		"TURBOTAX":
			_g.play_sound(random_from(sounds_collect))
			_g.money += 1000000000 + randi_range(0, 100000000)
			$Control/Money.text = "Money: " + _g.comma_sep(_g.money)
			area.queue_free()
		"FTC":
			_g.play_sound(random_from(sounds_hit))
			_g.money -= 2000000000 + randi_range(0, 100000000)
			$Control/Money.text = "Money: " + _g.comma_sep(_g.money)
			area.queue_free()

func _on_story_ok_button_pressed():
	if (introState == STORY):
		$Control/Story/RichTextLabel.text = "Jump over the FTC logo to avoid taking responsibility for your actions.\n\nYou'll also want to collect customer's credit cards which will help you lobby the government for regulation that favors your dystopian ideal of American society."
		$Control/Story/StoryOkButton.text = "Let's go!"
		introState = TUTORIAL
	else:
		$Control/Money.visible = true
		_g.play_sound(sound_okska)
		var tween = create_tween()
		tween.tween_property($Control/Story, "position", Vector2(0, 800), 1)
		tween.parallel().tween_property($StoryMusic, "volume_db", -45, 1)
		tween.tween_callback(func():
			$StoryMusic.playing = false
			$Control/Story.queue_free()
			start_game()
			)
