extends BattleEffect
## Recogearena: recupera la mitad de los PS, o 2/3 con tormenta de arena.


func on_hit(engine: BattleEngine, user: Battler, _target: Battler, _move: MoveData) -> int:
	if user.pokemon.current_hp >= user.pokemon.max_hp():
		engine.message(tr("¡Los PS %s están al máximo!") % engine.of_name(user))
		return HANDLED
	var part := 2.0 / 3.0 if engine.weather() == &"sandstorm" else 0.5
	engine.heal(user, roundi(user.pokemon.max_hp() * part))
	engine.message(tr("¡%s ha recuperado PS!") % engine.name_of(user))
	return HANDLED
