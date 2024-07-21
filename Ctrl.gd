extends Node

const commands:Dictionary = {
	"xp":"XP %.2f",
	"yp":"YP %.2f",
	"zp":"ZP %.2f",
	"xt":"XT %.2f",
	"yt":"YT %.2f",
	"zt":"ZT %.2f",
	"xc":"XC %.2f",
	"yc":"YC %.2f",
	"zc":"ZC %.2f",
	"x":"X %.2f",
	"y":"Y %.2f",
	"z":"Z %.2f",

	"xyp":"XY %.3f %.3f",
	"xy":"XY %.3f %.3f",
	"xyzp":"XYZP %.3f %.3f %.3f",
	"xyz":"XYZ %.3f %.3f %.3f",
	"dxy":"DXY %.3f %.3f",
	"dxyz":"DXYZ %.3f %.3f %.3f",
#	"dx":"DX %.3f",
#	"dy":"DY %.3f",
#	"dz":"DZ %.3f",
#	"dxy":"DXY %.3f %.3f",
#	"dxyz":"DXYZ %.3f %.3f, %.3f",
}

onready var command_stream: SerialStream = SerialStream.new(self)
onready var logger_stream: SerialStream = SerialStream.new(self)
onready var camera_stream: SerialStream = SerialStream.new(self)

onready var stepper_x = Stepper.new(command_stream, 'x')
onready var stepper_y = Stepper.new(command_stream, 'y')
onready var stepper_z = Stepper.new(command_stream, 'z')
onready var stepper_w = Stepper.new(command_stream, 'w')

onready var steppers:Dictionary = {'x':stepper_x, 'y':stepper_y, 'z':stepper_z, 'w':stepper_w}

signal rx_data(buf)
signal hp_notified(hp)

var coord_stable:bool = true
var relative_mode:bool = true

var targ_pos:Vector3 = Vector3.ZERO setget set_targ_pos
var targ_spd:Vector2 = Vector2.ZERO setget set_targ_spd
var ret_pos:Vector3 = Vector3.ZERO

var x_range = Rangef.new(0, 8)
var y_range = Rangef.new(0, 5)
var z_range = Rangef.new(0, 25)

const xy_ratio = 20 * 2
const z_ratio = 2

var max_spd:float = 1
var delta_per_frame:float = 1.0/240
var time_per_frame:float = 1.0/240
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
	send_command(['xyz', vector])

func drag_xyz(vector:Vector3):
	send_command(['dxyz', vector])

func move_xy(vector:Vector2):
	send_command(['xy', vector])

func move_xyt(vector:Vector2):
	stepper_x.set_trapezoid(vector.x)
	stepper_y.set_trapezoid(vector.y)	

func drag_xy(vector:Vector2):
	send_command(['dxy', vector])

func move_z(z:float):
	send_command(["z", z])

func set_targ_pos(val:Vector3):	
	targ_pos = val
	if(!coord_stable):
		return

	targ_pos.x = x_range.sat(targ_pos.x)
	targ_pos.y = y_range.sat(targ_pos.y)
	targ_pos.z = z_range.sat(targ_pos.z)

	move_xyz(val)

func set_targ_spd(val:Vector2):	
	targ_spd = val
	if(!coord_stable):
		return

	drag_xy(val)

func xy_input(vector:Vector2):
	if(relative_mode):
		var targ_pos_xy:Vector2 = Vector2(targ_pos.x, targ_pos.y)
		targ_pos_xy += vector * delta_per_frame
		targ_pos = Vector3(targ_pos_xy.x, targ_pos_xy.y, targ_pos.z)
		var spd:Vector2 = vector;
		self.targ_spd = spd;
	else:
		self.targ_pos = Vector3(vector.x, vector.y, targ_pos.z)


func xyz_input(vector:Vector3):
	if(relative_mode):
		self.targ_pos = targ_pos + vector * delta_per_frame
	else:
		self.targ_pos = vector

func z_input(z:float):
	if(!relative_mode):
		self.targ_pos = Vector3(targ_pos.x, targ_pos.y, lerp(z_range.from, z_range.to, inverse_lerp(z, -1, 1)))
	else:
		self.targ_pos = Vector3(targ_pos.x, targ_pos.y, clamp(targ_pos.z + z * delta_per_frame, z_range.from, z_range.to))

func left_joystick_tap(vector:Vector2):
	pass

func left_joystick_drag(vector:Vector2):
	xy_input(vector)

func left_joystick_sustain(vector:Vector2):
	xy_input(vector)

func left_joystick_release(vector:Vector2):
	pass

func right_joystick_drag(vector:Vector2):
	z_input(-vector.y)
	pass


func right_joystick_tap(vector:Vector2):
	pass

func right_joystick_sustain(vector:Vector2):
	z_input(-vector.y)

func right_joystick_release(_vector:Vector2):
#	toward_vector_target = Vector2(0,0)
	pass

func _ready():
	camera_stream.connect_stream("COM17", 921600)
	camera_stream.name = "C"#usbfs
	
	command_stream.connect_stream("COM15", 115200)
	command_stream.name = "B"#ble
	
	logger_stream.connect_stream("COM6", 115200 * 8)
	logger_stream.name = "L"#link
	

	
	command_stream.enable_tx_log = true
	command_stream.enable_rx_log = true
	logger_stream.enable_tx_log = true

func _physics_process(_delta):
	pass


func _process(_delta):
	pass

func reset():
	send_command(["rst"])

func cali():
	send_command(["cali"])

func home():
	steppers.x.set_current(-0.7)
	steppers.y.set_current(-0.7)
	steppers.z.set_current(-0.5)

func prepare():
	steppers.x.set_home(0)
	steppers.y.set_home(0)
	steppers.z.set_home(0)
	steppers.x.set_trapezoid(x_range.center())
	steppers.y.set_trapezoid(y_range.center())
	steppers.z.set_trapezoid(z_range.center())
	
	targ_pos = Vector3(x_range.center(), y_range.center(), z_range.center())

func save():
	pass

func open():
	pass
