extends BattleEffect
## Salmuera: doble de potencia si el objetivo tiene la mitad de sus PS o menos.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if target.pokemon.current_hp * 2 <= target.pokemon.max_hp() else power
