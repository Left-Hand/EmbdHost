extends Node

var host:String = "192.168.6.22"
var port:int = 80

var connected:bool = false
var disconnected_time:float = 0.0

const reconnect_timeout:float = 3.0

var halttime:int = 0
var err_str:String = ""
var info_str:String = ""

var callbacks:Dictionary = {}

signal app_data

func _ready() -> void:

	TcpClient.connect("connected", self, "_handle_client_connected")
	TcpClient.connect("disconnected", self, "_handle_client_disconnected")
	TcpClient.connect("error", self, "_handle_client_error")
	TcpClient.connect("data", self, "_handle_client_data")
	TcpClient.connect_to_host(host, port)

func _exit_tree() -> void:
	TcpClient.disconnect_from_host()
	
func report_err(text:String):
	err_str = text
	prints("error:",text)


func report_info(text:String):
	info_str = text
	prints("info:", text)


func _connect_after_timeout(timeout: float) -> void:
	report_info("trying to reconnect")
	yield(get_tree().create_timer(timeout), "timeout")
	TcpClient.connect_to_host(host, port)

func _handle_client_connected() -> void:
	connected = true
	TcpClient._stream.set_no_delay(true)

func _handle_client_data(data: PoolByteArray) -> void:
	var message: PoolByteArray = [97, 99, 107]
	TcpClient.send(message)

	emit_signal("app_data", data)


func _handle_client_disconnected() -> void:
	connected = false
	_connect_after_timeout(reconnect_timeout) # Try to reconnect after 3 seconds

func _handle_client_error() -> void:
	_connect_after_timeout(reconnect_timeout) # Try to reconnect after 3 seconds
