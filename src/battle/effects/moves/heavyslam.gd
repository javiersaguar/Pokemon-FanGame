extends BattleEffect
## Cuerpo Pesado: más fuerte cuanto más pese el usuario frente al objetivo (de 40 a 120).


func base_power(_engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _power: int) -> int:
	var ratio := user.weight() / target.weight()
	if ratio >= 5.0:
		return 120
	if ratio >= 4.0:
		return 100
	if ratio >= 3.0:
		return 80
	if ratio >= 2.0:
		return 60
	return 40
