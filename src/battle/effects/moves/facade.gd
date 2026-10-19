extends BattleEffect
## Imagen: el doble de potencia si el usuario está quemado, envenenado o paralizado. La quemadura no
## le reduce el daño (eso ya lo sabe DamageCalc).


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if user.pokemon.status in [&"brn", &"psn", &"tox", &"par"] else power
