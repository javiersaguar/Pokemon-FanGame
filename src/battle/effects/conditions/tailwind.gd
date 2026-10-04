extends BattleEffect
## Viento Afín: dobla la Velocidad de su bando durante 4 turnos (contando el actual).


func duration(_engine: BattleEngine) -> int:
	return 4


func residual_order() -> int:
	return 26


func on_start(engine: BattleEngine, holder: Variant, _state: Dictionary, _source: Battler) -> bool:
	engine.message(tr("¡Sopla un viento afín a favor %s!") % engine.team_of_name((holder as BattleSide).index))
	return true


func on_end(engine: BattleEngine, holder: Variant, _state: Dictionary) -> void:
	engine.message(tr("¡Ha amainado el viento afín que soplaba a favor %s!") % engine.team_of_name((holder as BattleSide).index))


func modify_speed(engine: BattleEngine, battler: Battler, speed: int) -> int:
	return speed * 2 if engine.has_side_condition(battler.side, &"tailwind") else speed
