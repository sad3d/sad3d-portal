extends TextureRect

"""
HELP

F10 - enable/disable pixelize effect
"""

var corp = 5
var init_size_x = 0.002
var init_size_y = 0.003
var size_x
var size_y


func _ready():
	visible = !PlayerVariables.highres
	
	size_x = init_size_x + init_size_x * 0.1 * (10 - corp)
	size_y = init_size_y + init_size_y * 0.1 * (10 - corp)
	material.set_shader_param("size_x", size_x)
	material.set_shader_param("size_y", size_y)
	
	
func _process(delta):
	corp = PlayerVariables.corporeality
	size_x = init_size_x + init_size_x * 0.1 * (10 - corp)
	size_y = init_size_y + init_size_y * 0.1 * (10 - corp)
	material.set_shader_param("size_x", size_x)
	material.set_shader_param("size_y", size_y)


func _input(event):
	
	if event is InputEventKey:
		
		if event.pressed:
			
				if event.scancode == KEY_F10:
					visible = !visible
					
				if event.scancode == KEY_O:
					corp += 1
					corp = clamp(corp, 1, 10)
					size_x = init_size_x + init_size_x * 0.1 * (10 - corp)
					size_y = init_size_y + init_size_y * 0.1 * (10 - corp)
					material.set_shader_param("size_x", size_x)
					material.set_shader_param("size_y", size_y)
					
					
				if event.scancode == KEY_I:
					corp -= 1
					corp = clamp(corp, 1, 10)
					size_x = init_size_x + init_size_x * 0.1 * (10 - corp)
					size_y = init_size_y + init_size_y * 0.1 * (10 - corp)
					material.set_shader_param("size_x", size_x)
					material.set_shader_param("size_y", size_y)
