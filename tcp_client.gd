extends Node
#
signal connected
signal data
signal disconnected
signal error

var _status: int = 0
var _stream: StreamPeerTCP = StreamPeerTCP.new()

func _ready() -> void:
	_status = _stream.get_status()

func _physics_process(_delta: float) -> void:
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			_stream.STATUS_NONE:
				TcpManager.report_info("Disconnected from host.")
				emit_signal("disconnected")
			_stream.STATUS_CONNECTING:
				TcpManager.report_info("Connecting to host.")
			_stream.STATUS_CONNECTED:
				_stream.set_no_delay(true)
				TcpManager.report_info("Connected to host.")
				emit_signal("connected")
			_stream.STATUS_ERROR:
				TcpManager.report_err("Error with socket stream.")
				emit_signal("error")

	if _status == _stream.STATUS_CONNECTED:
		var available_bytes: int = _stream.get_available_bytes()
		if available_bytes > 0:
			var data: Array = _stream.get_partial_data(available_bytes)
			# Check for read error.
			if data[0] != OK:
				TcpManager.report_err("Error getting data from stream: " + str(data[0]))
				emit_signal("error")
			else:
				emit_signal("data", data[1])

func connect_to_host(host: String, port: int) -> void:
	TcpManager.report_info("Connecting to %s:%d" % [host, port])
	# Reset status so we can tell if it changes to error again.
	_status = _stream.STATUS_NONE
	if _stream.connect_to_host(host, port) != OK:
		TcpManager.report_err("Error connecting to host.")
		emit_signal("error")

func disconnect_from_host() -> void:
	TcpManager.report_info("Disconnect")
	_status = _stream.STATUS_NONE
	_stream.disconnect_from_host()
	
func send(data: PoolByteArray) -> bool:
	if _status != _stream.STATUS_CONNECTED:
		TcpManager.report_err("Stream is not currently connected.")
		return false
	var error: int = _stream.put_data(data)
	if error != OK:
		TcpManager.report_err("Error writing to stream: " + str(error))
		return false
	return true
