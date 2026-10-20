extends BattleEffect
## Prensa Rodante: hasta 100 de potencia según los PS que le queden al objetivo.


func base_power(_engine: BattleEngine, _user: Battler, target: Battler, _move: MoveData, _power: int) -> int:
	return maxi(1, 100 * target.pokemon.current_hp / target.pokemon.max_hp())
