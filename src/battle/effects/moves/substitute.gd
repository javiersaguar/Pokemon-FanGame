extends BattleEffect
## Sustituto: gasta 1/4 de sus PS en un muñeco que recibe los golpes y bloquea casi todos los
## movimientos de estado de los rivales.


@warning_ignore("integer_division")
func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	var cost := user.pokemon.max_hp() / 4
	if user.has_volatile(&"substitute"):
		engine.message(tr("¡%s ya tiene un sustituto!") % engine.name_of(user))
		return HANDLED
	if user.pokemon.current_hp <= cost or cost <= 0:
		engine.message(tr("¡No le quedan PS suficientes para crear un sustituto!"))
		return HANDLED
	engine.deal_damage(user, cost, &"substitute")
	engine.add_volatile(user, &"substitute", user, {"hp": cost})
	return HANDLED
