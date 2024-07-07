extends Node

class_name Stream

var connected:bool = false
var enable_tx_log:bool = false
var enable_rx_log:bool = false

func connection() -> bool:
	return connected
