extends Node2D

const PLAYER = preload("res://objects/player/player.tscn")

@onready var login: LoginScreen = $CanvasLayer/Screens/Login
@onready var map_container: Node2D = $Map
@onready var players: Node2D = $Players

var _map_scene: PackedScene
var _map: Node2D
var _player_id: int = -1
var _player: Player

func _ready() -> void:
	Network.register_handler(Protocol.MsgLogin, _handle_login)
	Network.register_handler(Protocol.MsgJoinGame, _handle_join_game)
	Network.register_handler(Protocol.MsgAddPlayer, _handle_add_player)
	Network.register_handler(Protocol.MsgRemovePlayer, _handle_remove_player)
	Network.register_handler(Protocol.MsgMovePlayer, _handle_move_player)

func _handle_login(packet: Packet) -> void:
	var result = packet.get_u8()
	if result != 0:
		print("Failed to login (res=%d)" % [result])
		return
	print("Successfully logged in...")
	login.visible = false

func _handle_join_game(packet: Packet) -> void:
	_player_id = packet.get_u32()
	var x = packet.get_32()
	var y = packet.get_32()
	var map_name = packet.get_nstr()
	print("Entering game (id=%d,x=%d,y=%d,map=%s)" % [_player_id, x, y, map_name])
	_load_map(map_name)
	_create_player(_player_id, "Me", x, y, true)

func _handle_add_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player_name = packet.get_nstr()
	var _sprite = packet.get_nstr()
	var x = packet.get_32()
	var y = packet.get_32()
	print("Adding player %d to map" % [player_id])
	_create_player(player_id, player_name, x, y, false)

func _handle_remove_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var player = players.get_node_or_null("Player" + str(player_id))
	print("Removing player %d from map" % [player_id])
	if player != null:
		player.queue_free()

func _handle_move_player(packet: Packet) -> void:
	var player_id = packet.get_u32()
	if player_id == _player_id:
		return
	var dir = packet.get_u8()
	var player = players.get_node_or_null("Player" + str(player_id))
	if player is Player:
		player.move(dir)

func _load_map(map_name):
	_map_scene = load("res://maps/%s.tscn" % [map_name])
	if _map_scene == null:
		print("Error loading map '%s'" % [map_name])
		return
	_map = _map_scene.instantiate()
	map_container.add_child(_map)

func _create_player(id: int, character_name: String, x: int, y: int, is_local: bool):
	_player = PLAYER.instantiate()
	_player.name = "Player"+str(id)
	_player.position = Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE)
	_player.is_local_player = is_local
	_player.character_name = character_name
	players.add_child(_player)