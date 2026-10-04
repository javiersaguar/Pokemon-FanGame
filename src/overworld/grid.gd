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
