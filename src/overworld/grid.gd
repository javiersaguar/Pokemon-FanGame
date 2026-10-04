class_name Grid
extends RefCounted
## Conversión entre casillas y píxeles. Una casilla mide TILE × TILE píxeles y
## las entidades se colocan en el CENTRO de su casilla.

const TILE := 16
const HALF := Vector2(TILE / 2.0, TILE / 2.0)


static func to_world(tile: Vector2i) -> Vector2:
	return Vector2(tile * TILE) + HALF


static func to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i((world_pos / TILE).floor())


## Coloca una posición cualquiera en el centro de su casilla.
static func snap(world_pos: Vector2) -> Vector2:
	return to_world(to_tile(world_pos))


## "up", "down", "left" o "right" (así van las direcciones en JSON y en el guardado).
static func dir_name(dir: Vector2i) -> String:
	match dir:
		Vector2i.UP:
			return "up"
		Vector2i.LEFT:
			return "left"
		Vector2i.RIGHT:
			return "right"
		_:
			return "down"


static func dir_from_name(dir_text: String) -> Vector2i:
	match dir_text:
		"up":
			return Vector2i.UP
		"left":
			return Vector2i.LEFT
		"right":
			return Vector2i.RIGHT
		_:
			return Vector2i.DOWN


## Direcciones para ir de `from` a `to`: primero en horizontal y luego en vertical.
static func path_between(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var delta := to - from
	for i: int in absi(delta.x):
		path.append(Vector2i(signi(delta.x), 0))
	for i: int in absi(delta.y):
		path.append(Vector2i(0, signi(delta.y)))
	return path
