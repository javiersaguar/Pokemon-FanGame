extends BattleEffect
## Pantano (Voto Planta + Voto Agua): 4 turnos con la Velocidad del bando a la cuarta parte.


func duration(_engine: BattleEngine) -> int:
	return 4


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Un pantano rodea al equipo %s!") % engine.team_of_name((holder as BattleSide).index))
	return true


func modify_speed(_engine: BattleEngine, _battler: Battler, speed: int) -> int:
	return maxi(1, speed / 4)
