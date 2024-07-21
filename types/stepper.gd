extends Object

class_name Stepper

var command_stream:Stream = null
var node_ascii:String 

func _init(_command_stream, _node_ascii:String):
	command_stream = _command_stream
	node_ascii = _node_ascii

func _ready():
	command_stream = Ctrl.command_stream

func set_position(val):
	command_stream.println(node_ascii + 'p' + ' ' + str(val))


func set_current(val):
	command_stream.println(node_ascii + 'c' + ' ' + str(val))


func set_trapezoid(val):
	command_stream.println(node_ascii + 't' + ' ' + str(val))


func set_speed(val):
	command_stream.println(node_ascii + 's' + ' ' + str(val))


func set_home(val):
	command_stream.println(node_ascii + 'h' + ' ' + str(val))
