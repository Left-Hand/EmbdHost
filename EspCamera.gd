extends Control

onready var raw_img := ($CenterContainer3/raw)
onready var chr_img := ($CenterContainer3/chr)

enum State{
	IdleL,
	IdleH,
	TRANS_TYPE,
	HASH0,
	HASH1,
	HASH2,
	HASH3,
	TIME_STAMP,
	SIZE_X,
	SIZE_Y,
	DATA_INDEX_L,
	DATA_INDEX_H,
	Collecting
}

var state:int = State.IdleL
var data_len:int = 0
var data_hash:int = 0

#var image_load_thread:Thread = Thread.new()
#var image_recv_thread:Thread = Thread.new()
#var command_recv_thread:Thread = Thread.new()
#var image_data_thread:Thread = Thread.new()
#var image_load_semaphore:Semaphore = Semaphore.new()
#var image_access_mutex:Mutex = Mutex.new()
var time_since:float = 0
var bytes_since:int = 0
#var udp_server := UDPServer.new()

var image_recved_bytes:Array = []
var enter_recving:bool = false

var block_info:ImageBlock = ImageBlock.new()
var block_data:PoolByteArray = []

var pieces:Dictionary = {}
var stamps:Dictionary = {}

var t:float = 0

const mtu = 320

onready var left_joystick := $JoystickLeft
onready var right_joystick := $JoystickRight

func hash_djb2_buffer(arr:PoolByteArray) -> int:
	var ha:int = 5381
	
	for item in arr:
		ha = ((ha << 5) + ha) + item
		ha &= 0xffffffff
	return ha

func the_same_arr(arr:Array) -> bool:
	var same:bool = true
	for i in range(1, arr.size()):
		same &= (arr[0] == arr[i])
	
	return same
	
func the_same_dict(dict:Dictionary) -> bool:
	var same:bool = true
	var keys = dict.keys()
	keys.sort()

	for i in range(1, keys.size()):
		if(dict[keys[0]] != dict[keys[i]]):
			same = false
	
#	for i in range(keys.size()):
#		if(!keys.has(i)):
#			same = false
	return same
 

func _ready() -> void:
	
	left_joystick.connect("drag_signal", Ctrl, "left_joystick_drag")
	left_joystick.connect("tap_signal", Ctrl, "left_joystick_tap")
	left_joystick.connect("release_signal", Ctrl, "left_joystick_release")
	left_joystick.connect("sustain_signal", Ctrl, "left_joystick_sustain")
	
	right_joystick.connect("drag_signal", Ctrl, "right_joystick_drag")
	right_joystick.connect("tap_signal", Ctrl, "right_joystick_tap")
	right_joystick.connect("release_signal", Ctrl, "right_joystick_release")
	right_joystick.connect("sustain_signal", Ctrl, "right_joystick_sustain")

	Ctrl.camera_stream.connect("recv", self, "process_datas")

var last_image_index:int = 0
var image_index:int = 0
var block_total:int = 0



var frames:int = 0
var to_send_list:Array

func _physics_process(_delta):
	time_since += _delta
	t += _delta
	frames += 1
#	if(frames % 60 == 0):
#		serial_p.println(frames)


#func image_load_task():
#	while(true):
#		image_load_semaphore.wait()
#	load_image(image_full_data)



func load_image(data:PoolByteArray, size:Vector2, image_sp:int):
		var image = Image.new()
		var texture = ImageTexture.new()

		image.create_from_data(int(size.x), int(size.y), false, Image.FORMAT_L8, data)
		texture.create_from_image(image)
		match(image_sp):
			0:
				raw_img.texture = texture
			1:
				chr_img.texture = texture


var done_cycle:bool = false

func process_datas(datas:PoolByteArray) -> void:
	for data in datas:
		process_data(data)

func process_data(data:int) -> void:

	match(state):
		State.IdleL:
			if(data == 0xA8):
				state = State.IdleH

		State.IdleH:
			if(data == 0x54):
				state = State.TRANS_TYPE
			else:
				state = State.IdleL
		State.TRANS_TYPE:
			block_info.trans_type = data
			state += 1

		State.HASH0:
			block_info.hashcode = data
			state += 1
		State.HASH1:
			block_info.hashcode |= (data << 8)
			state += 1
		State.HASH2:
			block_info.hashcode |= (data << 16)
			state += 1
		State.HASH3:
			block_info.hashcode |= (data << 24)
			state += 1
		State.TIME_STAMP:
			image_index = data
			block_info.time_stamp = data
			state += 1
		State.SIZE_X:
			block_info.size_x = data
			state += 1
		State.SIZE_Y:
			block_info.size_y = data
			state += 1
		State.DATA_INDEX_L:
			block_info.data_index = data
			state += 1
		State.DATA_INDEX_H:
			block_info.data_index |= (data << 8)
			block_data.resize(0)

			state = State.Collecting

		State.Collecting:
			if(not block_info.is_packed()):
				block_data.append(data)
			else:
				for i in range(0, 8):
					if(data & (1 << i)):
						block_data.append(255)
					else:
						block_data.append(0)

			if(block_data.size() >= min(mtu, block_info.size_x * block_info.size_y - block_info.data_index)):
				var block_total:int = int(ceil(float(block_info.size_x * block_info.size_y) / mtu))
				var exp_hash:int = hash_djb2_buffer(block_data)
				var real_hash:int = block_info.hashcode
#				var exp_hash = real_hash
				if(exp_hash == real_hash):

					var block_data_clone:PoolByteArray = []

					for item in block_data:
						block_data_clone.append(item)

					var block_index = block_info.data_index / mtu
					pieces[block_index] = block_data_clone
					stamps[block_index] = block_info.time_stamp

					if(block_info.data_index == (block_total - 1) * mtu):#last block
						if(the_same_dict(stamps)):
							var image_full_data:PoolByteArray = []
							for key in pieces.keys():
								image_full_data.append_array(pieces[key])
							
							var size:Vector2 = Vector2(block_info.size_x, block_info.size_y)
							if(image_full_data.size() == block_info.size_x * block_info.size_y):
								load_image(image_full_data, size, block_info.trans_type)
							else:
								print("size error")

						pieces.clear()
						stamps.clear()
				else:
					print("nom", exp_hash, ",", real_hash)
				block_data.resize(0)
				state = State.IdleL




func _on_cali_pressed():
	Ctrl.cali()

func _on_reset_pressed():
	Ctrl.reset()

func _on_home_pressed():
	Ctrl.home()

func _on_prepare_pressed():
	Ctrl.prepare()

func _on_save_pressed():
	Ctrl.save()
