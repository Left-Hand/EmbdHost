extends Sprite

const RADIUS = 120
const SMALL_RADIUS = 40

var stick_pos
var evt_index = -1

var pressed:bool = false
var last_vec:Vector2 = Vector2.ZERO

onready var noter_node := get_parent()
onready var center_node := $center

func set_position(position):
	stick_pos = global_position


func vect_calculate(raw:Vector2) -> Vector2:
	var vect:Vector2 = raw / RADIUS
	if(raw.length() > RADIUS):
		vect = vect.normalized()
	return vect


func _input(event):

	if event is InputEventScreenTouch:
		var displacement:Vector2 = (event.position - stick_pos)
		if event.is_pressed():
			if stick_pos.distance_to(event.position) <= RADIUS:
				evt_index = event.index
				center_node.position = displacement.limit_length(RADIUS)
				pressed = true
				last_vec = vect_calculate(displacement)
				noter_node.tap(last_vec)
		elif evt_index != -1:
			if evt_index == event.index:
				evt_index = -1
				pressed = false
				center_node.position = Vector2()
				last_vec = vect_calculate(displacement)
				noter_node.release(last_vec)
	elif event is InputEventScreenDrag and evt_index == event.index:
		var dist = stick_pos.distance_to(event.position)
		if dist + SMALL_RADIUS >  RADIUS:
			dist = RADIUS - SMALL_RADIUS
		pressed = true
		var displacement:Vector2 = (event.position - stick_pos)
		
		last_vec = vect_calculate(displacement)
		noter_node.drag(last_vec)
		center_node.position = displacement.normalized() * dist
	pass

func _physics_process(delta):
	if(pressed):
		noter_node.sustain(last_vec)
