extends RayCast

"""
Interact with Colliders
Interactable object must have interact() method
"""


func _ready():
	add_exception(get_tree().get_root().find_node("Player", true, false))


func _input(_event):
	# Interacting
	if Input.is_action_just_pressed("interact"):
		var body = get_collider()
		if body && body.has_method("interact"):
			body.interact()
