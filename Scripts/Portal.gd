extends Viewport


onready var player = get_tree().get_root().find_node("Player", true, false)
onready var player_camera = player.get_node("RotationHelper/Camera")

onready var drag_ray = player.get_node("RotationHelper/DragRay")
onready var drag_point = player.get_node("RotationHelper/DragRay/DragPoint")

onready var portal_plane = $"PortalPlane"
onready var portal_area = $"PortalPlane/PortalArea"
onready var portal_dummy = $"PortalPlane/PortalDummy"

onready var portal_target = $"PortalTarget"
onready var portal_camera = $"PortalTarget/PortalCamera"


func _ready():
	portal_area.connect("body_entered", self, "_on_body_entered")
	


func _process(_delta):
	# Orient camera in space
	portal_dummy.global_transform.origin = player_camera.global_transform.origin
	portal_dummy.global_transform.basis = player_camera.global_transform.basis
	portal_camera.transform.origin = portal_dummy.transform.origin
	portal_camera.transform.basis = portal_dummy.transform.basis
	
	
func _on_body_entered(body):
	if body.name == "Player":
		
		var player_displacement = portal_plane.global_transform.origin - player.global_transform.origin
		
		player.global_transform.origin = portal_target.global_transform.origin - player_displacement
		player.global_transform.basis = Basis(Vector3.UP, portal_camera.global_transform.basis.get_euler().y)
		
		if drag_ray.dragged_object != null:
			drag_ray.dragged_object.global_transform.origin = drag_point.global_transform.origin
	elif body is RigidBody:
		
		var body_displacement = portal_plane.global_transform.origin - body.global_transform.origin
		
		body.global_transform.origin = portal_target.global_transform.origin - body_displacement
		body.global_transform.basis = Basis(Vector3.UP, portal_camera.global_transform.basis.get_euler().y)
