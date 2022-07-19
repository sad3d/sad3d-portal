extends ColorRect


onready var tween = $Tween


func fade_in(_color : Color, _duration : float):
	tween.interpolate_property(self, "color",
		_color * Color(1, 1, 1, 0), _color, _duration,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	
func fade_out(_color : Color, _duration : float):
	tween.interpolate_property(self, "color",
		_color, _color * Color(1, 1, 1, 0), _duration,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
