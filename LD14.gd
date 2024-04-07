extends Object

class_name LD14

enum State{
	Idle,
	Collecting
}

var state:int = State.Idle
var collected_data_cnt:int = 0;
var collected_data:PoolByteArray

var frames:Dictionary = {} 

func _ready():
	pass # Replace with function body.

func update_frame():
	var frame = LD14_Frame.new(collected_data)
	if(!frame.valid):
		return
	
	var new_key:float = frame.begin_angle
	
	if(frames.size() > TAU / 0.1):
		var nearest_key = null
		var nearest_value:float = INF
		for key in frames.keys():
			if nearest_key == null or abs(new_key - key) < nearest_value:
				nearest_key = key
				nearest_value = abs(new_key - key)

		if nearest_key != null:
			frames.erase(nearest_key)


	frames[new_key] = frame


func collect_data(data:int):
	collected_data.append(data);


func process_data(data:int):
	match(state):
		State.Idle:
			if(data == 0x54):
				collect_data(data)
				state = State.Collecting

		State.Collecting:
			collect_data(data)
			if(collected_data.size() == 47):
				update_frame()
				state = State.Idle
				collected_data.resize(0)
