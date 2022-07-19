extends Node

# Settings
var highres = true

# Player Stats
var loneliness = 5 setget set_loneliness
var corporeality = 7 setget set_corporeality
var reflexion = 1 setget set_reflexion


func set_loneliness(_value):
	loneliness = _value
	loneliness = clamp(loneliness, 1, 10)
	
	
func set_corporeality(_value):
	corporeality = _value
	corporeality = clamp(corporeality, 1, 10)
	
	
func set_reflexion(_value):
	reflexion = _value
	reflexion = clamp(reflexion, 1, 10)
	
	
func reset_skills():
	loneliness = 5
	corporeality = 7
	reflexion = 1
