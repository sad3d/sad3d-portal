extends RigidBody


export var can_rotate_freely = false
export var can_collide_with_player = false
export var is_heavy = false

export var hint = ""

var is_dragged = false


func start_drag():
	is_dragged = true
	
	
func end_drag():
	is_dragged = false
