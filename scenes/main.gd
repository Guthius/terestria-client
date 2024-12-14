extends Node2D

const PLAYER = preload("res://objects/player/player.tscn")
const REMOTE_PLAYER = preload("res://objects/remote_player/remote_player.tscn")

@onready var login: LoginScreen = $Screens/Login
@onready var map_container: Node2D = $World/Map
@onready var players: Node2D = $World/Players
@onready var chat_box: ChatBox = $World/Hud/ChatBox

var _map_scene: PackedScene
var _map: Node2D
var _player_id: int = -1
var _player: Player

func _ready() -> void:
	SignalBus.tcp_disconnected.connect(_on_connection_lost)
	SignalBus.notification.connect(_on_notification)
	
	Network.register_handler(Protocol.MsgLogin, _handle_login)
	Network.register_handler(Protocol.MsgJoinGame, _handle_join_game)
	Network.register_handler(Protocol.MsgAddPlayer, _handle_add_player)
	Network.register_handler(Protocol.MsgRemovePlayer, _handle_remove_player)
	Network.register_handler(Protocol.MsgMovePlayer, _handle_move_player)
	Network.register_handler(Protocol.MsgSetPlayerDirection, _handle_set_player_direction)
	Network.register_handler(Protocol.MsgAttack, _handle_attack)
	Network.register_handler(Protocol.MsgNotification, _handle_notification)

func _on_connection_lost() -> void:
	login.visible = true
	_reset_game()
	MessageBox.show_error("The connection with the server has been lost.")

func _on_notification(message: String) -> void:
	chat_box.add_chat(message)

func _reset_game() -> void:
	if _map != null:
		_map.queue_free()
		_map = null
	for player in players.get_children():
		player.queue_free()
	_player = null

func _get_player(player_id: int) -> Node2D:
	return players.get_node_or_null("Player" + str(player_id))

func _handle_login(packet: Packet) -> void:
	var result = packet.get_u8()
	if result != 0:
		print("Failed to login (res=%d)" % [result])
		return
	print("Successfully logged in...")
	login.visible = false

func _handle_join_game(packet: Packet) -> void:
	_player_id = packet.get_u32()
	var dir = packet.get_8()
	var x = packet.get_32()
	var y = packet.get_32()
	var map_name = packet.get_nstr()
	print("Entering game (id=%d,x=%d,y=%d,map=%s)" % [_player_id, x, y, map_name])
	_load_map(map_name)
	_create_player(_player_id, dir, x, y)

func _handle_add_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player_name = packet.get_nstr()
	var _sprite = packet.get_nstr()
	var dir = packet.get_8()
	var x = packet.get_32()
	var y = packet.get_32()
	print("Adding player %d to map" % [player_id])
	_create_remote_player(player_id, player_name, dir, x, y)

func _handle_remove_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player = _get_player(player_id)
	print("Removing player %d from map" % [player_id])
	if player != null:
		player.queue_free()

func _handle_move_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var dir = packet.get_u8()
	var player = _get_player(player_id)
	if player is Player:
		player.move(dir)
	elif player is RemotePlayer:
		player.move(dir)

func _handle_set_player_direction(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player = _get_player(player_id)
	if player is RemotePlayer:
		var dir = packet.get_u8()
		player.set_direction(dir)

func _handle_attack(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player = _get_player(player_id)
	if player is RemotePlayer:
		var dir = packet.get_u8()
		player.set_direction(dir)
		player.attack()

func _handle_notification(packet: Packet) -> void:
	var message = packet.get_nstr()
	if len(message) == 0:
		return
	SignalBus.notification.emit(message)

func _load_map(map_name):
	_map_scene = load("res://maps/%s.tscn" % [map_name])
	if _map_scene == null:
		print("Error loading map '%s'" % [map_name])
		return
	_map = _map_scene.instantiate()
	map_container.add_child(_map)
	if _player is Player and _map is Map:
		_player.set_map(_map)

func _create_remote_player(id: int, character_name: String, dir: int, x: int, y: int):
	var remote_player = REMOTE_PLAYER.instantiate()
	remote_player.name = "Player"+str(id)
	remote_player.position = Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE)
	remote_player.character_name = character_name
	remote_player.direction = dir
	players.add_child(remote_player)
	
func _create_player(id: int, dir: int, x: int, y: int):
	_player = PLAYER.instantiate()
	_player.name = "Player"+str(id)
	_player.position = Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE)
	_player.direction = dir
	players.add_child(_player)
	if _map is Map:
		_player.set_map(_map)
