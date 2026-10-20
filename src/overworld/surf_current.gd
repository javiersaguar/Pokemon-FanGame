@tool
class_name SurfCurrent
extends Node2D
## Corriente marina (Ruta marítima 1): mientras se hace Surf dentro de su rectángulo, arrastra al
## jugador una casilla por paso en `direction` hasta salir de ella o chocar. La pone el agente de rutas
## en el mapa (la esquina de arriba a la izquierda es la posición del nodo, en casillas de Grid.TILE).
## Los escollos son rocas con colisión normales: bloquean y no hace falta lógica propia.

@export var direction := Vector2i.DOWN
@export var size_tiles := Vector2i.ONE


func _ready() -> void:
	add_to_group(&"surf_current")


func rect() -> Rect2i:
	return Rect2i(Grid.to_tile(position), size_tiles)


## Dirección de la corriente en `tile` dentro de `root` (el mapa), o Vector2i.ZERO si no hay.
static func direction_at(root: Node, tile: Vector2i) -> Vector2i:
	if root == null:
		return Vector2i.ZERO
	for node: Node in root.find_children("*", "SurfCurrent", true, false):
		var current := node as SurfCurrent
		if current != null and current.rect().has_point(tile):
			return current.direction
	return Vector2i.ZERO
