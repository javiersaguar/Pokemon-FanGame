extends BattleEffect
## Protección (volátil de un turno): bloquea los movimientos que la respetan (bandera "protect").


func duration(_engine: BattleEngine) -> int:
	return 1


func residual_order() -> int:
	return 99


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se está protegiendo!") % engine.name_of(holder))
	return true


func on_try_hit(engine: BattleEngine, target: Battler, _state: Dictionary, _user: Battler, move: MoveData) -> bool:
	if not move.has_flag(&"protect"):
		return true
	engine.message(tr("¡%s se ha protegido!") % engine.name_of(target))
	return false
