extends Node2D

class_name Player

@onready var paperdoll: Paperdoll = $Paperdoll

var _allow_input: bool = true
var _direction: int = Direction.DIR_DOWN

var character_name: String

func _ready() -> void:
	paperdoll.attack_finished.connect(_enable_input)
	paperdoll.set_direction(_direction)

func _physics_process(_delta: float) -> void:
	if not _allow_input:
		return
	
	if Input.is_action_pressed("attack"):
		attack()
		
	if not _allow_input:
		return
		
	elif Input.is_action_pressed("move_up"):
		move(Direction.DIR_UP)
	elif Input.is_action_pressed("move_down"):
		move(Direction.DIR_DOWN)
	elif Input.is_action_pressed("move_left"):
		move(Direction.DIR_LEFT)
	elif Input.is_action_pressed("move_right"):
		move(Direction.DIR_RIGHT)
		
	if _allow_input:
		paperdoll.stop_walking()

func attack() -> void:
	_allow_input = false
	
	paperdoll.set_direction(_direction)
	paperdoll.attack()

func move(direction: int) -> void:
	if not _allow_input:
		return
	
	_allow_input = false
	_direction = direction
	
	var target = Direction.get_vector(direction)
	if target == Vector2.ZERO:
		_allow_input = true
		return
	
	var target_position = position + target * Constants.TILE_SIZE
	
	paperdoll.set_direction(_direction)
	paperdoll.start_walking()
	
	Protocol.send_move_player(int(_direction))
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, .15)
	tween.tween_callback(_enable_input)

func _enable_input() -> void:
	_allow_input = true
