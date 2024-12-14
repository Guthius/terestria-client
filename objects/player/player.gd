extends Node2D

class_name Player

@onready var paperdoll: Paperdoll = $Paperdoll
@onready var camera: Camera2D = $Camera
@onready var ray_cast_collision: RayCast2D = $RayCastCollision
@onready var chat: LineEdit = $Hud/ChatMargin/Chat

var _allow_input: bool = true
var _map: Map
var _chat_just_closed: bool

var direction: int = Direction.DIR_DOWN

func _ready() -> void:
	paperdoll.attack_finished.connect(_enable_input)
	paperdoll.set_direction(direction)
	
	if _map != null:
		_apply_map_config()

func _open_chat_line() -> void:
	chat.text = ""
	chat.visible = true
	chat.grab_focus()

func _send_chat() -> void:
	var text = chat.text.strip_edges()
	if len(text) > 0:
		Protocol.send_chat(text)
	chat.visible = false

func _physics_process(_delta: float) -> void:
	if not _allow_input:
		return
	
	if Input.is_action_just_pressed("chat"):
		if chat.visible:
			_send_chat()
		else:
			_open_chat_line()
	
	if chat.visible:
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
		
	_chat_just_closed = false
		
	if _allow_input:
		paperdoll.stop_walking()

func attack() -> void:
	_allow_input = false
	
	Protocol.send_attack(direction)
	
	paperdoll.set_direction(direction)
	paperdoll.attack()

func _within_map_bounds(pos: Vector2) -> bool:
	if _map == null:
		return false
	
	var left = pos.x
	var top = pos.y
	var right = pos.x + Constants.TILE_SIZE
	var bottom = pos.y + Constants.TILE_SIZE
		
	if left < _map.map_left or top < _map.map_top:
		return false
	
	if right > _map.map_right or bottom > _map.map_bottom:
		return false
	
	return true

func _can_move(direction: Vector2, pos: Vector2) -> bool:
	if not _within_map_bounds(pos):
		return false
	ray_cast_collision.rotation = direction.angle() - PI / 2
	ray_cast_collision.force_raycast_update()
	return !ray_cast_collision.is_colliding()

func move(dir: int) -> void:
	if not _allow_input:
		return
	
	var prev_dir = direction
	direction = dir
	
	var target = Direction.get_vector(direction)
	if target == Vector2.ZERO:
		return
	
	var target_position = position + target * Constants.TILE_SIZE
	if not _can_move(target, target_position):
		if prev_dir != dir:
			paperdoll.set_direction(direction)
			Protocol.send_set_direction(direction)
		return
	
	_allow_input = false
	
	paperdoll.set_direction(direction)
	paperdoll.start_walking()
	
	Protocol.send_move_player(int(direction))
	
	var tween = create_tween()
	
	tween.tween_property(self, "position", target_position, .15)
	tween.tween_callback(_enable_input)

func _enable_input() -> void:
	_allow_input = true

func _apply_map_config() -> void:
	if _map.constrain_camera:
		camera.limit_left = _map.map_left
		camera.limit_top = _map.map_top
		camera.limit_right = _map.map_right
		camera.limit_bottom = _map.map_bottom
	else:
		camera.limit_left = -10000000
		camera.limit_top = -10000000
		camera.limit_right = -10000000
		camera.limit_bottom = -10000000

func set_map(map: Map) -> void:
	_map = map
	if camera == null:
		return
	_apply_map_config()


func _on_chat_focus_exited() -> void:
	chat.visible = false
