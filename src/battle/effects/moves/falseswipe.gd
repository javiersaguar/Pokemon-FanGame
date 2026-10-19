extends BattleEffect
## Falso Tortazo: deja al objetivo con 1 PS como mínimo.


func modify_damage(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, amount: int) -> int:
	return mini(amount, target.pokemon.current_hp - 1)
