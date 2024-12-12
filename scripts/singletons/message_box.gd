extends Node

const ERROR_BOX = preload("res://scenes/screens/error_box/error_box.tscn")

func show_error(message: String) -> void:
	var error_box: ErrorBox = ERROR_BOX.instantiate()
	error_box.error_message = message
	get_tree().root.add_child(error_box)
	await error_box.close
	error_box.queue_free()
