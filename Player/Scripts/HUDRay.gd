extends RayCast

"""
Show Hint while looking on appropriate Objects
Object must have export var string hint on it

Change Crosshair while looking on interactable
and draggable Objects
"""


onready var hint_label = $"../../HUD/Hint"
onready var crosshair = $"../../HUD/Crosshair"


func _ready():
	add_exception(get_tree().get_root().find_node("Player", true, false))
	hint_label.text = ""
	
	
func _process(_delta):
	var body = get_collider()
	if body:
		
		# Show Hint
		if body.get("hint"):
			hint_label.text = String(body.hint)
		else:
			hint_label.text = ""
			
		# Change crosshair on draggable
		if body.has_method("start_drag"):
			crosshair.rect_rotation += 500 * _delta
		else:
			crosshair.rect_rotation = 0
			
		# Change crosshair on interactable
		if body.has_method("interact"):
			crosshair.set_modulate(Color(1, 1, 1, .8))
		else:
			crosshair.set_modulate(Color(1, 1, 1, .3))
			
	else:
		hint_label.text = ""
		crosshair.set_modulate(Color(1, 1, 1, .3))
		crosshair.rect_rotation = 0
