extends Node2D

class_name Map

@export var constrain_camera: bool = false

var map_left: int
var map_top: int
var map_right: int
var map_bottom: int

func _update_bounds(layer: TileMapLayer) -> void:
	if layer.name == "Metadata":
		layer.visible = false
	
	var rect = layer.get_used_rect()
	print(rect)
	
	var pos = rect.position
	var size = rect.size
	
	if pos.x < map_left:
		map_left = pos.x
		
	if pos.y < map_top:
		map_top = pos.y
		
	var right = pos.x + size.x
	if right > map_right:
		map_right = right
	
	var bottom = pos.y + size.y
	if bottom > map_bottom:
		map_bottom = bottom

func _compute_bounds_and_hide_meta_layer(children: Array[Node]) -> void:
	for C in children:
		if C is TileMapLayer:
			_update_bounds(C)
		if C.get_child_count() > 0:
			_compute_bounds_and_hide_meta_layer(C.get_children())

func _ready():
	_compute_bounds_and_hide_meta_layer(get_children())
	print("%d,%d,%d,%d" % [map_left, map_top, map_right, map_bottom])
	map_right = map_right * Constants.TILE_SIZE
	map_bottom = map_bottom * Constants.TILE_SIZE
