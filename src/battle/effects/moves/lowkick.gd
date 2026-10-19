extends BattleEffect
## Patada Baja: más fuerte cuanto más pesa el objetivo (de 20 a 120).


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _power: int) -> int:
	var kg := target.weight()
	if kg >= 200.0:
		return 120
	if kg >= 100.0:
		return 100
	if kg >= 50.0:
		return 80
	if kg >= 25.0:
		return 60
	if kg >= 10.0:
		return 40
	return 20
