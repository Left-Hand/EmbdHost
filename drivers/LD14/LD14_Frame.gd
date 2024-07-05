extends Object

class_name LD14_Frame

var points_cnt:int = 0
var rad:float = 0
var begin_angle:float = 0
var points:PoolVector2Array
var end_angle:float = 0
var tick:int = 0
var crc:int = 0

var valid:bool = true


func _init(collected_data:PoolByteArray):
	var base_index:int = 1
	
	points_cnt = collected_data[base_index] & 0x1f
	if(points_cnt != 12):
		valid = false
		return

	base_index += 1
	
	rad = deg2rad((collected_data[base_index] + (collected_data[base_index + 1] << 8)))
	base_index += 2
	
	begin_angle = deg2rad((collected_data[base_index] + (collected_data[base_index + 1] << 8)) * 0.01)
	base_index += 2
	
	end_angle = deg2rad((collected_data[base_index + points_cnt * 3] + (collected_data[base_index + 1 + points_cnt * 3] << 8)) * 0.01)
	
	var end_angle_temp:float = end_angle
	if end_angle < begin_angle:
		end_angle_temp += TAU
	
	var angle_step:float = (end_angle_temp - begin_angle) / (points_cnt - 1)
	var angle_current:float = begin_angle
	
	points.resize(0)
	for i in range(points_cnt):
		var distance:float = (collected_data[base_index] + (collected_data[base_index + 1] << 8)) * 0.001
		var point:Vector2 = Vector2(distance, 0).rotated(angle_current)
		points.append(point)
		
		base_index += 3
		angle_current += angle_step
		if(angle_current > TAU):
			angle_current -= TAU
