extends BattleEffect
## Marcha Espectral: el doble de potencia si el objetivo tiene un problema de estado.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.pokemon.status != &"" else power
