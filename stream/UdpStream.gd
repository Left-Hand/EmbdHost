extends Node

class_name UdpStream

var instance := UDPServer.new()
var peer:PacketPeerUDP = null
var port:int = 12345
var to_send_list:Array = []


func _ready():
#	instance.listen(12345)
#	connect_stream()
	pass

func _init(parent:Node):
	parent.add_child(self)

func connect_stream():
	print(port)
	instance.listen(port)


func connect_to_host(_host:String, _port:int) -> void:
	port = _port


func write(data: PoolByteArray) -> bool:
#	var error: int = _stream.put_data(data)
	return bool(peer.put_packet(data))

func _println(buf):
	match(typeof(buf)):
		TYPE_STRING:
			write(((buf as String) + "\r\n").to_ascii())
			print("[UDP>]", buf)
			
		TYPE_RAW_ARRAY:
			write((buf as PoolByteArray))
			print("[UDP>]", (buf as PoolByteArray).get_string_from_ascii())

func println(ss):
	to_send_list.append(ss);

func _parse_packet(_peer:PacketPeerUDP):
	var pkt:PoolByteArray = _peer.get_packet()
	var recv:String =  pkt.get_string_from_ascii().strip_edges()
	if(recv):
		print("[UDP<]", recv)
		get_node("/root/EspCamera/ColorRect").note()
	
func _process(delta):
	instance.poll()
	if instance.is_connection_available():
		var _peer : = instance.take_connection()
		peer = _peer

	if(peer != null):
		_parse_packet(peer)
		if(to_send_list):
			_println(to_send_list.pop_back())
