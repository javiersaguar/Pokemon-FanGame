extends BattleEffect
## Autotomía (Cola Cambio): gasta la mitad de sus PS en un sustituto y se cambia; el que entra se queda
## con el sustituto.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var cost := user.pokemon.max_hp() / 2
	if user.pokemon.current_hp <= cost or engine.side(user.side).first_able_index() < 0 or engine.has_side_condition(user.side, &"shedtail"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.deal_damage(user, cost, &"shedtail")
	engine.add_side_condition(user.side, &"shedtail", user, {"hp": user.pokemon.max_hp() / 4})
	engine.message(tr("¡%s ha dejado su cola como sustituto!") % engine.name_of(user))
	engine.request_switch(user, &"uturn")
	return HANDLED
