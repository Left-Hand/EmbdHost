extends Node

var tcp_client

func _ready():
	# 连接到ESP32的IP地址和端口
	var ip = "192.168.6.22"
	var port = 1234

	# 创建TCP客户端
	tcp_client = TCP_Server.new()

	# 连接到服务器
	var error = tcp_client.connect_to_host(ip, port)
	if error != OK:
		print("无法连接到服务器:", error)
	else:
		print("已连接到服务器")

	# 设置非阻塞模式
	tcp_client.set_no_delay(true)
	tcp_client.set_blocking(false)

func _process(delta):
	if tcp_client.is_connected():
		# 发送数据给服务器
		var data = "Hello from Godot!"
		tcp_client.put_data(data.to_ascii())
		tcp_client.flush()

		# 接收服务器的响应数据
		var buffer = PoolByteArray()
		var received = tcp_client.get_data(buffer, 1024*16)
		if received > 0:
			print("收到服务器响应：")

		# 断开连接
		tcp_client.disconnect_from_host()
