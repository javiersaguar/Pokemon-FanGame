extends BattleEffect
## Paga 1/2 de sus PS máximos para subir sus características; falla si no le llegan.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var cost := maxi(1, user.pokemon.max_hp() / 2)
	if user.pokemon.current_hp <= cost:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.deal_damage(user, cost, &"move")
	engine.boost(user, {&"atk": 2, &"spa": 2, &"spe": 2})
	return HANDLED
