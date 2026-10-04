class_name BattleRequest
extends RefCounted
## Lo que el motor necesita que decida el jugador (engine.request). Contrato: docs/contratos.md §8.5.

enum Kind { ACTION, SWITCH, LEARN_MOVE }

var kind: Kind = Kind.ACTION
var side: int = 0
var slot: int = 0
## ACTION y SWITCH: Pokémon del equipo que está (o estaba) en el campo. LEARN_MOVE: el que aprende.
var party_index: int = -1
## LEARN_MOVE: movimiento que quiere aprender.
var move_id: StringName = &""
var can_run: bool = false
var can_switch: bool = true
var can_use_items: bool = true
## ACTION: movimientos que se pueden elegir (con PP). Vacío = solo puede usar Forcejeo.
var usable_moves: Array[int] = []
## SWITCH: por qué hay que cambiar. Vacío = se ha debilitado; &"uturn" (Ida y Vuelta, Voltiocambio)
## o &"batonpass" (Relevo) = cambio a mitad de turno que no se puede cancelar.
var reason: StringName = &""


func _to_string() -> String:
	return "BattleRequest(%s, party=%d, move=%s)" % [Kind.keys()[kind], party_index, move_id]
