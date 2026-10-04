extends BattleEffect
## Red Viscosa (trampa): baja un nivel la Velocidad de cada Pokémon de ese bando que entre tocando el suelo.


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Una red viscosa se extiende a los pies %s!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡La red viscosa a los pies %s ha desaparecido!") % engine.team_of_name((holder as BattleSide).index))


func on_switch_in(engine: BattleEngine, battler: Battler, _state: Dictionary) -> void:
	if not engine.is_grounded(battler):
		return
	engine.message(tr("¡%s ha caído en una red viscosa!") % engine.name_of(battler))
	engine.boost(battler, {&"spe": -1}, true)
