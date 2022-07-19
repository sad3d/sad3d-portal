extends Control


func _input(event):
	if event is InputEventKey:
		
		if event.pressed:
			
			# Hide HUD
			if event.scancode == KEY_F2:
				visible = !visible
