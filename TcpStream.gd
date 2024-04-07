extends Node

class_name TcpStream


var host:String = "192.168.6.22"
var port:int = 80

var connected:bool = false
var disconnected_time:float = 0.0
const reconnect_timeout:float = 3.0

signal connected
signal recv
signal disconnected
signal error

var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()


func _ready() -> void:
	_status = _stream.get_status()

func connect_stream() -> void:
	connect_to_host(host, port)

func _init(parent:Node):
	parent.add_child(self)


func _exit_tree() -> void:
	disconnect_from_host()

func connect_to_host(host: String, port: int) -> void:
	report_info("connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		report_err("failed to connect to host.")
		emit_signal("error")


func report_err(text:String):
	prints("[TCP]",text)


func report_info(text:String):
	prints("[TCP]", text)


func _connect_after_timeout(timeout: float) -> void:
	report_info("trying to reconnect")
	yield(get_tree().create_timer(timeout), "timeout")
	connect_to_host(host, port)

func _handle_client_connected() -> void:
	connected = true
	_stream.set_no_delay(true)

func _handle_client_data(data: PoolByteArray) -> void:
	var message: PoolByteArray = [97, 99, 107]
	write(message)


func _handle_client_disconnected() -> void:
	connected = false
	_connect_after_timeout(reconnect_timeout) # Try to reconnect after 3 seconds


func _handle_client_error() -> void:
	_connect_after_timeout(reconnect_timeout) # Try to reconnect after 3 seconds


func _physics_process(_delta: float) -> void:
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				report_info("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				report_info("Connecting to host.")
			_stream.STATUS_CONNECTED:
				_stream.set_no_delay(true)
				report_info("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				report_err("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = _stream.get_partial_data(available_bytes)
			if data[0] != OK:
				report_err("Error getting data from stream: " + str(data[0]))
				emit_signal("error")
			else:
				emit_signal("recv", data[1])


func disconnect_from_host() -> void:
	report_info("Disconnect")
	_status = _stream.STATUS_NONE
	_stream.disconnect_from_host()


func write(data: PoolByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		report_err("Stream is not currently connected.")
		return false
	var error: int = _stream.put_data(data)
	if error != OK:
		report_err("Error writing to stream: " + str(error))
		return false
	return true


func println(buf):
	match(typeof(buf)):
		TYPE_STRING:
			write(((buf as String) + "\r\n").to_ascii())
			print("[>]", buf)
			
		TYPE_RAW_ARRAY:
			write((buf as PoolByteArray))
			print("[>]", (buf as PoolByteArray).get_string_from_ascii())
