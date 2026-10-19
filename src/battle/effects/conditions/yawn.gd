extends BattleEffect
## Somnolencia de Bostezo: al acabar el turno siguiente se duerme (si puede).


func duration(_engine: BattleEngine) -> int:
	return 2


func residual_order() -> int:
	return 23


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡%s se está adormilando!") % engine.name_of(holder))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	var b := holder as Battler
	if not b.is_fainted():
		engine.set_status(b, &"slp", null, false)
