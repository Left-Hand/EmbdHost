extends Node

class_name SerialStream

const OfSerial = preload("res://addons/GDOfSerial/GDOfSerial.gdns")
onready var instance := OfSerial.new()

var connected:bool = false
var com:String = "COM15"
var baud:int = 115200

func _init(parent:Node):
	parent.add_child(self)

func connect_stream() -> void:
	var list: Array = instance.get_device_list()
	print("serial list", list)
	if(list and list.has(com)):
		instance.begin(list[0], 115200)
		instance.flush()
		connected = true
	else:
		connected = false

func connect_to_host(_com:String, _baud:int):
	com = _com
	baud = _baud
	connect_stream()


func println(buf):
	if(!connected):
		return

	match(typeof(buf)):
		TYPE_STRING:
			instance.print(buf)
			instance.print("\r\n")
			print("[>]", buf)

		TYPE_RAW_ARRAY:
			var ss:String = buf.get_string_from_ascii()
			instance.print(ss)
			instance.print("\r\n")
			print("[>]", ss)

var temp_str:String


func process_recv_data():
	pass
	var recv_len = instance.available()
	if(recv_len):
		print("[<]", instance.read_string(instance.available()))
#		var sp:Array = instance.read_string(instance.available()).split("\r\n")
#		if(sp.size() == 1):
#			print("[<]", sp[0])
#		else:
#			for i in range(sp.size()):
#				var ss:String = sp[i]
#				if(i == sp.size() - 1):
#					remain_ss = ss
#				else:
#					print("[<]", ss)
#
#		if(sp.size()):
#			remain_ss = sp[0]
#		else:
#			remain_ss = ""
	if(instance.available()):
		var chr:int = ord(instance.read())
		if(chr == ord('\n')):
			temp_str.strip_edges()
			temp_str = ""
		else:
			temp_str += char(chr)

#        if(logger.available()){
#            char chr = logger.read();
#            if(chr == '\n'){
#                temp_str.trim();
#                auto tokens = splitString(temp_str, ' ');
#                auto argc = tokens[0][0];
#                tokens.erase(tokens.begin());
#                parseCommand(argc, tokens);
#                temp_str = "";
#            }else{
#                temp_str.concat(chr);
#            }
#        }

func _process(_delta):
	process_recv_data()


func _ready():
	connect_stream()

