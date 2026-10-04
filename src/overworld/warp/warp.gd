@tool
class_name Warp
extends Node2D
## Zona que lleva a otro mapa al pisarla (puertas, felpudos, bordes de ruta).
## Va dentro del nodo Warps del mapa. Ocupa `size` casillas desde la suya
## (hacia la derecha y hacia abajo).

enum Facing { KEEP, DOWN, LEFT, RIGHT, UP }

const FACING_VECTORS: Array[Vector2i] = [
	Vector2i.ZERO, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP,
]

@export var target_map: StringName
@export var target_spawn: StringName = &"default"
@export var arrival_facing: Facing = Facing.KEEP
@export var size := Vector2i.ONE:
	set(value):
		size = value.max(Vector2i.ONE)
		queue_redraw()
## Efecto de sonido al usarlo (id de AudioManager). Vacío = ninguno.
@export var sound: StringName = &"door"


func _ready() -> void:
	if not Engine.is_editor_hint():
		position = Grid.snap(position)


func contains_tile(tile: Vector2i) -> bool:
	return Rect2i(Grid.to_tile(position), size).has_point(tile)


func get_arrival_facing() -> Vector2i:
	return FACING_VECTORS[arrival_facing]


## Lo usa el jugador. La corrutina vive en el jugador (no en el Warp) porque el
## Warp se libera junto con su mapa al cambiar de mapa.
func is_valid() -> bool:
	if target_map == &"":
		push_error("Warp %s: no tiene target_map." % get_path())
		return false
	return true


func _draw() -> void:
	if Engine.is_editor_hint():
		var rect := Rect2(-Grid.HALF, Vector2(size * Grid.TILE))
		draw_rect(rect, Color(0.2, 0.6, 1.0, 0.35))
		draw_rect(rect, Color(0.2, 0.6, 1.0, 0.9), false)
