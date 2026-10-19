extends BattleEffect
## Carga Tóxica: el doble de potencia si el objetivo está envenenado.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.pokemon.status in [&"psn", &"tox"] else power
