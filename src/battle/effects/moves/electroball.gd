extends BattleEffect
## Bola Voltio: más fuerte cuanto más rápido sea el usuario frente al objetivo (de 40 a 150).


func base_power(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _power: int) -> int:
	var ratio := float(engine.speed_of(user)) / maxi(1, engine.speed_of(target))
	if ratio >= 4.0:
		return 150
	if ratio >= 3.0:
		return 120
	if ratio >= 2.0:
		return 80
	if ratio >= 1.0:
		return 60
	return 40
