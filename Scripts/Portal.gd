extends Area


onready var player = get_tree().get_root().find_node("Player", true, false)
onready var drag_ray = player.get_node("RotationHelper/DragRay")
onready var drag_point = player.get_node("RotationHelper/DragRay/DragPoint")

export (NodePath) var target_point
var target_transform


func _ready():
	connect("body_entered", self, "_on_body_entered")
	target_transform = get_node(target_point).global_transform


func _on_body_entered(body):
	if body.name == "Player":
		
		var player_displacement = global_transform.origin - player.global_transform.origin
		var player_direction = global_transform.basis.get_euler().y + player.global_transform.basis.get_euler().y
		
		player.global_transform.origin = target_transform.origin - player_displacement
		player.global_transform.basis = target_transform.basis.rotated(Vector3.UP, player_direction)
		
		if drag_ray.dragged_object != null:
			drag_ray.dragged_object.global_transform.origin = drag_point.global_transform.origin
