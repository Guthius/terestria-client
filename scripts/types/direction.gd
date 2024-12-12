extends Object

class_name Direction

const DIR_UP: int = 0
const DIR_DOWN: int = 1
const DIR_LEFT: int = 2
const DIR_RIGHT: int = 3

static func get_vector(direction: int) -> Vector2:
	match direction:
		Direction.DIR_UP:
			return Vector2.UP
		Direction.DIR_DOWN:
			return Vector2.DOWN
		Direction.DIR_LEFT:
			return Vector2.LEFT
		Direction.DIR_RIGHT:
			return Vector2.RIGHT
	return Vector2.ZERO
