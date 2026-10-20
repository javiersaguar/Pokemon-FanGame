extends BattleEffect
## Rayo Voluble: 30 % de probabilidad de doble potencia.


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	if engine.rand_chance(&"ficklebeam", 3, 10):
		engine.message(tr("¡%s lo da todo!") % engine.name_of(user))
		return power * 2
	return power
