extends BattleEffect
## Poder Reserva: 20 de potencia más 20 por cada nivel que tiene subido en sus características.


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	var raised := 0
	for stat: StringName in user.boosts:
		raised += maxi(0, user.boosts[stat])
	return power + 20 * raised
