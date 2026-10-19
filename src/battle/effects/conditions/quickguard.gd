extends BattleEffect
## Anticipo (un turno): bloquea los movimientos con prioridad de los rivales.


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Anticipo protege %s!") % engine.team_to_name((holder as BattleSide).index))
	return true


func _blocks(move: MoveData) -> bool:
	return move.priority > 0


func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, user: Battler, move: MoveData) -> bool:
	if user.side == target.side or not _blocks(move) or move.target in MoveData.FIELD_TARGETS:
		return true
	engine.message(tr("¡%s se ha protegido!") % engine.name_of(target))
	return false
