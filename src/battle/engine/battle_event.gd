class_name BattleEvent
extends RefCounted
## Un paso de la presentación del combate. El motor los genera y la BattleScene los reproduce en orden.
## Tipos y campos: docs/contratos.md §8.5. La escena debe ignorar los tipos que no conozca.

const MESSAGE := &"message"
const SWITCH_IN := &"switch_in"
const SWITCH_OUT := &"switch_out"
const MOVE := &"move"
const DAMAGE := &"damage"
const HEAL := &"heal"
const MISS := &"miss"
const FAINT := &"faint"
## Reglas Locke: un Pokémon del jugador ha muerto (va justo después de su `faint`).
const POKEMON_DIED := &"pokemon_died"
const STATUS := &"status"
const CANT_MOVE := &"cant_move"
const VOLATILE := &"volatile"
const BOOST := &"boost"
const EXP := &"exp"
const LEVEL_UP := &"level_up"
const MOVE_LEARNED := &"move_learned"
const CATCH := &"catch"
const ITEM_USED := &"item_used"
const FLEE := &"flee"
const TRAINER_SPEECH := &"trainer_speech"
const MONEY := &"money"
const TURN := &"turn"
const END := &"end"

var type: StringName
## 0 = jugador, 1 = rival, -1 = ninguno.
var side: int = -1
## Posición en el campo (0 en individuales), -1 = ninguna.
var slot: int = -1
var data: Dictionary = {}


static func make(event_type: StringName, event_side: int = -1, event_slot: int = -1, event_data: Dictionary = {}) -> BattleEvent:
	var e := BattleEvent.new()
	e.type = event_type
	e.side = event_side
	e.slot = event_slot
	e.data = event_data
	return e


func value(key: String, default: Variant = null) -> Variant:
	return data.get(key, default)


## Texto de un evento `message` (vacío en los demás).
func text() -> String:
	return str(data.get("text", ""))


func _to_string() -> String:
	return "%s(%d,%d) %s" % [type, side, slot, data]
