extends BattleEffect
## Acróbata: doble de potencia si el usuario no lleva objeto.


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return power * 2 if user.pokemon.held_item == &"" else power
