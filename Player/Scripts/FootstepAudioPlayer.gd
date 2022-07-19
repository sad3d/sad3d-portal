extends AudioStreamPlayer3D

onready var player = $"../.."
onready var floor_ray = $"../../FloorRay"

export var is_playing = true

export(Array, AudioStream) var footstep_sounds
export var walk_period = .7
export var run_period = .5
export var crouch_period = 1.2
export var footstep_period = .7

var surface


func _ready():
	play_footstep_sound()


func play_footstep_sound():
	while is_playing:
		if !player.is_flying && player.is_close_to_floor && player.linear_velocity.length() > 1:
			
			if player.is_crouching:
				footstep_period = crouch_period
			elif player.is_running:
				footstep_period = run_period
			else:
				footstep_period = walk_period


#Attention: material dependent sounds
#			if floor_ray.is_colliding():
#				surface = floor_ray.get_collider()
#				if surface.is_in_group("Sand"):
#					print_debug("sand")
#					set_stream(footstep_sounds[randi() % 3])
#				elif surface.is_in_group("Dirt"):
#					print_debug("dirt")
#					set_stream(footstep_sounds[randi() % 3 + 3])
#				else:
#					print_debug("none")
#					set_stream(footstep_sounds[randi() % 3 + 6])
#Attention
			
			set_stream(footstep_sounds[randi() % footstep_sounds.size()])
			set_pitch_scale(rand_range(0.9, 1.1))
			
			play()
			
			yield(get_tree().create_timer(footstep_period), "timeout")
			
		else:
			yield(get_tree().create_timer(footstep_period / 4), "timeout")
