extends BattleEffect
## Deseo Cura: el usuario se debilita y el siguiente que sale de su equipo se cura del todo.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if engine.side(user.side).first_able_index() < 0 or engine.has_side_condition(user.side, &"healingwish"):
		engine.message(tr("¡Pero falló!"))
		return HANDLED
	engine.add_side_condition(user.side, &"healingwish", user)
	engine.deal_damage(user, user.pokemon.current_hp, &"healingwish")
	return HANDLED
