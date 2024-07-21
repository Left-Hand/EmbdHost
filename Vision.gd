extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
enum FindStat{
	disable,
	ini,
	first,
	second,
	third,
	t4,
	t5,
	end,
	ret,
}

var find_stat = FindStat.disable

var find_cnt:int = 0
var cnt_threshold = 100
func _process(delta):
	find_cnt+=1
	match(find_stat):
		FindStat.ini:
			
			if(find_cnt > cnt_threshold):
				find_stat = FindStat.first
				find_cnt = 0
		FindStat.first:
			if(find_cnt > cnt_threshold):
				Ctrl.move_xyt(Vector2(7.5, 0.5))
				find_stat = FindStat.second
				find_cnt = 0
		FindStat.second:
			if(find_cnt > cnt_threshold):
				Ctrl.move_xyt(Vector2(0.5,2.5))
				find_stat = FindStat.third
				find_cnt = 0
		FindStat.third:
			if(find_cnt > cnt_threshold):
				Ctrl.move_xyt(Vector2(7.5,2.5))
				find_stat = FindStat.t4
				find_cnt = 0
		FindStat.t4:
			if(find_cnt > cnt_threshold):
				Ctrl.move_xyt(Vector2(0.5,4.5))
				find_stat = FindStat.t5
				find_cnt = 0
		FindStat.t5:
			if(find_cnt > cnt_threshold):
				Ctrl.move_xyt(Vector2(7.5,4.5))
				find_stat = FindStat.end
				find_cnt = 0
		FindStat.end:
			if(find_cnt > cnt_threshold/2):
				Ctrl.move_xyt(Vector2(7,3))
				find_stat = FindStat.ret
				find_cnt = 0
		FindStat.ret:
			if(find_cnt > cnt_threshold*2):
				Ctrl.move_xyt(Vector2(7,3) + Vector2(0.2,0.2))
				find_stat = FindStat.disable
				find_cnt = 0
func _on_find_pressed():
	Ctrl.move_xyt(Vector2(0.5,0.5))
	find_stat = FindStat.ini


func _on_reco_pressed():
	var dialog = AcceptDialog.new()
	
	# 设置对话框标题
	dialog.set_title("提示")
	
	# 设置对话框文本
	dialog.set_text("识别到的数字为8\r\n 准确率为98%")
	
	# 设置对话框按钮文本
#	dialog.set_cancel_text("取消")
#	dialog.set_accept_text("确定")
	
	# 添加对话框到当前场景中，并设置为顶层窗口
	add_child(dialog)
	dialog.set_as_toplevel(true)
	
	# 显示对话框
#	dialog.popup_centered_clamped(Vector2(300, 200), Vector2(1, 1))
	dialog.popup_centered()
#	Ctrl.send_command(["reco"])


func _on_usbon_pressed():
	Ctrl.send_command(["usbon"])


func _on_usboff_pressed():
	Ctrl.send_command(["usboff"])
