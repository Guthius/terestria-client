extends Label

class_name ChatBoxLine

func _ready() -> void:
	var timer: SceneTreeTimer = get_tree().create_timer(5)
	timer.timeout.connect(_start_fade_out)

func _start_fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 1)
	tween.tween_callback(queue_free)
