extends Node2D

@onready var Jimmy = $Jimmy
@onready var AudioManager = $Audio

var ftc = preload("res://ftc.tscn")
var turbotax = preload("res://turbotax.tscn")

var jump_power = 260
var gravity = 300

var sounds_welcome = [load("res://Sounds/character_jimmy_howdy_how_ya_doin_1.mp3"), load("res://Sounds/character_jimmy_greetings_friend_1.mp3")]
var sounds_jump = [load("res://Sounds/character_jimmy_jump_2.mp3"), load("res://Sounds/character_jimmy_woah_1.mp3")]
var sounds_collect = [load("res://Sounds/character_jimmy_awesome_1.mp3"), load("res://Sounds/character_jimmy_i_like_cheese_1.mp3"), load("res://Sounds/character_jimmy_i_like_cheese_2.mp3")]
var sounds_hit = [load("res://Sounds/character_jimmy_no_2.mp3"), load("res://Sounds/character_jimmy_what_1.mp3")]
var sound_gameover = load("res://Sounds/Spongebob-Fail-Sound-Effect-.mp3")

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

func play_sound(resource):
	var audio = AudioStreamPlayer.new()
	audio.stream = resource
	AudioManager.add_child(audio)
	audio.play()
	audio.connect("finished", audio.queue_free)

func random_from(array):
	return array[randi_range(0, array.size() - 1)]

func spawn_enemy():
	var enemy = ftc.instantiate()
	enemy.position = Vector2(760, 569)
	add_child(enemy)

func spawn_pickup():
	var pickup = turbotax.instantiate()
	pickup.position = Vector2(880, randi_range(200, 400))
	add_child(pickup)

func start_game():
	print("Game started")
	play_sound(sounds_welcome[randi_range(0, sounds_welcome.size() - 1)])
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
		play_sound(sounds_jump[randi_range(0, sounds_jump.size() - 1)])
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
			play_sound(random_from(sounds_collect))
			area.queue_free()
		"FTC":
			play_sound(random_from(sounds_hit))
			area.queue_free()

func _on_story_ok_button_pressed():
	if (introState == STORY):
		$Control/Story/RichTextLabel.text = "Jump over the FTC logo to avoid taking responsibility for your actions.\n\nYou'll also want to collect customer's credit cards which will help you lobby the government for regulation that favors your dystopian ideal of American society."
		$Control/Story/StoryOkButton.text = "Let's go!"
		introState = TUTORIAL
	else:
		$Control/Story.queue_free()
		start_game()
