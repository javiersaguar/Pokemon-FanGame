extends BattleEffect
## Giro Bola: más fuerte cuanto más lento sea el usuario frente al objetivo (hasta 150).


func base_power(engine: BattleEngine, user: Battler, target: Battler, _move: MoveData, _power: int) -> int:
	var mine := maxi(1, engine.speed_of(user))
	return mini(150, int(25.0 * engine.speed_of(target) / mine) + 1)
