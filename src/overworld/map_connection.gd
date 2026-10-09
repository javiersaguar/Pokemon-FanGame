class_name MapConnection
extends Resource
## Conexión de bordes. Offset suma a la coordenada paralela en el mapa destino.
@export_enum("north", "south", "west", "east") var edge := "east"
@export var target_map: StringName
@export var offset := 0
## Tramo del borde [desde, hasta) en casillas (la y en los bordes este y oeste, la x en norte y sur),
## para que un mismo borde lleve a mapas distintos. (0, 0) = todo el borde.
@export var span := Vector2i.ZERO
func matches(tile: Vector2i, bounds: Rect2i) -> bool:
	if span != Vector2i.ZERO:
		var along := tile.y if edge in ["east", "west"] else tile.x
		if along < span.x or along >= span.y:
			return false
	match edge:
		"east": return tile.x == bounds.end.x and tile.y >= bounds.position.y and tile.y < bounds.end.y
		"west": return tile.x == bounds.position.x - 1 and tile.y >= bounds.position.y and tile.y < bounds.end.y
		"south": return tile.y == bounds.end.y and tile.x >= bounds.position.x and tile.x < bounds.end.x
		"north": return tile.y == bounds.position.y - 1 and tile.x >= bounds.position.x and tile.x < bounds.end.x
	return false
func arrival(tile: Vector2i, bounds: Rect2i) -> Vector2i:
	match edge:
		"east": return Vector2i(bounds.position.x, tile.y + offset)
		"west": return Vector2i(bounds.end.x - 1, tile.y + offset)
		"south": return Vector2i(tile.x + offset, bounds.position.y)
		"north": return Vector2i(tile.x + offset, bounds.end.y - 1)
	return tile
