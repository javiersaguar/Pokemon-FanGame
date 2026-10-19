extends BattleEffect
## Puño Furia: 50 de potencia más 50 por cada golpe que ha recibido en el combate (hasta 350).


func base_power(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return mini(350, power + 50 * int(engine.times_hit.get(user.pokemon.uid, 0)))
