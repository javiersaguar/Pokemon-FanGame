@tool
class_name Trigger
extends Node2D
## Disparador de eventos (Fase 13.1). Va dentro del nodo Triggers del mapa.
## STEP: al pisar una de sus casillas. ON_ENTER: al terminar de entrar en el mapa.
## El evento es un script que hereda de StoryEvent; recibe `event_params`.

enum Mode { STEP, ON_ENTER }

@export var event: GDScript
@export var event_params: Dictionary = {}
@export var mode: Mode = Mode.STEP
## Casillas que ocupa desde la suya (hacia la derecha y abajo). Solo en STEP.
@export var size := Vector2i.ONE:
	set(value):
		size = value.max(Vector2i.ONE)
		queue_redraw()
## Solo se dispara si esta flag está activa.
@export var required_flag: StringName
## No se dispara si esta flag está activa.
@export var blocked_by_flag: StringName
## Flag que se activa al terminar el evento: así no se repite. Vacío = se repite.
@export var once_flag: StringName


func _ready() -> void:
	if not Engine.is_editor_hint():
		position = Grid.snap(position)


func contains_tile(tile: Vector2i) -> bool:
	return Rect2i(Grid.to_tile(position), size).has_point(tile)


func can_fire() -> bool:
	if event == null:
		return false
	if required_flag != &"" and not GameState.flag(required_flag):
		return false
	if blocked_by_flag != &"" and GameState.flag(blocked_by_flag):
		return false
	return once_flag == &"" or not GameState.flag(once_flag)


## Ejecuta el evento. Quien espere debe esperar a esta llamada de Cutscene (no
## a una corrutina del Trigger), porque el Trigger muere si el evento cambia de mapa.
func fire() -> void:
	await Cutscene.play(event, self, event_params, once_flag)


func _draw() -> void:
	if Engine.is_editor_hint():
		var rect := Rect2(-Grid.HALF, Vector2(size * Grid.TILE))
		draw_rect(rect, Color(1.0, 0.6, 0.1, 0.3))
		draw_rect(rect, Color(1.0, 0.6, 0.1, 0.9), false)
