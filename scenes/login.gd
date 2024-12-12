extends NinePatchRect

class_name LoginScreen

@onready var c_server_addr: LineEdit = $VBox/Margin/VBox/Server/ServerAddr
@onready var c_port: SpinBox = $VBox/Margin/VBox/Server/Port
@onready var c_character_name: LineEdit = $VBox/Margin/VBox/Name/CharacterName
@onready var c_connect: Button = $VBox/Margin/VBox/Margin/Connect

func _is_valid_server_addr() -> bool:
	var server = c_server_addr.text
	if len(server) == 0:
		return false
	
	var port = c_port.value
	if port < 1 or port > 65535:
		return false
	
	return true

func _is_valid_character_name() -> bool:
	var character_name = c_character_name.text
	return len(character_name) >= 3

func _line_edit_text_changed(_new_text: String) -> void:
	c_connect.disabled = !_is_valid_server_addr() or !_is_valid_character_name()

func _line_edit_text_submitted(_new_text: String) -> void:
	_on_connect_button_pressed()

func _on_connect_button_pressed() -> void:
	if !_is_valid_server_addr():
		return
	
	if !_is_valid_character_name():
		return
		
	var server = c_server_addr.text
	var port = c_port.value
	var character_name = c_character_name.text
	
	Network.connect_to_server(server, port)
	await SignalBus.tcp_connected
	
	Protocol.send_login(character_name)