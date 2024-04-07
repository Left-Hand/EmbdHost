extends Object

class_name ProtocolItem


var _buf:PoolByteArray
var _len:int = 0
var _cnt:int = 0


func _init() -> void:
    pass

func add_data(data:int) -> bool:
    if(_cnt < _len):
        _buf.append(data)
        return true
    return false

func clear_data():
    _buf.resize(0)

