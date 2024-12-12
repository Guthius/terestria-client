extends Node2D

class_name Player

@onready var paperdoll: Paperdoll = $Paperdoll
@onready var camera: Camera2D = $Camera

var _allow_input: bool = true
var _move_queue: Array[int]
var _direction: int = Direction.DIR_DOWN
var character_name: String
var is_local_player: bool = false

func _ready() -> void:
	paperdoll.set_direction(_direction)
	if is_local_player:
		camera.enabled = true

func _process(_delta: float) -> void:
	if !is_local_player:
		return
	
	if _allow_input:
		if Input.is_action_pressed("ui_accept"):
			attack()
		elif Input.is_action_pressed("ui_up"):
			move(Direction.DIR_UP)
		elif Input.is_action_pressed("ui_down"):
			move(Direction.DIR_DOWN)
		elif Input.is_action_pressed("ui_left"):
			move(Direction.DIR_LEFT)
		elif Input.is_action_pressed("ui_right"):
			move(Direction.DIR_RIGHT)
		else:
			paperdoll.stop_walking()

func attack() -> void:
	_allow_input = false
	
	paperdoll.set_direction(_direction)
	paperdoll.attack()
	
	await paperdoll.attack_finished
	
	_allow_input = true

func move(direction: int) -> void:
	if not _allow_input:
		if !is_local_player:
			_move_queue.push_back(direction)
		return
	
	_direction = direction
	
	var target = Direction.get_vector(direction)
	if target == Vector2.ZERO:
		return
	
	var target_position = position + target * Constants.TILE_SIZE
	
	paperdoll.set_direction(_direction)
	paperdoll.start_walking()
	
	_allow_input = false
	
	if is_local_player:
		Protocol.send_move_player(int(_direction))
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, .15)
	
	await tween.finished
	
	_allow_input = true
	
	if !is_local_player and len(_move_queue) > 0:
		var next_move = _move_queue.pop_front()
		move(next_move)
