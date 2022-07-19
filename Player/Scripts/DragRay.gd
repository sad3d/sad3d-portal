extends RayCast

"""
Dragging RigidBodies
Draggable object must be Rigidbody and must have start_drag()
and optionally end_drag() functions

Draggable object can optionally have 
can_rotate_freely set to True
and
can_collide_with_player set to True
so that it can rotate and collide like a door etc.

"""


onready var drag_point = $DragPoint

export var drag_force = 400
export var max_drag_distance = 1.8
export var min_drag_distance = .8
export var hold_to_drag = false

var dragged_object = null

var init_contact_monitor
var init_max_contacts_reported
var init_linear_damp
var init_angular_damp
var init_mass


func _ready():
	add_exception(get_tree().get_root().find_node("Player", true, false))
	

func _physics_process(_delta):
	
	# Dragging
	if !is_instance_valid(dragged_object):
		dragged_object = null
		return
	
	if dragged_object != null:
		var drag_vector = drag_point.global_transform.origin - dragged_object.global_transform.origin
		
		if  drag_vector.length() > max_drag_distance * 2:
			let_go()
		else:
			if !dragged_object.get("is_heavy"):
				dragged_object.add_central_force(drag_vector * drag_force * 50 * _delta)
			else:
				dragged_object.add_central_force(Vector3(drag_vector.x, drag_vector.y * 0.5, drag_vector.z).normalized()  * drag_force * 15 * _delta)
			
			# Correct orientation
			# (If not free rotation object, e. g. a door)
			if !dragged_object.get("can_rotate_freely") && !dragged_object.get_colliding_bodies():

				dragged_object.add_torque(Vector3(
						Vector3.FORWARD.dot(dragged_object.global_transform.basis.y) * 100,
						drag_point.global_transform.basis.z.dot(dragged_object.global_transform.basis.x) * 200,
						Vector3.RIGHT.dot(dragged_object.global_transform.basis.y) * 100) * _delta)


func _input(_event):
	# Dragging objects
	if Input.is_action_just_pressed("drag"):
		if dragged_object == null && is_colliding():
			var body = get_collider()
			if body.is_class("RigidBody") && body.has_method("start_drag"):
				dragged_object = body
				drag_point.global_transform.origin = get_collision_point()
				drag_point.translation.z = clamp(drag_point.translation.z, -max_drag_distance, -min_drag_distance)
				hold()
				
		elif dragged_object != null:
			let_go()
				
	if hold_to_drag && Input.is_action_just_released("drag"):
			if dragged_object != null:
				let_go()
				
				
	# Throwing object
	if Input.is_action_just_pressed("throw"):
		if dragged_object != null:
				drag_point.global_transform.basis = global_transform.basis
				if init_mass >= 1:
					dragged_object.add_central_force(-drag_point.global_transform.basis.z * drag_force)
				else:
					dragged_object.add_central_force(-drag_point.global_transform.basis.z * drag_force * init_mass)
				let_go()
				
				
	# Bringing object closer and farther
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_UP):
		drag_point.translation.z -= 0.1
		drag_point.translation.z = clamp(drag_point.translation.z, -max_drag_distance, -min_drag_distance)
	if Input.is_mouse_button_pressed(BUTTON_WHEEL_DOWN):
		drag_point.translation.z += 0.1
		drag_point.translation.z = clamp(drag_point.translation.z, -max_drag_distance, -min_drag_distance)
		
		
	# Rotating object
	if Input.is_action_just_pressed("rotate"):
		drag_point.rotation.y += deg2rad(-45)


func hold():
	if dragged_object == null:
		return
			
	dragged_object.start_drag()
	
	drag_point.global_transform.basis = dragged_object.global_transform.basis
	
	init_contact_monitor = dragged_object.is_contact_monitor_enabled()
	init_max_contacts_reported= dragged_object.get_max_contacts_reported()
	dragged_object.set_contact_monitor(true)
	dragged_object.set_max_contacts_reported(1)
	
	init_linear_damp = dragged_object.linear_damp
	init_angular_damp = dragged_object.angular_damp
	init_mass = dragged_object.mass
	if dragged_object.get("is_heavy"):
		dragged_object.linear_damp = 1
		dragged_object.angular_damp = 1
		dragged_object.set_mass(15)
	else:
		dragged_object.linear_damp = 120
		dragged_object.angular_damp = 120
		dragged_object.set_mass(1)
	
	if(!(dragged_object.get("is_heavy") || dragged_object.get("can_collide_with_player"))):
		dragged_object.add_collision_exception_with($"../..")
		$"../../FloorRay".add_exception(dragged_object)
		$"../../StairsRay".add_exception(dragged_object)


func let_go():
	if dragged_object == null:
		return
	
	if (dragged_object.has_method("end_drag")):
		dragged_object.end_drag()
	
	dragged_object.set_contact_monitor(init_contact_monitor)
	dragged_object.set_max_contacts_reported(init_max_contacts_reported)
	
	dragged_object.linear_damp = init_linear_damp
	dragged_object.angular_damp = init_angular_damp
	dragged_object.set_mass(init_mass)
	
	if(!(dragged_object.get("is_heavy") || dragged_object.get("can_collide_with_player"))):
		dragged_object.remove_collision_exception_with($"../..")
		$"../../FloorRay".remove_exception(dragged_object)
		$"../../StairsRay".remove_exception(dragged_object)
	
	dragged_object = null
