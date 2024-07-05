extends Node

#var l_vector:Vector2
const toward_command:String = "T %.3f %.3f"
const move_command:String = "M %.3f %.3f"

#const r_tap_command:String = ' %d'
const shot_command:String = 'S %d %d'
var shot_spec:int = 2
var shot_period:int = 200

onready var stream := UdpStream.new(self)

signal rx_data(buf)
signal hp_notified(hp)

var move_vector:Vector2


var toward_vector_target:Vector2
var toward_vector_current:Vector2
var toward_max_step:float = 4


func tx_data(buf:PoolByteArray):
	pass

func send_line(ss:String):
	stream.println(ss)


func move_notify(vector:Vector2):
	send_line(move_command%[vector.y, - pow(abs(vector.x), 0.8) * sign(vector.x) * TAU])

func shot_notify():
	send_line(shot_command%[int(min(shot_period, 255)), shot_spec])

func left_joystick_drag(vector:Vector2):
	move_notify(vector)

func left_joystick_tap(vector:Vector2):
	move_notify(vector)

func left_joystick_release(_vector:Vector2):
	move_notify(Vector2(0,0))
	move_notify(Vector2(0,0))

func toward_notify(yaw_and_pitch:Vector2):
	send_line(toward_command%[yaw_and_pitch.x, yaw_and_pitch.y])


#func toward_update(delta:float):
#	if(not (toward_vector_current - toward_vector_target).length_squared() < 0.0001):
#		toward_vector_current = toward_vector_current.move_toward(toward_vector_target, toward_max_step * delta)
#		toward_notify(toward_vector_current)


func right_joystick_drag(vector:Vector2):
#	toward_vector_target = vector
	toward_notify(vector)


func right_joystick_tap(vector:Vector2):

#	toward_vector_target = vector
	shot_notify()
	toward_notify(vector)


func right_joystick_release(_vector:Vector2):
	toward_vector_target = Vector2(0,0)


func set_shot_period(period:int):
	shot_period = period


func set_shot_spec(spec:int):
	shot_spec = spec


func _ready():
	stream.connect_stream()
	pass

func _physics_process(_delta):
	pass


func _process(_delta):
#	toward_update(_delta
	pass


