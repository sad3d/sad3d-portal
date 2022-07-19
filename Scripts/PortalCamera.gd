extends Camera

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var player_camera = player.get_node("RotationHelper/Camera")

onready var portal_plane = $"../Portal1Plane"
onready var portal_target = $"../Portal1Target"

var plane_player_vector


func _process(delta):
	plane_player_vector = portal_plane.global_transform.origin - player_camera.global_transform.origin 
	
	global_transform.origin = portal_target.global_transform.origin - plane_player_vector
	global_transform.basis = player_camera.global_transform.basis
