extends Node

const commands:Dictionary = {
	"x":"X %.3f",
	"y":"X %.3f",
	"z":"Z %.3f",
	"xy":"XY %.3f %.3f",
	"xyz":"XYZ %.3f %.3f %.3f",
	"dx":"DX %.3f",
	"dy":"DY %.3f",
	"dz":"DZ %.3f",
	"dxy":"DXY %.3f %.3f",
	"dxyz":"DXYZ %.3f %.3f, %.3f",
}

onready var command_stream: SerialStream = SerialStream.new(self)
onready var camera_stream:SerialStream = SerialStream.new(self)

signal rx_data(buf)
signal hp_notified(hp)

var relative_mode:bool = true
var set_pos:Vector3 = Vector3.ZERO
var ret_pos:Vector3 = Vector3.ZERO

var max_spd:float = 1
var max_pos_delta_per_frame:float = 0.1
var max_acc:float = 1


func send_line(ss:String):
	command_stream.println(ss)

func send_command(args:Array):
	if(!args.size()):
		pass
		
	var header:String = args[0]
	if(args.size() == 1):
		command_stream.println(header)
	else:
		var paraments:Array
		for i in range(1,args.size()):
			var arg = args[i]
			match typeof(arg):
				TYPE_INT, TYPE_REAL:
					paraments.push_back(float(arg))
				TYPE_BOOL:
					paraments.push_back(float(int(arg)))
				TYPE_STRING:
#					paraments.push_back(arg)
					pass
				TYPE_VECTOR2:
					paraments.push_back(float((arg as Vector2).x))
					paraments.push_back(float((arg as Vector2).y))
				TYPE_VECTOR3:
					paraments.push_back(float((arg as Vector3).x))
					paraments.push_back(float((arg as Vector3).y))
					paraments.push_back(float((arg as Vector3).z))
		
		var format:String = commands[header]
		command_stream.println(format%paraments)

func move_xyz(vector:Vector3):
	if(relative_mode):
		set_pos += vector * max_pos_delta_per_frame
		send_command(["dxyz", set_pos])
	else:
		set_pos = vector
		send_command(["xyz", set_pos])

func move_xy(vector:Vector2):
	if(relative_mode):
		var set_pos_xy:Vector2 = Vector2(set_pos.x, set_pos.y)
		set_pos_xy += vector * max_pos_delta_per_frame
		set_pos = Vector3(set_pos_xy.x, set_pos_xy.y, set_pos.z)
		send_command(["dxy", set_pos_xy])
	else:
		set_pos = Vector3(vector.x, vector.y, set_pos.z)
		send_command(["xy", vector])

#func move_x(x:float):
#	send_command(["x", x])
#
#func move_y(y:float):
#	send_command(["y", y])

func move_z(z:float):
	send_command(["z", z])
	
func left_joystick_tap(vector:Vector2):
	pass

func left_joystick_drag(vector:Vector2):
	move_xy(vector)

func left_joystick_release(vector:Vector2):
	pass

func right_joystick_drag(vector:Vector2):
	move_z(vector.y)
	pass


func right_joystick_tap(vector:Vector2):

	pass


func right_joystick_release(_vector:Vector2):
#	toward_vector_target = Vector2(0,0)
	pass

func _ready():
#	stream.connect_stream()
	command_stream.enable_tx_log = true
	pass

func _physics_process(_delta):
	pass


func _process(_delta):
	pass


