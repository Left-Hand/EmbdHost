extends Object

class_name Rangef

var from:float = -INF
var to:float = INF

func _init(_from:float, _to:float)->void:
	from = _from
	to = _to


func has(val:float)->bool:
	return from < val and val < to


func sat(val:float)->float:
	return clamp(val, from, to)

func center() -> float:
	return (from + to) * 0.5
