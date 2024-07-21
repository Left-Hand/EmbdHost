extends Object

class_name ImageBlock

var trans_type:int = 0
var hashcode:int = 0
var time_stamp:int = 0
var size_x:int = 0
var size_y:int = 0
var data_index:int = 0

func is_packed() -> bool:
	return trans_type & 0xf0 == 0x10;
