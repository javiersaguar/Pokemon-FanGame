extends BattleEffect
## Superdiente: quita la mitad de los PS que le quedan al objetivo (al menos 1).


@warning_ignore("integer_division")
func fixed_damage(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData) -> int:
	return maxi(1, target.pokemon.current_hp / 2)
