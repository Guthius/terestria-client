extends Node

const MAX_TRIES: int = 5
const RETRY_DELAY: float = .5
const CONNECT_DELAY: float = .2

var _status: int = 0
var _stream: StreamPeerTCP
var _buffer: PackedByteArray = PackedByteArray()
var _packet: Packet = Packet.new()

var handlers = {}

func connect_to_server(host: String, port: int) -> bool:
	print("Connecting to server at %s:%d" % [host, port])
	
	var stream = StreamPeerTCP.new()
	
	_status = StreamPeerTCP.STATUS_NONE
	
	if stream.connect_to_host(host, port) != OK:
		print("Failed to connect to server (network error)")
		return false
	for i in range(MAX_TRIES):
		stream.poll()
		_status = stream.get_status()
		match _status:
			StreamPeerTCP.STATUS_CONNECTED:
				_stream = stream
				await get_tree().create_timer(CONNECT_DELAY).timeout
				SignalBus.tcp_connected.emit()
				print("Connected to server")
				return true
			StreamPeerTCP.STATUS_ERROR:
				print("There was a problem connecting to the server")
				return false
		await get_tree().create_timer(RETRY_DELAY).timeout
	print("Failed to connect to the server (server may be down)")
	return false

func _receive_data() -> void:
	var available_bytes: int = _stream.get_available_bytes()
	if available_bytes == 0:
		return
	
	var data: Array = _stream.get_partial_data(available_bytes)
	if data[0] != OK:
		print("Error receiving data from server: ", data[0])
		return
	
	_buffer.append_array(data[1])
	while len(_buffer) >= 2:
		var packet_end = _buffer.decode_u16(0) + 2
		if len(_buffer) >= packet_end:
			var packet = _buffer.slice(2, packet_end)
			_packet.data_array = packet
			_handle_data(_packet)
		_buffer = _buffer.slice(packet_end)

func _process(_delta) -> void:
	if _stream == null:
		return
	
	_stream.poll()
	
	var new_status: int = _stream.get_status()
	if new_status != _status:
		_status = new_status
		match _status:
			StreamPeerTCP.STATUS_NONE:
				print("The connection with the server has been closed")
				SignalBus.tcp_disconnected.emit()
			StreamPeerTCP.STATUS_ERROR:
				print("The connection with the server was lost")
				SignalBus.tcp_connection_lost.emit()
				SignalBus.tcp_disconnected.emit()
	
	if _status == StreamPeerTCP.STATUS_CONNECTED:
		_receive_data()

func _handle_data(packet: Packet) -> void:
	var packet_id = packet.get_u16()
	print("Received packet %d from server" % [packet_id])
	var packet_handler = handlers.get(packet_id)
	if packet_handler is Callable:
		packet_handler.call(packet)

func register_handler(packet_id: int, handler: Callable) -> void:
	handlers[packet_id] = handler
	
func send(packet: Packet) -> void:
	if _status == _stream.STATUS_CONNECTED:
		_stream.put_16(packet.get_size())
		_stream.put_data(packet.data_array)
