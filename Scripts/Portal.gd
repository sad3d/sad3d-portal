extends Viewport


onready var player = get_tree().get_root().find_node("Player", true, false)
onready var player_camera = player.get_node("RotationHelper/Camera")

onready var drag_ray = player.get_node("RotationHelper/DragRay")
onready var drag_point = player.get_node("RotationHelper/DragRay/DragPoint")

onready var portal_plane = $"PortalPlane"
onready var portal_area = $"PortalPlane/PortalArea"
onready var portal_camera_dummy = $"PortalPlane/PortalCameraDummy"
onready var portal_player_dummy = $"PortalPlane/PortalPlayerDummy"

onready var portal_target = $"PortalTarget"
onready var portal_camera = $"PortalTarget/PortalCamera"

var player_distance
export var max_render_distance = 50.0

export (NodePath) var portal_pair
var portal_pair_node


func _ready():
	portal_area.connect("body_entered", self, "_on_body_entered")
	portal_pair_node = get_node(portal_pair)
	


func _process(_delta):
	# Orient camera and in space
	portal_camera_dummy.global_transform.origin = player_camera.global_transform.origin
	portal_camera_dummy.global_transform.basis = player_camera.global_transform.basis
	portal_camera.transform.origin = portal_camera_dummy.transform.origin
	portal_camera.transform.basis = portal_camera_dummy.transform.basis
	
	portal_player_dummy.global_transform.origin = player.global_transform.origin
	portal_player_dummy.global_transform.basis = player.global_transform.basis
	
	# Check distance to player, do not render if far
	player_distance = portal_plane.global_transform.origin.distance_to(player.global_transform.origin)
	
	if player_distance >= max_render_distance:
		render_target_update_mode = Viewport.UPDATE_DISABLED
	else:
		render_target_update_mode = Viewport.UPDATE_WHEN_VISIBLE
		
	# Set clipping plane for PortalCamera
	portal_camera.near = player_distance
	if player_distance < 0.1:
		portal_camera.near = 0.05
	else:
		portal_camera.near = player_distance
	
	
func _on_body_entered(body):
	if body.name == "Player":
		
		var player_displacement = portal_player_dummy.global_transform.origin - portal_plane.global_transform.origin
		
		if portal_plane.global_transform.basis.z.dot(-player_displacement) > 0:
		
			player.global_transform.origin = portal_target.global_transform.origin + player_displacement
			player.global_transform.basis = Basis(Vector3.UP, portal_camera.global_transform.basis.get_euler().y)
		
	elif body is RigidBody:

		var body_displacement = portal_plane.global_transform.origin - body.global_transform.origin
		body.global_transform.origin = portal_target.global_transform.origin - body_displacement
