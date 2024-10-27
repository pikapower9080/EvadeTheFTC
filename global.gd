extends Node

var game_speed:int = 30
var money = 15090000000

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	return res

func play_sound(resource):
	var audio = AudioStreamPlayer.new()
	audio.stream = resource
	add_child(audio)
	audio.play()
	audio.connect("finished", audio.queue_free)
