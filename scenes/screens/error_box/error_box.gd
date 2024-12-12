extends CanvasLayer

class_name ErrorBox

@onready var c_label: Label = $CenterContainer/Dialog/VBox/Margin/VBox/Label
@onready var c_close: Button = $CenterContainer/Dialog/VBox/Margin/VBox/Margin/Close

var error_message: String

signal close

func _ready() -> void:
	c_label.text = error_message

func _on_close_pressed() -> void:
	c_close.disabled = true
	close.emit()
