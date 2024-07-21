extends Panel


enum METHOD{
	METHOD_NONE
	METHOD_HUI,
	METHOD_LISA,
	METHOD_GRAB,
	METHOD_REP,
	METHOD_INTE
}

var method = METHOD.METHOD_NONE setget set_method

var t:float = 0 
var reloc:bool = false

func set_method(_method):
	method = _method
#	t = -3
#	reloc = false
	match(method):
		METHOD.METHOD_NONE:
			Ctrl.send_command(["nne"])
		METHOD.METHOD_HUI:
			Ctrl.send_command(["hui"])
		METHOD.METHOD_LISA:
			Ctrl.send_command(["lisa"])
#			_pos = Vector2(Ctrl.x_range.center() + 2 * sin(_t), Ctrl.y_range.center() + 2 * cos(_t))
		METHOD.METHOD_GRAB:
			Ctrl.send_command(["grab"])
			pass
		METHOD.METHOD_REP:
			Ctrl.send_command(["rep"])
			pass
		METHOD.METHOD_INTE:
			Ctrl.send_command(["inte"])
			pass
#	changed = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#
#func _physics_process(delta):
#	if(method == METHOD.METHOD_NONE):
#		return
#	t += 1.0 /240
#	var _t:float = max(t, 0)
#	var _pos:Vector2
#
#	match(method):
#		METHOD.METHOD_HUI:
#			pass
#		METHOD.METHOD_LISA:
#			_pos = Vector2(Ctrl.x_range.center() + 2 * sin(_t), Ctrl.y_range.center() + 2 * cos(_t))
#		METHOD.METHOD_GRAB:
#			pass
#		METHOD.METHOD_REP:
#			pass
#		METHOD.METHOD_INTER:
#			pass
#
#	if(t > 0):
#		Ctrl.send_command(["xy", _pos])
#	else:
#		if(reloc == false):
#			reloc = true
#			Ctrl.send_command(["xyt", _pos])

func _on_hui_pressed():
	self.method = METHOD.METHOD_HUI

func _on_lisa_pressed():
	self.method = METHOD.METHOD_LISA


func _on_grab_pressed():
	self.method = METHOD.METHOD_GRAB


func _on_inter_pressed():
	self.method = METHOD.METHOD_INTE


func _on_replay_pressed():
	self.method = METHOD.METHOD_REP


func _on_none_pressed():
	self.method = METHOD.METHOD_NONE
