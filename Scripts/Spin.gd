extends Position3D


export var speed = 1.0

func _process(delta):
	rotate(Vector3.UP, speed * delta)
