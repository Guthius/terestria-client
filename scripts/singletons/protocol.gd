extends Node

const MsgLogin: int = 1
const MsgJoinGame: int = 2
const MsgAddPlayer: int = 3
const MsgRemovePlayer: int = 4
const MsgMovePlayer: int = 5
const MsgSetPlayerPosition: int =  6

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
