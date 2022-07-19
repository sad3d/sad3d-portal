extends Area

func _ready():
	connect("body_entered", get_tree().get_root().find_node("Player", true, false), "_on_Ladder_body_entered")
	connect("body_exited", get_tree().get_root().find_node("Player", true, false), "_on_Ladder_body_exited")
