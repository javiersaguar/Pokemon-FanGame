extends BattleEffect
## Respiro: recupera la mitad de los PS y pierde el tipo Volador hasta el final del turno.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, move: MoveData) -> int:
	if user.pokemon.current_hp >= user.pokemon.max_hp():
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(user))
		return HANDLED
	engine.heal(user, roundi(user.pokemon.max_hp() * float(move.heal[0]) / move.heal[1]), &"move")
	engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	if user.has_type(&"flying"):
		engine.add_volatile(user, &"roost", user)
	return HANDLED
