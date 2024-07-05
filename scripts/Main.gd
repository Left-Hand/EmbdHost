extends Node

#onready var _serial: OfSerial = $OfSerial
onready var _data_line: LineEdit = $DataContainer/DataLine
onready var _terminal: TextEdit = $Terminal
onready var _hexa: CheckButton = $DataContainer/Hexa

var ld14:LD14 = LD14.new()

func _ready() -> void:
	var list: Array = _serial.get_device_list()
	print(list)
	_serial.begin(list[0], 115200)
	_serial.flush()


func _input(event:InputEvent):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER:
			_on_SendData_pressed()

var last_dir:Vector2 = Vector2.ZERO
var last_face:Vector2 = Vector2.ZERO

func println(ss:String) -> void:
	_serial.print(ss)
	_serial.print("\r\n")
	prints("->", ss)

func update_velocity(dir:Vector2) -> void:
	if last_dir != dir:
		last_dir = dir
		println("V " + str(dir.x)+" "+ str(dir.y))

func update_face(face:Vector2) -> void:
	if last_face != face:
		last_face = face
		println("F " + str(face.x)+" "+ str(face.y))

var t:float = 0
func _process(_delta):
	t += _delta
#	update_velocity(Vector2(0.1, 0).rotated(t))
	if(_serial.available()):
		var recv:String = ""
		while _serial.available():
			recv += char(_serial.read())

		var tokens:PoolStringArray = recv.split("\r\n")
		var validTokens: PoolStringArray = []

		for token in tokens:
			if token.strip_edges() != "" and ord(token[0]) <= 127:
				validTokens.append(token)

		for token in validTokens:
			if(token):
				prints("<-", token)
	
	var dir:Vector2 = Vector2.ZERO

	if(Input.is_action_pressed("ui_right")):
		dir.y = 1
	elif(Input.is_action_pressed("ui_left")):
		dir.y = -1
	else:
		dir.y = 0
	
	if(Input.is_action_pressed("ui_up")):
		dir.x = -1
	elif(Input.is_action_pressed("ui_down")):
		dir.x = 1
	else:
		dir.x = 0

	var face:Vector2 = Vector2.ZERO

	if(Input.is_action_pressed("ui_w")):
		face.y = 0.5
	elif(Input.is_action_pressed("ui_s")):
		face.y = -0.5
	else:
		face.y = 0
	
	if(Input.is_action_pressed("ui_a")):
		face.x = -0.1
	elif(Input.is_action_pressed("ui_d")):
		face.x = 0.1
	else:
		face.x = 0

	update_velocity(dir)
	update_face(face)
	var points:PoolVector2Array = [
		Vector2.ZERO, Vector2.RIGHT, Vector2(1,1), Vector2(0,1), Vector2(0.5, 0.5)
	]
	
	var _t:float = t * 3
	var p0:Vector2 = points[int(_t) % points.size()]
	var p1:Vector2 = points[(int(_t) + 1) % points.size()]
#	update_face((0.2 * lerp(p0, p1, _t - floor(_t)) + Vector2(0, -0.2)))
#	update_face(Vector2(cos(_t*3), sin(_t*4))*0.1 + Vector2(0, -0.2))

func _on_SendData_pressed():
	prints("->", _data_line.text)
	_serial.print(_data_line.text)
	_serial.print("\r\n")
