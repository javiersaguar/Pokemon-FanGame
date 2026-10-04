class_name BattleAction
extends RefCounted
## Decisión de un bando para el turno (o respuesta a una BattleRequest). Contrato: docs/contratos.md §8.5.

enum Kind { FIGHT, SWITCH, ITEM, RUN, LEARN_MOVE }

## Orden de resolución dentro del turno: huir, cambiar, objetos y, al final, movimientos.
const ORDER: Dictionary[int, int] = {
	Kind.RUN: 0, Kind.SWITCH: 1, Kind.ITEM: 2, Kind.FIGHT: 3, Kind.LEARN_MOVE: 4,
}

var kind: Kind = Kind.FIGHT
## FIGHT: posición del movimiento (0-3); -1 = Forcejeo. ITEM (Éter...): movimiento al que se aplica.
var move_index: int = -1
## FIGHT: posición del objetivo en el bando rival (0 en individuales).
var target_slot: int = 0
## SWITCH: Pokémon del equipo que entra. ITEM: Pokémon sobre el que se usa (-1 = sin objetivo).
var party_index: int = -1
var item_id: StringName = &""
## LEARN_MOVE: movimiento que se olvida (0-3); -1 = no aprender el nuevo.
var forget_index: int = -1
## Acción obligada por el motor (movimiento bloqueado, de dos turnos o recarga): no gasta PP
## y no se comprueba. No la crea la interfaz.
var forced: bool = false


static func fight(index: int, target: int = 0) -> BattleAction:
	var a := BattleAction.new()
	a.kind = Kind.FIGHT
	a.move_index = index
	a.target_slot = target
	return a


static func switch_to(index: int) -> BattleAction:
	var a := BattleAction.new()
	a.kind = Kind.SWITCH
	a.party_index = index
	return a


static func use_item(item: StringName, on_party_index: int = -1, on_move_index: int = -1) -> BattleAction:
	var a := BattleAction.new()
	a.kind = Kind.ITEM
	a.item_id = item
	a.party_index = on_party_index
	a.move_index = on_move_index
	return a


static func run() -> BattleAction:
	var a := BattleAction.new()
	a.kind = Kind.RUN
	return a


static func learn_move(index_to_forget: int) -> BattleAction:
	var a := BattleAction.new()
	a.kind = Kind.LEARN_MOVE
	a.forget_index = index_to_forget
	return a


func _to_string() -> String:
	return "BattleAction(%s, move=%d, party=%d, item=%s, forget=%d)" % [
		Kind.keys()[kind], move_index, party_index, item_id, forget_index]
