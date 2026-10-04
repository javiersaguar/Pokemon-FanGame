@tool
class_name MapEntity
extends Node2D
## Base de todo lo que hay en el mapa y se puede examinar con `accept` (NPC,
## objeto del suelo, cartel...). Aparece o desaparece según flags.
## Las clases hijas deben ser @tool y llamar a super() en _ready().

## Solo está si esta flag está activa.
@export var visible_if_flag: StringName
## Desaparece si esta flag está activa.
@export var hidden_if_flag: StringName


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	position = Grid.snap(position)
	EventBus.flag_changed.connect(_on_flag_changed)
	_refresh_presence()


func tile_position() -> Vector2i:
	return Grid.to_tile(position)


func is_present() -> bool:
	if visible_if_flag != &"" and not GameState.flag(visible_if_flag):
		return false
	if hidden_if_flag != &"" and GameState.flag(hidden_if_flag):
		return false
	return true


## La llama el jugador al pulsar `accept` delante. Puede ser corrutina: el
## jugador espera a que termine (con el input bloqueado).
func interact(_player: Player) -> void:
	pass


## Mapa al que pertenece (raíz de su escena).
func get_map() -> MapRoot:
	return owner as MapRoot


func _on_flag_changed(key: StringName, _value: bool) -> void:
	if key == visible_if_flag or key == hidden_if_flag:
		_refresh_presence()


func _refresh_presence() -> void:
	var present := is_present()
	visible = present
	process_mode = Node.PROCESS_MODE_INHERIT if present else Node.PROCESS_MODE_DISABLED
	_set_collisions_enabled(present)


func _set_collisions_enabled(enabled: bool) -> void:
	for shape: Node in find_children("*", "CollisionShape2D", true, false):
		(shape as CollisionShape2D).set_deferred(&"disabled", not enabled)
