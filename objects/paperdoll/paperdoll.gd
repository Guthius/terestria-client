extends Node2D

class_name Paperdoll

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree

var _direction: Vector2 = Vector2(0, -1)

func _get_direction_vector(dir: int) -> Vector2:
	match dir:
		Direction.DIR_DOWN:
			return Vector2.DOWN
		Direction.DIR_UP:
			return Vector2.UP
		Direction.DIR_LEFT:
			return Vector2.LEFT
		Direction.DIR_RIGHT:
			return Vector2.RIGHT
	return Vector2.DOWN

var _walking: bool = false

signal attack_finished

func start_walking():
	_walking = true
	
func stop_walking():
	_walking = false
	
func attack() -> void:
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _end_attack() -> void:
	attack_finished.emit()

func set_direction(dir: int) -> void:
	var vector = _get_direction_vector(dir)
	if _direction == vector:
		return
	animation_tree.set("parameters/Attacking/blend_position", vector)
	animation_tree.set("parameters/States/Idle/blend_position", vector)
	animation_tree.set("parameters/States/Walking/blend_position", vector)
	_direction = vector
