extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_pick_pressed():
	Ctrl.send_command(["mt 1"])
	Ctrl.stepper_z.set_trapezoid(26)


func _on_drop_pressed():
	Ctrl.stepper_z.set_trapezoid(20)
	Ctrl.send_command(["mt 0"])


func _on_hold_pressed():
	Ctrl.stepper_z.set_trapezoid(20)


func _on_throw_pressed():
	Ctrl.send_command(["mt 0"])
	Ctrl.stepper_z.set_trapezoid(10)
