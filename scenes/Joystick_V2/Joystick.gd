extends Control


func _input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed():
			print(event.position)
#			if stick_pos.distance_to(event.position) <= RADIUS:
#				evt_index = event.index
