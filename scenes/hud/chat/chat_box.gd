extends MarginContainer

class_name ChatBox

const CHAT_BOX_LINE = preload("res://scenes/hud/chat/chat_box_line.tscn")

@onready var container: VBoxContainer = $ChatContainer

func add_chat(message: String) -> void:
	if len(message) == 0:
		return
	var chat_box_line: ChatBoxLine = CHAT_BOX_LINE.instantiate()
	chat_box_line.text = message
	container.add_child(chat_box_line)
