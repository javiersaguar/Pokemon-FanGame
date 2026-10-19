extends BattleEffect
## Bastión Final: no puede cambiarse ni huir.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s ya no puede huir!") % engine.name_of(holder))
	return true


func traps(_engine: BattleEngine, _battler: Battler, _state: Dictionary) -> bool:
	return true
