extends Viewport


onready var player = get_tree().get_root().find_node("Player", true, false)
onready var player_camera = player.get_node("RotationHelper/Camera")

onready var drag_ray = player.get_node("RotationHelper/DragRay")
onready var drag_point = player.get_node("RotationHelper/DragRay/DragPoint")

onready var portal_plane = $"PortalPlane"
onready var portal_area = $"PortalPlane/PortalArea"
onready var camera_dummy = $"PortalPlane/PortalCameraDummy"
onready var player_dummy = $"PortalPlane/PortalPlayerDummy"

onready var portal_target = $"PortalTarget"
onready var portal_camera = $"PortalTarget/PortalCamera"

var player_distance
var player_offset
export var max_render_distance = 50.0


func _ready():
	portal_area.connect("body_exited", self, "_on_body_exited")


func _process(_delta):
	# Orient camera in space
	camera_dummy.global_transform.origin = player_camera.global_transform.origin
	camera_dummy.global_transform.basis = player_camera.global_transform.basis
	portal_camera.transform.origin = camera_dummy.transform.origin
	portal_camera.transform.basis = camera_dummy.transform.basis
	
	player_dummy.global_transform.origin = player.global_transform.origin
	player_dummy.global_transform.basis = player.global_transform.basis
	
	# Check distance to player, do not render if far
	player_distance = portal_plane.global_transform.origin.distance_to(player.global_transform.origin)
	player_offset = player_dummy.global_transform.origin - portal_plane.global_transform.origin
	
	if player_offset.length() < 5:
		render_target_update_mode = Viewport.UPDATE_ALWAYS
	elif player_distance <= max_render_distance:
		render_target_update_mode = Viewport.UPDATE_WHEN_VISIBLE
	else:
		render_target_update_mode = Viewport.UPDATE_DISABLED
		
	# Set clipping plane for PortalCamera
	if player_distance < 2:
		portal_camera.near = 0.05
	else:
		portal_camera.near = clamp(player_distance - 2, 0.05, portal_camera.far)


func _on_body_exited(body):
	if body.name == "Player":
		
		player_offset = player_dummy.global_transform.origin - portal_plane.global_transform.origin
		
		if player_offset.dot(portal_plane.transform.basis.z) < 0:
			
			player.global_transform.origin = portal_target.global_transform.origin + player_offset
			player.global_transform.basis = Basis(Vector3.UP, portal_camera.global_transform.basis.get_euler().y)
			
			
	elif body is RigidBody:
		
		if body.linear_velocity.dot(portal_plane.transform.basis.z) < 0:
		
			var body_displacement = portal_plane.global_transform.origin - body.global_transform.origin
			body.global_transform.origin = portal_target.global_transform.origin - body_displacement
