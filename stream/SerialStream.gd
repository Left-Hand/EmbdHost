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
	var ss:String = ""
	match(typeof(buf)):
		
		TYPE_INT: 
			ss = str(buf)
			
		TYPE_STRING:
			ss = buf

		TYPE_RAW_ARRAY:
			ss = buf.get_string_from_ascii()

	if(!connected):
		if(self.enable_tx_log):
			print("[-", self.name, "]", ss)
	else:
		instance.println(ss)
		if(self.enable_tx_log):
			print("[>", self.name, "]", ss)

#func println(buf) -> void:
#	printn(buf)
#	printn("\r\n")

func _recv(ss:String) -> void:
	if(self.enable_rx_log):
		print("[<", self.name, "]", ss)

func _process_recv_data():
	var i:int = instance.available()
	if(i == 0):
		return
	
	
#	var arr:PoolByteArray = instance.read_bytes()
	var arr:PoolByteArray
	while i:
		arr.append(instance.read())
		i-=1

	if(self.enable_rx_log):
		print("[<", self.name, "]", arr.get_string_from_ascii())

	emit_signal("recv", arr)
func _process(_delta):
	if connected:
		_process_recv_data()

func _ready():
	print(get_list())
