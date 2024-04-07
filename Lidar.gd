extends Node2D

onready var _serial: OfSerial = OfSerial

var ld14:LD14 = LD14.new()
var turns_per_second:float = 0
var view_scale:float = 50.0

func _ready() -> void:
	var list: Array = _serial.get_device_list()
	print(list)
	_serial.begin(list[0], 115200)
	_serial.flush()
	


func _process(_delta):
	while _serial.available():
		ld14.process_data(_serial.read())
	update()

func _draw():
#	material.set_shader_param("point_size", 4.0)  # 设置点的大小

#	draw_set_material(material)


		
	var _turns_per_second:float = 0
	var farest_point:Vector2 = Vector2()
	var farest_distance:float = 0
	
	for frame in ld14.frames.values():
		_turns_per_second += frame.rad / TAU
		for point in frame.points:
#			draw_point(point)
			draw_rect(Rect2(point * view_scale, Vector2.ONE * 4), Color.aquamarine)
#			draw_circle(point * view_scale, 1.0, Color.red)
			if(point.length() > farest_distance):
				farest_distance = point.length()
				farest_point = point
	
	draw_line(Vector2(), farest_point * view_scale, Color.blue)
	var frames_cnt:int = ld14.frames.keys().size()
	if frames_cnt:
		turns_per_second = _turns_per_second / frames_cnt
#	print(turns_per_second)
