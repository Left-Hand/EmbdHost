extends Control

#onready var _serial: OfSerial = $"/root/OfSerial"
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
 

onready var camera_stream := TcpStream.new(self)
func _ready() -> void:
	camera_stream.connect_stream()
	camera_stream.connect("recv", self, "process_datas")
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
	command_recv_thread.start(self, "command_recv_task")

func joystick_l_callback(vect:Vector2):
	update_velocity(Vector2(-vect.y, vect.x))

func joystick_r_callback(vect:Vector2):
	update_face(vect)

var last_image_index:int = 0
var image_index:int = 0
var block_total:int = 0



var frames:int = 0
var to_send_list:Array

func send(ss:String):
	to_send_list.push_back(ss)

var last_dir:Vector2 = Vector2.ZERO
var last_face:Vector2 = Vector2.ZERO



func update_velocity(dir:Vector2) -> void:
	if last_dir != dir:
		last_dir = dir
		send("V " + str(dir.x)+" "+ str(dir.y))

func update_face(face:Vector2) -> void:
	if last_face != face:
		last_face = face
		send("F " + str(face.x)+" "+ str(face.y))

var udp_peer:PacketPeerUDP = null

func _physics_process(_delta):
	time_since += _delta
	t += _delta
	frames += 1


func command_recv_task():
	while(true):
		pass
	

var peers:=[]
#func command_recv_task() -> void:
#	pass
#	while(true):
#		udp_server.poll()
#		if udp_server.is_connection_available():
#
#			var peer : PacketPeerUDP = udp_server.take_connection()
#			peers.append(peer)
#			var pkt = peer.get_packet()
#
##			var bytes_temp:PoolByteArray
##			for item in pkt:
##				bytes_temp.append(item)
#
##			process_datas(pkt)
##			if(pkt.size()):
#			print(pkt.get_string_from_ascii().strip_edges())
#			pee
#			println(peer as PacketPeerUDP, "V 1 9 0")



func image_recv_task() -> void:
	pass


func image_load_task():
	while(true):
		image_load_semaphore.wait()
		load_image(image_full_data)
		
func load_image(datas:PoolByteArray):
		var image = Image.new()
		var load_err:int = image.load_jpg_from_buffer(datas)
		image.flip_y()

	#	var load_err:int = OK
	#	image.create_from_data(640, 480, false, Image.FORMAT_L8, _buf)
	#	print("!")
		if(load_err == OK):
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			$CenterContainer3/view.texture = texture

#func image_data_task():
#	while(true):
##		image_access_mutex.lock()
#		print("??")
#		var bytes:int = image_recved_bytes.pop_front()
##		image_access_mutex.unlock()
#
#		for byte in bytes:
#			process_data(byte)

func process_datas(datas:PoolByteArray):
#	bytes_since += datas.size()
##	print("????", time_since)
#	if(time_since):
##		print(bytes_since / time_since/ 1000, "kB/S")
#		pass

	for data in datas:
		process_data(data)


var done_cycle:bool = false





func process_data(data:int):
	match(state):
		State.IdleL:
			if(data == 0xA8):
				state = State.IdleH

		State.IdleH:
			if(data == 0x54):
				state += 1
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
			
#			prints("iindex", image_index)
#			prints("hash", image_block_temp.block_hash)
#			prints("index", image_block_temp.block_index, image_index)
#			prints("starts", image_block_temp.block_start)
#			prints("ends", image_block_temp.block_end)

#			image_blocks_data.clear()
			
			state = State.Collecting
		State.Collecting:
			image_block_data.append(data)
			if(image_block_data.size() >= image_block_temp.block_end - image_block_temp.block_start):

			# 	done_cycle = true
				bytes_since = 0
				time_since = 0
#				prints(image_block_temp.image_index, image_block_temp.block_index, image_block_tkemp.block_total)
				if(hash_djb2_buffer(image_block_data) == image_block_temp.block_hash):

					var block_data_temp:PoolByteArray = []

					for item in image_block_data:
						block_data_temp.append(item)

					image_blocks_data[image_block_temp.block_index] = block_data_temp
					image_blocks_belong_index[image_block_temp.block_index] = image_block_temp.image_index

					
					if(image_block_temp.block_index == block_total - 1):
						if(the_same_dict(image_blocks_belong_index)):

							for key in image_blocks_data.keys():
								image_full_data.append_array(image_blocks_data[key])

#							image_load_semaphore.post()
							load_image(image_full_data)

						image_full_data.resize(0)
						image_blocks_data.clear()
						image_blocks_belong_index.clear()
					

				image_block_data.resize(0)

				state = State.IdleL


#func _exit_tree():
#	image_load_thread.wait_to_finish()
