extends ColorRect



var last_time:float = 0
var curr_time:float = 0

func note():
	last_time = curr_time

func _process(delta):
	curr_time += delta
	self.modulate = Color(1.0, 1.0, 1.0, clamp(1.0 - 10 * (curr_time - last_time), 0, 1))
