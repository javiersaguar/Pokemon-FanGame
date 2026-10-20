extends BattleEffect
## Mil Púas Tóxicas: el doble de potencia contra un objetivo envenenado.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.pokemon.status in [&"psn", &"tox"] else power
