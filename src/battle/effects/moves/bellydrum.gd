extends BattleEffect
## Tambor: gasta la mitad de sus PS máximos y sube el Ataque al máximo. Falla con la mitad o menos.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var cost := user.pokemon.max_hp() / 2
	if user.pokemon.current_hp <= cost or user.boosts[&"atk"] >= 6:
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.deal_damage(user, cost, &"bellydrum")
	engine.boost(user, {&"atk": 12}, true)
	engine.message(tr("¡%s ha usado la mitad de sus PS y ha subido su Ataque al máximo!") % engine.name_of(user))
	return HANDLED
