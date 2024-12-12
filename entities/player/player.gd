extends Node2D

class_name Player

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var camera_2d: Camera2D = $Camera2D

var _moving: bool = false
var _move_queue: Array[int]
var _direction: int = Direction.DIR_DOWN
var _reset_to_idle: bool = true

var character_name: String
var is_local_player: bool = false

func _ready() -> void:
	if is_local_player:
		camera_2d.enabled = true

func _process(_delta: float) -> void:
	if is_local_player and not _moving:
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
	
	if _reset_to_idle:
		_play_idle_animation()

func attack() -> void:
	match _direction:
		Direction.DIR_DOWN:
			animation_player.play("attack_down")
		Direction.DIR_UP:
			animation_player.play("attack_up")
		Direction.DIR_LEFT:
			animation_player.play("attack_left")
		Direction.DIR_RIGHT:
			animation_player.play("attack_right")
	await animation_player.animation_finished
	_play_idle_animation()

func _play_idle_animation() -> void:
	_reset_to_idle = false
	match _direction:
		Direction.DIR_DOWN:
			animation_player.play("idle_down")
		Direction.DIR_UP:
			animation_player.play("idle_up")
		Direction.DIR_LEFT:
			animation_player.play("idle_left")
		Direction.DIR_RIGHT:
			animation_player.play("idle_right")

func _get_walk_animation() -> String:
	match _direction:
		Direction.DIR_DOWN:
			return "walk_down"
		Direction.DIR_UP:
			return "walk_up"
		Direction.DIR_LEFT:
			return "walk_left"
		Direction.DIR_RIGHT:
			return "walk_right"
	return ""

func _play_walk_animation() -> void:
	var animation = _get_walk_animation()
	if animation_player.current_animation == animation:
		return
	animation_player.play(animation)

func _end_walk() -> void:
	_reset_to_idle = true
	_moving = false
	if !is_local_player and len(_move_queue) > 0:
		var next_move = _move_queue.pop_front()
		move(next_move)

func move(direction: int) -> void:	
	if _moving:
		if !is_local_player:
			_move_queue.push_back(direction)
		return
	
	_direction = direction
	
	var target = Direction.get_vector(direction)
	if target == Vector2.ZERO:
		return
	
	var target_position = position + target * Constants.TILE_SIZE
	
	_play_walk_animation()
	
	_reset_to_idle = false
	_moving = true
	
	if is_local_player:
		Protocol.send_move_player(int(_direction))
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, .15)
	tween.tween_callback(_end_walk)
