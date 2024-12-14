extends Node

const MsgLogin: int = 1
const MsgJoinGame: int = 2
const MsgAddPlayer: int = 3
const MsgRemovePlayer: int = 4
const MsgMovePlayer: int = 5
const MsgSetPlayerPosition: int =  6
const MsgSetPlayerDirection: int = 7
const MsgChangeMap: int = 8
const MsgAttack: int = 9
const MsgChat: int = 10
const MsgNotification: int = 11

func send_login(character_name: String) -> void:
	var packet = Packet.new()
	packet.put_16(MsgLogin)
	packet.put_nstr(character_name)
	Network.send(packet)

func send_move_player(dir: int) -> void:
	var packet = Packet.new()
	packet.put_16(MsgMovePlayer)
	packet.put_8(dir)
	Network.send(packet)

func send_set_direction(dir: int) -> void:
	var packet = Packet.new()
	packet.put_16(MsgSetPlayerDirection)
	packet.put_8(dir)
	Network.send(packet)

func send_attack(dir: int) -> void:
	var packet = Packet.new()
	packet.put_16(MsgAttack)
	packet.put_8(dir)
	Network.send(packet)

func send_chat(message: String) -> void:
	var packet = Packet.new()
	packet.put_16(MsgChat)
	packet.put_nstr(message)
	Network.send(packet)
