extends BattleEffect
## Arcoíris (Voto Agua + Voto Fuego): 4 turnos con los efectos secundarios del bando al doble (en el motor).


func duration(_engine: BattleEngine) -> int:
	return 4


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Ha aparecido un arcoíris en el cielo del equipo %s!") % engine.team_of_name((holder as BattleSide).index))
	return true
