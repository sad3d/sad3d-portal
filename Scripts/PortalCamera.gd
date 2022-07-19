extends Camera

onready var player = get_tree().get_root().find_node("Player", true, false)
onready var player_camera = player.get_node("RotationHelper/Camera")

onready var portal_plane = $"../../Portal1Plane"
onready var portal_target = $".."

onready var portal_dummy = $"../../Portal1Plane/Spatial"

var plane_player_vector
var player_direction

var init_transform

func _ready():
	init_transform = portal_target.global_transform
	global_transform.origin = init_transform.origin
	global_transform.basis = init_transform.basis
	

func _process(delta):
	portal_dummy.global_transform.origin = player_camera.global_transform.origin
	portal_dummy.global_transform.basis = player_camera.global_transform.basis
	plane_player_vector = portal_plane.global_transform.origin - player_camera.global_transform.origin 
	
#	transform.origin = init_transform.origin - plane_player_vector
#	global_transform.basis = init_transform.basis * player_camera.global_transform.basis
	transform.origin = portal_dummy.transform.origin
	transform.basis = portal_dummy.transform.basis
