extends BattleEffect
## Paga 1/3 de sus PS máximos para subir sus características; falla si no le llegan.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var cost := maxi(1, user.pokemon.max_hp() / 3)
	if user.pokemon.current_hp <= cost:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.deal_damage(user, cost, &"move")
	engine.boost(user, {&"atk": 1, &"def": 1, &"spa": 1, &"spd": 1, &"spe": 1})
	return HANDLED
