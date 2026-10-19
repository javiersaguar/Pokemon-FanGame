extends BattleEffect
## Neblina (5 turnos): impide que los rivales bajen las características de los de su bando.


func duration(_engine: BattleEngine) -> int:
	return 5


func residual_order() -> int:
	return 26


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡La neblina cubre %s!") % engine.team_to_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("La neblina %s se ha disipado.") % engine.team_of_name((holder as BattleSide).index))


func prevents_boost_drop(_engine: BattleEngine, _target: Battler, _state: Dictionary, _source: Battler) -> bool:
	return true
