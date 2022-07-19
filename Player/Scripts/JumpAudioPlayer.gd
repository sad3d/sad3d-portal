extends AudioStreamPlayer3D


onready var player = $"../.."
onready var ceiling_ray = $"../../CeilingRay"

export var is_playing = true
export(Array, AudioStream) var jump_sounds
var is_jumping = false


func _input(_event):
	if is_playing:
		
		if Input.is_action_just_pressed("jump"):
			if player.is_close_to_floor && !player.is_crouching && !player.is_flying && !ceiling_ray.is_colliding():
				set_stream(jump_sounds[randi() % jump_sounds.size()])
				set_pitch_scale(rand_range(0.9, 1.1))
				play()
				is_jumping = true
