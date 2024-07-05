extends Sprite

const RADIUS = 120
const SMALL_RADIUS = 40

var stick_pos
var evt_index = -1

onready var noter_node := get_parent()
onready var center_node := $center

func set_position(position):
	stick_pos = global_position
#	print(get_global_transform().basis_xform(position), "why")
	
func vect_calculate(raw:Vector2) -> Vector2:

	var vect:Vector2 = raw / RADIUS
	if(raw.length() > RADIUS):
		vect = vect.normalized()
	return vect


func _input(event):

	if event is InputEventScreenTouch:
#		print('??')
		var displacement:Vector2 = (event.position - stick_pos)
		if event.is_pressed():
			print(event.position)
			if stick_pos.distance_to(event.position) <= RADIUS:
				evt_index = event.index
				center_node.position = displacement.limit_length(RADIUS)
				
				noter_node.tap(vect_calculate(displacement))
		elif evt_index != -1:
			if evt_index == event.index:
				evt_index = -1

				center_node.position = Vector2()
				noter_node.release(vect_calculate(displacement))
	elif event is InputEventScreenDrag and evt_index == event.index:
		var dist = stick_pos.distance_to(event.position)
		if dist + SMALL_RADIUS >  RADIUS:
			dist = RADIUS - SMALL_RADIUS
		
		var displacement:Vector2 = (event.position - stick_pos)
			
#		var ang = event.position.angle_to_point(stick_pos)
		
#		$"../".stick_vector = vect
#		$"../".stick_angle = ang
#		$"../".stick_speed = dist
		noter_node.drag(vect_calculate(displacement))
		center_node.position = displacement.normalized() * dist
	pass
