extends BattleEffect
## Azote: más potencia cuantos menos PS le queden al usuario (de 20 a 200).


@warning_ignore("integer_division")
func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, _power: int) -> int:
	var ratio := 48 * user.pokemon.current_hp / maxi(1, user.pokemon.max_hp())
	if ratio <= 1:
		return 200
	if ratio <= 4:
		return 150
	if ratio <= 9:
		return 100
	if ratio <= 16:
		return 80
	if ratio <= 32:
		return 40
	return 20
