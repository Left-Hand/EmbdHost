extends Control

onready var serial: SerialStream = SerialStream.new(self)
onready var serial_p:SerialStream = SerialStream.new(self)

enum State{
	IdleL,
	IdleH,
	IMAGE_INDEX,
	BLOCK_INDEX,
	BLOCK_TOTAL,
	HASH0,
	HASH1,
	HASH2,
	HASH3,
	BLOCK_START_L,
	BLOCK_START_H,
	BLOCK_END_L,
	BLOCK_END_H,
	Collecting
}

var state:int = State.IdleL
var data_len:int = 0
var data_hash:int = 0

var image_load_thread:Thread = Thread.new()
var image_recv_thread:Thread = Thread.new()
var command_recv_thread:Thread = Thread.new()
var image_data_thread:Thread = Thread.new()
var image_load_semaphore:Semaphore = Semaphore.new()
var image_access_mutex:Mutex = Mutex.new()
var time_since:float = 0
var bytes_since:int = 0
var udp_server := UDPServer.new()

var image_recved_bytes:Array = []
var enter_recving:bool = false
var image_block_temp:ImageBlock = ImageBlock.new()
var image_block_data:PoolByteArray = []
var image_blocks_data:Dictionary = {}
var image_blocks_belong_index:Dictionary = {}
var image_full_data:PoolByteArray = []
var t:float = 0

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
	
	for i in range(keys.size()):
		if(!keys.has(i)):
			same = false
	return same
 

#onready var camera_stream := TcpStream.new(self)
func _ready() -> void:
	serial.connect_stream(	"COM15", 115200)
	serial.name = "B"
	serial.connect("recv", self, "process_data")
	
	serial_p.connect_stream("COM12", 115200)
	serial_p.name = "P"
#	serial_p.connect("recv", self, "process_datas")
	
#	camera_stream.connect_stream()
#	camera_stream.connect("recv", self, "process_datas")
#	$JoystickLeft.connect("control_signal", self, "joystick_l_callback")
#	$JoystickRight.connect("control_signal", self, "joystick_r_callback")
	left_joystick.connect("drag_signal", Ctrl, "left_joystick_drag")
	left_joystick.connect("tap_signal", Ctrl, "left_joystick_tap")
	left_joystick.connect("release_signal", Ctrl, "left_joystick_release")

	right_joystick.connect("drag_signal", Ctrl, "right_joystick_drag")
	right_joystick.connect("tap_signal", Ctrl, "right_joystick_tap")
	right_joystick.connect("release_signal", Ctrl, "right_joystick_release")

#	image_load_thread.start(self, "image_load_task")
#	image_recv_thread.start(self, "image_recv_task")
#	image_data_thread.start(self, "image_data_task")
#	command_recv_thread.start(self, "command_recv_task")

func joystick_l_callback(vect:Vector2):
#	update_velocity(Vector2(-vect.y, vect.x))
	pass

func joystick_r_callback(vect:Vector2):
#	update_face(vect)
	pass

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


func image_load_task():
	while(true):
		image_load_semaphore.wait()
	load_image(image_full_data)



func load_image(datas:PoolByteArray):
		var image = Image.new()

		image.create_from_data(12, 12, false, Image.FORMAT_L8, datas)

		image.flip_x()

		var texture = ImageTexture.new()
		texture.create_from_image(image)
		$CenterContainer3/view.texture = texture


var done_cycle:bool = false

func process_data(data:int):

	match(state):
		State.IdleL:
			if(data == 0xA8):
				state = State.IdleH

		State.IdleH:
			if(data == 0x54):
				state = State.IMAGE_INDEX
			else:
				state = State.IdleL
		State.IMAGE_INDEX:
			image_index = data
			image_block_temp.image_index = data
			state += 1
		State.BLOCK_INDEX:
			image_block_temp.block_index = data
			state += 1
		State.BLOCK_TOTAL:
			block_total = data
			image_block_temp.block_total = data
			state += 1
		State.HASH0:
			image_block_temp.block_hash = data
			state += 1
		State.HASH1:
			image_block_temp.block_hash |= (data << 8)
			state += 1
		State.HASH2:
			image_block_temp.block_hash |= (data << 16)
			state += 1
		State.HASH3:
			image_block_temp.block_hash |= (data << 24)
			state += 1
		State.BLOCK_START_L:
			image_block_temp.block_start = data
			state += 1
		State.BLOCK_START_H:
			image_block_temp.block_start |= (data << 8)
			state += 1
		State.BLOCK_END_L:
			image_block_temp.block_end = data
			state += 1
		State.BLOCK_END_H:
			image_block_temp.block_end |= (data << 8)

			image_blocks_data.clear()
			state = State.Collecting

		State.Collecting:
			image_block_data.append(data)
			if(image_block_data.size() >= image_block_temp.block_end - image_block_temp.block_start):

				bytes_since = 0
				time_since = 0

				var exp_hash:int = hash_djb2_buffer(image_block_data)
				var real_hash:int = image_block_temp.block_hash
#				var exp_hash = real_hash

				if(exp_hash == real_hash):

					var block_data_temp:PoolByteArray = []

					for item in image_block_data:
						block_data_temp.append(item)

					image_blocks_data[image_block_temp.block_index] = block_data_temp
					image_blocks_belong_index[image_block_temp.block_index] = image_block_temp.image_index


					if(image_block_temp.block_index == block_total - 1):
						if(the_same_dict(image_blocks_belong_index)):
							for key in image_blocks_data.keys():
								image_full_data.append_array(image_blocks_data[key])
							load_image(image_full_data)

						image_full_data.resize(0)
						image_blocks_data.clear()
						image_blocks_belong_index.clear()
				else:
					print("nom", exp_hash, ",", real_hash)
				image_block_data.resize(0)
				state = State.IdleL


