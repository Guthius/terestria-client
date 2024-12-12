class_name Packet extends StreamPeerBuffer

func put_nstr(text: String) -> void:
	var bytes = text.to_utf8_buffer()
	put_u16(len(bytes))
	put_data(bytes)

func get_nstr() -> String:
	var bytes = get_u16()
	if bytes == 0:
		return ""
	return get_string(bytes)
