extends BattleEffect
## Levitón (5 turnos): no toca el suelo, así que lo de tipo Tierra no le afecta.


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 18


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s levita gracias al electromagnetismo!") % engine.name_of(holder))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	if not (holder as Battler).is_fainted():
		engine.message(tr("¡El electromagnetismo de %s se ha disipado!") % engine.inner_name_of(holder))


func grounding(_state: Dictionary) -> int:
	return -1


func immune_to(engine: BattleEngine, target: Battler, _state: Dictionary, move: MoveData) -> bool:
	return move.type == &"ground" and not move.is_status() and move.id != &"thousandarrows" and not engine.is_grounded(target)
