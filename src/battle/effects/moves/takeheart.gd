extends BattleEffect
## Bravura: sube el Ataque Especial y la Defensa Especial y cura su problema de estado.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.pokemon.status != &"":
		engine.cure_status(user)
	engine.boost(user, {&"spa": 1, &"spd": 1})
	return HANDLED
