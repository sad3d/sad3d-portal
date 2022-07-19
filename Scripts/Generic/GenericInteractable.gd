extends Node


export var is_active = false

export var hint = ""


func _ready():
	perform()
	
	
func interact():
	is_active = !is_active
	perform()
	
	
func perform():
	if is_active:
		pass
	else:
		pass
