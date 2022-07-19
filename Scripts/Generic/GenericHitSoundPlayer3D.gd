extends AudioStreamPlayer3D


#HitSoundPlayer3D must be an immediate child of RigidBody
onready var rigidbody: RigidBody = $".."
onready var init_pitch = pitch_scale

export (Array, AudioStream) var hit_sounds

var is_hitting = false


func _ready():
	rigidbody.connect("body_entered", self, "_on_body_entered")

func _on_body_entered(_body):
	if !is_hitting && rigidbody.linear_velocity.length() > 0.1:
		is_hitting = true
		
		# Play hit sound
		if hit_sounds.size() > 0:
			set_stream(hit_sounds[randi() % hit_sounds.size()])
			set_pitch_scale(rand_range(init_pitch * 0.9, init_pitch * 1.1))
			unit_size = clamp(rigidbody.linear_velocity.length() / 15, 0, .4)
			play()
		
		yield(get_tree().create_timer(0.1), "timeout")
		is_hitting = false
