extends Control


onready var _serial: OfSerial = $"/root/OfSerial"

func _ready() -> void:
	var list: Array = _serial.get_device_list()
	print(list)
	_serial.begin(list[0], 921600)
	_serial.flush()

func _process(_delta):
	var recv_len = _serial.available()
	if(recv_len):
		var recv:String = ""
		recv = _serial.read_string(_serial.available())
#		while _serial.available() :
#			recv += char(_serial.read())
		processString(recv)


var partialString = ""
var exist_numbers:Array = []

func processString(input: String):
	partialString += input
	var lines:PoolStringArray = partialString.split("\r\n")
	
	var has_end:bool = false
	if(not lines[lines.size() - 1]):
		has_end = true
		lines.remove(lines.size() - 1)

	for i in range(lines.size() - 1):
		if(i == 0):
			partialString += lines[0]
			stringToNumberArray(partialString)
		else:
			partialString = ""
			stringToNumberArray(lines[i])
	
	if has_end:
		partialString = ""
		stringToNumberArray(lines[lines.size() - 1])
	else:
		partialString = lines[lines.size() - 1]
		
var im_w:int = 16
var im_h:int = 24

func stringToNumberArray(_input_string: String):
#	print(_input_string)
	var input_string = _input_string.strip_edges()
	var number_array:Array = input_string.split_floats(",")
#	print(input_string)
	exist_numbers.append_array(number_array)
	if(exist_numbers.size() >= im_w * im_h):
		$Sprite.texture = convertArrayToTexture(exist_numbers.slice(0, im_w * im_h - 1))
		exist_numbers = exist_numbers.slice(im_h * im_w, exist_numbers.size())



func convertArrayToTexture(input_array: PoolRealArray) -> ImageTexture:
	var value_size:int = input_array.size()
	var image = Image.new()
	image.create(im_w, im_h, false, Image.FORMAT_RGBA8)
	image.lock()
	
	var min_value:float = 25
	var max_value:float = 50

#	var min_value:float = INF
#	var max_value:float = -INF

#	for y in range(im_h):
#		for x in range(im_w):
#			var value:float = input_array[y * 32 + x]
#			if value != 0:
#				min_value = min(min_value, value)
#				max_value = max(max_value, value)

#	prints(min_value, max_value)
	for y in range(im_h):
		for x in range(im_w):
			var value:float = input_array[y * im_w + x]
			var color:Color = Color.black
			if(value):
				color = Color.from_hsv(0.0, 1.0, inverse_lerp(min_value, max_value, value))
			image.set_pixel(x, y, color)

	var texture = ImageTexture.new()
	texture.create_from_image(image)

	return texture
