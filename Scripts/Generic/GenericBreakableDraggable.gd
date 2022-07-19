extends RigidBody


onready var break_sound_player: AudioStreamPlayer3D = $BreakSoundPlayer3D

export var can_rotate_freely = false
export var can_collide_with_player = false
export var is_heavy = false

export var hint = ""

export var break_velocity = 1.0

var is_dragged = false
var is_hitting = false
var is_breaking = false

export (PackedScene) var debris_scene = null
var debris


func _ready():
	connect("body_entered", self, "_on_body_entered")
	

func start_drag():
	is_dragged = true
	
	
func end_drag():
	is_dragged = false
	

func _on_body_entered(_body):
	if !is_dragged:
		if !is_breaking:
			if linear_velocity.length() >= break_velocity:
				blow_up()
				

func blow_up():
	is_breaking = true
	
	break_sound_player.play()
	
	visible = false
	
	if !debris:
		debris = debris_scene.instance()
		get_tree().get_root().add_child(debris)
		debris.global_transform = global_transform
		debris.global_transform.basis = global_transform.basis
		
	for n in debris.get_children():
		if n.is_class("RigidBody"):
			n.linear_velocity = linear_velocity
			
	yield(break_sound_player, "finished")
	queue_free()
