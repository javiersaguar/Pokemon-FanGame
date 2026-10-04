class_name PartialTrapMoveEffect
extends BattleEffect
## Movimientos que atrapan y dañan 4-5 turnos (Giro Fuego, Torbellino, Acoso, Atadura...).

## Mensaje al atrapar ("¡%s ha quedado atrapado en un torbellino de fuego!").
var trap_text: String = ""


func on_after_hit(engine: BattleEngine, user: Battler, target: Battler, move: MoveData, _damage: int) -> void:
	if target.is_fainted() or target.has_volatile(&"partiallytrapped"):
		return
	var data := {
		"move": String(move.id), "move_name": move.name, "source_side": user.side,
		"source_party": user.party_index, "text": trap_text,
	}
	if engine.add_volatile(target, &"partiallytrapped", user, data):
		engine.message(tr(trap_text) % engine.name_of(target))
