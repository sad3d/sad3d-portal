extends Light


onready var audio_player = $FlashlightAudioPlayer3D

func _input(event):
	if Input.is_action_just_pressed("flashlight"):
		visible = !visible
		audio_player.play()
