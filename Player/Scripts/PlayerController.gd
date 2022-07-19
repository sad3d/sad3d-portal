extends RigidBody


"""
HELP

F2 - hide HUD
F3 - fly mode
F7 - noclip

F5 - less mouse sensitivity
F6 - more mouse sensitivity
"""

onready var rotation_helper = $RotationHelper
onready var body_collision_shape = $BodyCollisionShape
onready var floor_ray = $FloorRay
onready var stairs_ray = $StairsRay
onready var ceiling_ray = $CeilingRay

export var is_active = true

export var mouse_sensitivity = .15
export var x_rotation_limit = 80
export var cameta_tilt_enabled = true
export var z_tilt_limit = 3
var z_tilt = 0
var y_rotation = 0

var joy_x_value = 0
var joy_y_value = 0

export var walk_speed = 30
export var run_speed = 50
var init_run_speed
export var crouch_speed = 20
export var movement_smoothness = .2

export var jump_height = 1000
export var stair_jump_height = 30
export var custom_gravity = 9.8
var gravity_helper = 0

export var hold_to_run = true
var is_running = false
export var hold_to_crouch = true
var is_crouching = false


var velocity = Vector3()
var final_velocity = Vector3()

var is_flying = false
var is_close_to_floor = false

export var enable_cheats = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	init_run_speed = run_speed
		
		
func _integrate_forces(state):
	if !is_active:
		return
	
	if is_flying:
		fly(state)
	else:
		walk(state)
		crouch(state)
	
	# Joystick rotation
	y_rotation += joy_x_value
	rotation_helper.rotation.x += joy_y_value
	rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, deg2rad(-x_rotation_limit), deg2rad(x_rotation_limit))


func _input(event):
	if !is_active:
		return
		
	# Rotation
	if event is InputEventMouseMotion:
		y_rotation += deg2rad(-event.relative.x * mouse_sensitivity * 25000)
		rotation_helper.rotation.x += deg2rad(-event.relative.y * mouse_sensitivity)
		rotation_helper.rotation.x = clamp(rotation_helper.rotation.x, deg2rad(-x_rotation_limit), deg2rad(x_rotation_limit))
		
	if event is InputEventJoypadMotion:
		if event.axis == JOY_ANALOG_RX:
			joy_x_value = deg2rad(-event.axis_value * mouse_sensitivity * 300000)
		if event.axis == JOY_ANALOG_RY:
			joy_y_value = deg2rad(-event.axis_value * mouse_sensitivity * 10)
	

		
	# Running
	if Input.is_action_just_pressed("run"):
		if !is_running:
			is_running = true
		else:
			is_running = false
	if hold_to_run && Input.is_action_just_released("run"):
		is_running = false
		
	# Crouching
	if Input.is_action_just_pressed("crouch"):
		if is_crouching && !ceiling_ray.is_colliding():
			is_crouching = false
		else:
			is_crouching = true
	if hold_to_crouch && !Input.is_action_pressed("crouch") && !ceiling_ray.is_colliding():
		is_crouching = false
		
		
	# Extra hotkeys
	if event is InputEventKey:
		
		if event.pressed:
			
			# Fly cheat
			if event.scancode == KEY_F3:
				if enable_cheats:
					is_flying = !is_flying
				
			# Mouse sensitivity
			elif event.scancode == KEY_F5:
				mouse_sensitivity -= .05
				mouse_sensitivity = clamp(mouse_sensitivity, 0, 10)
				
			elif event.scancode == KEY_F6:
				mouse_sensitivity += .05
				mouse_sensitivity = clamp(mouse_sensitivity, 0, 10)
				
			# Noclip + Fly cheat
			elif event.scancode == KEY_F7:
				if enable_cheats:
					set_collision_layer_bit(0, !get_collision_layer_bit(0))
					set_collision_mask_bit(0, !get_collision_mask_bit(0))
					set_collision_layer_bit(1, !get_collision_layer_bit(1))
					set_collision_mask_bit(1, !get_collision_mask_bit(1))
					set_collision_layer_bit(2, !get_collision_layer_bit(2))
					set_collision_mask_bit(2, !get_collision_mask_bit(2))
					if get_collision_mask_bit(0) == false:
						is_flying = true
					else:
						is_flying = false
		
	
func walk(state):
	# Tilt
	if cameta_tilt_enabled:
		tilt_camera(state)
	
	# Walk
	velocity = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		velocity -= get_global_transform().basis.z
	if Input.is_action_pressed("backward"):
		velocity += get_global_transform().basis.z
	if Input.is_action_pressed("right"):
		velocity += get_global_transform().basis.x
	if Input.is_action_pressed("left"):
		velocity -= get_global_transform().basis.x

	velocity = velocity.normalized()

	var speed
	if is_crouching:
		speed = crouch_speed
	elif is_running:
		# Corporeality effects:
		run_speed = init_run_speed + init_run_speed
		speed = run_speed
	else:
		speed = walk_speed
		
	velocity = velocity * speed
	
	# Jumping	
	if floor_ray.is_colliding():
		is_close_to_floor = true
	else:
		is_close_to_floor = false
		
	if is_close_to_floor && Input.is_action_just_pressed("jump") && !is_crouching && !ceiling_ray.is_colliding():
		velocity.y += jump_height
		is_close_to_floor = false
	
	if !is_close_to_floor:
		gravity_helper += 0.2
		gravity_helper = clamp(gravity_helper, 1, abs(linear_velocity.y) * 150)
	else:
		gravity_helper = clamp(abs(linear_velocity.length()) * 0.5, 0, 0.5)
		
	velocity += Vector3.DOWN * custom_gravity * gravity_helper

	
	# Stairs climbing
	if Input.is_action_pressed("forward") && stairs_ray.is_colliding():
		if stairs_ray.get_collision_normal().dot(Vector3.UP) > .98:
			velocity.y += stair_jump_height
			
			
	# Moving platforms
	var platform
	if platform == null && floor_ray.is_colliding():
		platform = floor_ray.get_collider()
	else:
		platform = null
		
	if platform != null && platform.is_class("RigidBody"):
		velocity += platform.linear_velocity * 6.125
		add_torque(Vector3.UP * platform.angular_velocity.y * weight * .5)
	
	# Final velocity and movement
	final_velocity = final_velocity.linear_interpolate(velocity, float(1) / movement_smoothness * state.get_step())
	add_central_force(final_velocity * weight)
	
	#Y Axis Rotation
	add_torque(Vector3.UP * y_rotation * state.get_step())
	y_rotation = 0


func fly(state):
	# Tilt
	if cameta_tilt_enabled:
		tilt_camera(state)
		
	# Fly
	velocity = Vector3.ZERO

	if Input.is_action_pressed("forward"):
		velocity -= rotation_helper.get_global_transform().basis.z
	if Input.is_action_pressed("backward"):
		velocity += rotation_helper.get_global_transform().basis.z
	if Input.is_action_pressed("right"):
		velocity += get_global_transform().basis.x
	if Input.is_action_pressed("left"):
		velocity -= get_global_transform().basis.x
	if Input.is_action_pressed("jump"):
		velocity += get_global_transform().basis.y
	if Input.is_action_pressed("crouch"):
		velocity -= get_global_transform().basis.y

	velocity = velocity.normalized()

	var speed
	
	if is_running:
		# Corporeality effects:
		run_speed = init_run_speed + init_run_speed
		speed = run_speed
	else:
		speed = walk_speed
		
	velocity = velocity * speed
	
	# Final velocity and movement
	final_velocity = final_velocity.linear_interpolate(velocity, float(1) / movement_smoothness * state.get_step())
	add_central_force(final_velocity * weight)
	
	#Y Axis Rotation
	add_torque(Vector3.UP * y_rotation * state.get_step())
	y_rotation = 0


func crouch(state):
	if is_crouching:
		body_collision_shape.shape.height = .3
		rotation_helper.translation.y = lerp(rotation_helper.translation.y, .15, 5 * state.get_step())
		floor_ray.translation.y = -.15
		stairs_ray.translation.y = .05
	else:
		body_collision_shape.shape.height = lerp(body_collision_shape.shape.height, 1.1, 5 * state.get_step())
		rotation_helper.translation.y = lerp(rotation_helper.translation.y, .75, 5 * state.get_step())
		floor_ray.translation.y = lerp(floor_ray.translation.y, -.55, 5 * state.get_step())
		stairs_ray.translation.y = lerp(stairs_ray.translation.y, -.35, 5 * state.get_step())


func tilt_camera(state):
	if Input.is_action_pressed("right"):
		z_tilt = -deg2rad(z_tilt_limit)
	elif Input.is_action_pressed("left"):
		z_tilt = deg2rad(z_tilt_limit)
	else:
		z_tilt = 0
	rotation_helper.rotation.z = lerp(rotation_helper.rotation.z, z_tilt, 5 * state.get_step())

	
func _on_Ladder_body_entered(body):
	if body.name == "Player":
		is_flying = true
	
	
func _on_Ladder_body_exited(body):
	if body.name == "Player":
		is_flying = false
	
