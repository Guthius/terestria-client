extends Node2D

class_name RemotePlayer

@onready var paperdoll: Paperdoll = $Paperdoll

var _moving: bool = false
var _move_queue: Array[int]
var _direction: int = Direction.DIR_DOWN

var character_name: String

func _ready() -> void:
	paperdoll.set_direction(_direction)

func attack() -> void:
	paperdoll.set_direction(_direction)
	paperdoll.attack()

func move(direction: int) -> void:
	if _moving:
		_move_queue.push_back(direction)
		return
	
	_direction = direction
	
	var target = Direction.get_vector(direction)
	if target == Vector2.ZERO:
		return
	
	var target_position = position + target * Constants.TILE_SIZE
	
	_moving = true
	
	paperdoll.set_direction(_direction)
	paperdoll.start_walking()
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, .15)
	tween.tween_callback(_move_finished)

func _move_finished() -> void:
	_moving = false
	if len(_move_queue) > 0:
		move(_move_queue.pop_front())
	else:
		paperdoll.stop_walking()
