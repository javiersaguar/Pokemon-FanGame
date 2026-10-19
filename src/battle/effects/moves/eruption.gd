extends BattleEffect
## Erupción: 150 de potencia con los PS al máximo, menos cuantos menos PS le quedan.


func base_power(_engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData, power: int) -> int:
	return maxi(1, int(power * user.pokemon.current_hp / float(user.pokemon.max_hp())))
