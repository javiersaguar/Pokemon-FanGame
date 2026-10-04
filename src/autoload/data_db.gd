extends Node
## STUB PROVISIONAL creado por el Agente 1 para que el proyecto arranque.
## Dueño: Agente 2, que lo sustituye por la versión real (Fase 4.5).
## API mínima prevista (docs/contratos.md, sección DataDB): devuelve null o
## valores neutros y avisa por consola.

var is_loaded := false


func _ready() -> void:
	is_loaded = true


func species(id: StringName) -> Variant:
	return _missing("species", id)


func move(id: StringName) -> Variant:
	return _missing("move", id)


func item(id: StringName) -> Variant:
	return _missing("item", id)


func type_effectiveness(_atk_type: StringName, _def_types: Array[StringName]) -> float:
	return 1.0


func _missing(kind: String, id: StringName) -> Variant:
	push_warning("DataDB (stub): %s('%s') todavía no está implementado." % [kind, id])
	return null
