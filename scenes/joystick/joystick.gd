extends Node2D

export(int) var joy_id = 0

var stick_speed = 0
var stick_angle = 0
var stick_vector = Vector2()

var stick_speed_ant = 0
var stick_angle_ant = 0
var stick_vector_ant = Vector2()

var stick_vector_scaler = Vector2(1, -1)

signal control_signal(vector)

signal drag_signal(vector)
signal tap_signal(vector)
signal release_signal(vector)

func _ready():
	$border.set_position(global_position)
	pass

func _process(_delta):
	pass


var frame_dur:int = 10
var frames:int = 0

#func _input(event):
#	print(event);
	
func tap(vector:Vector2):
	emit_signal("tap_signal", vector * stick_vector_scaler)

func drag(vector:Vector2):
	emit_signal("drag_signal", vector * stick_vector_scaler)

func release(vector:Vector2):
	emit_signal("release_signal", vector * stick_vector_scaler)

#func _physics_process(delta):
#	frames += 1
#	if(frames % frame_dur == 0):
#		if 	stick_speed != stick_speed_ant or \
#			stick_angle != stick_angle_ant or \
#			stick_vector != stick_vector_ant:
#			stick_speed_ant = stick_speed
#			stick_angle_ant = stick_angle
#			stick_vector_ant = stick_vector
#			emit_signal("control_signal", stick_vector * stick_vector_scaler)
