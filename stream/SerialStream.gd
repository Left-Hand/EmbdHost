extends "Stream.gd"

class_name SerialStream 

const OfSerial = preload("res://addons/GDOfSerial/GDOfSerial.gdns")
onready var instance := OfSerial.new()

signal recv

var _temp_str:String

func _init(parent:Node):
	parent.add_child(self)

func get_list() -> Array:
	return instance.get_device_list()

func connect_stream(com:String, baud:int) -> bool:
	var m_list: Array = get_list()
	
	if(m_list and m_list.has(com)):
		instance.begin(com, baud)
		instance.flush()
		connected = true
	else:
		connected = false
	return connected

func println(buf) -> void:
	if(!connected):
		return

	var ss:String = ""
	match(typeof(buf)):
		
		TYPE_INT: 
			ss = str(buf)
			
		TYPE_STRING:
			ss = buf

		TYPE_RAW_ARRAY:
			ss = buf.get_string_from_ascii()

	instance.print(ss)
	instance.print("\r\n")
	if(self.enable_tx_log):
		print("[>", self.name, "]", ss)

func _recv(ss:String) -> void:
	if(self.enable_rx_log):
		print("[<", self.name, "]", ss)

func _process_recv_data():
	var i:int = instance.available()
	while i:
		emit_signal("recv", instance.read())
		i-=1

func _process(_delta):
	if connected:
		_process_recv_data()

func _ready():
	print(get_list())
